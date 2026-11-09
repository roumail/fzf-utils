function! fzf_utils#pick_files(dir, callback) abort
  let l:dir = fnamemodify(expand(a:dir), ':p')
  let l:spec = fzf#vim#with_preview(extend(fzf_utils#files#options(), {
        \ 'dir': l:dir,
        \ 'options': ['--multi', '--prompt', fnamemodify(l:dir, ':~') . ' '],
        \ }))
  let l:spec['sink*'] = {lines -> a:callback(map(filter(copy(lines), '!empty(v:val)'),
        \ {_, f -> fnamemodify(l:dir . f, ':p')}))}
  " fzf runs in a terminal: the callback comes after this returns
  call fzf#run(fzf#wrap('fzf-utils-pick', l:spec))
endfunction

function! fzf_utils#grep_scope_args(scope) abort
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

function! s:has_project_detect() abort
  return !empty(globpath(&runtimepath, 'autoload/project_detect.vim', 1))
endfunction

function! fzf_utils#grep_scopes() abort
  let l:list = [['all', []]]
  if !s:has_project_detect() || empty(project_detect#active())
    return l:list
  endif
  let l:parts = project_detect#parts()
  let l:seen = [[]]
  for [l:part, l:key] in [['project', 'sources'], ['tests', 'tests']]
    " First every language's places together, then each language's own
    for [l:language, l:places] in [['', s:all_places(l:parts, l:key)]]
          \ + map(copy(l:parts), {_, p -> [p.language, p[l:key]]})
      if l:part ==# 'tests' && empty(l:places)
        continue
      endif
      let l:args = fzf_utils#grep_scope_args({'root': project_detect#root(), 'places': l:places, 'language': l:language})
      if index(l:seen, l:args) < 0
        call add(l:list, [s:scope_label(l:part, l:language), l:args])
        call add(l:seen, l:args)
      endif
    endfor
  endfor
  return l:list
endfunction

function! s:all_places(parts, key) abort
  let l:places = []
  for l:part in a:parts
    " Code with no places of its own is anywhere in the root, so all of it is
    if a:key ==# 'sources' && empty(l:part.sources)
      return []
    endif
    call extend(l:places, filter(copy(l:part[a:key]), 'index(l:places, v:val) < 0'))
  endfor
  return l:places
endfunction

function! s:scope_label(part, language) abort
  return empty(a:language) ? a:part : a:part . ' ' . a:language
endfunction

function! fzf_utils#grep_scope(label, ...) abort
  " Looked up on each call, so mappings can be made before the project is known
  for [l:label, l:args] in fzf_utils#grep_scopes()
    if l:label ==# a:label
      call call('fzf_utils#grep#window', (a:0 && !empty(a:1) ? [a:1] : []) + ['--'] + l:args)
      return
    endif
  endfor
  echo 'Grep: no scope "' . a:label . '" in this project'
endfunction

function! fzf_utils#grep_scope_pick(...) abort
  let l:pattern = a:0 ? a:1 : ''
  let l:labels = map(fzf_utils#grep_scopes(), 'v:val[0]')
  if len(l:labels) == 1
    call call('fzf_utils#grep#window', a:0 ? [a:1] : [])
    return
  endif
  call fzf#run(fzf#wrap({
        \ 'source': l:labels,
        \ 'sink': {label -> fzf_utils#grep_scope(label, l:pattern)},
        \ }))
endfunction

function! fzf_utils#grep_code(...) abort
  call call('fzf_utils#grep_scope', [s:label('project')] + a:000)
endfunction

function! fzf_utils#grep_tests(...) abort
  call call('fzf_utils#grep_scope', [s:label('tests')] + a:000)
endfunction

function! s:label(part) abort
  " The current file's language, in a project of several
  let l:language = s:has_project_detect() ? get(project_detect#part(), 'language', '') : ''
  return s:scope_label(a:part, l:language)
endfunction

function! fzf_utils#word_pattern() abort
  let l:mode = mode()
  if l:mode =~# "^[vV\<C-v>]"
    if exists('*getregion')
      let l:text = join(getregion(getpos('v'), getpos('.'), {'type': l:mode}), "\n")
    else
      let l:save = [getreg('"'), getregtype('"')]
      normal! y
      let l:text = substitute(getreg('"'), '\n$', '', '')
      call setreg('"', l:save[0], l:save[1])
    endif
    execute "normal! \<Esc>"
  else
    let l:text = expand('<cword>')
  endif
  " Live grep starts in regex mode
  return '\b' . escape(l:text, '\.^$*+?()[]{}|') . '\b'
endfunction
