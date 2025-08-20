load "stdlibcore.ring"
load "hmac.ring"
load "jwt.ring"
load "utils/color.ring"
load "jsonlib.ring"

func main
	# Create a new instance of our JWT handler
	oJWT = new JWT

	# The secret key should be long, random, and kept private
	cSecret = "a-very-secure-and-secret-key-that-is-long"

	# Create the payload as a Ring list.
	# 'exp' (expiration time) is a standard claim.
	# It's good practice to set an expiration for all tokens.
	payload = [
		:user_id = 101,
		:username = "Dummy",
		:roles = ["admin", "editor"],
		:iat = unixtime(),  # Issued At
		:exp = unixtime() + 3600 # Expires in 1 hour (3600 seconds)
	]

	? colorText([:text = "--- JWT Encoding Test ---", :color = :BRIGHT_YELLOW, :style = :BOLD])
	? colorText([:text = "Payload to encode:", :color = :CYAN]) + " " + list2json(payload)
	? colorText([:text = copy("-", 50), :color = :BRIGHT_BLACK])

	# Generate the token
	token = oJWT.Encode(payload, cSecret)
	? colorText([:text = "Generated JWT: ", :color = :GREEN]) + token
	? colorText([:text = copy("*", 70), :color = :BRIGHT_BLACK])

	? colorText([:text = "--- JWT Decoding Test (Valid Token) ---", :color = :BRIGHT_YELLOW, :style = :BOLD])
	try
		decoded_payload = oJWT.Decode(token, cSecret)
		? colorText([:text = "Token successfully verified!", :color = :BRIGHT_GREEN])
		? colorText([:text = "Decoded Payload:", :color = :CYAN]) + " " + list2json(decoded_payload)
		? colorText([:text = "Username from payload: ", :color = :MAGENTA]) + decoded_payload[:username]
	catch
		? colorText([:text = "Error during decoding: ", :color = :BRIGHT_RED]) + cCatchError
	done
	? colorText([:text = copy("*", 70), :color = :BRIGHT_BLACK])


	# Invalid Signature Test
	? colorText([:text = "--- JWT Decoding Test (Invalid Signature) ---", :color = :BRIGHT_YELLOW, :style = :BOLD])
	# Tamper with the token by adding extra characters
	invalid_token = token + "tampered"
	? colorText([:text = "Attempting to decode a tampered token...", :color = :YELLOW])
	try
		oJWT.Decode(invalid_token, cSecret)
	catch
		? colorText([:text = "Successfully caught expected error: ", :color = :BRIGHT_GREEN]) + cCatchError
	done
	? colorText([:text = copy("*", 70), :color = :BRIGHT_BLACK])


	# Expired Token Test
	? colorText([:text = "--- JWT Decoding Test (Expired Token) ---", :color = :BRIGHT_YELLOW, :style = :BOLD])
	? colorText([:text = "Creating an already-expired token...", :color = :YELLOW])
	expired_payload = [
		:user_id = 202,
		:exp = unixtime() - 60 # Expired 60 seconds ago
	]
	expired_token = oJWT.Encode(expired_payload, cSecret)
	? colorText([:text = "Attempting to decode expired token...", :color = :YELLOW])
	try
		oJWT.Decode(expired_token, cSecret)
	catch
		? colorText([:text = "Successfully caught expected error: ", :color = :BRIGHT_GREEN]) + cCatchError
	done
	? colorText([:text = copy("*", 70), :color = :BRIGHT_BLACK])