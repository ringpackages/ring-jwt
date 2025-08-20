load "stdlibcore.ring"

cPathSep = "/"

if isWindows()
	cPathSep = "\\"
ok

# Remove the jwt.ring file from the load directory
remove(exefolder() + "load" + cPathSep + "jwt.ring")

# Change current directory to the samples directory
chdir(exefolder() + ".." + cPathSep + "samples")

# Remove the UsingJWT directory if it exists
if direxists("UsingJWT")
	OSDeleteFolder("UsingJWT")
ok