" Hidden files are listed, .git never is. Every option is spelled out and the
" global ignore file (~/.config/fd/ignore) is skipped, so the result doesn't
" depend on per-user fd setup. Must list the same files fzf-utils-rg searches.
let s:fd_base = 'fd --type f --strip-cwd-prefix --hidden --follow'
      \ . ' --no-global-ignore-file --exclude .git -E "**/__pycache__/**"'

function! s:fd_cmd() abort
  let l:cmd = s:fd_base
  if get(g:, 'fzf_utils_include_ignored', 0)
    " --exclude still applies with --no-ignore
    let l:cmd .= ' --no-ignore'
  endif
  return l:cmd
endfunction

" fzf options that make fd the file source, following the ignore toggle. Empty
" when fd is not installed, so fzf falls back to its default source. Nothing
" global is changed: $FZF_DEFAULT_COMMAND is left alone.
function! fzf_utils#fd#options() abort
  return executable('fd') ? {'source': s:fd_cmd()} : {}
endfunction
