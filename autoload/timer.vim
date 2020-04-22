"" Set timer and notify when it expires

if exists('g:loaded_etimer')
    finish
endif
let g:loaded_etimer = 1

let s:timer_callback = get(g:, 'etimer_callback', 'NotifyTimer')

let s:factors = {
            \"ms": 1,
            \"s": 1000,
            \"m": 60 * 1000,
            \"h": 60 * 60 * 1000,
            \}
let s:active_timers = {}

function NotifyTimer(timer_id)
    let l:timer_interval = remove(s:active_timers, a:timer_id)
    call timer_stop(a:timer_id)
    echom printf("Timer %d (%s) expired!", a:timer_id, l:timer_interval)
endfunction

function! s:start_timer(i)
    let l:interval = s:parse_interval(a:i)
    if l:interval == -1
        return -1
    endif
    let l:timer = timer_start(l:interval, s:timer_callback)
    let s:active_timers[l:timer] = a:i
    echo printf("Timer %d set", l:timer)
endfunction

function s:parse_interval(i)
    if a:i!~#"[smh]$"
        echoerr printf("Invalid interval %s, expected format \d+(ms|s|m|h)$", a:i)
        return -1
    endif
    let l:len = strlen(trim(a:i))
    let l:unit_idx = 1
    if a:i=~#"ms$"
        let l:unit_idx = 2
    endif
    let l:split_idx = l:len - l:unit_idx
    let l:unit = strpart(a:i, l:split_idx, l:unit_idx)
    let l:interval = str2nr(strpart(a:i, 0, l:split_idx))
    let l:interval = l:interval * get(s:factors, l:unit, 1)
    return l:interval
endfunction

function s:list_timers()
    for key in keys(s:active_timers)
        echo printf("%d -> %s", key, s:active_timers[key])
    endfor
endfunction

function s:cancel_timers(...)
    if len(a:000) == 1
        let l:timer_id = str2nr(a:1)
        if !has_key(s:active_timers, l:timer_id)
            echom printf("Timer ID %s not found", a:1)
            return
        endif
        call remove(s:active_timers, l:timer_id)
        call timer_stop(l:timer_id)
        return
    endif
    let s:active_timers = {}
    call timer_stopall()
endfunction

" Register relevant commands
function! timer#register()
    command! -nargs=1 ETimer call s:start_timer(<q-args>)
    command! -nargs=? ETCancel call s:cancel_timers(<f-args>)
    command! -nargs=0 ETList call s:list_timers()
endfunction
