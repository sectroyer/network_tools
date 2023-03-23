#!/usr/bin/env python3.10

import sys
import base64
from pyasn1.codec.der import decoder as der_decoder

def get_file_content(_file):
	with open(_file, "r") as file:
			return file.read()

def get_r_from_file(signature_file_path):
	signature_b64=get_file_content(signature_file_path).strip()
	signature_der=base64.b64decode(signature_b64)

	decoded_signature, _ =der_decoder.decode(signature_der)
	return hex(decoded_signature[0]) # 0 -> r, s -> 1

print("\nECDSA Nonce Collision Checking Tool by Michał Majchrowicz Afine Team\n")

if len(sys.argv) != 3:
	print(f"Usage: {sys.argv[0]} signature_file1.txt signature_file2.txt")
	sys.exit(1)
else:
	signature_file1 = sys.argv[1]
	signature_file2 = sys.argv[2]
	print(f"signature_file1: {signature_file1}")
	print(f"signature_file2: {signature_file2}")


if get_r_from_file(signature_file1) == get_r_from_file(signature_file2):
	print("\nSignature collision detected :)\n")
else:
	print("\nSignatures differ.\n")
