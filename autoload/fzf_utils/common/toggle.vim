" g:fzf_utils_include_ignored (see README):
"   0 = respect ignore files (default)
"   1 = also search ignored files (fd --no-ignore, rg --no-ignore)
" :FdFiles, :Grep and :RgRaw read it on every search.
function! fzf_utils#common#toggle#toggle_ignored() abort
  let g:fzf_utils_include_ignored = !get(g:, 'fzf_utils_include_ignored', 0)
  echo 'fzf-utils include ignored: ' . (g:fzf_utils_include_ignored ? 'on' : 'off')
endfunction
