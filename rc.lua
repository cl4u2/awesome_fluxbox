-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init("/home/clauz/.config/awesome/defaultcla0/theme.lua")

-- This is used later as the default terminal and editor to run.
-- terminal = "xterm"
terminal = "xterm -fg white -bg black"
-- editor = os.getenv("EDITOR") or "nano"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
ourscreen = 1

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
	names = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, "-", "="},
	layout = { awful.layout.suit.max, layouts[1], layouts[1], layouts[1], awful.layout.suit.floating, awful.layout.suit.max, awful.layout.suit.floating, layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] }
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- CLA
awful.util.gkrellm_mouse_enabled = true
gkmatcher = function(c)
	return awful.rules.match(c, { class = "Gkrellm" })
end

find_gkclient = function()
	gkclient = nil
	for c in awful.client.iterate(gkmatcher) do
		gkclient = c
		break
	end
	return gkclient
end

show_gkrellm = function ()
		--awful.client.run_or_raise("gkrellm", gkmatcher)
		gkclient = find_gkclient()
		currentscreen = mouse.screen
		if gkclient then
				gkclient.sticky = true
				gkclient.x = screen[currentscreen].geometry.width - 99
				gkclient.y = math.floor(screen[currentscreen].geometry.height * 0.03)
				--gkclient:tags(tags[mouse.screen])
				awful.client.movetoscreen(gkclient, currentscreen)
				awful.client.movetotag(awful.tag.selected(), gkclient)
				client.focus = gkclient
				gkclient:raise()
		else
				-- awful.util.spawn("gkrellm -w")
				awful.util.spawn_with_shell("pgrep gkrellm || gkrellm -w")
		end
		if gktimer.started then
				gktimer:stop()
		end
		gktimer:start()
end

hide_gkrellm = function (gkclient)
		if not gkclient then
				gkclient = find_gkclient()
		end
		if gkclient then
				gkclient.minimized = true
				if not gktimer.started then
						gktimer:stop()
				end
		end
end

toggle_gkrellm = function () 
		gkminimized = true
		gkclient = nil
		for c in awful.client.iterate(gkmatcher) do
				gkminimized = gkminimized and c.minimized
				gkclient = c
		end
		if gkminimized then
				show_gkrellm()
		else
				hide_gkrellm(gkclient)
		end
		awful.util.gkrellm_mouse_enabled = true

	end

gkrellm_mouse = function (c)
	if awful.util.gkrellm_mouse_enabled then
		xy = mouse.coords()
		if xy ~= nil and xy['x'] ~= nil then
				mousex = xy['x']
		else
				mousex = 0
		end
		if xy ~= nil and xy['y'] ~= nil then
				mousey = xy['y']
		else
				mousey = 0
		end
		currentscreen = mouse.screen
		if mousex > math.ceil(screen[currentscreen].geometry.width * 0.99) and 
            mousey > math.ceil(screen[currentscreen].geometry.height * 0.06) and 
            mousey < math.ceil(screen[currentscreen].geometry.height * 0.91) 
        then
				show_gkrellm()
		elseif mousex <= math.ceil(screen[currentscreen].geometry.width * 0.94) or
            mousey <= math.ceil(screen[currentscreen].geometry.height * 0.06) or
            mousey >= math.ceil(screen[currentscreen].geometry.height * 0.91)
        then
				hide_gkrellm(nil)
		end
	end
end

gktimer = timer({timeout = 0.1})
gktimer:connect_signal("timeout", gkrellm_mouse)
--CLA


-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

	-- mygkrellmbar = awful.wibox.new({ position = "right", screen =s, ontop = true, width = 1, height = 1, visible = true })
	-- mygkrellmbar.drawin:connect_signal("mouse::enter", gkrellm_mouse)
	--mygkrellmbar:connect_signal("mouse::leave", gkrellm_mouse)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
        -- function ()
        --     awful.client.focus.history.previous()
        --     if client.focus then
        --         client.focus:raise()
        --     end
        -- end),
    awful.key({ modkey, "Shift"   }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "t",      function () awful.util.spawn("lxterminal") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    awful.key({ modkey ,"Control" }, "i", function() awful.util.spawn_with_shell("/usr/bin/setxkbmap it") end),
    awful.key({ modkey ,"Control" }, "u", function() awful.util.spawn_with_shell("/usr/bin/setxkbmap us") end),
    awful.key({ modkey ,          }, "z", function() awful.util.spawn_with_shell("xscreensaver-command -lock") end),
    -- Prompt
    --awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
	--CLA
	awful.key({ modkey },            "r",     function () 
			awful.util.spawn_with_shell( "exe=`dmenu_run -b -nf '#ff9900' -nb '#222222' -sf '#000000' -sb '#ff9900'` && exec $exe")
	end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

-- dontshowkey = awful.key(nil, modkey, nil);
-- dontshowkey:connect_signal("press");
-- dontshowkey:connect_signal("release");

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    --awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey, "Control" }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
	-- CLA: titlebar key from the awesome wiki
    -- awful.key({ modkey, "Shift" }, "t", 
	--     function (c)
	-- 		if c.titlebar then 
	-- 				awful.titlebar:remove(c)
	-- 		else 
	-- 				awful.titlebar:add(c, { modkey = modkey }) 
	-- 		end
	-- 	end),
    awful.key({ modkey,           }, "w", function(c) 
			awful.util.gkrellm_mouse_enabled = (not awful.util.gkrellm_mouse_enabled) or false
	end),
    awful.key({ modkey ,          }, "g", function(c) 
			awful.util.spawn_with_shell("killall gkrellm && gkrellm -w")
	end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

newnames = {"0", "-", "="}
for i = 10, 12 do
    nn = newnames[i-9]
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, nn,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, nn,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, nn,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, nn,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Gimp" },
      properties = { floating = true, 
	  				 tag = tags[1][7],
					 switchtotag = true,
			       } 
	},
    { rule = { class = "Skype" },
      properties = { floating = true, 
	  				 tag = tags[1][5],
					 --switchtotag = true,
					 -- x = 939,
					 -- y = 20,
			       } 
	},
    { rule = { class = "Pidgin" },
      properties = { floating = true, 
	  				 tag = tags[1][5],
					 --switchtotag = true,
					 -- x = 503,
					 -- y = 44
			       } 
	 },
	{ rule = { class = "Gkrellm" },
	  properties = { floating = true, 
	  				 sticky = true, 
					 skip_taskbar = true, 
					 focusable = false,
					 x = screen[ourscreen].geometry.width - 99, 
					 y = math.floor(screen[ourscreen].geometry.height * 0.03),
			       },
	},
    { rule = { class = "Wicd-client.py" },
      properties = { floating = true, 
	  				 -- minimized = true,
					 skip_taskbar = true
			       } 
	},
    -- Set Firefox to always map on tags number 2 of screen 1.
    --{ rule = { class = "Firefox" },
    --  --properties = { tag = tags[1][2] } },
    --  properties = { tag = tags[1][1], switchtotag = true } },
    --{ rule = { class = "Thunderbird" },
    --  properties = { tag = tags[1][1], switchtotag = true } },
    --{ rule = { class = "chromium" },
    --  properties = { tag = tags[1][1], switchtotag = true } },
}
-- }}}


-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)


    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end

	    -- CLA
		gkrellm_mouse(c)
	    -- CLA
    end)

	-- CLA
	c:connect_signal("mouse::leave", gkrellm_mouse)
	--c:connect_signal("timeout", gkrellm_mouse)
	-- CLA

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

toggle_gkrellm()
awful.util.spawn_with_shell("pgrep xscreensaver || xscreensaver -no-splash")
awful.util.spawn_with_shell("pgrep wicd-client || wicd-gtk -t")
awful.util.spawn_with_shell("pgrep clipit || clipit")
awful.util.spawn_with_shell("xsetroot -solid black")
awful.util.spawn_with_shell("xbindkeys")
awful.util.spawn_with_shell("pgrep redshift || redshift-gtk")
awful.util.spawn_with_shell("pgrep -a cbatticon | grep BAT0 || cbatticon -n BAT0")
awful.util.spawn_with_shell("pgrep -a cbatticon | grep BAT1 || cbatticon -n BAT1")

