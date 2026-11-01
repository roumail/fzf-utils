function! fzf_utils#rg#scope#word_key(part, key) abort
  if !exists('g:loaded_fzf_vim') || !exists('g:loaded_project_detect') || empty(&filetype)
        \ || &filetype !=# project_detect#language()
    return a:key
  endif
  return printf("\<Cmd>call fzf_utils#grep_%s(fzf_utils#word_pattern())\<CR>", a:part)
endfunction
