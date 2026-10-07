function! s:list_buffers() abort
  return split(execute('ls'), "\n")
endfunction

function! s:delete_buffers(lines) abort
  execute 'bwipeout' join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

function! fzf_utils#buffers#delete() abort
  call fzf#run(fzf#wrap({
        \ 'source': s:list_buffers(),
        \ 'sink*': { lines -> s:delete_buffers(lines) },
        \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
        \ }))
endfunction
