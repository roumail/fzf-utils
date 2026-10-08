" Hidden files are searched and symlinks followed; .git and __pycache__ never
" are. --no-config ignores $RIPGREP_CONFIG_PATH, so the result doesn't depend
" on per-user rg setup. Must search the same files fd/files.vim lists.
let s:rg_base = 'rg --no-config --column --line-number --no-heading --color=always'
      \ . ' --smart-case --hidden --follow --glob=!.git --glob=!__pycache__'

function! s:rg_cmd() abort
  return s:rg_base . (get(g:, 'fzf_utils_include_ignored', 0) ? ' --no-ignore' : '')
endfunction

function! fzf_utils#rg#ripgrep#get_command() abort
  return s:rg_cmd()
endfunction

function! fzf_utils#rg#ripgrep#command_factory(extra_opts) abort
  " Don't escape - <f-args> already gave us properly parsed arguments
  let l:cmd = s:rg_cmd()
  if !empty(a:extra_opts)
    let l:cmd .= ' ' . join(a:extra_opts, ' ')
  endif
  return l:cmd
endfunction

function! fzf_utils#rg#ripgrep#mode(prefix, flag) abort
  return a:prefix . (empty(a:flag) ? '' : ' ' . a:flag) . ' -e'
endfunction
