local currentVersion = "2.15.9"
local repoUrl = "https://github.com/dragonsgatereborn/EMCO"
local apiUrl = "https://api.github.com/repos/dragonsgatereborn/EMCO/releases/latest"
local packageUrl = repoUrl .. "/releases/latest/download/@PKGNAME@.mpackage"

local function installLatest(latestTag)
  if latestTag and latestTag ~= "" then
    cecho("<green>EMCO Chat: <reset>Latest version: " .. latestTag .. "\n")
  else
    cecho("<green>EMCO Chat: <reset>Latest version: unknown (installing latest)\n")
  end
  uninstallPackage("@PKGNAME@")
  installPackage(packageUrl)
  cecho("<green>EMCO Chat: <reset>Update complete! Package installed from:\n")
  cecho("<green>EMCO Chat: <reset>" .. packageUrl .. "\n")
end

cecho("<green>EMCO Chat: <reset>Current version: " .. currentVersion .. "\n")
cecho("<green>EMCO Chat: <reset>Updating from " .. repoUrl .. "\n")
cecho("<green>EMCO Chat: <reset>Fetching latest version...\n")

if getHTTP then
  local completed = false
  tempTimer(3, function()
    if not completed then
      cecho("<green>EMCO Chat: <reset>Latest version: unknown (timed out, installing latest)\n")
      installLatest("")
    end
  end)
  getHTTP(apiUrl, function(body)
    if completed then return end
    completed = true
    local tag = body and body:match('"tag_name"%s*:%s*"([^"]+)"') or ""
    installLatest(tag)
  end)
else
  installLatest("")
end
