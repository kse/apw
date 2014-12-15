APW fork
========
Fork of [APW](http://github.com/mokasin/apw) with percentages![](http://i.imgur.com/5VR2kFr.png), progressbar vertical and themed.

mouse clicks spawns: veromix and pavucontrol by left and right buttons


Awesome Pulseaudio Widget
=========================

Awesome Pulseaudio Widget (APW) is a little widget for
[Awesome WM](http://awesome.naquadah.org/), using the awful progressbar widget,
to display default's sink volume and control Pulseaudio.

It's compatible with Awesome 3.5.

First time I'm using Lua. So it might be a little bit quirky.

Get it
------

```sh
cd $XDG_CONFIG_HOME/awesome/
git clone https://github.com/mokasin/apw.git
```

Use it
------

Just put these line to the appropriate places in
*$XDG_CONFIG_HOME/awesome/rc.lua*.

```lua
-- Load the library.
local apw = require("apw")

-- Load the widget
local apwwidget = apw.widget

-- Example: Add to wibox. Here to the right. Do it the way you like it.
right_layout:add(apwwidget)

-- Configure the hotkeys.
awful.key({ }, "XF86AudioRaiseVolume",  apwwidget.Up),
awful.key({ }, "XF86AudioLowerVolume",  apwwidget.Down),
awful.key({ }, "XF86AudioMute",         apwwidget.ToggleMute),

```

Customize it
------------

### Theme

*Important:* `beautiful.init` must be called before you `require` apw for
theming to work.

Just add these variables to your Beautiful theme.lua file and set them
to whatever colors or gradients you wish:

```lua
--{{{ APW
theme.apw = {
	fg_color = theme.fg_normal,
	bg_color = theme.bg_systray,
	mute_fg_color = "#CC9393",
	mute_bg_color = "#663333",
	margin_bottom = 1,
	margin_top = 1,
	margin_left = 10,
	width = 6
}
--}}}

```

### Directly edit widget.lua

You also can customize some properties by editing the configuration variables
directly in `widget.lua` (i.e. add a margin).
It is advisable to customize the source file in an own branch. This makes it
easy to update to a new version of APW via rebasing.

Mixer
----

Right-clicking the widget launches a mixer.  By default this is `pavucontrol`,
but you can set a different command by calling SetMixer() on your APW object:

```lua
apwwidget:SetMixer("mixer_command -whatever")
```

### Tip
You could update the widget periodically if you'd like. In case, the volume is
changed from somewhere else.

```lua
APWTimer = timer({ timeout = 0.5 }) -- set update interval in s
APWTimer:connect_signal("timeout", apwwidget.Update)
APWTimer:start()
```

Contributing
------------
Just fork it and file a pull request. I'll look into it.
