function! prompter#ready()
  return 1
endfunction

function! s:getopt(params, key, def)
  if type(a:params) == type({})
    return get(a:params, a:key, a:def)
  endif
  return a:def
endfunction

function! s:fire(params, name, args)
  let F = s:getopt(a:params, a:name, '')
  try
    if !empty(F)
      return call(F, a:args)
    endif
  catch
  endtry
  return ''
endfunction

function! prompter#input(...)
  let [t_ve, guicursor] = [&t_ve, &guicursor]
  set t_ve=
  set guicursor=a:NONE

  let params = a:0 > 0 ? a:1 : ''
  let base = s:getopt(params, 'prompt', empty(params) ? '' : string(params))
  let color = s:getopt(params, 'color', 'Comment')
  let histtype = s:getopt(params, 'histtype', '')
  let hist = histtype =~ '^[:/=@>]$' ? map(range(1, &history), 'histget(histtype, v:val * -1)') : []
  let C = s:getopt(params, 'on_change', '')

  let input = ['', '', '']
  let decide = 0
  let histpos = -1
  try
    while 1
      redraw
      exe "echohl " . color | echon base
      echohl Normal | echon input[0]
      echohl Constant | echon input[1]
      echohl Normal | echon input[2]
      echohl None
      if empty(input[1])
        echohl Constant | echon '_' | echohl None
      endif
      let nr = getchar()
      let chr = !type(nr) ? nr2char(nr) : nr
      let last = input
      let changed = 0
      if nr >=# 0x20
        let input[0] .= chr
        let changed = 1
      elseif chr == "\<Esc>"
        break
      elseif chr == "\<CR>"
        let decide = 1
        break
      elseif chr == "\<BS>" || chr == "\<C-H>"
        if empty(input[0])
          break
        endif
        let [input[0], _] = [substitute(input[0], '.$', '', ''), 1]
        let changed = 1
      elseif chr == "\<C-W>"
        let input = ['', '', '']
        let changed = 1
      elseif chr == "\<Home>" || chr == "\<C-A>"
        let s = join(input, '')
        let input = ['', matchstr(s, '^.'), substitute(s, '^.', '', '')]
      elseif chr == "\<End>" || chr == "\<C-E>"
        let input = [join(input, ''), '', '']
      elseif chr == "\<Up>"
        if len(hist) > 0
          let histpos = min([histpos+1, len(hist)-1])
          let input = [hist[histpos], '', '']
          let changed = 1
        endif
      elseif chr == "\<Down>"
        if len(hist) > 0
          let histpos = max([0, abs(histpos-1)])
          let histpos = histpos % len(hist)
          let input = [hist[histpos], '', '']
          let changed = 1
        endif
      elseif chr == "\<Left>"
        if !empty(input[0])
          let input = [substitute(input[0], '.$', '', ''), matchstr(input[0], '.$'), input[1] . input[2]]
        endif
      elseif chr == "\<Right>"
        let input = [input[0] . input[1], matchstr(input[2], '^.'), substitute(input[2], '^.', '', '')]
      endif
      call s:fire(params, 'on_change', [input])
    endwhile
  catch
  finally
    let result = join(input, '')
    redraw
    if decide
      redraw
      exe "echohl " . color | echon base
      echohl Normal | echon result
      echohl None
      let tmp = s:fire(params, 'on_enter', [input])
      if type(tmp) == type('')
        let result = tmp
      endif
      if histtype =~ '^[:/=@>]$'
        if histtype == '/'
          let @/ = result
        endif
        call histadd(histtype, result)
      endif
    else
      redraw
      echo
      let result = ''
      call s:fire(params, 'on_cancel', [input])
    endif
    let &t_ve = t_ve
    let &guicursor = guicursor
  endtry
  return result
endfunction

" vim:set et sw=2:
