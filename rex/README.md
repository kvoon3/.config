# rex

Live Rex configuration for this machine. `init.lua` is the file Rex loads.

The herdr style `ctrl+b` keymap in `init.lua` is maintained upstream.
See https://github.com/kvoon3/rex-herdr-keybinding for the keymap, the
herdr to Rex mapping table, and install notes.

The `leaf` plugin owns the marked block at the top of `init.lua`. Keep it in
place when editing, and put new bindings after it.

`init.lua` carries a deployed copy of the keymap. Change the keymap upstream,
then copy it into `init.lua` below the leaf block so the two stay identical.
