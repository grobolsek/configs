-- Shows a dot while a workspace visible on this bar's monitor (active one or
-- open scratchpad) has a maximized or fullscreen window. State comes from
-- watch.py (Hyprland events). barWidget.* only has this bar's context inside
-- update(), so the stream callback just stores the latest line and update()
-- applies it.

local latest = ""

noctalia.runStream("exec python3 -I '" .. noctalia.pluginDir() .. "/watch.py'", function(line)
  -- only accept state lines ("DP-3=1 HDMI-A-1=0"), never stray error output
  if string.find(line, "^%S+=%d") then
    latest = line
  end
end)

function update()
  noctalia.setUpdateInterval(100)
  barWidget.setGlyph("point-filled")
  barWidget.setGlyphColor("primary")
  barWidget.setText("")

  local output = barWidget.outputName()
  local on = false
  for name, value in string.gmatch(latest, "(%S+)=(%d)") do
    if name == output then
      on = value == "1"
    end
  end
  barWidget.setVisible(on)
end
