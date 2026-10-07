let s:fd_base = 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git -E "**/__pycache__/**"'

function! s:fd_cmd() abort
  let l:cmd = s:fd_base
  if get(g:, 'fzf_include_ignored', 0)
    " -I = don't respect ignore files, -E still allows explicit excludes
    let l:cmd .= ' -I'
  endif
  return l:cmd
endfunction

function! fzf_utils#fd#update_default_fd_command() abort
  let $FZF_DEFAULT_COMMAND = s:fd_cmd()
endfunction

