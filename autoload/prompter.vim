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
  let base = s:getopt(params, 'prompt', string(params))
  let color = s:getopt(params, 'color', 'Comment')
  let C = s:getopt(params, 'on_change', '')

  let input = ['', '', '']
  let decide = 0
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
      echohl Comment | echon base
      echohl Normal | echon result
      echohl None
      redraw
      let tmp = s:fire(params, 'on_enter', [input])
      if type(tmp) == type('')
        let result = tmp
      endif
    else
      let result = ''
      call s:fire(params, 'on_cancel', [input])
    endif
    let &t_ve = t_ve
    let &guicursor = guicursor
  endtry
  return result
endfunction

" vim:set et sw=2:
