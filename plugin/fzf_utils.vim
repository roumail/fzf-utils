" fzf-utils: the ignore toggle shared with fzf-utils-rg, :FdFiles (fzf.vim's
" :Files listing with fd) and :BD.
" Requires junegunn/fzf and junegunn/fzf.vim; fd is optional.
if exists('g:loaded_fzf_utils')
  finish
endif
let g:loaded_fzf_utils = 1

" Required plugins are checked once every plugin has loaded (VimEnter, or now
" when loaded later): their g:loaded_* guards tell whether they are installed.
" Without them nothing below is defined.
function! s:init() abort
  let l:missing = filter({
        \ 'junegunn/fzf': 'g:loaded_fzf',
        \ 'junegunn/fzf.vim': 'g:loaded_fzf_vim',
        \ }, '!exists(v:val)')
  if !empty(l:missing)
    echohl WarningMsg
    echomsg 'fzf-utils: not loaded, requires ' . join(sort(keys(l:missing)), ', ')
    echohl None
    return
  endif

  " Flips g:fzf_utils_include_ignored, shared with fzf-utils-rg (see README)
  command! FzfToggleIgnored call fzf_utils#toggle#toggle_ignored()

  " fzf.vim's :Files, listing files with fd (following :FzfToggleIgnored) when
  " it is installed. Own name, so fzf.vim's commands are left alone.
  " https://github.com/junegunn/fzf.vim?tab=readme-ov-file#example-customizing-files-command
  command! -bang -nargs=? -complete=dir FdFiles
        \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(fzf_utils#fd#options()), <bang>0)

  " <Plug> mapping; no keys are bound here (see README)
  nnoremap <silent> <Plug>(fzf-utils-files) <Cmd>FdFiles<CR>

  " Pick buffers to wipe out (<Tab> marks several, ctrl-a takes them all)
  command! BD call fzf_utils#buffers#delete()
endfunction

if v:vim_did_enter
  call s:init()
else
  augroup fzf_utils_init
    autocmd!
    autocmd VimEnter * ++once call s:init()
  augroup END
endif
