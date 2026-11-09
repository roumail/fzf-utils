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

Optional: [project-detect](https://github.com/vimoured/project-detect) lets you
search just a project's code or tests. It adds the choices in `:GrepScope` and
makes the mappings in [Searching part of a project](#searching-part-of-a-project)
work:

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
imap <c-x><c-f> <Plug>(fzf-utils-complete-path)
imap <c-x><c-d> <Plug>(fzf-utils-complete-dir)
imap <c-x><c-l> <Plug>(fzf-utils-complete-line)
```

### Searching part of a project

These need project-detect:

| Mapping | Searches |
| --- | --- |
| `<Plug>(fzf-utils-grep-scope)` | The part you pick, the same as `:GrepScope`: everything, the project's code, its tests, or either of those in one of the project's languages only. |
| `<Plug>(fzf-utils-grep-code)` | The project's code, in the current file's language. |
| `<Plug>(fzf-utils-grep-tests)` | The project's tests, in the current file's language. |

Add `-word` to any of them, as in `<Plug>(fzf-utils-grep-code-word)`, to start
the search already filled in. In normal mode it searches for the word under the
cursor, and in visual mode for the selection, matching whole words only.

```vim
nmap <leader>rs <Plug>(fzf-utils-grep-scope)
nmap <leader>rp <Plug>(fzf-utils-grep-code)
nmap <leader>rt <Plug>(fzf-utils-grep-tests)
nmap <leader>rP <Plug>(fzf-utils-grep-code-word)
xmap <leader>rP <Plug>(fzf-utils-grep-code-word)
```

Without project-detect, or outside a project, `<Plug>(fzf-utils-grep-scope)` is a
plain `:Grep`, and the code and tests mappings say there's nothing to search.

### Completion

Path completion can insert several files: mark them with `<Tab>`, and they go in
on one line with a space between them.

If the path you're completing starts with `@`, each file keeps that `@`, the form
[vim-prompts](https://github.com/vimoured/vim-prompts)' `@files` expects:

```text
@src/a.py @tests/b.py
```

## Configuration

### Completion sources

Completion uses the same settings as the shell's fzf keys:

| Completion | Lists | Preview |
| --- | --- | --- |
| Path | `$FZF_CTRL_T_COMMAND` | `$FZF_CTRL_T_OPTS` |
| Directory | `$FZF_ALT_C_COMMAND` | `$FZF_ALT_C_OPTS` |

When a command isn't set, path completion lists what `:FdFiles` does, and
directory completion lists its directories.

### Ignored files

`:FzfToggleIgnored` adds `--no-ignore` to every listing and search, including
completion. To include ignored files from the start in one project, set this in
its local config:

```vim
let g:fzf_utils_include_ignored = 1
```

## Tests

The specs in [vim-suite](https://github.com/vimoured/vim-suite) define what it
does: `test/fzf-utils.vim`, `test/fzf-utils-outside-a-project.vim` and
`test/fzf-utils-project-without-tests.vim`.
