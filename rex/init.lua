-- >>> leaf >>>
-- Managed by `leaf rex install`; `leaf rex uninstall` removes it.
-- plugin: dbd96079ad70c4c6
dofile("/Users/kvoon/.config/rex/plugins/leaf/init.lua").setup({ bin = { "/Users/kvoon/.local/bin/leaf" } })
-- open: idle classic
-- <<< leaf <<<

local bindings = {
  -- panes
  { "ctrl+b>z", "pane.zoom" },
  { "ctrl+b>x", "pane.close" },
  { "ctrl+b>shift+h", "pane.move", { direction = "left" } },
  { "ctrl+b>shift+j", "pane.move", { direction = "down" } },
  { "ctrl+b>shift+k", "pane.move", { direction = "up" } },
  { "ctrl+b>shift+l", "pane.move", { direction = "right" } },

  { "ctrl+b>tab", "pane.focus_next" },
  { "ctrl+b>shift+tab", "pane.focus_previous" },

  -- focus
  { "ctrl+b>h", "pane.focus", { direction = "left" } },
  { "ctrl+b>j", "pane.focus", { direction = "down" } },
  { "ctrl+b>k", "pane.focus", { direction = "up" } },
  { "ctrl+b>l", "pane.focus", { direction = "right" } },

  -- splits
  { "ctrl+b>v", "pane.split", { direction = "right" } },
  { "ctrl+b>-", "pane.split", { direction = "down" } },

  -- tabs
  { "ctrl+b>c", "client.tab.new" },
  { "ctrl+b>n", "client.tab.next" },
  { "ctrl+b>p", "client.tab.previous" },
  { "ctrl+b>shift+t", "client.tab.rename" },
  { "ctrl+b>shift+x", "client.tab.close" },

  -- session/workspace
  { "ctrl+b>w", "session.switch" },
  { "ctrl+b>shift+n", "session.new" },
  { "ctrl+b>shift+w", "session.rename" },
  { "ctrl+b>shift+d", "session.close" },
  { "ctrl+b>g", "pane.go_to" },

  -- misc
  { "ctrl+b>b", "client.sidebar.toggle" },
  { "ctrl+b>q", "client.visibility.toggle" },
  { "ctrl+b>shift+/", "client.palette.toggle" },
  { "ctrl+b>t", "pane.new_floating" },
  { "ctrl+b>[", "client.find.open" },
  { "ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" } },
  { "ctrl+b>s", "client.settings" },
  { "ctrl+b>shift+p", "pane.rename" },
  { "ctrl+b>shift+r", "client.config.reload" },
}

for _, b in ipairs(bindings) do rex.bind(b[1], b[2], b[3]) end

for i = 1, 9 do rex.bind(string.format("ctrl+b>%d", i), "client.tab.goto", { index = i }) end

rex.mode("resize", { exclusive = true })
rex.bind("ctrl+b>r", "client.mode.enter", { name = "resize" })
rex.bind("resize/h", "pane.resize", { direction = "left" })
rex.bind("resize/j", "pane.resize", { direction = "down" })
rex.bind("resize/k", "pane.resize", { direction = "up" })
rex.bind("resize/l", "pane.resize", { direction = "right" })
rex.bind("resize/enter", "client.mode.exit")
