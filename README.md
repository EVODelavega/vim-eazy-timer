# vim-eazy-timer
Basic timer plugin for vim. First attempt at writing a vim plugin.

## Usage

There's only 3 commands: `ETimer`, `ETList`, and `ETCancel`. The commands are pretty self-explanatory.

* `ETimer`: set a timer, requires 1 argument to specify the duration
* `ETList`: Lists timers that are currently active (timer ID -> duration)
* `ETCancel`: cancels all timers that are active

### Creating a timer

Just run `:ETimer <duration>`, where `<duration>` takes a format like `10s`, `500ms`, `1h` or `15m`. Some examples:

* Set a timer for 2 hours: `:ETimer 2h`
* Set a timer for 15 minutes: `ETimer 15m`

Setting one timer doesn't affect the other timer

### Actions when timer expires

The default behaviour is a simple `Timer expired` message being echoed, and calls timer_stop on the timer. You can specify a custom callback function by setting `g:etimer_callback = 'MyCallback'` in your .vimrc. The callback takes one argument (the timer id).

### Cancelling all timers

`ETCancel` takes no arguments, and is equivalent to `call timer_stopall()`.

### See active timers

`ETList` just lists the actual timer ID's and their duration. Example

```
:ETimer 15s
:ETList
```

Will output something like:

```
3 -> 15s
```

### TODO's

- Add information on when the listed timers were set, seeing how much time is left
- Allowing `ETimer` to take a second argument for a specific callback
- Make `ETimer` take `-nargs=+` args, so we can set several timers at once
