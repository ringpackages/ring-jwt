aPackageInfo = [
	:name = "Ring JWT",
	:description = "JWT library for the Ring programming language.",
	:folder = "ring-jwt",
	:developer = "ysdragon",
	:email = "",
	:license = "MIT License",
	:version = "1.0.0",
	:ringversion = "1.23",
	:versions = 	[
		[
			:version = "1.0.0",
			:branch = "main"
		]
	],
	:libs = 	[
		[
			:name = "ringopenssl",
			:version = "1.0.9",
			:providerusername = "ringpackages"
		],
		[
			:name = "jsonlib",
			:version = "1.0.16",
			:providerusername = "ringpackages"
		]
	],
	:files = 	[
		"lib.ring",
		"main.ring",
		"examples/01_jwt_api.ring",
		"examples/02_jwt_gui.ring",
		"examples/03_jwt_middleware.ring",
		"examples/static/app.js",
		"examples/static/style.css",
		"src/hmac.ring",
		"src/hmac_test.ring",
		"src/jwt.ring",
		"src/jwt_test.ring",
		"src/utils/color.ring",
		"src/utils/helpers.ring",
		"src/utils/install.ring",
		"src/utils/uninstall.ring",
		"README.md",
		"LICENSE"
	],
	:ringfolderfiles = 	[

	],
	:windowsfiles = 	[

	],
	:linuxfiles = 	[

	],
	:ubuntufiles = 	[

	],
	:fedorafiles = 	[

	],
	:freebsdfiles = 	[

	],
	:macosfiles = 	[

	],
	:windowsringfolderfiles = 	[

	],
	:linuxringfolderfiles = 	[

	],
	:ubunturingfolderfiles = 	[

	],
	:fedoraringfolderfiles = 	[

	],
	:freebsdringfolderfiles = 	[

	],
	:macosringfolderfiles = 	[

	],
	:run = "ring main.ring",
	:windowsrun = "",
	:linuxrun = "",
	:macosrun = "",
	:ubunturun = "",
	:fedorarun = "",
	:setup = "ring src/utils/install.ring",
	:windowssetup = "",
	:linuxsetup = "",
	:macossetup = "",
	:ubuntusetup = "",
	:fedorasetup = "",
	:remove = "ring src/utils/uninstall.ring",
	:windowsremove = "",
	:linuxremove = "",
	:macosremove = "",
	:ubunturemove = "",
	:fedoraremove = ""
]