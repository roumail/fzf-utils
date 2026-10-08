# fzf-utils

Small additions to [fzf.vim](https://github.com/junegunn/fzf.vim) for finding files.

- `:FzfToggleIgnored` flips `g:fzf_utils_include_ignored` (see below).
- `:Files[!]`, `:Buffers[!]`: fzf.vim's commands with a preview window.
- `:BD`: pick buffers to wipe out (`<Tab>` marks several, `ctrl-a` takes all).
- `:Files` lists files with [fd](https://github.com/sharkdp/fd) when it is
  installed. Nothing global changes: `$FZF_DEFAULT_COMMAND` is left alone, so
  other fzf commands and your shell keep their own source. Without fd, `:Files`
  uses fzf's default source and doesn't follow `g:fzf_utils_include_ignored`.

## Shared option: `g:fzf_utils_include_ignored`

Read on every search by `:Files` here and by `:Grep` / `:Rg` in
[fzf-utils-rg](https://github.com/roumail/fzf-utils-rg), so one
`:FzfToggleIgnored` covers file and content searches. Both plugins search the
same files:

| Value | Searched |
| --- | --- |
| `0` (default) | Files not excluded by `.gitignore`, `.ignore` and git's global excludes, hidden files included. |
| `1` | Also ignored files. |

`.git` is never searched. fd also honours `.fdignore` and rg `.rgignore`. The
fd and rg commands spell out every option and skip per-user configuration
(`~/.config/fd/ignore`, `$RIPGREP_CONFIG_PATH`), so your shell setup doesn't
change the result.

Set it in a project's local config to start with ignored files included, e.g.
inside a `.venv`:

```vim
let g:fzf_utils_include_ignored = 1
```

## Install

Requires [fzf](https://github.com/junegunn/fzf) and fzf.vim; `fd` is optional.
If a required plugin is missing, Vim shows
`fzf-utils: not loaded, requires …` at startup and the plugin defines nothing.

```vim
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'roumail/fzf-utils'
```
