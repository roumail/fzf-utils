function! fzf_utils#pick_files(dir, callback) abort
  let l:dir = fnamemodify(expand(a:dir), ':p')
  let l:spec = fzf#vim#with_preview(extend(fzf_utils#fd#files#options(), {
        \ 'dir': l:dir,
        \ 'options': ['--multi', '--prompt', fnamemodify(l:dir, ':~') . ' '],
        \ }))
  let l:spec['sink*'] = {lines -> a:callback(map(filter(copy(lines), '!empty(v:val)'),
        \ {_, f -> fnamemodify(l:dir . f, ':p')}))}
  " fzf runs in a terminal: the callback comes after this returns
  call fzf#run(fzf#wrap('fzf-utils-pick', l:spec))
endfunction
