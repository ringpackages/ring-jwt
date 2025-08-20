load "httplib.ring"
load "jwt.ring"

# Define a secret key for JWT signing
cJWTSecret = "your_super_secret_key_here"

oServer = new Server {

    # Login route to issue a JWT
    route(:Post, "/login", :login)

    # Protected route that requires a valid JWT
    route(:Get, "/protected", :protectedRoute)

    ? "To get the JWT key: "
    ? `Try with: curl -X POST -H "Content-Type: application/json" -d '{"username": "user", "password": "password"}' http://localhost:8080/login`
    listen("0.0.0.0", 8080)
}

func login
    # Get the request body
    cRequest = oServer.request()
    cBody = cRequest.body()
    
    # Parse the request body as JSON (expecting username and password)
    aCredentials = json2list(cBody)
    cUsername = aCredentials[:username]
    cPassword = aCredentials[:password]

    # In a real application, you would verify these credentials against a database
    if cUsername = "user" and cPassword = "password"
        # Create a payload for the JWT
        # Include 'exp' (expiration time) for token validity
        # Set expiration to 1 hour from now (unixtime() + 3600)
        nExp = unixtime() + 3600 # Token expires in 1 hour
        
        payload = [
            :sub = cUsername, # Subject
            :iat = unixtime(), # Issued At
            :exp = nExp, # Expiration Time
            :role = "admin" # Example custom claim
        ]

        # Create a new JWT instance and encode the token
        oJWT = new JWT
        cToken = oJWT.Encode(payload, cJWTSecret)

        oServer.setContent(list2json([:token = cToken]), "application/json")
        ? "Now try with: "
        ? `curl -H 'Authorization: Bearer `+cToken+`' http://localhost:8080/protected`
    else
        oServer.setContent(list2json([:message = "Invalid credentials"]), "application/json")
        oServer.setStatus(401) # Unauthorized
		? oServer.getStatus()
    ok

func protectedRoute
    oRequest = oServer.request()
    if oRequest.has_header("Authorization")
        # Get the Authorization header
        cAuthHeader = oRequest.get_header_value("Authorization")
    ok

    # Extract token from 'Bearer <token>' format
    cToken = substr(cAuthHeader, "Bearer ", "")

    if isstring(cToken) and len(cToken) > 0
        try
            oJWT = new JWT
            aPayload = oJWT.Decode(cToken, cJWTSecret)
            
            oServer.setContent(list2json([:message = "Welcome to the protected route!", :user = aPayload[:sub], :role = aPayload[:role]]), "application/json")
        catch
            oServer.setContent(list2json([:message = "Invalid or expired token", :error = ccatcherror]), "application/json")
            oServer.setStatus(401) # Unauthorized
        done
    else
        oServer.setContent(list2json([:message = "Authorization token not provided"]), "application/json")
        oServer.setStatus(401)
    ok