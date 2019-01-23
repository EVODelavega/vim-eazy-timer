# vim-eazy-timer
Basic timer plugin for vim. First attempt at writing a vim plugin.

## Usage

There's only 2 commands: `ETimer` and `ETCancel`. The first command allows you to set timers, the second cancels all timers that haven't expired yet.

### Creating a timer

Just run `:ETimer <duration>`, where `<duration>` takes a format like `10s`, `500ms`, `1h` or `15m`. Some examples:

* Set a timer for 2 hours: `:ETimer 2h`
* Set a timer for 15 minutes: `ETimer 15m`

Setting one timer doesn't affect the other timer

### Actions when timer expires

The default behaviour is a simple `Timer expired` message being echoed, and calls timer_stop on the timer. You can specify a custom callback function by setting `g:etimer_callback = 'MyCallback'` in your .vimrc. The callback takes one argument (the timer id).

### Cancelling all timers

`ETCancel` takes no arguments, and is equivalent to `call timer_stopall()`.

### TODO's

- Add a command to show what timers are currently running, and when they were set
- Support cancelling specific timers
- Allowing `ETimer` to take a second argument for a specific callback
- ...
