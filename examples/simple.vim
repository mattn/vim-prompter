function! s:on_enter(input)
  echo "YOU MAN!: " . join(a:input, '')
endfunction

function! s:on_cancel(input)
  echo "WHY JAPANESE PEOPLE!"
endfunction

call prompter#input({
\ 'prompt': '# ',
\ 'on_enter':  function('s:on_enter'),
\ 'on_cancel': function('s:on_cancel'),
\})
