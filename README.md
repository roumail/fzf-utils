# fzf-utils

Small additions to [fzf.vim](https://github.com/junegunn/fzf.vim) for finding files.

- `:FzfToggleIgnored` flips `g:fzf_include_ignored` (default `0`: skip ignored files)
  and fires `User FzfUtilsIgnoredToggled`.
- `:Files[!]`, `:Buffers[!]`: fzf.vim's commands with a preview window.
- Sets `$FZF_DEFAULT_COMMAND` to an [fd](https://github.com/sharkdp/fd) command
  unless it is already set, and rebuilds it when the ignore toggle flips.

[fzf-utils-rg](https://github.com/roumail/fzf-utils-rg) reads the same
`g:fzf_include_ignored`, so one `:FzfToggleIgnored` covers both file and content
searches when both are installed.

## Install

Requires [fzf](https://github.com/junegunn/fzf), fzf.vim and `fd`.

```vim
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'roumail/fzf-utils'
```
