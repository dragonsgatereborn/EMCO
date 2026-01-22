local repoUrl = "https://github.com/dragonsgatereborn/EMCO"
local packageUrl = repoUrl .. "/releases/latest/download/@PKGNAME@.mpackage"

cecho("<green>EMCO Chat: <reset>Updating from " .. repoUrl .. "\n")
cecho("<green>EMCO Chat: <reset>Fetching latest version...\n")

uninstallPackage("@PKGNAME@")
installPackage(packageUrl)

cecho("<green>EMCO Chat: <reset>Update complete! Package installed from:\n")
cecho("<green>EMCO Chat: <reset>" .. packageUrl .. "\n")