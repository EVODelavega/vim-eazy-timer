"" EZ Timer plugin, simple way to set timers or run a stopwatch in Vim

if exists('g:loaded_etimer')
    finish
endif
let g:loaded_etimer = 1
let s:keepcpo = &cpo
set cpo&vim

" Register the commands
call timer#RegisterCommands()

let &cpo= s:keepcpo
unlet s:keepcpo
