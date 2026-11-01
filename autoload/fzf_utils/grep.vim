" Hidden files are searched and symlinks followed; .git and __pycache__ never
" are. --no-config ignores $RIPGREP_CONFIG_PATH, so the result doesn't depend
" on per-user rg setup. Must search the same files files.vim lists.
let s:rg_base = 'rg --no-config --column --line-number --no-heading --color=always'
      \ . ' --smart-case --hidden --follow --glob=!.git --glob=!__pycache__'

function! fzf_utils#grep#command() abort
  return s:rg_base . (get(g:, 'fzf_utils_include_ignored', 0) ? ' --no-ignore' : '')
endfunction

function! s:command_factory(extra_opts) abort
  " Don't escape - <f-args> already gave us properly parsed arguments
  let l:cmd = fzf_utils#grep#command()
  if !empty(a:extra_opts)
    let l:cmd .= ' ' . join(a:extra_opts, ' ')
  endif
  return l:cmd
endfunction

function! s:mode(prefix, flag) abort
  return a:prefix . (empty(a:flag) ? '' : ' ' . a:flag) . ' -e'
endfunction

let s:last_bang = 0
let s:last_args = []
let s:history_file = tempname()

function! fzf_utils#grep#replay() abort
  let l:query = getreg('/')

  let [l:pattern, l:options] = s:split_args(s:last_args)

  call call(
        \ 'fzf_utils#grep#interactive',
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

function! s:on_exit(code) abort
  " So that replay, n/N and :History/ see the accepted query
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

function! fzf_utils#grep#capture_query(spec) abort
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

function! s:parse_args(arg_list) abort
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


function! fzf_utils#grep#complete(lead, cmdline, pos) abort
  if a:cmdline[: a:pos - 1] !~# '\s--\s' || a:lead =~# '^-'
    return []
  endif
  " With their trailing /, which makes parse_args pass them as paths
  return getcompletion(a:lead, 'dir')
endfunction

function! fzf_utils#grep#interactive(bang, ...) abort
  let s:last_bang = a:bang
  let s:last_args = a:000

  let [l:options, l:pattern] = s:parse_args(a:000)

  let l:prefix = s:command_factory(l:options)

  let l:cmd_regex = s:mode(l:prefix, '')
  let l:cmd_fixed = s:mode(l:prefix, '-F')
  let l:cmd_word  = s:mode(l:prefix, '-w')

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
  call fzf_utils#grep#capture_query(l:preview_opts)

  " Start in regex mode; '-e' keeps the query from being read as a path or flag
  call fzf#vim#grep2(l:cmd_regex, l:pattern, l:preview_opts, a:bang)
endfunction

function! fzf_utils#grep#window(...) abort
  call call('fzf_utils#grep#interactive', [0] + a:000)
endfunction

function! fzf_utils#grep#word_key(part, key) abort
  if !exists('g:loaded_fzf_vim') || !exists('g:loaded_project_detect') || empty(&filetype)
        \ || &filetype !=# project_detect#language()
    return a:key
  endif
  return printf("\<Cmd>call fzf_utils#grep_%s(fzf_utils#word_pattern())\<CR>", a:part)
endfunction
