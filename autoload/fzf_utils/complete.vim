" Insert-mode completion through fzf, for <expr> mappings (see README).
"
" fzf runs in a terminal window, and the command-line window (q:, q/, <C-f>
" on the command line) forbids opening one (E11). There Vim's own completion
" is used where it has one, as its popup menu works in that window.

function! s:in_cmdwin() abort
  return getcmdwintype() !=# ''
endfunction

" The files :FdFiles lists, for the file name before the cursor. The prefix is
" \f, read with 'isfname': fzf.vim's own reading takes its @ (letters) for a
" literal @, so @file would search for @file.
function! fzf_utils#complete#path() abort
  if s:in_cmdwin()
    return "\<C-x>\<C-f>"
  endif
  let l:separator = strpart(getline('.'), 0, col('.') - 1) =~# '@\f*$' ? ' @' : ' '
  return fzf#vim#complete#path(fzf_utils#grep#files_command(), fzf#wrap({
        \ 'prefix': '\f*$',
        \ 'options': ['--multi'],
        \ 'reducer': {lines -> join(lines, l:separator)},
        \ }))
endfunction

" Lines of the open buffers
function! fzf_utils#complete#line() abort
  if s:in_cmdwin()
    return "\<C-x>\<C-l>"
  endif
  return fzf#vim#complete#line()
endfunction

" In Insert mode the mode message draws over anything echoed, so the warning
" is a popup (allowed in the command-line window), and kept in :messages
function! s:warn_cmdwin() abort
  let msg = 'fzf completion is not available in the command-line window'
  echomsg msg
  call popup_notification(msg, {'highlight': 'WarningMsg', 'line': &lines - 2})
endfunction

" fzf#vim#complete() with the spec a:Spec() returns (a Funcref or function
" name, called only when fzf can run). In the command-line window, where Vim
" has nothing to fall back on, it says so and types nothing.
function! fzf_utils#complete#with(Spec) abort
  if s:in_cmdwin()
    call s:warn_cmdwin()
    return ''
  endif
  return fzf#vim#complete(call(a:Spec, []))
endfunction
