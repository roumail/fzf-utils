function! s:buf_label(b) abort
  let l:name = fnamemodify(bufname(a:b), ':t')
  return empty(l:name) ? '[No Name]' : l:name
endfunction

function! s:list_tabs() abort
  return map(range(1, tabpagenr('$')), {_, nr ->
        \ nr . "\t" . join(map(tabpagebuflist(nr), {_, b -> s:buf_label(b)}), ', ')})
endfunction

function! s:close_tabs(lines) abort
  let l:nrs = map(copy(a:lines), {_, l -> str2nr(split(l, "\t")[0])})
  if len(l:nrs) == tabpagenr('$')
    " Vim keeps one tab: an empty one
    $tabnew
  endif
  let l:left = 0
  " Highest first, so closing one doesn't renumber those still to close
  for nr in reverse(sort(l:nrs, 'n'))
    try
      execute 'tabclose' nr
    catch
      " A file changed and not written
      let l:left += 1
    endtry
  endfor
  if l:left
    echohl ErrorMsg
    echomsg 'fzf-utils: ' . l:left . ' tab(s) left open: unsaved changes'
    echohl None
  endif
endfunction

function! fzf_utils#common#tabs#close() abort
  call fzf#run(fzf#wrap({
        \ 'source': s:list_tabs(),
        \ 'sink*': { lines -> s:close_tabs(lines) },
        \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
        \ }))
endfunction
