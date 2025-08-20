load "hmac.ring"
load "utils/color.ring"

func main
	? colorText([:text = "--- Testing HMAC ---", :color = :BRIGHT_YELLOW, :style = :BOLD])

	# Test Vector 1: HMAC-SHA256
	# From RFC 4231 test case 2
	key1 = "LOL"
	data1 = "what do you want?"
	expected1_hex = "86a74784e9d93e5754f3eecd77f197963e2eb74178bef8aa529fe296963abe59"

	? colorText([:text = "Test Case 1: HMAC-SHA256", :color = :BRIGHT_CYAN])
	? colorText([:text = "Key: ", :color = :MAGENTA]) + "'" + key1 + "'"
	? colorText([:text = "Data: ", :color = :MAGENTA]) + "'" + data1 + "'"

	# Get hex output by passing 'false' for raw_output
	result1_hex = hmac(key1, data1, "sha256", false)
	? colorText([:text = "Computed (hex): ", :color = :GREEN]) + result1_hex
	? colorText([:text = "Expected (hex): ", :color = :GREEN]) + expected1_hex
	if result1_hex = expected1_hex
		? colorText([:text = "Result: OK", :color = :BRIGHT_GREEN])
	else
		? colorText([:text = "Result: FAILED", :color = :BRIGHT_RED])
	ok
	? colorText([:text = copy("-", 50), :color = :BRIGHT_BLACK])

	# Test Vector 2: HMAC-SHA1
	# From RFC 2202 test case 2
	key2 = copy(char(0x0b), 20) # key = 20 bytes of the character 0x0b
	data2 = "Hi There"
	expected2_hex = "b617318655057264e28bc0b6fb378c8ef146be00"

	? colorText([:text = "Test Case 2: HMAC-SHA1", :color = :BRIGHT_CYAN])
	? colorText([:text = "Key: ", :color = :MAGENTA]) + "20 bytes of 0x0b"
	? colorText([:text = "Data: ", :color = :MAGENTA]) + "'" + data2 + "'"

	result2_hex = hmac(key2, data2, "sha1", false)
	? colorText([:text = "Computed (hex): ", :color = :GREEN]) + result2_hex
	? colorText([:text = "Expected (hex): ", :color = :GREEN]) + expected2_hex
	if result2_hex = expected2_hex
		? colorText([:text = "Result: OK", :color = :BRIGHT_GREEN])
	else
		? colorText([:text = "Result: FAILED", :color = :BRIGHT_RED])
	ok
	? colorText([:text = copy("-", 50), :color = :BRIGHT_BLACK])

	# Test Vector 3: HMAC-SHA512 with raw output
	# This test verifies that the raw binary output correctly converts to the hex output
	key3 = "my-long-and-secure-secret-key"
	data3 = "this is a test message for checking the raw output format"

	? colorText([:text = "Test Case 3: HMAC-SHA512 (Raw vs Hex)", :color = :BRIGHT_CYAN])
	result3_hex = hmac(key3, data3, "sha512", false)
	result3_raw = hmac(key3, data3, "sha512", true)

	? colorText([:text = "Computed (hex): ", :color = :GREEN]) + result3_hex
	? colorText([:text = "Computed (raw converted to hex): ", :color = :GREEN]) + str2hex(result3_raw)

	if upper(result3_hex) = upper(str2hex(result3_raw))
		? colorText([:text = "Result: OK", :color = :BRIGHT_GREEN])
	else
		? colorText([:text = "Result: FAILED", :color = :BRIGHT_RED])
	ok
	? colorText([:text = copy("-", 50), :color = :BRIGHT_BLACK])