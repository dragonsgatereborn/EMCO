local currentVersion = "2.15.15"
local repoUrl = "https://github.com/dragonsgatereborn/EMCO"
local apiUrl = "https://api.github.com/repos/dragonsgatereborn/EMCO/releases/latest"
local packageUrl = repoUrl .. "/releases/latest/download/@PKGNAME@.mpackage"

local function installLatest(latestTag)
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
  tempTimer(8, function()
    if not completed then
      completed = true
      cecho("<green>EMCO Chat: <reset>Latest version: unknown (timed out). Installing latest.\n")
      installLatest("")
    end
  end)
  getHTTP(apiUrl, {}, function(body, code)
    if completed then return end
    completed = true
    if code and tonumber(code) ~= 200 then
      cecho("<green>EMCO Chat: <reset>Latest version: unknown (HTTP " .. tostring(code) .. "). Installing latest.\n")
      installLatest("")
      return
    end
    local tag = body and body:match('"tag_name"%s*:%s*"([^"]+)"') or ""
    if tag == "" then
      cecho("<green>EMCO Chat: <reset>Latest version: unknown (invalid response). Installing latest.\n")
      installLatest("")
      return
    end
    cecho("<green>EMCO Chat: <reset>Latest version: " .. tag .. "\n")
    local currentTag = currentVersion
    if tag == currentTag or tag == ("v" .. currentTag) then
      cecho("<green>EMCO Chat: <reset>Already up to date.\n")
      return
    end
    cecho("<green>EMCO Chat: <reset>Updating to " .. tag .. "\n")
    installLatest(tag)
  end)
else
  cecho("<green>EMCO Chat: <reset>Latest version: unknown (getHTTP unavailable). Installing latest.\n")
  installLatest("")
end
