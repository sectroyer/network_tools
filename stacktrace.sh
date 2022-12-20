#!/bin/bash

source color.sh

if [ ! -d "$1" ] || [ ! -f "$2" ]
then
	echo "Usage: $0 <folder_to_check> <crash_log.txt> <verbose>"
	exit -1
fi
cd "$1"
IFS='
'
verbose=false
if [ "$3" == "verbose" ]
then
	verbose=true
fi
echo -e "\nFaces version finder\n"

git_tags=($(git tag))
#git_tags=($(cat ../faces_ok_tags.txt))
#git_tags=($(cat ../faces_probably.txt))
#echo "Found tags: "
#echo "$git_tags"
#sed -n 2p | grep '.'; echo $?
test_cases=($(cat "$2" | cut -d '(' -f 2 | tr -d ')'))
#echo "Found test cases:"
#echo "$test_cases"

matching_tags=()

for git_tag in ${git_tags[@]}
do
	if $verbose
	then
		echo "TAG: $git_tag"
	else
		printf "%-30s" "TAG: $git_tag"
	fi
	git checkout "$git_tag" -f &> /dev/null
	#echo  git --force checkout "$git_tag"
	is_good=true
	test_function=""
	for test_case in ${test_cases[@]}
	do
		current_function=$(cat "$2" | grep "$test_case" | cut -d '(' -f 1 | grep "[^\.]*$" -o)
		test_file="${test_case%:*}"
		test_line="${test_case##*:}"
		if $verbose
		then
			printf "%-35s" "$test_case"
		fi
		file_path_to_test=$(find ./ | grep "/$test_file")
		if [ -n "$file_path_to_test" ]
		then
			if $verbose
			then
				tprintg "OK"
			fi
			cat "$file_path_to_test" | sed -n "${test_line}p" | grep -q '.'
			if [ $? -eq 0 ]
			then
				if $verbose
				then
					tprintg "OK"
					if [ -n "$test_function" ]
					then
						cat "$file_path_to_test" | sed -n "${test_line}p" | grep "$test_function" -q
						if [ $? -eq 0 ]
						then
							tprintg "OK"
						else
							tprintr "NO"
						fi
					fi
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
		if $verbose
		then
			echo ""
		fi
		#echo "T: $test_file"
		#echo "L: $test_line"
		test_function="$current_function"
	done
	if $verbose
	then
		:
	else
		if $is_good
		then
			tprintg "OK"
			matching_tags+=("$git_tag")
		else
			tprintr "NO"
		fi
	fi
	echo ""
done

echo -e "\nFound following matches:\n"
for git_match in ${matching_tags[@]}
do
    printgn "$git_match"
done
echo ""
