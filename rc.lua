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
local hotkeys_popup = require("awful.hotkeys_popup").widget

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
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
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
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
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
		currentscreen = awful.screen.focused().index
        width = 0
        for i = 1, currentscreen do
            width = width + screen[i].geometry.width
        end
		if gkclient then
				gkclient.sticky = true
				--gkclient:tags(tags[mouse.screen])
				awful.client.movetoscreen(gkclient, currentscreen)
				gkclient.x = width - 99
				gkclient.y = math.floor(awful.screen.focused().geometry.height * 0.03)
				awful.client.movetotag(awful.tag.selected(), gkclient)
				client.focus = gkclient
				gkclient:raise()
                -- naughty.notify({ preset = naughty.config.presets.critical,
                --                  text= "currentscreen " .. currentscreen .. " width: " .. screen[currentscreen].geometry.width .. " height: " .. screen[currentscreen].geometry.height .. " x: " .. gkclient.x .. "y: " ..gkclient.y,
                --                  title = "coords" })
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
		currentscreen = awful.screen.focused().index

         -- naughty.notify({ preset = naughty.config.presets.critical,
         --                  text= "x: " .. mousex .. " y: " .. mousey .. " screen: " .. currentscreen .. " " .. screen[currentscreen].geometry.width .. "x" .. screen[currentscreen].geometry.height,
         --                  title = "coords" })

        -- in multiscreen the coordinates go OOB
        if mousex > screen[currentscreen].geometry.width then
            if currentscreen > 1 then
                -- screen 2 is right of screen 1
                mousex = mousex - screen[currentscreen - 1].geometry.width
            else if currentscreen == 1 then
                -- screen 2 is left of screen 1
                mousex = mousex - screen[currentscreen + 1].geometry.width
            end end
        end
        if mousey > screen[currentscreen].geometry.height then
            if currentscreen > 1 then
                mousey = mousey - screen[currentscreen - 1].geometry.height
            end
        end

        -- show gkrellm iff close to screen border
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

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        if string.sub(beautiful.wallpaper, 1, 1) == "#" then
            gears.wallpaper.set(beautiful.wallpaper)
        else
            local wallpaper = beautiful.wallpaper
            -- If wallpaper is a function, call it with the screen
            if type(wallpaper) == "function" then
                wallpaper = wallpaper(s)
            end
            gears.wallpaper.maximized(wallpaper, s, true)
        end
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    -- Define a tag table which hold all screen tags.
    tags = {
    	names = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, "-", "="},
    	layout = {  awful.layout.suit.max,
                    awful.layout.suit.tile,
                    awful.layout.suit.tile,
                    awful.layout.suit.tile,
                    awful.layout.suit.tile,
                    awful.layout.suit.max,
                    awful.layout.suit.floating,
                    awful.layout.suit.tile,
                    awful.layout.suit.tile,
                    awful.layout.suit.tile,
                    awful.layout.suit.tile,
                    awful.layout.suit.max }
    }
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
    -- }}}

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }

	-- mygkrellmbar = awful.wibox.new({ position = "right", screen =s, ontop = true, width = 1, height = 1, visible = true })
	-- mygkrellmbar.drawin:connect_signal("mouse::enter", gkrellm_mouse)
	--mygkrellmbar:connect_signal("mouse::leave", gkrellm_mouse)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- Tags https://awesomewm.org/doc/api/classes/tag.html

local function delete_tag()
    local t = awful.screen.focused().selected_tag
    if not t then return end
    t:delete()
end

local function add_tag()
    awful.tag.add("+", {
        screen= awful.screen.focused(),
        volatile = true,
        layout = awful.layout.suit.tile
    }):view_only()
end

local function rename_tag()
    awful.prompt.run {
        prompt       = "New tag name: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = function(new_name)
            if not new_name or #new_name == 0 then return end

            local t = awful.screen.focused().selected_tag
            if t then
                t.name = new_name
            end
        end
    }
end

local function move_to_new_tag()
    local c = client.focus
    if not c then return end

    local t = awful.tag.add(c.class,{screen= c.screen, volatile = true})
    c:tags({t})
    t:view_only()
end

local function copy_tag()
    local t = awful.screen.focused().selected_tag
    if not t then return end

    local clients = t:clients()
    local t2 = awful.tag.add(t.name .. "_", awful.tag.getdata(t), {volatile = true})
    t2:clients(clients)
    t2:view_only()
end

gapped = false

local function add_gaps()
    local t = awful.screen.focused().selected_tag
    if not t then return end
    if gapped then
        t.gap = 0
        gapped = false
    else
        t.gap = 5
        gapped = true
    end
end



-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
    --           {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    -- awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
    --           {description = "show main menu", group = "awesome"}),

    -- Tags https://awesomewm.org/doc/api/classes/tag.html
    awful.key({ modkey,           }, "a", add_tag,
              {description = "add a tag", group = "tag"}),
    awful.key({ modkey, "Shift"   }, "a", delete_tag,
              {description = "delete the current tag", group = "tag"}),
    awful.key({ modkey, "Control"   }, "a", move_to_new_tag,
              {description = "add a tag with the focused client", group = "tag"}),
    awful.key({ modkey, "Mod1"   }, "a", copy_tag,
              {description = "create a copy of the current tag", group = "tag"}),
    awful.key({ modkey, "Shift"   }, "r", rename_tag,
              {description = "rename the current tag", group = "tag"}),
    awful.key({ modkey, "Shift"   }, "g", add_gaps,
              {description = "add gaps", group = "tag"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    -- awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
    --           {description = "run prompt", group = "launcher"}),
	awful.key({ modkey },            "r",     function () 
			awful.util.spawn_with_shell( "exe=`dmenu_run -b -nf '#ff9900' -nb '#222222' -sf '#000000' -sb '#ff9900'` && exec $exe")
	end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
    -- CLA
    awful.key({ modkey ,"Control" }, "i", function() awful.util.spawn_with_shell("/usr/bin/setxkbmap it") end),
    awful.key({ modkey ,"Control" }, "u", function() awful.util.spawn_with_shell("/usr/bin/setxkbmap us") end),
    awful.key({ modkey ,          }, "z", function() awful.util.spawn_with_shell("xscreensaver-command -lock") end),
    awful.key({ modkey ,          }, "s", function() awful.util.spawn_with_shell("/usr/bin/xclip -i ~/.ssh/id_rsa.pub") end),
    awful.key({ modkey ,          }, "v", function() awful.util.spawn_with_shell("~/bin/labvga.sh") end),
    awful.key({ modkey ,"Shift"   }, "v", function() awful.util.spawn_with_shell("xrandr --output DP2 --off") end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"}),
    -- CLA
    awful.key({ modkey,           }, "w", function(c) 
			awful.util.gkrellm_mouse_enabled = (not awful.util.gkrellm_mouse_enabled) or false
	end),
    awful.key({ modkey ,          }, "g", function(c) 
			awful.util.spawn_with_shell("killall gkrellm && gkrellm -w")
	end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

newnames = {"0", "-", "="}
for i = 10, 12 do
    nn = newnames[i-9]
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, nn,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, nn,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, nn,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, nn,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     -- size_hints_honor = true,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "Mplayer",
          "pinentry",
          "Gimp",
          "Skype",
          "Pidgin",
          "Konversation",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

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
    { rule = { class = "Skype", "Pidgin", "Konversation" },
      properties = { floating = true, 
                     tag = "7"
			       } 
	},
    -- Add titlebars to normal clients and dialogs
    --{ rule_any = {type = { "normal", "dialog" }
    --  }, properties = { titlebars_enabled = true }
    --},

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
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
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
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
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
    -- CLA
    gkrellm_mouse(c)
end)

-- CLA
client.connect_signal("mouse::leave", gkrellm_mouse)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- CLA
toggle_gkrellm()
awful.util.spawn_with_shell("pgrep xscreensaver || xscreensaver -no-splash")
awful.util.spawn_with_shell("pgrep wicd-client || wicd-gtk -t")
awful.util.spawn_with_shell("pgrep clipit || clipit")
-- awful.util.spawn_with_shell("xsetroot -solid black")
awful.util.spawn_with_shell("xbindkeys")
awful.util.spawn_with_shell("pgrep redshift || redshift-gtk")
-- awful.util.spawn_with_shell("pgrep -a cbatticon | grep BAT0 || cbatticon -n BAT0")
-- awful.util.spawn_with_shell("pgrep -a cbatticon | grep BAT1 || cbatticon -n BAT1")

