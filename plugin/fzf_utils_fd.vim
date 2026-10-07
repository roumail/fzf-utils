" fzf-utils: list files for fzf with fd, following the ignore toggle.
" Requires junegunn/fzf and fd. :FzfToggleIgnored is in plugin/fzf_utils.vim.
if exists('g:loaded_fzf_utils_fd')
  finish
endif
let g:loaded_fzf_utils_fd = 1

" Initialize FZF_DEFAULT_COMMAND if not set
if empty($FZF_DEFAULT_COMMAND)
  call fzf_utils#fd#update_default_fd_command()
endif

" Rebuild the fd command when :FzfToggleIgnored flips the shared toggle
augroup fzf_utils_fd
  autocmd!
  autocmd User FzfUtilsIgnoredToggled call fzf_utils#fd#update_default_fd_command()
augroup END
