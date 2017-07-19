function! s:on_change(input)
  call clearmatches()
  exe "match Search /" . join(a:input, '') . "/"
endfunction

function! s:on_enter(input)
  call clearmatches()
  echohl Warning | echo "WHY JAPANESE PEOPLE!: " . join(a:input, '') | echohl None
endfunction

function! s:complete(input)
  return split(glob(a:input[0] . '*'), "\n")
endfunction

call prompter#input({
\ 'color': 'Normal',
\ 'prompt': '/',
\ 'on_complete': function('s:complete'),
\ 'on_enter':  function('s:on_enter'),
\ 'on_change':  function('s:on_change'),
\})
