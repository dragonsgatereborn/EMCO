local echo = demonnic.helpers.echo

if demonnic.container then
  if demonnic.container.hide then
    demonnic.container:hide()
  end
  if demonnic.container.close then
    demonnic.container:close()
  end
  if demonnic.container.destroy then
    demonnic.container:destroy()
  end
end

demonnic.container = nil
demonnic.chat = nil
collectgarbage("collect")

demonnic.helpers.resetToDefaults()
echo("Restarted EMCO chat window.")
