" fzf-utils: the ignore toggle shared with fzf-utils-rg, :FdFiles (fzf.vim's
" :Files listing with fd) and :BD.
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

" Flips g:fzf_utils_include_ignored, shared with fzf-utils-rg (see README)
command! FzfToggleIgnored call fzf_utils#toggle#toggle_ignored()

" fzf.vim's :Files, listing files with fd (following :FzfToggleIgnored) when it
" is installed. Own name, so fzf.vim's commands are left alone.
" https://github.com/junegunn/fzf.vim?tab=readme-ov-file#example-customizing-files-command
command! -bang -nargs=? -complete=dir FdFiles
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(fzf_utils#fd#options()), <bang>0)

" <Plug> mapping; no keys are bound here (see README)
nnoremap <silent> <Plug>(fzf-utils-files) <Cmd>FdFiles<CR>

" Pick buffers to wipe out (<Tab> marks several, ctrl-a takes them all)
command! BD call fzf_utils#buffers#delete()
