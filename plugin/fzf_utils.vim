" fzf-utils: the ignore toggle shared with fzf-utils-rg, and fzf.vim's
" Files/Buffers with a preview, Files listing with fd.
" Requires junegunn/fzf and junegunn/fzf.vim; fd is optional.
if exists('g:loaded_fzf_utils')
  finish
endif
" Required plugins: without them nothing here is defined
let s:missing = filter({
      \ 'junegunn/fzf.vim': 'autoload/fzf/vim.vim',
      \ }, 'empty(globpath(&rtp, v:val))')
if !empty(s:missing)
  echohl WarningMsg
  echomsg 'fzf-utils: not loaded, requires ' . join(sort(keys(s:missing)), ', ')
  echohl None
  finish
endif
unlet s:missing
let g:loaded_fzf_utils = 1

" Single toggle for both rg and fd
command! FzfToggleIgnored call fzf_utils#toggle#toggle_ignored()

" Similar to default FZF command, however FZF doesn't give preview
" https://github.com/junegunn/fzf.vim?tab=readme-ov-file#example-customizing-files-command
" Files are listed with fd (following :FzfToggleIgnored) when it is installed
command! -bang -nargs=* Files
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(fzf_utils#fd#options()), <bang>0)
command! -bang -nargs=* Buffers
      \ call fzf#vim#buffers(fzf#vim#with_preview(), <bang>0)

" Pick buffers to wipe out (<Tab> marks several, ctrl-a takes them all)
command! BD call fzf_utils#buffers#delete()
