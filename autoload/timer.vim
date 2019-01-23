"" Set timer and notify when it expires

if exists('g:loaded_etimer')
    finish
endif
let g:loaded_etimer = 1

let s:timer_callback = get(g:, 'etimer_callback', 'NotifyTimer')

function NotifyTimer(timer_id)
    call timer_stop(a:timer_id)
    echom "Timer expired!"
endfunction

function! s:start_timer(i)
    let l:len = strlen(trim(a:i))
    let l:unit_idx = 1
    " check if unit of time is specified
    if a:i!~#"[smh]$"
        echom "Invalid interval (format \d+(s|m|h|ms))"
        return 1
    endif
    if a:i=~#"ms$"
        let l:unit_idx = 2
    endif
    " split stirng into unit and count respectively
    let l:split_idx = l:len - l:unit_idx
    let l:unit = strpart(a:i, l:split_idx, l:unit_idx)
    let l:interval = str2nr(strpart(a:i, 0, l:split_idx))
    if l:unit != "ms"
        let l:interval = l:interval * 1000
        " this multiplies for both minutes and hours
        if l:unit != "s"
            let l:interval = l:interval * 60
        endif
        if l:unit == "h"
            let l:interval = l:interval * 60
        endif
    endif
    let l:timer = timer_start(l:interval, s:timer_callback)
    echo "Timer set"
endfunction

" Register relevant commands
command! -nargs=1 ETimer call s:start_timer(<q-args>)
command! -nargs=0 ETCancel call timer_stopall()
