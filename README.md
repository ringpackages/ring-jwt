# Ring JWT

JWT authentication and authorization library for the Ring programming language.

## Features

- **JWT Encoding:** Create JSON Web Tokens with a given payload and secret.
- **JWT Decoding & Verification:** Decode JWTs and verify their signature and expiration.
- **HMAC Support:** Utilizes HMAC-SHA256 for secure token signing.

## Installation

This library can be installed using the Ring Package Manager (RingPM).

```bash
ringpm install ring-jwt from ysdragon
```

## Usage

### Basic JWT Operations

The core functionality is provided by the `JWT` class.

```ring
load "jwt.ring"

oJWT = new JWT
cSecret = "your_super_secret_key_here"

# Example Payload
payload = [
    :sub = "user123",
    :iat = unixtime(),
    :exp = unixtime() + 3600, # Expires in 1 hour
    :role = "member"
]

# Encode the token
cToken = oJWT.Encode(payload, cSecret)
? "Encoded JWT: " + cToken

# Decode and verify the token
try
    aDecodedPayload = oJWT.Decode(cToken, cSecret)
    ? "Decoded Payload: " + list2code(aDecodedPayload)
catch
    ? "Error decoding token: " + cCatchError
done
```

### 2. API Reference

#### `JWT` Class

The `JWT` class provides methods for encoding and decoding JSON Web Tokens.

##### `new JWT()`

Creates a new instance of the `JWT` class.

##### `Encode(payload, secret)`

Encodes a given payload into a JWT string.

- `payload` (List): The data to be encoded into the JWT. This should be a Ring list.
- `secret` (String): The secret key used for signing the JWT.

**Returns:** (String) The encoded JWT string.

##### `Decode(token, secret)`

Decodes a JWT string, verifies its signature, and returns the payload.

- `token` (String): The JWT string to decode.
- `secret` (String): The secret key used for verifying the JWT's signature.

**Returns:** (List) The decoded payload as a Ring list.

**Raises/Throws:**
- `Invalid token format` if the token does not have three parts.
- `Token has expired` if the `exp` claim in the payload indicates the token is expired.
- `Invalid signature` if the token's signature is invalid.


## Examples

You can find various usage examples in the [`examples`](examples).

## Contributing

Contributions are welcome! Please feel free to open issues or submit pull requests.

## License

This project is licensed under the [MIT License](LICENSE).