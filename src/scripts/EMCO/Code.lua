--[[
========================================================
 EMCO CHAT WINDOW — AVAILABLE COMMANDS & FEATURES
========================================================
This system controls your tabbed chat window (EMCO).
All commands begin with:  emco

--------------------------------------------------------
 TAB MANAGEMENT
--------------------------------------------------------
emco addtab <tabname>
  Adds a new tab to the chat window.

emco remtab <tabname>
  Removes an existing tab.

--------------------------------------------------------
 DISPLAY & APPEARANCE
--------------------------------------------------------
emco show
  Shows the EMCO chat window.

emco hide
  Hides the EMCO chat window.

emco lock
  Locks the window so it cannot be moved or resized.

emco unlock
  Unlocks the window so it can be moved/resized again.

emco font <fontname>
  Sets the font used by the chat consoles.

emco fontSize <size>
  Sets the font size for the chat consoles.

emco tabFontSize <size>
  Sets the font size for the tabs (independent of console).

emco addFontSize <size>
  Alias for tabFontSize.

emco color <option> <value>
  Changes colors for tabs and backgrounds.
  Use 'emco color' by itself to see available options.

emco title <new title>
  Sets the title displayed at the top of the chat window.
  Default title: "Tabbed Chat"

--------------------------------------------------------
 MESSAGE DISPLAY OPTIONS
--------------------------------------------------------
emco timestamp <true|false>
  Turns timestamps on or off for messages.

emco blankLine <true|false>
  Inserts (or removes) a blank line between messages.

emco blink <true|false>
  Turns tab blinking on or off for new activity.

--------------------------------------------------------
 NOTIFICATIONS
--------------------------------------------------------
emco notify <tabname>
  Enables OS-level notifications for that tab.

emco unnotify <tabname>
  Disables OS-level notifications for that tab.

--------------------------------------------------------
 GAGGING / FILTERING
--------------------------------------------------------
emco gag <pattern>
  Adds a gag filter (hides matching text).

emco ungag <pattern>
  Removes a gag filter.

emco gaglist
  Shows all currently active gag patterns.

--------------------------------------------------------
 CONFIGURATION
--------------------------------------------------------
emco save
  Saves your current EMCO configuration to disk.

emco load
  Loads your saved EMCO configuration.

emco version
  Displays the current EMCO version and repository information.

emco update
  (Re)installs or updates to the latest EMCO package version.

emco restart
  Restarts the EMCO chat window and reloads defaults.

--------------------------------------------------------
USAGE IN CODE
--------------------------------------------------------
To copy lines from triggers to a tab:
  demonnic.chat:append("TabName")

To send custom messages:
  demonnic.chat:cecho("TabName", "Your message here\n")
  demonnic.chat:decho("TabName", "Your message here\n")
  demonnic.chat:hecho("TabName", "Your message here\n")

Full API documentation:
  https://demonnic.github.io/mdk/current/classes/EMCO.html

========================================================
 End of EMCO Help
========================================================
]]--

local defaultConfig = {activeColor = "black", inactiveColor = "black", activeBorder = "green", activeText = "green", inactiveText = "grey", background = "black", windowBorder = "green", title = "green"}
local emco = require("@PKGNAME@.emco")
emco.cmdLineStyleSheet = nil
demonnic = demonnic or {}
demonnic.helpers = demonnic.helpers or {}
demonnic.config = demonnic.config or defaultConfig
local baseStyle = Geyser.StyleSheet:new(f [[
  border-width: 2px; 
  border-style: solid; 
]])
local activeStyle = Geyser.StyleSheet:new(f [[
  border-color: {demonnic.config.activeBorder};
  background-color: {demonnic.config.activeColor};
]], baseStyle)
local inactiveStyle = Geyser.StyleSheet:new(f [[
  border-color: {demonnic.config.inactiveColor};
  background-color: {demonnic.config.inactiveColor};
]], baseStyle)
local adjLabelStyle = Geyser.StyleSheet:new(f[[
  background-color: rgba(0,0,0,100%);
  border: 4px double;
  border-color: {demonnic.config.windowBorder};
  border-radius: 4px;]])

local default_constraints = {name = "EMCOPrebuiltChatContainer", x = "-25%", y = "-60%", width = "25%", height = "60%", titleText = "Tabbed Chat"}


local chatEMCO = demonnic.chat
local EMCOfilename = getMudletHomeDir() .. "/EMCO/EMCOPrebuiltChat.lua"
local confFile = getMudletHomeDir() .. "/EMCO/EMCOPrebuiltExtraOptions.lua"

function demonnic.helpers.echo(msg)
  msg = msg or ""
  cecho(f "<green>EMCO Chat: <reset>{msg}\n")
end

function demonnic.helpers.resetToDefaults()
  default_constraints.adjLabelstyle = adjLabelStyle:getCSS()
  demonnic.container = demonnic.container or Adjustable.Container:new(default_constraints)
  demonnic.config = defaultConfig
  demonnic.chat = emco:new({
    name = "EMCOPrebuiltChat",
    x = 0,
    y = 0,
    height = "100%",
    width = "100%",
    consoles = {"All", "Program", "OOC", "RP", "Whisper", "Group", "Game"},
    allTab = true,
    allTabName = "All",
    blankLine = true,
    blink = true,
    bufferSize = 10000,
    deleteLines = 500,
    timestamp = true,
    fontSize = 14,
    tabFontSize = 16,
    font = "Ubuntu Mono",
    consoleColor = demonnic.config.background,
    activeTabCSS = activeStyle:getCSS(),
    inactiveTabCSS = inactiveStyle:getCSS(),
    activeTabFGColor = demonnic.config.activeText,
    inactiveTabFGColor = demonnic.config.inactiveText,
    gap = 3,
    commandLine = true,
  }, demonnic.container)
  chatEMCO = demonnic.chat
  demonnic.helpers.retheme()
end

function demonnic.helpers.retheme()
  activeStyle:set("background-color", demonnic.config.activeColor)
  activeStyle:set("border-color", demonnic.config.activeBorder)
  inactiveStyle:set("background-color", demonnic.config.inactiveColor)
  inactiveStyle:set("border-color", demonnic.config.inactiveColor)
  adjLabelStyle:set("border-color", demonnic.config.windowBorder)
  local als = adjLabelStyle:getCSS()
  demonnic.container.adjLabelstyle = als
  demonnic.container.adjLabel:setStyleSheet(als)
  demonnic.container:setTitle(demonnic.container.titleText, demonnic.config.title)
  chatEMCO.activeTabCSS = activeStyle:getCSS()
  chatEMCO.inactiveTabCSS = inactiveStyle:getCSS()
  chatEMCO:setActiveTabFGColor(demonnic.config.activeText)
  chatEMCO:setInactiveTabFGColor(demonnic.config.inactiveText)
  chatEMCO:setConsoleColor(demonnic.config.background)
  chatEMCO:switchTab(chatEMCO.currentTab)
end

function demonnic.helpers.setConfig(cfg, val)
  local validOptions = table.keys(demonnic.config)
  if not table.contains(validOptions, cfg) then
    return nil, f"invalid option: valid options are {table.concat(validOptions, ', ')}"
  end
  demonnic.config[cfg] = val
  demonnic.helpers.retheme()
  return true
end

function demonnic.helpers.save()
  chatEMCO:save()
  table.save(confFile, demonnic.config)
  demonnic.container:save()
end

function demonnic.helpers.load()
  if io.exists(confFile) then
    local conf = {}
    table.load(confFile, conf)
    demonnic.config = table.update(demonnic.config, conf)
    for option, value in pairs(defaultConfig) do
      demonnic.config[option] = demonnic.config[option] or value
    end
  end
  if io.exists(EMCOfilename) then
    chatEMCO:hide()
    chatEMCO:load()
    chatEMCO:show()
  end
  demonnic.container:load()
  demonnic.helpers.retheme()
end

local function startup()
  demonnic.helpers.resetToDefaults()
  demonnic.helpers.load()
end

registerNamedEventHandler("demonnicEMCO", "EMCOprebuilt startup", "sysLoadEvent", startup)
