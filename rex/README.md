# rex

Live Rex configuration for this machine. `init.lua` is the file Rex loads.

It holds two managed blocks. `leaf` owns the first. The second is written by
the rex-herdr-keybinding CLI and only loads the keymap.

The keymap and the herdr to Rex mapping table live upstream.
See https://github.com/kvoon3/rex-herdr-keybinding.

The keymap is installed to `~/.config/rex/plugins/rex-herdr-keybinding`, which
is machine-local and stays out of this repo. Manage it with
`rex-herdr-keybinding install`, `enable`, `disable`, or `uninstall`.