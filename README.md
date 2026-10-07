# fzf-utils

Small additions to [fzf.vim](https://github.com/junegunn/fzf.vim) for finding files.

- `:FzfToggleIgnored` flips `g:fzf_include_ignored` (default `0`: skip ignored files)
  and fires `User FzfUtilsIgnoredToggled`.
- `:Files[!]`, `:Buffers[!]`: fzf.vim's commands with a preview window.
- `:BD`: pick buffers to wipe out (`<Tab>` marks several, `ctrl-a` takes all).
- `:Files` lists files with [fd](https://github.com/sharkdp/fd) when it is
  installed (excluding `.git` and `__pycache__`; `-I` while ignored files are
  included). Nothing global changes: `$FZF_DEFAULT_COMMAND` is left alone, so
  other fzf commands and your shell keep their own source. Without fd, `:Files`
  uses fzf's default.

[fzf-utils-rg](https://github.com/roumail/fzf-utils-rg) reads the same
`g:fzf_include_ignored`, so one `:FzfToggleIgnored` covers both file and content
searches when both are installed.

## Install

Requires [fzf](https://github.com/junegunn/fzf) and fzf.vim; `fd` is optional.

```vim
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'roumail/fzf-utils'
```
