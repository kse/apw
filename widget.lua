-- Copyright 2013 mokasin
-- This file is part of the Awesome Pulseaudio Widget (APW).
-- 
-- APW is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- APW is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with APW. If not, see <http://www.gnu.org/licenses/>.

local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local pulseaudio = require("apw.pulseaudio")


-- Configuration variables
local width         = 8          -- width in pixels of progressbar
local margin_right  = 0          -- right margin in pixels of progressbar 
local margin_left   = 0          -- left margin in pixels of progressbar 
local margin_top    = 2          -- top margin in pixels of progressbar 
local margin_bottom = 2          -- bottom margin in pixels of progressbar  
local step          = 0.05       -- stepsize for volume change (ranges from 0 to 1)
local minstep       = 0.01	 -- minimum stepsize for volume
local color         = '#aaaaaa'  -- '#698f1e' -- foreground color of progessbar
local color_bg      = '#222222'  -- '#33450f' -- background color
local color_mute    = '#cc0000'  -- foreground color when muted
local color_bg_mute = color_bg   -- '#532a15' -- background color when muted
local color_amp     = '$3465a4'  -- bar color when over 100%
local color_amp_bg  = color      -- background color when over 100%
local mixer         = 'pavucontrol' -- mixer command
local mixer_class   = 'Pavucontrol'
local second	    = 'veromix'     -- veromix command
local second_class  = 'veromix'
local icon_theme    = 'gnome'
local icon_path     = '/usr/share/icons/'..icon_theme..'/32x32/status/'
local icon_level    = { [0] = 'muted', 'low', 'medium', 'high' }

-- default configuration overridden by Beautiful theme
color = beautiful.apw_fg_color or color
color_bg = beautiful.apw_bg_color or color_bg
color_mute = beautiful.apw_mute_fg_color or color_mute
color_bg_mute = beautiful.apw_mute_bg_color or color_bg_mute
margin_right = beautiful.apw_margin_right or margin_right
margin_left = beautiful.apw_margin_left or margin_left
margin_top = beautiful.apw_margin_top or margin_top
margin_bottom = beautiful.apw_margin_bottom or margin_bottom
width = beautiful.apw_width or width


-- End of configuration

local notid = 0
local p = pulseaudio:Create()

local pulseBar = awful.widget.progressbar()
local pulseBox = wibox.widget.textbox(1)

pulseBar:set_width(width)
pulseBar:set_vertical(true)
pulseBar.step = step
pulseBar.minstep = minstep

local pulseWidget = wibox.layout.margin(pulseBar, margin_right, margin_left, margin_top, margin_bottom)

function pulseWidget.setColor(mute, volume)
	if mute then
		pulseBar:set_color(color_mute)
		pulseBar:set_background_color(color_bg_mute)
	else
		if p.Volume > 1.0 then
			pulseBar:set_color(color_amp)
        	        pulseBar:set_background_color(color_amp_bg)
		else
			pulseBar:set_color(color)
			pulseBar:set_background_color(color_bg)
		end
	end
end

local function _update()
	if p.Volume > 1.0 then 
		pulseBar:set_value(p.Volume - 1.0)
	else
                pulseBar:set_value(p.Volume)
	end
	pulseBox:set_text(p.Perc)
	pulseWidget.setColor(p.Mute, p.Volume)
end

function pulseWidget.SetMixer(command)
	mixer = command
end

function pulseWidget.SetSecondary(command)
        second = command
end

function pulseWidget.Up()
	p:SetVolume(p.Volume + pulseBar.step)
	notid = naughty.notify({ title = 'apw', text = 'Volume: '..p.Perc,
				icon = icon_path..'/audio-volume-'..icon_level[math.ceil(p.Volume/0.50)]..'.png',
				timeout = 2, replaces_id = notid }).id
	_update()
end	

function pulseWidget.Down()
	p:SetVolume(p.Volume - pulseBar.step)
	notid = naughty.notify({ title = 'apw', text = 'Volume: '..p.Perc,
				icon = icon_path..'/audio-volume-'..icon_level[math.ceil(p.Volume/0.50)]..'.png',
				timeout = 2, replaces_id = notid }).id
	_update()
end	

function pulseWidget.minUp()
	p:SetVolume(p.Volume + pulseBar.minstep)
	if p.Mute then
		pulseWidget.ToggleMute()
	end
	_update()
end	

function pulseWidget.minDown()
	p:SetVolume(p.Volume - pulseBar.minstep)
	if p.Mute then
		pulseWidget.ToggleMute()
	end
	_update()
end	


function pulseWidget.ToggleMute()
	p:ToggleMute()
	local  msg = { [false] = 'Unmuted', [true] = 'Muted' }
	local icon = { [false] = icon_path..'/audio-volume-'..icon_level[math.ceil(p.Volume/0.5)]..'.png',
			[true] = icon_path..'/audio-volume-'..icon_level[0]..'.png' }
	notid = naughty.notify({ title = 'apw', text = msg[p.Mute]..': '..p.Perc,
				icon = icon[p.Mute], timeout = 2, replaces_id = notid }).id
	_update()
end

function pulseWidget.Update()
	p:UpdateState()
	_update()
end

function pulseWidget.LaunchMixer()
	run_or_kill(mixer,  { class = mixer_class })
	_update()
end

function pulseWidget.LaunchSecondary()
	run_or_kill(second, { class = second_class })
	_update()	
end

function run_or_kill(cmd, properties)
   local clients = client.get()
   local focused = awful.client.next(0)
   local findex = 0
   local matched_clients = {}
   local n = 0
   for i, c in pairs(clients) do
      --make an array of matched clients
      if match(properties, c) then
         n = n + 1
         matched_clients[n] = c
         if c == focused then
            findex = n
         end
      end
   end
   if n > 0 then
      local c = matched_clients[1]
      -- if the focused window matched switch focus to next in list
      if 0 < findex and findex < n then
         c = matched_clients[findex+1]
      end
      local ctags = c:tags()
      if #ctags == 0 then
         -- ctags is empty, show client on current tag
         local curtag = awful.tag.selected()
         awful.client.movetotag(curtag, c)
      else
         -- Otherwise, pop to first tag client is visible on
         awful.tag.viewonly(ctags[1])
      end
      -- And then kill the client
      c:kill()
      return
   end
   awful.util.spawn(cmd)
end

-- Returns true if all pairs in table1 are present in table2
function match (table1, table2)
   for k, v in pairs(table1) do
      if table2[k] ~= v and not table2[k]:find(v) then
         return false
      end
   end
   return true
end

function pulseWidget.text()
	return pulseBox
end


-- register mouse button actions
buttonsTable = awful.util.table.join(
                awful.button({ }, 1,  pulseWidget.LaunchMixer),
		awful.button({ }, 12, pulseWidget.ToggleMute),
		awful.button({ }, 2,  pulseWidget.ToggleMute),
		awful.button({ }, 3,  pulseWidget.LaunchSecondary),
		awful.button({ }, 4,  pulseWidget.minUp),
		awful.button({ }, 5,  pulseWidget.minDown)
	)
pulseWidget:buttons(buttonsTable)
pulseBox:buttons(buttonsTable)


-- initialize
_update()

return pulseWidget
