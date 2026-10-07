let s:fd_base = 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git -E "**/__pycache__/**"'

function! s:fd_cmd() abort
  let l:cmd = s:fd_base
  if get(g:, 'fzf_include_ignored', 0)
    " -I = don't respect ignore files, -E still allows explicit excludes
    let l:cmd .= ' -I'
  endif
  return l:cmd
endfunction

" fzf options that make fd the file source, following the ignore toggle. Empty
" when fd is not installed, so fzf falls back to its default source. Nothing
" global is changed: $FZF_DEFAULT_COMMAND is left alone.
function! fzf_utils#fd#options() abort
  return executable('fd') ? {'source': s:fd_cmd()} : {}
endfunction

