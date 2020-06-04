# lsbuffer.vim

*__NOTE__: This plugin is in the super beta stages. Use at your own risk. :P*

## Usage

When an ls buffer is opened, you can quickly navigate to different directories,
modify the file system in simple ways, and open files or directories in the
current window or new splits.

Currently, `readdirex()` is used, so you must be at version `8.2.0875` or above.
Backup functions for older versions are not yet implemented.

More things to come. Stay tuned. :)

### Global Mappings

| Key | Description |
| --- | ----------- |
| `<leader>ls` | Open new ls buffer in a new split |
| `<leader>lS` | Open new ls buffer in current window |
| `<leader>ll` | Open last ls buffer in a new split (not implemented) |
| `<leader>lL` | Open last ls buffer in current window (not implemented) |

### Buffer Mappings

| Key | Description |
| --- | ----------- |
| `l` | open file in current window or navigate to directory in current ls buffer |
| `<cr>` | same as `l` |
| `v` | open file in vertical split or navigate to directory in a new window in a **new ls buffer** |
| `s` | like `v` but horizontal split instead |
| `h` | go to parent directory (`../`) |
| `r` | update ls buffer |
| `d{motion}` | delete a range of lines, prompting once for each file and twice for each nonempty directory |
| `{visual}d` | delete range of lines selected by `{visual}` selection like `d{motion}` |
| `dd` | equivalent to `Vd` to delete current file or directory |
| `c` | start issuing `:CD` command to change directory for the current ls buffer |
| `t` | start issuing `:TOUCH` command to touch a file |
| `D` | start issuing `:MKDIR` command to make one or more directories ('p' flag passed to `mkdir()`) |
| `z` | toggle hidden (dot) file (dot files hidden by default) |

## TODO

- support symlinks with "\t\x00-> theSymLink" (like in previous lsbuffer implementation)
- change vim's `:pwd` (global, local, or tab page) to lsbuffer's `b:cwd` with mappings to `:exe 'cd '..b:cwd`, `:lcd ..`, and `:tcd ..`
- support different view options (use 'perm', 'group', 'type', and 'size' from `readdirex()` as well as full path and other path options)
- optionally show the current path at top with NUL in front
- optionally show "." and/or ".." at top (move cursor after when entering new directory though)
- implement lsbuffer#last()
- reimplement script functions as autoload functions probably (so anyone can directly call the functions as desired for scriptability)
- more useful mappings?
- make some commands to open files/directories that respect `<mods>`
- find more things to add to TODO :V

