-- Shows a dot while the active workspace on this bar's monitor has a
-- maximized or fullscreen window. State comes from watch.py (Hyprland events).
-- barWidget.* only has this bar's context inside update(), so the stream
-- callback just stores the latest line and update() applies it.

local latest = ""

noctalia.runStream("exec python3 -I '" .. noctalia.pluginDir() .. "/watch.py'", function(line)
  latest = line
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
