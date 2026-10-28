let s:last_bang = 0
let s:last_args = []
" fzf appends the accepted query here; read back in s:on_exit
let s:history_file = tempname()

function! fzf_utils#rg#live_grep#replay() abort
  " Populated by s:on_exit after each accepted live grep
  let l:query = getreg('/')

  let [l:pattern, l:options] = s:split_args(s:last_args)

  call call(
        \ 'fzf_utils#rg#live_grep#interactive',
        \ [s:last_bang, l:query, '--'] + l:options
        \ )
endfunction

function! s:split_args(arg_list) abort
  let sep = index(a:arg_list, '--')

  if sep == -1
    let pattern = join(a:arg_list, ' ')
    let options = []
  elseif sep == 0
    let pattern = ''
    let options = a:arg_list[1:]
  else
    let pattern = join(a:arg_list[:sep-1], ' ')
    let options = a:arg_list[sep+1:]
  endif
  return [pattern, options]
endfunction

" Copy the accepted fzf query into the search register and history so that
" replay, n/N and :History/ see it. Called by fzf before the sink opens the
" selected file.
function! s:on_exit(code) abort
  if a:code != 0 || !filereadable(s:history_file)
    return
  endif
  let l:lines = readfile(s:history_file)
  if empty(l:lines) || empty(l:lines[-1])
    return
  endif
  call setreg('/', l:lines[-1])
  call histadd('/', l:lines[-1])
endfunction

" Add query capture to an fzf.vim spec (e.g. from fzf#vim#with_preview).
function! fzf_utils#rg#live_grep#capture_query(spec) abort
  let l:opts = ['--history', s:history_file, '--history-size', '50',
        \ '--bind', 'ctrl-n:down']
  if type(get(a:spec, 'options', [])) == v:t_list
    let a:spec.options = get(a:spec, 'options', []) + l:opts
  else
    let a:spec.options .= ' ' . join(map(l:opts, 'fzf#shellescape(v:val)'))
  endif
  let a:spec.exit = function('s:on_exit')
  return a:spec
endfunction

function! fzf_utils#rg#live_grep#parse_args(arg_list) abort
  let [pattern, options] = s:split_args(a:arg_list)

  let rg_options = []

  for item in options
    if item =~ '/$' || item =~ '^\.\{0,2\}/'
      " Pass as an rg path argument; a -g glob can't express ./, ../ or
      " absolute paths. Safe because the query always follows -e.
      call add(rg_options, shellescape(item))
    else
      call add(rg_options, item)
    endif
  endfor

  return [rg_options, pattern]
endfunction


" :Grep's completion: directories after `--`, ending in / so parse_args passes
" them as paths; nothing for the pattern or for rg's flags
function! fzf_utils#rg#live_grep#complete(lead, cmdline, pos) abort
  if a:cmdline[: a:pos - 1] !~# '\s--\s' || a:lead =~# '^-'
    return []
  endif
  return getcompletion(a:lead, 'dir')
endfunction

function! fzf_utils#rg#live_grep#interactive(bang, ...) abort
  let s:last_bang = a:bang
  let s:last_args = a:000

  let [l:options, l:pattern] = fzf_utils#rg#live_grep#parse_args(a:000)

  let l:prefix = fzf_utils#rg#ripgrep#command_factory(l:options)

  let l:cmd_regex = fzf_utils#rg#ripgrep#mode(l:prefix, '')
  let l:cmd_fixed = fzf_utils#rg#ripgrep#mode(l:prefix, '-F')
  let l:cmd_word  = fzf_utils#rg#ripgrep#mode(l:prefix, '-w')

  let l:preview_opts = fzf#vim#with_preview({
        \ 'options': [
        \   '--delimiter', ':', '--nth', '4..', '--with-nth', '1,2',
        \   '--prompt', 'Regex> ',
        \   '--header', 'C-r (regex) | C-f (fixed) | C-w (word)',
        \   '--bind', 'ctrl-f:change-prompt(Fixed> )+reload(' . l:cmd_fixed . ' {q})',
        \   '--bind', 'ctrl-w:change-prompt(Word> )+reload(' . l:cmd_word  . ' {q})',
        \   '--bind', 'ctrl-r:change-prompt(Regex> )+reload(' . l:cmd_regex . ' {q})',
        \ ]
        \ }, 'right,70%,border-left,+{2}+4/3,~4', 'ctrl-p')
  call fzf_utils#rg#live_grep#capture_query(l:preview_opts)

  " Start in regex mode; '-e' keeps the query from being read as a path or flag
  call fzf#vim#grep2(l:cmd_regex, l:pattern, l:preview_opts, a:bang)
endfunction

function! fzf_utils#rg#live_grep#fullscreen(...) abort
  call call('fzf_utils#rg#live_grep#interactive', [1] + a:000)
endfunction

function! fzf_utils#rg#live_grep#window(...) abort
  call call('fzf_utils#rg#live_grep#interactive', [0] + a:000)
endfunction

" The selection in visual mode, else the word under the cursor, as a ripgrep
" regex with word boundaries. Regex characters in it are escaped, so it matches
" literally (live grep starts in regex mode).
function! fzf_utils#rg#live_grep#word_pattern() abort
  let l:mode = mode()
  if l:mode =~# "^[vV\<C-v>]"
    if exists('*getregion')
      let l:text = join(getregion(getpos('v'), getpos('.'), {'type': l:mode}), "\n")
    else
      let l:save = [getreg('"'), getregtype('"')]
      normal! y
      let l:text = getreg('"')
      call setreg('"', l:save[0], l:save[1])
    endif
    execute "normal! \<Esc>"
  else
    let l:text = expand('<cword>')
  endif
  return '\b' . escape(l:text, '\.^$*+?()[]{}|') . '\b'
endfunction
