load "httplib.ring"
load "jwt.ring"

# Define a secret key for JWT signing
cJWTSecret = "your_super_secret_key_here"

oServer = new Server {

    # Serve the main HTML page
    route(:Get, "/", :serveMainPage)
    
    oServer.shareFolder("static")
    
    # API routes
    route(:Post, "/api/login", :apiLogin)
    route(:Post, "/api/refresh", :apiRefresh)
    route(:Post, "/api/logout", :apiLogout)
    route(:Get, "/api/protected", :apiProtected)
    route(:Get, "/api/profile", :apiProfile)
    route(:Get, "/api/auth", :apiCheckAuth)

    ? "Listening on: 0.0.0.0:8080"
    listen("0.0.0.0", 8080)
}

func serveMainPage
    cHTML = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JWT Authentication Demo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-10">
                <div class="card shadow-sm">
                    <div class="card-header bg-primary text-white">
                        <h1 class="card-title mb-0">JWT Authentication Demo</h1>
                    </div>
                    <div class="card-body">
                        <div id="loginSection" class="section">
                            <h2 class="h4 mb-4">Login</h2>
                            <form id="loginForm">
                                <div class="mb-3">
                                    <label for="username" class="form-label">Username:</label>
                                    <input type="text" class="form-control" id="username" name="username" value="user" required>
                                </div>
                                <div class="mb-3">
                                    <label for="password" class="form-label">Password:</label>
                                    <input type="password" class="form-control" id="password" name="password" value="password" required>
                                </div>
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-box-arrow-in-right"></i> Login
                                </button>
                            </form>
                        </div>
                        
                        <div id="tokenSection" class="section hidden">
                            <h2 class="h4 mb-4">Authentication Status</h2>
                            <div class="card mb-4">
                                <div class="card-body">
                                    <div id="userDataDisplay" class="mb-3">
                                        <p><strong>Username:</strong> <span id="displayUsername"></span></p>
                                        <p><strong>Role:</strong> <span id="displayRole"></span></p>
                                        <p><strong>Expires At:</strong> <span id="displayExpiresAt"></span></p>
                                    </div>
                                    <div class="d-flex flex-wrap gap-2 justify-content-end">
                                        <button class="btn btn-warning btn-sm" id="refreshTokenBtn">
                                            <i class="bi bi-arrow-clockwise"></i> Refresh Session
                                        </button>
                                        <button class="btn btn-danger btn-sm" id="logoutBtn">
                                            <i class="bi bi-box-arrow-right"></i> Logout
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div id="protectedSection" class="section hidden">
                            <h2 class="h4 mb-4">Protected Resources</h2>
                            <div class="d-flex gap-2 mb-4">
                                <button class="btn btn-info" id="getProtectedBtn">
                                    <i class="bi bi-shield-lock"></i> Get Protected Data
                                </button>
                                <button class="btn btn-info" id="getProfileBtn">
                                    <i class="bi bi-person-circle"></i> Get Profile
                                </button>
                            </div>
                            <div class="card">
                                <div class="card-header bg-light">
                                    <h5 class="mb-0">Response</h5>
                                </div>
                                <div class="card-body">
                                    <pre id="responseArea" class="response-area bg-light p-3 rounded"></pre>
                                </div>
                            </div>
                        </div>
                        
                        <div id="statusMessage" class="status-message mt-3"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
    <script src="/static/app.js"></script>

    <div class="toast-container position-fixed bottom-0 end-0 p-3">
        <!-- Toasts will be appended here -->
    </div>
</body>
</html>
    `
    oServer.setContent(cHTML, "text/html")

func apiLogin
    cBody = oServer.request().body()
    aCredentials = json2list(cBody)
    cUsername = aCredentials[:username]
    cPassword = aCredentials[:password]

    if cUsername = "user" and cPassword = "password"
        nExp = unixtime() + 3600
        nRefreshExp = unixtime() + 86400
        
        payload = [
            :sub = cUsername,
            :iat = unixtime(),
            :exp = nExp,
            :role = "admin",
            :type = "access"
        ]
        
        refreshPayload = [
            :sub = cUsername,
            :iat = unixtime(),
            :exp = nRefreshExp,
            :role = "admin",
            :type = "refresh"
        ]

        oJWT = new JWT
        cAccessToken = oJWT.Encode(payload, cJWTSecret)
        cRefreshToken = oJWT.Encode(refreshPayload, cJWTSecret)

        # Set cookies for the tokens
        oServer.setCookie("accesstoken=" + cAccessToken + "; Path=/; HttpOnly; SameSite=Strict; Max-Age=3600")
        oServer.setCookie("refreshtoken=" + cRefreshToken + "; Path=/; HttpOnly; SameSite=Strict; Max-Age=86400")
        
        oServer.setContent(list2json([
            :success = true,
            :message = "Login successful"
        ]), "application/json")
    else
        oServer.setContent(list2json([:message = "Invalid credentials"]), "application/json")
        oServer.setStatus(401)
    ok

func apiRefresh
    cRefreshToken = oServer.Cookies()[:refreshtoken]
    
    if not isNull(cRefreshToken) and isstring(cRefreshToken) and len(cRefreshToken) > 0
        try
            oJWT = new JWT
            aPayload = oJWT.Decode(cRefreshToken, cJWTSecret)
            
            if aPayload[:type] != "refresh"
                throw "Invalid token type"
            end
            
            if aPayload[:exp] < unixtime()
                throw "Refresh token expired"
            end
            
            nExp = unixtime() + 3600
            newPayload = [
                :sub = aPayload[:sub],
                :iat = unixtime(),
                :exp = nExp,
                :role = aPayload[:role],
                :type = "access"
            ]
            
            cNewAccessToken = oJWT.Encode(newPayload, cJWTSecret)
            
            # Set cookie for the new access token
            oServer.setCookie("accesstoken=" + cNewAccessToken + "; Path=/; HttpOnly; SameSite=Strict; Max-Age=3600")
            
            oServer.setContent(list2json([
                :success = true,
                :message = "Token refreshed successfully"
            ]), "application/json")
            
        catch
            oServer.setContent(list2json([:message = "Invalid or expired refresh token", :error = ccatcherror]), "application/json")
            oServer.setStatus(401)
        done
    else
        oServer.setContent(list2json([:message = "Refresh token not provided"]), "application/json")
        oServer.setStatus(400)
    ok

func apiLogout
    cBody = oServer.request().body()
    aRequest = json2list(cBody)
    cRefreshToken = aRequest[:refreshToken]
    
    # Clear the cookies
    oServer.setCookie("accesstoken=; Path=/; HttpOnly; SameSite=Strict; Max-Age=0")
    oServer.setCookie("refreshtoken=; Path=/; HttpOnly; SameSite=Strict; Max-Age=0")
    
    oServer.setContent(list2json([
        :success = true,
        :message = "Successfully logged out"
    ]), "application/json")

func apiProtected
    oRequest = oServer.request()
    cToken = ""
    
    # Get token from cookie
    if !isNull(oServer.Cookies()[:accesstoken])
        cToken = oServer.Cookies()[:accesstoken]
    else
        oServer.setContent(list2json([:message = "Authorization token not provided (cookie)"]), "application/json")
        oServer.setStatus(401)
        return
    ok

    try
        oJWT = new JWT
        aPayload = oJWT.Decode(cToken, cJWTSecret)
        
        oServer.setContent(list2json([
            :message = "Welcome to the protected route!",
            :user = aPayload[:sub],
            :role = aPayload[:role],
            :tokenType = aPayload[:type],
            :expiresAt = aPayload[:exp]
        ]), "application/json")
    catch
        oServer.setContent(list2json([:message = "Invalid or expired token", :error = ccatcherror]), "application/json")
        oServer.setStatus(401)
    done

func apiCheckAuth
    oRequest = oServer.request()
    cToken = ""
    
    # Get token from cookie
    if !isNull(oServer.Cookies()[:accesstoken])
        cToken = oServer.Cookies()[:accesstoken]
    else
        oServer.setContent(list2json([:authenticated = false]), "application/json")
        return
    ok

    try
        oJWT = new JWT
        aPayload = oJWT.Decode(cToken, cJWTSecret)
        
        oServer.setContent(list2json([
            :authenticated = true,
            :user = aPayload[:sub],
            :role = aPayload[:role],
            :expiresAt = aPayload[:exp]
        ]), "application/json")
    catch
        oServer.setContent(list2json([:authenticated = false]), "application/json")
    done

func apiProfile
    oRequest = oServer.request()
    cToken = ""
    
    # Get token from cookie
    if !isNull(oServer.Cookies()[:accesstoken])
        cToken = oServer.Cookies()[:accesstoken]
    else
        oServer.setContent(list2json([:message = "Authorization token not provided (cookie)"]), "application/json")
        oServer.setStatus(401)
        return
    ok

    try
        oJWT = new JWT
        aPayload = oJWT.Decode(cToken, cJWTSecret)
        
        oServer.setContent(list2json([
            :username = aPayload[:sub],
            :role = aPayload[:role],
            :tokenType = aPayload[:type],
            :issuedAt = aPayload[:iat],
            :expiresAt = aPayload[:exp],
            :permissions = ["read", "write", "delete"]
        ]), "application/json")
    catch
        oServer.setContent(list2json([:message = "Invalid or expired token", :error = ccatcherror]), "application/json")
        oServer.setStatus(401)
    done