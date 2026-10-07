" fzf-utils: the ignore toggle shared by fd (plugin/fzf_utils_fd.vim) and
" fzf-utils-rg, and fzf.vim's Files/Buffers with a preview.
" Requires junegunn/fzf and junegunn/fzf.vim.
if exists('g:loaded_fzf_utils')
  finish
endif
let g:loaded_fzf_utils = 1

" Single toggle for both rg and fd
command! FzfToggleIgnored call fzf_utils#toggle#toggle_ignored()

" Similar to default FZF command, however FZF doesn't give preview
" https://github.com/junegunn/fzf.vim?tab=readme-ov-file#example-customizing-files-command
command! -bang -nargs=* Files
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* Buffers
      \ call fzf#vim#buffers(fzf#vim#with_preview(), <bang>0)
