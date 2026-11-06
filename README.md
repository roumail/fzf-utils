# fzf-utils

Additions to [fzf.vim](https://github.com/junegunn/fzf.vim): finding files with
[fd](https://github.com/sharkdp/fd), live and static
[ripgrep](https://github.com/BurntSushi/ripgrep) searches, and picking buffers
to wipe out.

| Command | `<Plug>` mapping | Needs | What it does |
| --- | --- | --- | --- |
| `:FdFiles[!] [dir]` | `<Plug>(fzf-utils-files)` | fd | Find files: fzf.vim's `:Files`, listing with fd. |
| `:Grep[!] [pattern] [-- rg-options/paths]` | `<Plug>(fzf-utils-grep)` | rg | Live grep: ripgrep re-runs as you type. `C-r` regex, `C-f` fixed string, `C-w` word. After `--`, `<Tab>` completes directories, with the `/` that makes them paths. |
| | `<Plug>(fzf-utils-grep-word)` | rg | `:Grep` for the word under the cursor, or the visual selection (n, x). |
| | `<Plug>(fzf-utils-grep-dir)` | rg | `:Grep` in the current buffer's directory. |
| | `<Plug>(fzf-utils-grep-replay)` | rg | Replay the last live grep with its last query. |
| `:GrepScope [pattern]` | `<Plug>(fzf-utils-grep-scope)` | rg | Pick a scope of the current project ([Project scopes](#project-scopes)), then `:Grep` in it. Without a project, a plain `:Grep`. |
| | `<Plug>(fzf-utils-grep-scope-word)` | rg | `:GrepScope` for the word under the cursor, or the visual selection (n, x). |
| | `<Plug>(fzf-utils-grep-code)`, `<Plug>(fzf-utils-grep-code-word)` | rg | `:Grep` in the project's code, in its language; `-word` for the word under the cursor or the visual selection (n, x). |
| | `<Plug>(fzf-utils-grep-tests)`, `<Plug>(fzf-utils-grep-tests-word)` | rg | The same in the project's tests. |
| `:RgRaw[!] <rg args>` | | rg | Static grep: ripgrep runs once with your arguments as given (`:RgRaw -g "*.vim" foo src/`), fzf filters the result. |
| `:FzfToggleIgnored` | | | Include or leave out ignored files in `:FdFiles`, `:Grep` and `:RgRaw`. |
| `:BD` | | | Pick buffers to wipe out (`<Tab>` marks several, `ctrl-a` takes all). |
| `:TD` | | | Pick tabs to close (`<Tab>` marks several, `ctrl-a` takes all). |

Commands and mappings that need fd or rg are defined when that tool is
installed. `:Grep` and `:RgRaw` save the accepted query to the search register
and `:History/`.

Bind the `<Plug>` mappings to keys of your choice. For example, `<leader>r`
then where to search, uppercase for the word under the cursor:

```vim
nmap <leader><leader> <Plug>(fzf-utils-files)
nmap <leader>r/ <Plug>(fzf-utils-grep)
nmap <leader>r? <Plug>(fzf-utils-grep-word)
nmap <leader>rp <Plug>(fzf-utils-grep-code)
nmap <leader>rP <Plug>(fzf-utils-grep-code-word)
nmap <leader>r. <Plug>(fzf-utils-grep-dir)
nmap <leader>rr <Plug>(fzf-utils-grep-replay)
nmap <leader>rs <Plug>(fzf-utils-grep-scope)
nnoremap <leader>r: :Grep
```

For other plugins, `fzf_utils#pick_files(dir, callback)` picks files under
`dir` the same way (`<Tab>` marks several) and calls `callback` with their
absolute paths once the pick is done, e.g. for
[vim-prompts](https://github.com/roumail/vim-prompts):

```vim
let g:prompts_file_picker = 'fzf_utils#pick_files'
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
`project go`, `tests` and `tests go`. A Vim plugin has `project`,
`project vim`, `tests` and `tests vim`.

| Function | What it does |
| --- | --- |
| `fzf_utils#grep_scope_pick([pattern])` | `:GrepScope`: pick a scope in fzf, then live grep in it. |
| `fzf_utils#grep_code([pattern])` | Live grep in the project's code, in its language. |
| `fzf_utils#grep_tests([pattern])` | Live grep in the project's tests, in its language. |
| `fzf_utils#grep_scope(label [, pattern])` | Live grep in the scope `label`. |
| `fzf_utils#grep_scopes()` | `[label, rg-args]` pairs: `all`, then the project's scopes. |
| `fzf_utils#grep_scope_args(scope)` | The rg arguments for a scope: `{'root': …, 'places': …, 'language': …}`, with `places` directories (trailing `/`) and file globs relative to `root`, `[]` for all of it, and `language` an rg type or `''`. |
| `fzf_utils#word_pattern()` | The word under the cursor, or the visual selection, as a pattern: regex characters escaped, wrapped in `\b`. |

The project is looked up when they are called, so mappings work in any
project. Where the project has no such scope, they print
`Grep: no scope "<label>" in this project`.

## Install

Requires [fzf](https://github.com/junegunn/fzf) and fzf.vim. `:FdFiles` also
requires `fd`; `:Grep`, `:RgRaw` and the grep mappings require `rg`.

```vim
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'roumail/fzf-utils'
Plug 'roumail/project-detect'  " for project scopes
```
