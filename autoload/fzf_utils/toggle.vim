" Unified ignore toggle for both rg and fd
" g:fzf_include_ignored:
"   1 = search in ignored files (rg -u, fd -I)
"   0 = respect .gitignore (default)
function! fzf_utils#toggle#is_ignored_included() abort
  return get(g:, 'fzf_include_ignored', 0)
endfunction

" Flip g:fzf_include_ignored. rg reads it on every search; companions that
" cache a command (fd) rebuild it on the FzfUtilsIgnoredToggled event
function! fzf_utils#toggle#toggle_ignored() abort
  let g:fzf_include_ignored = !get(g:, 'fzf_include_ignored', 0)
  if exists('#User#FzfUtilsIgnoredToggled')
    doautocmd <nomodeline> User FzfUtilsIgnoredToggled
  endif
  echo 'FZF include ignored: ' . (g:fzf_include_ignored ? 'on' : 'off')
endfunction
