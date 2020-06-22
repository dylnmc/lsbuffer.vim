# lsbuffer.vim

*__NOTE__: This plugin is in the beta stages. Please test it out and leave an issue for features or bugs. :P*

## Usage

When an ls buffer is opened, you can quickly navigate to different directories,
modify the file system in simple ways, and open files or directories in the
current window or new splits.

Currently, `readdirex()` is used, so you must be at version `8.2.0875` or above.
Backup functions for older versions are not yet implemented.

More things to come. Stay tuned. :)

### Global Mappings

| Key          | Description                                             |
| ---          | -----------                                             |
| `<leader>ls` | Open new ls buffer in a new split                       |
| `<leader>lS` | Open new ls buffer in current window                    |
| ~`<leader>ll`~ | Open last ls buffer in a new split (not implemented)    |
| ~`<leader>lL`~ | Open last ls buffer in current window (not implemented) |

### Buffer Mappings

| Key         | Description                                                                                   |
| ---         | -----------                                                                                   |
| `l`         | open file in current window or navigate to directory in current ls buffer                     |
| `<cr>`      | same as `l`                                                                                   |
| `v`         | open file in vertical split or navigate to directory in a new window in a **new ls buffer**   |
| `s`         | like `v` but horizontal split instead                                                         |
| `h`         | go to parent directory (`../`)                                                                |
| `r`         | update ls buffer                                                                              |
| `d{motion}` | delete a range of lines, prompting once for each file and twice for each nonempty directory   |
| `{visual}d` | delete range of lines selected by `{visual}` selection like `d{motion}`                       |
| `dd`        | equivalent to `Vd` to delete current file or directory                                        |
| `c`         | start issuing `:CD` command to change directory for the current ls buffer                     |
| `t`         | start issuing `:TOUCH` command to touch a file                                                |
| `D`         | start issuing `:MKDIR` command to make one or more directories ('p' flag passed to `mkdir()`) |
| `Z`         | toggle hidden (dot) file (dot files hidden by default)                                        |

## TODO

- use xdg-open or global list to open files (using executable() and system())
- change vim's `:pwd` (global, local, or tab page) to lsbuffer's `b:cwd` with mappings to `:exe 'cd '..b:cwd`, `:lcd ..`, and `:tcd ..`
- optional `autochdir` functionality
- implement `<plug>`s instead of blatant overwriting
- use defaults with `hasmapto()` and `mapargs` (but DON'T break `<leader>l` -> this can cause lag!)
- support different view options (use 'perm', 'group', 'type', and 'size' from `readdirex()` as well as full path and other path options)
- optionally show the current path at top with NUL in front
- optionally show "." and/or ".." at top (move cursor after when entering new directory though)
- implement lsbuffer#last()
- reimplement script functions as autoload functions probably (so anyone can directly call the functions as desired for scriptability)
- more useful mappings?
- allow for scattered selection (some form of marks)
    - maybe use `+` to add a mark and `-` to remove a mark and `=` to toggle mark
- use `<plug>`s for all default mappings and check using `hasmapto()` so user can set own bindings
- use xdg-open on commands
- mapping to jump to symbolic link's reference (`gl`, `g<cr>`, others?)
- use autocmds like netrw to autoopen when editing a directory
- implement `:BULKEDIT`
- preview? (very difficult)
- find more things to add to TODO :V

---

- ~make some commands to open files/directories that respect `<mods>`~
- ~support symlinks with "fileName\t\x00 -> theSymLink" (like in previous lsbuffer implementation)~
