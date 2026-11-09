" Hidden files are listed and symlinks followed; .git and __pycache__ never
" are. Every option is spelled out and the global ignore file
" (~/.config/fd/ignore) is skipped, so the result doesn't depend on per-user fd
" setup. Must list the same files grep.vim searches.
let s:fd_base = 'fd --strip-cwd-prefix --hidden --follow'
      \ . ' --no-global-ignore-file --exclude .git --exclude __pycache__'

function! s:fd_cmd(type) abort
  let l:cmd = s:fd_base . ' --type ' . a:type
  if get(g:, 'fzf_utils_include_ignored', 0)
    " --exclude still applies with --no-ignore
    let l:cmd .= ' --no-ignore'
  endif
  return l:cmd
endfunction

function! fzf_utils#files#options() abort
  return {'source': s:fd_cmd('f')}
endfunction

" The directories, by the same rules (for <C-x><C-d>)
function! fzf_utils#files#dirs_command() abort
  return s:fd_cmd('d')
endfunction
