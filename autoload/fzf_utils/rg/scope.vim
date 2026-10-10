" Live grep within the scopes of the current project, from project-detect
" (project_detect#scopes()).

" rg arguments for a project-detect scope, as :Grep takes them after '--'.
" Directories are search paths. With file globs, everything becomes a -g glob
" over the root, since rg combines several -g globs as alternatives. A
" directory glob is matched relative to the working directory, so it is
" anchored only when the working directory is the root.
function! fzf_utils#rg#scope#args(scope) abort
  let l:root = a:scope.root
  let l:dirs = filter(copy(a:scope.places), 'v:val =~# "/$"')
  let l:globs = filter(copy(a:scope.places), 'v:val !~# "/$"')
  let l:at_root = l:root ==# getcwd()

  if empty(l:globs)
    let l:paths = empty(l:dirs) ? (l:at_root ? [] : ['']) : l:dirs
    let l:args = map(l:paths, 's:path(l:root, v:val)')
  else
    let l:args = l:at_root ? [] : [s:path(l:root, '')]
    let l:globs = map(l:dirs, 'l:at_root ? v:val . "**" : "**/" . v:val . "**"') + l:globs
    " :Grep passes flags to the shell as they are: quote the glob
    let l:args += map(l:globs, '"-g" . shellescape(v:val)')
  endif

  if !empty(a:scope.language)
    call add(l:args, '-t' . a:scope.language)
  endif
  return l:args
endfunction

" a:dir of a:root as a search path, relative to the working directory where
" possible, with a trailing '/'
function! s:path(root, dir) abort
  let l:path = fnamemodify(a:root . '/' . a:dir, ':.')
  " The working directory itself is ''
  return empty(l:path) ? './' : l:path =~# '/$' ? l:path : l:path . '/'
endfunction

" [label, rg-args] pairs: 'all' (the working directory), then the project's
" scopes. A scope that searches the same files as an earlier one is left out.
function! fzf_utils#rg#scope#list() abort
  let l:list = [['all', []]]
  if !exists('g:loaded_project_detect')
    return l:list
  endif
  let l:seen = [[]]
  for l:scope in project_detect#scopes()
    let l:args = fzf_utils#rg#scope#args(l:scope)
    if index(l:seen, l:args) < 0
      call add(l:list, [l:scope.label, l:args])
      call add(l:seen, l:args)
    endif
  endfor
  return l:list
endfunction

" Live grep in the scope a:label, optionally starting with a pattern.
" The scope is looked up now, so mappings can be made before the project is
" known.
function! fzf_utils#rg#scope#grep(label, ...) abort
  for [l:label, l:args] in fzf_utils#rg#scope#list()
    if l:label ==# a:label
      call call('fzf_utils#rg#live_grep#window', (a:0 && !empty(a:1) ? [a:1] : []) + ['--'] + l:args)
      return
    endif
  endfor
  echo 'Grep: no scope "' . a:label . '" in this project'
endfunction

" :GrepScope: pick a scope in fzf, then live grep in it, optionally starting
" with a pattern. With no project it is a plain :Grep.
function! fzf_utils#rg#scope#pick(...) abort
  let l:pattern = a:0 ? a:1 : ''
  let l:labels = map(fzf_utils#rg#scope#list(), 'v:val[0]')
  if len(l:labels) == 1
    call call('fzf_utils#rg#live_grep#window', a:0 ? [a:1] : [])
    return
  endif
  call fzf#run(fzf#wrap({
        \ 'source': l:labels,
        \ 'sink': {label -> fzf_utils#rg#scope#grep(label, l:pattern)},
        \ }))
endfunction

" Live grep in the project's code / tests, limited to its language, optionally
" starting with a pattern
function! fzf_utils#rg#scope#code(...) abort
  call call('fzf_utils#rg#scope#grep', [s:label('project')] + a:000)
endfunction

function! fzf_utils#rg#scope#tests(...) abort
  call call('fzf_utils#rg#scope#grep', [s:label('tests')] + a:000)
endfunction

" 'project python' for a:part 'project' in a Python project
function! s:label(part) abort
  let l:language = exists('g:loaded_project_detect') ? project_detect#language() : ''
  return empty(l:language) ? a:part : a:part . ' ' . l:language
endfunction

" For the gw / gW mappings: in a buffer of the project's language, grep the
" project's code / tests (a:part) for the word under the cursor or the
" selection. Anywhere else a:key, Vim's own command.
function! fzf_utils#rg#scope#word_key(part, key) abort
  if !exists('g:loaded_project_detect') || empty(&filetype)
        \ || &filetype !=# project_detect#language()
    return a:key
  endif
  return printf("\<Cmd>call fzf_utils#rg#scope#%s(fzf_utils#rg#live_grep#word_pattern())\<CR>", a:part)
endfunction
