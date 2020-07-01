# lsbuffer.vim

*unix only for now*

*early stages; use with caution*

## Usage

When an ls buffer is opened, you can quickly navigate to different directories,
modify the file system in simple ways, and open files or directories in the
current window or new splits.

Currently, `readdirex()` is used, so you must be at version `8.2.0875` or above.
Backup functions for older versions are not yet implemented.

More things to come. Stay tuned. :)

### Global Mappings

| Key          | Description                                             |
|--------------|---------------------------------------------------------|
| `<leader>ls` | Open new ls buffer in current window                    |
| `<leader>lS` | Open new ls buffer a new split                          |
| `<leader>ll` | Open last ls buffer in a new split (not implemented)    |
| `<leader>lL` | Open last ls buffer in current window (not implemented) |

### Buffer Mappings

| Key         | Description                                                                                 |
|-------------|---------------------------------------------------------------------------------------------|
| `l`         | open file in current window or navigate to directory in current ls buffer                   |
| `<cr>`      | same as `l`                                                                                 |
| `v`         | open file in vertical split or navigate to directory in a new window in a **new ls buffer** |
| `s`         | like `v` but horizontal split instead                                                       |
| `h`         | go to parent directory (`../`)                                                              |
| `r`         | update ls buffer                                                                            |
| `o`         | open file under cursor with an external program (use `xdg-open` if empty)                   |
| `d{motion}` | delete a range of lines, prompting once for each file and twice for each nonempty directory |
| `{visual}d` | delete range of lines selected by `{visual}` selection like `d{motion}`                     |
| `dd`        | equivalent to `Vd` to delete current file or directory                                      |
| `aa`        | enable *autochdir* for global pwd (auto `:cd`)                                              |
| `al`        | enable *autochdir* for local buffer's (buffer's) pwd (auto `:lcd`)                          |
| `at`        | enable *autochdir* for tabpage's pwd (auto `:tcd`)                                          |
| `ad`        | disable *autochdir*                                                                         |
| `cc`        | change vim's *global* pwd to lsbuffer's cwd                                                 |
| `cl`        | change vim's *local* pwd to lsbuffer's cwd                                                  |
| `ct`        | change vim's *tabpage* pwd to lsbuffer's cwd                                                |
| `R`         | resolve symbolic link and navigate there                                                    |
| `gR`        | resolve symbolic link and navigate there in a **new ls buffer**                             |
| `~`         | go to ~ or $HOME directory                                                                  |
| `Z`         | toggle hidden (dot) file (dot files hidden by default)                                      |
| `C`         | start issuing `:Cd `                                                                        |
| `T`         | start issuing `:Touch`                                                                      |
| `D`         | start issuing `:Mkdir`                                                                      |
| `F`         | start issuing `:FilterToggle`                                                               |

### Buffer Commands

| Command         | Description                                               | Example                                                                  |
|-----------------|-----------------------------------------------------------|--------------------------------------------------------------------------|
| `:Cd`           | command to change directory for the current ls buffer     | `:Cd ~/Downloads` to go to Downloads in home                             |
| `:Touch`        | create one or more empty files                            | `:Touch foo\ 1.txt foo\ 2.txt` to touch files "foo 1.txt" and "foo2.txt" |
| `:Mkdir`        | make one or more directories (like `mkdir -p` in a shell) | `:Mkdir dir\ 1 dir\ 2` to make directories "dir 1" and "dir 2"           |
| `:FilterToggle` | Show/Hide patterns in lsbuffer                            | `:FilterToggle \.pdf$` to filter out any files with extension ".pdf"     |

### Autocmds

| Autocmd           | Description                                                                    |
|-------------------|--------------------------------------------------------------------------------|
| ` LsBufferNewPre` | Just after creating a new lsbuffer but before creating any `<buffer>` mappings |
| `LsBufferNew`     | Just after creating a new lsbuffer and after creating all `<buffer>` mappings  |

## TODO

- implement `<plug>`s instead of blatant overwriting
- support different view options (use 'perm', 'group', 'type', and 'size' from `readdirex()` as well as full path and other path options)
- optionally show the current path at top with NUL in front
- optionally show "." and/or ".." at top (move cursor after when entering new directory though)
- reimplement script functions as autoload functions probably (so anyone can directly call the functions as desired for scriptability)
- give a prefix for each line and implement "actions" with `x` to "execute" staged actions
- use `<plug>`s for all default mappings and check using `hasmapto()` so user can set own bindings
- `l` / `<cr>` doesn't just open vim for some files -> `xdg-open` and mapping for some file extensions
- `o` for "open with" prompt, `O` for `xdg-open`
- `gm` and `gM` to bookmark current directory and delete bookmark (resp.)
    - also need a way to list and :browse marked directories
    - `g'` and `` g` `` to go to a bookmarked directory
- use autocmds like netrw to autoopen when editing a directory
- implement `:Bulkedit`
- find more things to add to TODO :V

##### COMPLETED

- ~make some commands to open files/directories that respect `<mods>`~
- ~support symlinks with "fileName\t\x00 -> theSymLink" (like in previous lsbuffer implementation)~
- ~change vim's `:pwd` (global, local, or tab page) to lsbuffer's `b:cwd` with mappings to `:exe 'cd '..b:cwd`, `:lcd ..`, and `:tcd ..`~
- ~`autochdir` functionality~
- ~use defaults with `hasmapto()` and `mapargs` (but DON'T break `<leader>l` -> this can cause lag!)~
- ~implement lsbuffer#last()~
- ~jump to symbolic link (`R`)~
