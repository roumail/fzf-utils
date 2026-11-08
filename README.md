# fzf-utils

Additions to [fzf.vim](https://github.com/junegunn/fzf.vim): find files with
[fd](https://github.com/sharkdp/fd), search live or once with
[ripgrep](https://github.com/BurntSushi/ripgrep), and pick buffers or tabs to
close.

**Vim or Neovim:** Vim only, tested on 9.1 and newer. It calls a Vim-only
function (`popup_notification()`), so it doesn't work on Neovim.

## Install

Needs [fzf](https://github.com/junegunn/fzf) and fzf.vim. File finding needs
`fd`, and searching needs `rg`; their commands and mappings are defined when
those tools are installed.

```vim
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'vimoured/fzf-utils'
```

Add [project-detect](https://github.com/vimoured/project-detect) to search just
a project's code or tests:

```vim
Plug 'vimoured/project-detect'
```

## Use

| Command | What it does |
| --- | --- |
| `:FdFiles[!] [dir]` | Find files. |
| `:Grep[!] [pattern] [-- rg-options/paths]` | Live search: ripgrep reruns as you type. |
| `:GrepScope [pattern]` | Pick a part of the project, then `:Grep` in it. |
| `:RgRaw[!] <rg args>` | Run ripgrep once with your arguments and filter the result. |
| `:FzfToggleIgnored` | Include or leave out ignored files, for every listing and search. |
| `:BD` | Pick buffers to wipe out. |
| `:TD` | Pick tabs to close. |

Bind the `<Plug>` mappings you want:

```vim
nmap <leader><leader> <Plug>(fzf-utils-files)
nmap <leader>r/ <Plug>(fzf-utils-grep)
nmap <leader>r? <Plug>(fzf-utils-grep-word)
xmap <leader>r? <Plug>(fzf-utils-grep-word)
nmap <leader>r. <Plug>(fzf-utils-grep-dir)
nmap <leader>rr <Plug>(fzf-utils-grep-replay)
nmap <leader>rs <Plug>(fzf-utils-grep-scope)
nmap <leader>rp <Plug>(fzf-utils-grep-code)
nmap <leader>rt <Plug>(fzf-utils-grep-tests)
imap <c-x><c-f> <Plug>(fzf-utils-complete-path)
imap <c-x><c-l> <Plug>(fzf-utils-complete-line)
```

`-word` variants of the scope, code and tests mappings search for the word under
the cursor or the selection.

To include ignored files from the start in one project, set
`let g:fzf_utils_include_ignored = 1` in its local config.

## Tests

The specs in [vim-suite](https://github.com/vimoured/vim-suite) define what it
does: `test/fzf-utils.vim`, `test/fzf-utils-outside-a-project.vim` and
`test/fzf-utils-project-without-tests.vim`.
