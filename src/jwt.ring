# JWT Library for the Ring Programming Language
# Author: Youssef Saeed (ysdragon) <youssefelkholey@gmail.com>

load "utils/helpers.ring"

Class JWT
	# Default algorithm
	algorithm = "HS256"
	tokenType = "JWT"

	# Encodes a payload (as a Ring list) into a JWT string
	func Encode(payload, secret)
		# Create the header as a Ring list
		header = [
			:alg = self.algorithm,
			:typ = self.tokenType
		]

		# Encode Header and Payload
		base64UrlHeader = self.Base64UrlEncode(list2json(header))
		base64UrlPayload = self.Base64UrlEncode(list2json(payload))

		# Create the signature
		signingInput = base64UrlHeader + "." + base64UrlPayload
		signature = self.Sign(signingInput, secret)
		base64UrlSignature = self.Base64UrlEncode(signature)

		# Assemble the token
		return base64UrlHeader + "." + base64UrlPayload + "." + base64UrlSignature

	# Decodes a JWT string, verifies it, and returns the payload as a Ring list
	func Decode(token, secret)
		# Split the token into its three parts
		aTokenParts = split(token, ".")
		if len(aTokenParts) != 3
			raise("Invalid token format")
		ok
		encodedHeader  = aTokenParts[1]
		encodedPayload = aTokenParts[2]
		encodedSignature = aTokenParts[3]

		# Decode payload to check for expiration before verifying signature
		payloadString = self.Base64UrlDecode(encodedPayload)
		payload = json2list(payloadString)

		# Check if the 'exp' key exists and if the token is expired
		if self.listKeyExists(payload, "exp")
			if payload[:exp] < unixtime()
				raise("Token has expired")
			ok
		ok

		# Verify the signature
		signingInput = encodedHeader + "." + encodedPayload
		expectedSignature = self.Sign(signingInput, secret)
		providedSignature = self.Base64UrlDecode(encodedSignature)

		if not hmac_compare(expectedSignature, providedSignature)
			raise("Invalid signature")
		ok

		# 4. Return the decoded payload
		return payload

	private

	# Encodes data using Base64Url format
	func Base64UrlEncode(data)
		base64String = StringToBase64(data)
		# Make it URL-safe
		base64UrlString = substr(base64String, "+", "-")
		base64UrlString = substr(base64UrlString, "/", "_")
		# Remove padding
		base64UrlString = substr(base64UrlString, "=", "")
		return base64UrlString

	# Decodes data from Base64Url format
	func Base64UrlDecode(data)
		# Replace URL-safe characters with standard Base64 characters
		base64String = substr(data, "-", "+")
		base64String = substr(base64String, "_", "/")

		# Add padding back if necessary
		switch len(base64String) % 4
			on 2 base64String += "=="
			on 3 base64String += "="
		off

		return Base64ToString(base64String)

	# Creates an HMAC-SHA256 signature
	func Sign(input, secret)
		if self.algorithm = "HS256"
			return hmac(secret, input, "sha256", true)
		else
			raise("Unsupported algorithm: " + self.algorithm)
		ok
		return ""

	# Helper function to check for a key in a Ring list
	func listKeyExists(list, key)
		for item in list
			if islist(item) and len(item) = 2 and item[1] = key
				return true
			ok
		next
		return false