" Insert-mode completion through fzf, for <expr> mappings (see README).
"
" fzf runs in a terminal window, and the command-line window (q:, q/, <C-f>
" on the command line) forbids opening one (E11). There Vim's own completion
" is used where it has one, as its popup menu works in that window.

function! s:in_cmdwin() abort
  return getcmdwintype() !=# ''
endfunction

" The listing the shell's fzf uses, from fzf's own variable, following
" :FzfToggleIgnored; a:default when the variable isn't set
function! s:shell_listing(variable, default) abort
  let l:command = getenv(a:variable)
  if empty(l:command)
    return a:default
  endif
  return l:command . (get(g:, 'fzf_utils_include_ignored', 0) ? ' --no-ignore' : '')
endfunction

" The prefix is \f, read with 'isfname': fzf.vim's own reading takes its @
" (letters) for a literal @, so @file would search for @file.
function! s:path(listing, spec) abort
  return fzf#vim#complete#path(a:listing, fzf#wrap(extend({'prefix': '\f*$'}, a:spec)))
endfunction

" The files Ctrl-T lists in the shell, for the file name before the cursor
function! fzf_utils#complete#path() abort
  if s:in_cmdwin()
    return "\<C-x>\<C-f>"
  endif
  let l:separator = strpart(getline('.'), 0, col('.') - 1) =~# '@\f*$' ? ' @' : ' '
  return s:path(s:shell_listing('FZF_CTRL_T_COMMAND', fzf_utils#grep#files_command()), {
        \ 'options': '--multi ' . $FZF_CTRL_T_OPTS,
        \ 'reducer': {lines -> join(lines, l:separator)},
        \ })
endfunction

" The directories Alt-C lists in the shell, for the name before the cursor
function! fzf_utils#complete#dir() abort
  if s:in_cmdwin()
    return "\<C-x>\<C-f>"
  endif
  return s:path(s:shell_listing('FZF_ALT_C_COMMAND', fzf_utils#files#dirs_command()), {
        \ 'options': '--no-multi ' . $FZF_ALT_C_OPTS,
        \ })
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
