# HMAC Implementation in the Ring Programming Language
# Author: Youssef Saeed (ysdragon) <youssefelkholey@gmail.com>

# Load OpenSSL library
load "openssllib.ring"

/*
	hmac(key, message, algorithm, raw_output)

	Computes an HMAC digest using the specified hash algorithm.

	Parameters:
		key (string): The secret key for the HMAC operation.
		message (string): The message to be authenticated.
		algorithm (string): The hash algorithm to use ("sha256", "sha1", "sha512").
		raw_output (bool): If true, returns raw binary data; if false, returns a lowercase hex string.

	Returns:
		string: The HMAC digest as a string, or raises an error on failure.

	Notes:
		- If the key is longer than the block size, it is hashed.
		- If the key is shorter than the block size, it is padded with null bytes.
		- Pads and XOR operations are performed as per RFC 2104.
*/
func hmac(key, message, algorithm, raw_output)
	# 1. Set algorithm-specific parameters
	block_size = 0
	hash_function_name = ""

	switch lower(algorithm)
		on "sha1"
			block_size = 64
			hash_function_name = "sha1"
		on "sha256"
			block_size = 64
			hash_function_name = "sha256"
		on "sha512"
			block_size = 128
			hash_function_name = "sha512"
		other
			raise("HMAC Error: Unsupported hash algorithm '" + algorithm + "'")
	off

	# Prepare the key as per RFC 2104
	# If key is longer than the block size, it is hashed to fit.
	if len(key) > block_size
		key = hex2str(_hash(key, hash_function_name))
	ok

	# If key is shorter than the block size, it is padded with null bytes.
	if len(key) < block_size
		key = key + copy(char(0), block_size - len(key))
	ok

	# Define inner and outer pads

	# Outer pad consists of repeating 0x5c bytes
	o_pad = copy(char(0x5c), block_size) 
	
	# Inner pad consists of repeating 0x36 bytes
	i_pad = copy(char(0x36), block_size)

	# Perform XOR operations
	o_key_pad = _xor_strings(key, o_pad)
	i_key_pad = _xor_strings(key, i_pad)

	# Calculate the HMAC value
	# Inner hash: H(i_key_pad || message)
	inner_hash_raw = hex2str(_hash(i_key_pad + message, hash_function_name))

	# Outer hash: H(o_key_pad || inner_hash)
	final_hash_hex = _hash(o_key_pad + inner_hash_raw, hash_function_name)

	# Return the result in the desired format
	if raw_output
		return hex2str(final_hash_hex)
	else
		return final_hash_hex
	ok

/*
	hmac_compare(known_string, user_string)

	Performs a constant-time comparison between two strings, typically used for comparing HMAC or hash values.
	This function helps prevent timing attacks by ensuring the comparison time does not depend on the content of the strings.

	Parameters:
		known_string (string): The reference string, usually a securely generated hash or HMAC.
		user_string (string): The string to compare against the reference.

	Returns:
		true  - if both strings are of equal length and all characters match exactly.
		false - if the strings differ in length, type, or any character does not match.

	Notes:
		- Both inputs must be strings; otherwise, the function returns false.
		- The comparison is performed in constant time, regardless of where the first difference occurs.
		- Useful for cryptographic operations where leaking timing information could be a security risk.
*/
func hmac_compare(known_string, user_string)
	# Ensure both inputs are strings to prevent type errors
	if not isstring(known_string) or not isstring(user_string)
		return false
	ok

	len_known = len(known_string)
	len_user = len(user_string)

	# Hashes of different lengths are never equal.
	# The length check itself doesn't need to be constant-time as hash
	# output lengths are fixed and public for a given algorithm.
	if len_known != len_user
		return false
	ok

	# The result variable accumulates all differences.
	# It will be 0 if and only if all characters are the same.
	result = 0

	# Loop through every single character. DO NOT exit this loop early.
	for i = 1 to len_known
		# XOR the ASCII values of the characters.
		# The result of XOR is 0 if the bytes are identical, and non-zero otherwise.
		char_diff = ascii(known_string[i]) ^ ascii(user_string[i])

		# Use the bitwise OR operator '|' to accumulate the differences into the result.
		# If any 'char_diff' is non-zero, 'result' will become and stay non-zero.
		result = result | char_diff
	next

	# Return true only if the accumulated result is exactly 0.
	return (result = 0)

# Functions to call the correct hash function from openssllib.

# Helper function that returns the hash as a lowercase hex string.
func _hash(data, func_name)
	switch func_name
		on "sha1"   return sha1(data)
		on "sha256" return sha256(data)
		on "sha512" return sha512(data)
	off
	raise("HMAC Error: _hash called with invalid function name.")
	return NULL

# Helper function to perform a byte-wise XOR on two strings of equal length.
func _xor_strings(s1, s2)
	result = ""
	for i = 1 to len(s1)
		# XOR the ASCII values of the characters at each position
		result += char( ascii(s1[i]) ^ ascii(s2[i]) )
	next
	return result