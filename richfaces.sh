#!/bin/bash

source ../color.sh

if [ ! -d "$1" ] || [ ! -f "$2" ]
then
	echo "Usage: $0 <folder_to_check> <jslist.txt>"
fi
cd "$1"
IFS='
'
verbose=false
if [ "$3" == "verbose" ]
then
	verbose=true
fi
jslist=($(cat "$2"))
#printgn "1" test
#printcn "2"
#printbn "3"
#printon "4"
#printmn "5"
#printrn "6"
function print_percentage(){
	ten_percent=$(($2 / 10))
	twenty_percent=$(($ten_percent * 2))
	thirty_percent=$(($ten_percent * 3))
	fourty_percent=$(($ten_percent * 4))
	fifty_percent=$(($ten_percent * 5))
	sixty_percent=$(($ten_percent * 6))
	if [ $1 -gt $sixty_percent ]
	then
		tprintg "$1/$2"
	elif [ $1 -gt $fifty_percent ]
	then
		tprintc "$1/$2"
	elif [ $1 -gt $fourty_percent ]
	then
		tprintb "$1/$2"
	elif [ $1 -gt $thirty_percent ]
	then
		tprinto "$1/$2"
	elif [ $1 -gt $twenty_percent ]
	then
		tprintm "$1/$2"
	else
		tprintr "$1/$2"
	fi
}


echo -e "\nRichFaces version finder\n"
if [ "$3" == "diff" ]
then
	for jsfile in ${jslist[@]}
	do
		printg "$jsfile:"
		file_path_to_test=$(find ./ | grep "/$jsfile\$")
		diff "$file_path_to_test" "../org/org.richfaces/$jsfile"
		echo ""
	done
	exit 0
fi

#sed -n 2p | grep '.'; echo $?
#test_cases=($(cat "$2" | cut -d '(' -f 2 | tr -d ')'))
#echo "Found test cases:"
#echo "$test_cases"
git_commits=()
echo -e "Gathering js file commits...\n"
printf "%-40sCHECK:\tFILE COMMITS:\tTOTAL COMMITS:\n\n" "Filename:"
for jsfile in ${jslist[@]}
do
	file_path_to_test=$(find ./ | grep "/$jsfile\$")
	printf "%-40s" "$jsfile"
	if [ -n "$file_path_to_test" ]
	then
		printg "OK"
		file_git_commits=($(git log --follow -p -- "$file_path_to_test" | grep "commit " | cut -d ' ' -f 2))
		git_commits=($(echo "${git_commits[@]}" "${file_git_commits[@]}" | tr ' ' '\n' | sort -u))
		tprintg "\t${#file_git_commits[@]}"
		tprintg "\t${#git_commits[@]}"
	else
		printr "NO"
	fi
	echo ""
done
echo ""
commit_number=0
for git_commit in ${git_commits[@]}
do
	commit_number=$(($commit_number + 1))
	git checkout "$git_commit" -f &> /dev/null
	commit_date=$(git log | grep Date | head -n 1)
	if $verbose
	then
		echo "$commit_date"
		echo "COMMIT($commit_number/${#git_commits[@]}) $git_commit:"
	else
		echo -e -n "$commit_date\t\tCOMMIT($commit_number/${#git_commits[@]})\t\t$git_commit:\t"
	fi
	#echo  git --force checkout "$git_commit"
	good_count=0
	for jsfile in ${jslist[@]}
	do
		file_path_to_test=$(find ./ | grep "/$jsfile\$")
		if $verbose
		then
			printf "%-40s" "$jsfile"
		fi
		is_good=true
		if [ -n "$file_path_to_test" ]
		then
			diff "$file_path_to_test" "../org/org.richfaces/$jsfile" &> /dev/null
			if [ $? -eq 0 ]
			then
				if $verbose
				then
					tprintg "OK"
				fi
			else
				if $verbose
				then
					tprintr "NO"
				fi
				is_good=false
			fi
		else
			if $verbose
			then
				tprintr "NO"
			fi
			is_good=false
		fi
		if $is_good
		then
			good_count=$(($good_count + 1))
		fi
		if $verbose
		then
			echo ""
		fi
	done
	if $verbose
	then
		echo ""
	else
		#tprintg "$good_count/${#jslist[@]}"
		print_percentage "$good_count" "${#jslist[@]}"
		echo ""
	fi
done
