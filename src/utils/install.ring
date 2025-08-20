/*
	Ring JWT Library Install Script
	----------------------------------
	This script installs the Ring JWT library for the current platform.
*/

load "stdlibcore.ring"
load "src/utils/color.ring"

# Default library settings
cPathSep = "/"

# Platform detection and configuration
if isWindows()
	cPathSep = "\\"
ok

# Copy examples to the samples/UsingJWT directory
cCurrentDir = currentdir()
cPackagePath = exefolder() + ".." + cPathSep + "tools" + cPathSep + "ringpm" + cPathSep + "packages" + cPathSep + "ring-jwt"
cExamplesPath = cPackagePath + cPathSep + "examples"
cSamplesPath = exefolder() + ".." + cPathSep + "samples" + cPathSep + "UsingJWT"

# Ensure the samples directory exists and create it if not
if not direxists(exefolder() + ".." + cPathSep + "samples")
	makeDir(exefolder() + ".." + cPathSep + "samples")
ok

# Create the UsingJWT directory
makeDir(cSamplesPath)

# Change to the samples directory
chdir(cSamplesPath)

# Loop through the examples and copy them to the samples directory
for item in dir(cExamplesPath) 
	if item[2]
		OSCopyFolder(cExamplesPath + cPathSep, item[1])
	else
		OSCopyFile(cExamplesPath + cPathSep + item[1])
	ok
next

# Change back to the original directory
chdir(cCurrentDir)

# Write the load command to the jwt.ring file
write(exefolder() + "load" + cPathSep + "jwt.ring", `load "/../../tools/ringpm/packages/ring-jwt/lib.ring"`)

? colorText([:text = "Successfully installed Ring JWT!", :color = :BRIGHT_GREEN, :style = :BOLD])
? colorText([:text = "You can refer to samples in: ", :color = :CYAN]) + colorText([:text = cSamplesPath, :color = :YELLOW])
? colorText([:text = "Or in the package directory: ", :color = :CYAN]) + colorText([:text = cExamplesPath, :color = :YELLOW])