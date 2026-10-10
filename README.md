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
| `:GrepScope [pattern]` | `<Plug>(fzf-utils-grep-scope)` | rg | Pick a scope of the current project ([Project scopes](#project-scopes)), then `:Grep` in it. Without a project, a plain `:Grep`. |
| | `<Plug>(fzf-utils-grep-scope-word)` | rg | `:GrepScope` for the word under the cursor, or the visual selection (n, x). |
| `:RgRaw[!] <rg args>` | | rg | Static grep: ripgrep runs once with your arguments as given (`:RgRaw -g "*.vim" foo src/`), fzf filters the result. |
| `:FzfToggleIgnored` | | | Include or leave out ignored files in `:FdFiles`, `:Grep` and `:RgRaw`. |
| `:BD` | | | Pick buffers to wipe out (`<Tab>` marks several, `ctrl-a` takes all). |

Commands and mappings that need fd or rg are defined when that tool is
installed. `:Grep` and `:RgRaw` save the accepted query to the search register
and `:History/`.

Apart from `gw` / `gW` in project files ([Project scopes](#project-scopes)), no
keys are bound. For example:

```vim
nmap <leader><leader> <Plug>(fzf-utils-files)
nmap <leader>r/ <Plug>(fzf-utils-grep)
nmap <leader>r. <Plug>(fzf-utils-grep-dir)
nmap <leader>rr <Plug>(fzf-utils-grep-replay)
nmap <leader>rs <Plug>(fzf-utils-grep-scope)
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

## Project scopes

With [project-detect](https://github.com/roumail/project-detect) installed,
`:Grep` can search one part of the current project: its code or its tests,
optionally limited to its language. The scopes of a Python project are
`project`, `project python`, `tests` and `tests python`. A Go project has
`project go`, `tests` and `tests go`.

In a buffer of the project's language (a Python file in a Python project, a Go
file in a Go module), two keys grep the word under the cursor, or the visual
selection, matched literally:

| Key | Mode | Searches |
| --- | --- | --- |
| `gw` | n, x | the project's code, in its language |
| `gW` | n, x | the project's tests, in its language |

In other buffers `gw` is Vim's own.

| Function | What it does |
| --- | --- |
| `fzf_utils#rg#scope#pick([pattern])` | `:GrepScope`: pick a scope in fzf, then live grep in it. |
| `fzf_utils#rg#scope#code([pattern])` | Live grep in the project's code, in its language. |
| `fzf_utils#rg#scope#tests([pattern])` | Live grep in the project's tests, in its language. |
| `fzf_utils#rg#scope#grep(label [, pattern])` | Live grep in the scope `label`. |
| `fzf_utils#rg#scope#list()` | `[label, rg-args]` pairs: `all`, then the project's scopes. |
| `fzf_utils#rg#scope#args(scope)` | The rg arguments for one of `project_detect#scopes()`. |
| `fzf_utils#rg#live_grep#word_pattern()` | The word under the cursor, or the visual selection, as a pattern: regex characters escaped, wrapped in `\b`. |

The project is looked up when they are called, so mappings work in any
project:

```vim
nnoremap <leader>rp <Cmd>call fzf_utils#rg#scope#code()<CR>
nnoremap <leader>rt <Cmd>call fzf_utils#rg#scope#tests()<CR>
```

Where the project has no such scope, they print
`Grep: no scope "<label>" in this project`.

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
Plug 'roumail/project-detect'  " for project scopes
```
