" g:fzf_utils_include_ignored, shared with fzf-utils-rg (see README):
"   0 = respect ignore files (default)
"   1 = also search ignored files (fd --no-ignore, rg --no-ignore)
" :FdFiles and fzf-utils-rg's :Grep / :Rg read it on every search.
function! fzf_utils#toggle#toggle_ignored() abort
  let g:fzf_utils_include_ignored = !get(g:, 'fzf_utils_include_ignored', 0)
  echo 'fzf-utils include ignored: ' . (g:fzf_utils_include_ignored ? 'on' : 'off')
endfunction
