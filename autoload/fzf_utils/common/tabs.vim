function! s:list_tabs() abort
  return map(range(1, tabpagenr('$')), {_, nr ->
        \ nr . "\t" . join(map(tabpagebuflist(nr), {_, b -> fnamemodify(bufname(b), ':t') ?: '[No Name]'}), ', ')})
endfunction

function! s:close_tabs(lines) abort
  " Highest first, so closing one doesn't renumber those still to close
  for nr in reverse(sort(map(copy(a:lines), {_, l -> str2nr(split(l, "\t")[0])}), 'n'))
    execute 'tabclose' nr
  endfor
endfunction

function! fzf_utils#common#tabs#close() abort
  call fzf#run(fzf#wrap({
        \ 'source': s:list_tabs(),
        \ 'sink*': { lines -> s:close_tabs(lines) },
        \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
        \ }))
endfunction
