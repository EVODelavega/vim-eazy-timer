let s:factors = {
            \"ms": 1,
            \"s": 1000,
            \"m": 60 * 1000,
            \"h": 60 * 60 * 1000,
            \}
let s:active_timers = {}

let s:stopwatch = v:false
let s:stopwatch_id = 0
let s:stopwatch_time = 0
let s:stopwatch_start = 0

function NotifyTimer(timer_id)
    let l:timer_interval = remove(s:active_timers, a:timer_id)
    call timer_stop(a:timer_id)
    echohl ErrorMsg
    echom printf("Timer %d (%s) expired!", a:timer_id, l:timer_interval)
    echohl None
endfunction

function! s:start_timer(i)
    let l:interval = s:parse_interval(a:i)
    if l:interval == -1
        return -1
    endif
    let l:timer = timer_start(l:interval, get(g:, 'etimer_callback', 'NotifyTimer'))
    let s:active_timers[l:timer] = a:i
    echohl WarningMsg
    echo printf("Timer %d set", l:timer)
    echohl None
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
    echohl ModeMsg
    for key in keys(s:active_timers)
        echo printf("%d -> %s", key, s:active_timers[key])
    endfor
    echohl None
endfunction

function s:cancel_timers(...)
    if len(a:000) == 0
        call s:stopall()
        return
    endif
    let l:timer_id = str2nr(a:1)
    if !has_key(s:active_timers, l:timer_id)
        echom printf("Timer ID %s not found", a:1)
        return
    endif
    call remove(s:active_timers, l:timer_id)
    call timer_stop(l:timer_id)
endfunction

function s:start_stopwatch(...)
    if s:stopwatch
        echom "Stopwatch already running"
        return
    endif
    let l:precision = get(g:, 'etimer_stopwatch_interval', '1s')
    if len(a:000) == 1
        let l:precision = a:1
    endif
    let interval = s:parse_interval(l:precision)
    function! CB(...) closure
        let s:stopwatch_time += interval
        "" Each time set locatime -> second precision if time is cancelled
        let s:stopwatch_start = localtime()
    endfunction
    let s:stopwatch = v:true
    let s:stopwatch_start = localtime()
    let s:stopwatch_id = timer_start(interval, funcref('CB'),
                \ {'repeat': -1})
endfunction

function s:stop_stopwatch()
    if !s:stopwatch
        echom "Stopwatch not running"
        return
    endif
    call timer_stop(s:stopwatch_id)
    let s:stopwatch_id = 0
    let l:hours = s:stopwatch_time / get(s:factors, 'h', 3600000)
    let s:stopwatch_time -= l:hours * get(s:factors, 'h', 3600000)
    let l:minutes = s:stopwatch_time / get(s:factors, 'm', 60000)
    let s:stopwatch_time -= l:minutes * get(s:factors, 'm', 60000)
    let l:seconds = s:stopwatch_time / get(s:factors, 's', 1000)
    let l:ms = s:stopwatch_time - l:seconds * get(s:factors, 's', 1000)
    let l:seconds += localtime() - s:stopwatch_start
    "" Add the extra seconds, update mins/seconds if needed
    if l:seconds > 60
        let l:minutes += l:seconds/60
        let l:seconds = fmod(l:seconds, 60)
        if l:minutes > 60
            l:hours += l:minutes / 60
            l:minutes = fmod(l:minutes/60)
        endif
    endif
    let s:stopwatch_time = 0
    let s:stopwatch_start = 0
    echom printf("Stopwatch ended after %dh %dm %ds %dms", l:hours, l:minutes, l:seconds, l:ms)
endfunction

function s:stopall()
    if !s:stopwatch
        call timer_stopall()
    else
        for key in keys(s:active_timers)
            timer_stop(key)
        endfor
    endif
    s:active_timers = {}
endfunction

" Register relevant commands
function! timer#Register()
    command! -nargs=1 ETimer call s:start_timer(<q-args>)
    command! -nargs=? ETCancel call s:cancel_timers(<f-args>)
    command! -nargs=0 ETList call s:list_timers()
    command! -nargs=? ETStart call s:start_stopwatch(<f-args>)
    command! -nargs=0 ETStop call s:stop_stopwatch()
endfunction
