function! fzf_utils#rg#scope#args(scope) abort
  let l:root = a:scope.root
  let l:dirs = filter(copy(a:scope.places), 'v:val =~# "/$"')
  let l:globs = filter(copy(a:scope.places), 'v:val !~# "/$"')
  let l:at_root = l:root ==# getcwd()

  if empty(l:globs)
    let l:paths = empty(l:dirs) ? (l:at_root ? [] : ['']) : l:dirs
    let l:args = map(l:paths, 's:path(l:root, v:val)')
  else
    " rg takes several -g globs as alternatives, so the directories become globs
    " too. A glob is matched relative to the working directory: it can only be
    " anchored there.
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

function! s:path(root, dir) abort
  let l:path = fnamemodify(a:root . '/' . a:dir, ':.')
  " The working directory itself is ''
  return empty(l:path) ? './' : l:path =~# '/$' ? l:path : l:path . '/'
endfunction

function! fzf_utils#rg#scope#list() abort
  let l:list = [['all', []]]
  if !exists('g:loaded_project_detect') || empty(project_detect#active())
    return l:list
  endif
  let l:seen = [[]]
  for [l:part, l:places] in [['project', project_detect#sources()], ['tests', project_detect#tests()]]
    if l:part ==# 'tests' && empty(l:places)
      continue
    endif
    for l:language in uniq(['', project_detect#language()])
      let l:args = fzf_utils#rg#scope#args({'root': project_detect#root(), 'places': l:places, 'language': l:language})
      if index(l:seen, l:args) < 0
        call add(l:list, [empty(l:language) ? l:part : s:label(l:part), l:args])
        call add(l:seen, l:args)
      endif
    endfor
  endfor
  return l:list
endfunction

function! fzf_utils#rg#scope#grep(label, ...) abort
  " Looked up on each call, so mappings can be made before the project is known
  for [l:label, l:args] in fzf_utils#rg#scope#list()
    if l:label ==# a:label
      call call('fzf_utils#rg#live_grep#window', (a:0 && !empty(a:1) ? [a:1] : []) + ['--'] + l:args)
      return
    endif
  endfor
  echo 'Grep: no scope "' . a:label . '" in this project'
endfunction

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

function! fzf_utils#rg#scope#code(...) abort
  call call('fzf_utils#rg#scope#grep', [s:label('project')] + a:000)
endfunction

function! fzf_utils#rg#scope#tests(...) abort
  call call('fzf_utils#rg#scope#grep', [s:label('tests')] + a:000)
endfunction

function! s:label(part) abort
  let l:language = exists('g:loaded_project_detect') ? project_detect#language() : ''
  return empty(l:language) ? a:part : a:part . ' ' . l:language
endfunction

function! fzf_utils#rg#scope#word_key(part, key) abort
  if !exists('g:loaded_fzf_vim') || !exists('g:loaded_project_detect') || empty(&filetype)
        \ || &filetype !=# project_detect#language()
    return a:key
  endif
  return printf("\<Cmd>call fzf_utils#rg#scope#%s(fzf_utils#rg#live_grep#word_pattern())\<CR>", a:part)
endfunction
