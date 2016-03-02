function! s:on_change(input)
  call clearmatches()
  exe "match Search /" . join(a:input, '') . "/"
endfunction

function! s:on_enter(input)
  call clearmatches()
  echohl Warning | echo "WHY JAPANESE PEOPLE!: " . join(a:input, '') | echohl None
endfunction

call prompter#input({
\ 'color': 'Normal',
\ 'prompt': '/',
\ 'on_enter':  function('s:on_enter'),
\ 'on_change':  function('s:on_change'),
\})
