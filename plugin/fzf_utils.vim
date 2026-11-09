function! s:init_common() abort
  " Flips g:fzf_utils_include_ignored, read by every file listing and search
  " (see README)
  command! FzfToggleIgnored call fzf_utils#ignored#toggle()

  " Pick buffers to wipe out (<Tab> marks several, ctrl-a takes them all)
  command! BD call fzf_utils#buffers#delete()

  " Pick tabs to close (<Tab> marks several, ctrl-a takes them all)
  command! TD call fzf_utils#tabs#close()

  " <Plug> mappings; no keys are bound here (see README)
  " Insert-mode line completion; Vim's own in the command-line window
  inoremap <expr> <Plug>(fzf-utils-complete-line) fzf_utils#complete#line()
endfunction

function! s:init_fd() abort
  " fzf.vim's :Files, listing files with fd (following :FzfToggleIgnored).
  " Own name, so fzf.vim's commands are left alone.
  " https://github.com/junegunn/fzf.vim?tab=readme-ov-file#example-customizing-files-command
  command! -bang -nargs=? -complete=dir FdFiles
        \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(fzf_utils#files#options()), <bang>0)

  " <Plug> mapping; no keys are bound here (see README)
  nnoremap <silent> <Plug>(fzf-utils-files) <Cmd>FdFiles<CR>
  " Insert-mode directory name completion; Vim's own file name completion in
  " the command-line window
  inoremap <expr> <Plug>(fzf-utils-complete-dir) fzf_utils#complete#dir()
endfunction

function! s:init_rg() abort
  " Grep: Live grep (updates search results as you type in fzf)
  "
  " Uses '--' to separate the search pattern from ripgrep options:
  "
  "   :Grep pattern -- -g "*.vim" -t python
  "
  " Three scenarios:
  "
  " 1. Pattern before '--', options after:
  "      :Grep error -- -g "*.log"
  "    → Initial pattern: "error", filtered to *.log files
  "
  " 2. No pattern, only options (starts with '--'):
  "      :Grep -- -g "*.vim"
  "    → No initial pattern, type in fzf, filtered to *.vim files
  "
  " 3. No '--' found:
  "      :Grep error code
  "    → Entire input treated as pattern: "error code"
  "
  " Path shortcuts:
  "   Paths ending with '/' or starting with './', '../', or '/'
  "   are passed to ripgrep as search paths:
  "      :Grep pattern -- src/ ../other/
  "
  " Mode switching (via keybinds in fzf):
  "   C-r: Regex mode (default)
  "   C-f: Fixed string mode
  "   C-w: Word boundary mode
  "
  " Bang modifier:
  "   :Grep!  → Fullscreen mode
  "   :Grep   → Normal mode (windowed)
  "
  " Examples:
  "   :Grep pattern
  "   :Grep pattern -- -g "*vim-rc*"
  "   :Grep pattern -- -g "!*.log" -t python
  "   :Grep -- -g "*.vim"
  "   :Grep error -- src/
  "   :Grep! pattern  " fullscreen
  " <Tab> after -- completes directories
  command! -bang -nargs=* -complete=customlist,fzf_utils#grep#complete Grep call fzf_utils#grep#interactive(<bang>0, <f-args>)

  " RgRaw: Static grep (runs ripgrep once, then fzf filters that fixed list)
  "
  " Arguments are passed directly to ripgrep as a raw string. Own name, so
  " fzf.vim's :Rg (whose input is a single pattern) is left alone.
  " This allows natural ripgrep syntax such as:
  "
  "   :RgRaw pattern
  "   :RgRaw -g "*vim-rc*" pattern
  "   :RgRaw -u -g "!log/" pattern path/to/dir
  "
  " Unlike Grep, this command does not re-run ripgrep while typing;
  " fzf only filters the fixed result set returned by the initial rg run.
  "
  " Bang modifier:
  "   :RgRaw!  → Fullscreen mode
  "   :RgRaw   → Normal mode (windowed)
  " https://github.com/junegunn/fzf.vim/issues/1533#issuecomment-2015075571
  command! -bang -nargs=* RgRaw call fzf#vim#grep(
        \ fzf_utils#grep#command() . " " . <q-args>,
        \ fzf_utils#grep#capture_query(fzf#vim#with_preview({
        \       'options': '--delimiter : --nth 4.. --preview-window +{2}-5,~3'
        \       }, 'right:50%', 'ctrl-p')),
        \ <bang>0)

  " GrepScope: pick a scope of the current project (project-detect) in fzf,
  " then live grep in it. Without a project it is a plain :Grep.
  "   :GrepScope
  "   :GrepScope pattern
  command! -nargs=? GrepScope call fzf_utils#grep_scope_pick(<f-args>)

  " <Plug> mappings; no keys are bound here (see README)
  " :GrepScope, and :GrepScope for the word under the cursor / the selection
  nnoremap <silent> <Plug>(fzf-utils-grep-scope) <Cmd>GrepScope<CR>
  nnoremap <silent> <Plug>(fzf-utils-grep-scope-word) <Cmd>call fzf_utils#grep_scope_pick(fzf_utils#word_pattern())<CR>
  xnoremap <silent> <Plug>(fzf-utils-grep-scope-word) <Cmd>call fzf_utils#grep_scope_pick(fzf_utils#word_pattern())<CR>
  " Replay the last live grep with its last query
  nnoremap <silent> <Plug>(fzf-utils-grep-replay) <Cmd>call fzf_utils#grep#replay()<CR>
  " Live grep in the current buffer's directory
  nnoremap <silent> <Plug>(fzf-utils-grep-dir) <Cmd>execute 'Grep -- ' . expand('%:.:h') . '/'<CR>
  " Live grep from the working directory
  nnoremap <silent> <Plug>(fzf-utils-grep) <Cmd>Grep<CR>
  " Insert-mode file name completion; Vim's own in the command-line window
  inoremap <expr> <Plug>(fzf-utils-complete-path) fzf_utils#complete#path()

  " Live grep from the working directory for the word under the cursor / the
  " selection
  nnoremap <silent> <Plug>(fzf-utils-grep-word) <Cmd>call fzf_utils#grep#window(fzf_utils#word_pattern())<CR>
  xnoremap <silent> <Plug>(fzf-utils-grep-word) <Cmd>call fzf_utils#grep#window(fzf_utils#word_pattern())<CR>
  " Live grep in the project's code / tests (project-detect), in its language;
  " -word for the word under the cursor / the selection
  nnoremap <silent> <Plug>(fzf-utils-grep-code) <Cmd>call fzf_utils#grep_code()<CR>
  nnoremap <silent> <Plug>(fzf-utils-grep-code-word) <Cmd>call fzf_utils#grep_code(fzf_utils#word_pattern())<CR>
  xnoremap <silent> <Plug>(fzf-utils-grep-code-word) <Cmd>call fzf_utils#grep_code(fzf_utils#word_pattern())<CR>
  nnoremap <silent> <Plug>(fzf-utils-grep-tests) <Cmd>call fzf_utils#grep_tests()<CR>
  nnoremap <silent> <Plug>(fzf-utils-grep-tests-word) <Cmd>call fzf_utils#grep_tests(fzf_utils#word_pattern())<CR>
  xnoremap <silent> <Plug>(fzf-utils-grep-tests-word) <Cmd>call fzf_utils#grep_tests(fzf_utils#word_pattern())<CR>
endfunction

call s:init_common()
if executable('fd')
  call s:init_fd()
endif
if executable('rg')
  call s:init_rg()
endif
