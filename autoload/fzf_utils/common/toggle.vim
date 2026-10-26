" g:fzf_utils_include_ignored: see README
function! fzf_utils#common#toggle#toggle_ignored() abort
  let g:fzf_utils_include_ignored = !get(g:, 'fzf_utils_include_ignored', 0)
  echo 'fzf-utils include ignored: ' . (g:fzf_utils_include_ignored ? 'on' : 'off')
endfunction
