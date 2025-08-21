load "httplib.ring"
load "jwt.ring"

# Define a secret key for JWT signing
cJWTSecret = "your_middleware_secret_key_here"

# Global JWT middleware instance
oJWTMiddleware = new JWTMiddleware(cJWTSecret)

oServer = new Server {

    # Public routes (no authentication required)
    route(:Get, "/", :home)
    route(:Post, "/login", :login)
    route(:Get, "/public", :publicInfo)

    # Protected routes (authentication required)
    route(:Get, "/dashboard", :dashboard)
    route(:Get, "/profile", :profile)
    route(:Get, "/admin", :adminPanel)

    ? "JWT Middleware Example Server"
    ? "============================="
    ? "Public routes:"
    ? "  GET  /           - Home page"
    ? "  POST /login      - Login endpoint"
    ? "  GET  /public     - Public information"
    ? ""
    ? "Protected routes (require JWT):"
    ? "  GET  /dashboard  - User dashboard"
    ? "  GET  /profile    - User profile"
    ? "  POST /api/data   - API data endpoint"
    ? "  GET  /admin      - Admin panel (admin role required)"
    ? ""
    ? "Server listening on: 0.0.0.0:8080"
    listen("0.0.0.0", 8080)
}

func home
    cHTML = `<!DOCTYPE html>
<html>
<head>
    <title>JWT Middleware Example</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .route { margin: 10px 0; padding: 10px; border: 1px solid #ccc; }
        .public { background-color: #e8f5e8; }
        .protected { background-color: #fff3cd; }
        .admin { background-color: #f8d7da; }
        code { background-color: #f4f4f4; padding: 2px 4px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>JWT Middleware Example</h1>
        <p>This example demonstrates how to use JWT middleware to protect routes.</p>

        <h2>Testing the API:</h2>

        <div class="route public">
            <strong>1. Get public information:</strong><br>
            <code>curl http://localhost:8080/public</code>
        </div>

        <div class="route public">
            <strong>2. Login to get JWT token:</strong><br>
            <code>curl -X POST -H "Content-Type: application/json" -d '{"username": "user", "password": "password"}' http://localhost:8080/login</code>
        </div>

        <div class="route public">
            <strong>3. Login as admin:</strong><br>
            <code>curl -X POST -H "Content-Type: application/json" -d '{"username": "admin", "password": "admin123"}' http://localhost:8080/login</code>
        </div>

        <div class="route protected">
            <strong>4. Access protected dashboard:</strong><br>
            <code>curl -H "Authorization: Bearer YOUR_JWT_TOKEN" http://localhost:8080/dashboard</code>
        </div>

        <div class="route protected">
            <strong>5. Access user profile:</strong><br>
            <code>curl -H "Authorization: Bearer YOUR_JWT_TOKEN" http://localhost:8080/profile</code>
        </div>

        <div class="route admin">
            <strong>7. Access admin panel (admin role required):</strong><br>
            <code>curl -H "Authorization: Bearer YOUR_ADMIN_JWT_TOKEN" http://localhost:8080/admin</code>
        </div>

        <h2>Available Test Users:</h2>
        <ul>
            <li><strong>user</strong> / password (role: user)</li>
            <li><strong>admin</strong> / admin123 (role: admin)</li>
        </ul>
    </div>
</body>
</html>`
    oServer.setContent(cHTML, "text/html")

func login
    cBody = oServer.request().body()
    aCredentials = json2list(cBody)
    cUsername = aCredentials[:username]
    cPassword = aCredentials[:password]

    # Simple user authentication (in real app, check against database)
    aUsers = [
        ["user", "password", "user"],
        ["admin", "admin123", "admin"]
    ]

    cRole = ""
    for aUser in aUsers
        if aUser[1] = cUsername and aUser[2] = cPassword
            cRole = aUser[3]
            exit
        ok
    next

    if cRole != ""
        nExp = unixtime() + 3600 # 1 hour expiration

        if cRole = "admin"
            aPermissions = ["read", "write", "delete", "admin"]
        else
            aPermissions = ["read", "write"]
        ok

        payload = [
            :sub = cUsername,
            :iat = unixtime(),
            :exp = nExp,
            :role = cRole,
            :permissions = aPermissions
        ]

        oJWT = new JWT
        cToken = oJWT.Encode(payload, cJWTSecret)

        oServer.setContent(list2json([
            :success = true,
            :message = "Login successful",
            :token = cToken,
            :role = cRole,
            :expires_in = 3600
        ]), "application/json")
    else
        oServer.setContent(list2json([
            :success = false,
            :message = "Invalid credentials"
        ]), "application/json")
        oServer.setStatus(401)
    ok

func publicInfo
    oServer.setContent(list2json([
        :message = "This is public information accessible to everyone",
        :timestamp = unixtime(),
        :server = "Ring JWT Middleware Example"
    ]), "application/json")

func dashboard
    # Use middleware to protect this route
    if not oJWTMiddleware.authenticate(NULL)
        return
    ok

    aUser = oJWTMiddleware.getUser()

    oServer.setContent(list2json([
        :message = "Welcome to your dashboard, " + aUser[:sub] + "!",
        :role = aUser[:role],
        :permissions = aUser[:permissions],
        :dashboard_data = [
            :recent_activities = ["Login", "Viewed profile", "Updated settings"],
            :notifications = 3,
            :unread_messages = 5
        ]
    ]), "application/json")

func profile
    # Use middleware to protect this route
    if not oJWTMiddleware.authenticate(NULL)
        return
    ok

    aUser = oJWTMiddleware.getUser()

    oServer.setContent(list2json([
        :username = aUser[:sub],
        :role = aUser[:role],
        :permissions = aUser[:permissions],
        :profile = [
            :full_name = "John Doe",
            :email = aUser[:sub] + "@example.com",
            :member_since = "2024-01-15",
            :last_login = time(aUser[:iat])
        ]
    ]), "application/json")

func adminPanel
    # Use middleware to protect this route with role requirement
    if not oJWTMiddleware.authenticate("admin")
        return
    ok

    aUser = oJWTMiddleware.getUser()

    oServer.setContent(list2json([
        :message = "Welcome to the admin panel, " + aUser[:sub] + "!",
        :admin_data = [
            :total_users = 150,
            :active_sessions = 23,
            :system_status = "healthy",
            :recent_logs = [
                "User login: admin",
                "System backup completed",
                "Security scan passed"
            ]
        ]
    ]), "application/json")

# JWT Middleware Class
class JWTMiddleware

    cSecret = ""
    aCurrentUser = []

    func init cSecretKey
        cSecret = cSecretKey

    func authenticate cRequiredRole
        oRequest = oServer.request()

        if not oRequest.has_header("Authorization")
            oServer.setContent(list2json([
                :error = "Authorization header missing"
            ]), "application/json")
            oServer.setStatus(401)
            return false
        ok

        cAuthHeader = oRequest.get_header_value("Authorization")

        if not substr(cAuthHeader, "Bearer ")
            oServer.setContent(list2json([
                :error = "Invalid authorization format. Use: Bearer <token>"
            ]), "application/json")
            oServer.setStatus(401)
            return false
        ok

        cToken = substr(cAuthHeader, "Bearer ", "")

        try
            oJWT = new JWT
            aPayload = oJWT.Decode(cToken, cSecret)

            # Check if token is expired
            if aPayload[:exp] < unixtime()
                oServer.setContent(list2json([
                    :error = "Token has expired"
                ]), "application/json")
                oServer.setStatus(401)
                return false
            ok

            # Check role requirement if specified
            if cRequiredRole != NULL
                if aPayload[:role] != cRequiredRole
                    oServer.setContent(list2json([
                        :error = "Insufficient permissions. Required role: " + cRequiredRole
                    ]), "application/json")
                    oServer.setStatus(403)
                    return false
                ok
            ok

            # Store user data for later use
            aCurrentUser = aPayload
            return true

        catch
            oServer.setContent(list2json([
                :error = "Invalid token",
                :details = ccatcherror
            ]), "application/json")
            oServer.setStatus(401)
            return false
        done

    func getUser
        return aCurrentUser

    func getUserId
        return aCurrentUser[:sub]

    func getUserRole
        return aCurrentUser[:role]

    func hasPermission cPermission
        if aCurrentUser[:permissions] != NULL
            return find(aCurrentUser[:permissions], cPermission) > 0
        ok
        return false