# fzf-utils

Additions to [fzf.vim](https://github.com/junegunn/fzf.vim): finding files with
[fd](https://github.com/sharkdp/fd), live and static
[ripgrep](https://github.com/BurntSushi/ripgrep) searches, and picking buffers
to wipe out.

| Command | `<Plug>` mapping | Needs | What it does |
| --- | --- | --- | --- |
| `:FdFiles[!] [dir]` | `<Plug>(fzf-utils-files)` | fd | Find files: fzf.vim's `:Files`, listing with fd. |
| `:Grep[!] [pattern] [-- rg-options/paths]` | `<Plug>(fzf-utils-grep)` | rg | Live grep: ripgrep re-runs as you type. `C-r` regex, `C-f` fixed string, `C-w` word. |
| | `<Plug>(fzf-utils-grep-dir)` | rg | `:Grep` in the current buffer's directory. |
| | `<Plug>(fzf-utils-grep-replay)` | rg | Replay the last live grep with its last query. |
| `:RgRaw[!] <rg args>` | | rg | Static grep: ripgrep runs once with your arguments as given (`:RgRaw -g "*.vim" foo src/`), fzf filters the result. |
| `:FzfToggleIgnored` | | | Include or leave out ignored files in `:FdFiles`, `:Grep` and `:RgRaw`. |
| `:BD` | | | Pick buffers to wipe out (`<Tab>` marks several, `ctrl-a` takes all). |

Commands and mappings that need fd or rg are defined when that tool is
installed. `:Grep` and `:RgRaw` save the accepted query to the search register
and `:History/`.

No keys are bound. For example:

```vim
nmap <leader><leader> <Plug>(fzf-utils-files)
nmap <leader>r/ <Plug>(fzf-utils-grep)
nmap <leader>r. <Plug>(fzf-utils-grep-dir)
nmap <leader>rr <Plug>(fzf-utils-grep-replay)
nnoremap <leader>r: :Grep
```

## Files searched

`:FdFiles` lists, and `:Grep` / `:RgRaw` search, the same files. The search:

- includes hidden files (dotfiles),
- follows symlinks,
- skips `.git` and `__pycache__`,
- skips files excluded by `.gitignore`, `.ignore` and git's global excludes
  (plus `.fdignore` for fd and `.rgignore` for rg), unless ignored files are
  included (next section).

fd runs without `~/.config/fd/ignore` and ripgrep with `--no-config`, both
with every option spelled out, so the result is the same whatever your shell
setup.

## Including ignored files: `g:fzf_utils_include_ignored`

| Value | Ignored files |
| --- | --- |
| `0` (default) | Left out |
| `1` | Included |

`:FzfToggleIgnored` flips it. `:FdFiles`, `:Grep` and `:RgRaw` read it on every
search, so one toggle switches file and content searches together.

To start with ignored files included in one project, e.g. one with a `.venv`,
set it in that project's local config:

```vim
let g:fzf_utils_include_ignored = 1
```

## Built on it

[grepscope](https://github.com/roumail/grepscope) builds `:GrepScope` (grep
within project scopes) on top of `:Grep`.

## Install

Requires [fzf](https://github.com/junegunn/fzf) and fzf.vim. `:FdFiles` also
requires `fd`; `:Grep`, `:RgRaw` and the grep mappings require `rg`.
Required plugins are checked once every plugin has loaded, so the order of your
Plug lines doesn't matter. If one is missing, Vim shows
`fzf-utils: not loaded, requires …` at startup and the plugin defines nothing.

```vim
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'roumail/fzf-utils'
```
