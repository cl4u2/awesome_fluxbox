---------------------------
-- Default awesome theme --
---------------------------

local theme = {}

theme.font          = "sans 8"

theme.bg_normal     = "#222222"
--theme.bg_focus      = "#535d6c"
theme.bg_focus      = "#444444"
theme.bg_urgent     = "#ff9900"
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

--theme.fg_normal     = "#aaaaaa"
theme.fg_normal     = "#ff9900"
--theme.fg_focus      = "#ffffff"
theme.fg_focus      = "#ff9900"
theme.fg_urgent     = "#000000"
theme.fg_minimize   = "#ffffff"

theme.useless_gap   = 0
theme.border_width  = "1"
theme.border_normal = "#535d6c"
theme.border_focus  = "#ff9900"
theme.border_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_sel   = "/home/clauz/.config/awesome/defaultcla0/taglist/squarefw.png"
theme.taglist_squares_unsel = "/home/clauz/.config/awesome/defaultcla0/taglist/squarew.png"

theme.tasklist_floating_icon = "/home/clauz/.config/awesome/defaultcla0/tasklist/floatingw.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = "/home/clauz/.config/awesome/defaultcla0/submenu.png"
theme.menu_height = 15
theme.menu_width  = 100

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = "/home/clauz/.config/awesome/defaultcla0/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = "/home/clauz/.config/awesome/defaultcla0/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = "/home/clauz/.config/awesome/defaultcla0/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = "/home/clauz/.config/awesome/defaultcla0/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = "/home/clauz/.config/awesome/defaultcla0/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = "/home/clauz/.config/awesome/defaultcla0/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = "/home/clauz/.config/awesome/defaultcla0/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = "/home/clauz/.config/awesome/defaultcla0/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = "/home/clauz/.config/awesome/defaultcla0/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = "/home/clauz/.config/awesome/defaultcla0/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = "/home/clauz/.config/awesome/defaultcla0/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = "/home/clauz/.config/awesome/defaultcla0/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = "/home/clauz/.config/awesome/defaultcla0/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = "/home/clauz/.config/awesome/defaultcla0/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = "/home/clauz/.config/awesome/defaultcla0/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = "/home/clauz/.config/awesome/defaultcla0/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = "/home/clauz/.config/awesome/defaultcla0/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = "/home/clauz/.config/awesome/defaultcla0/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = "/home/clauz/.config/awesome/defaultcla0/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = "/home/clauz/.config/awesome/defaultcla0/titlebar/maximized_focus_active.png"

-- You can use your own command to set your wallpaper
-- theme.wallpaper = "/usr/share/awesome/themes/default/background.png"
-- theme.wallpaper_cmd = { "awsetbg /home/clauz/.config/awesome/defaultcla0/background.png" }
theme.wallpaper = "#000000"

-- You can use your own layout icons like this:
theme.layout_fairh = "/home/clauz/.config/awesome/defaultcla0/layouts/fairhw.png"
theme.layout_fairv = "/home/clauz/.config/awesome/defaultcla0/layouts/fairvw.png"
theme.layout_floating  = "/home/clauz/.config/awesome/defaultcla0/layouts/floatingw.png"
theme.layout_magnifier = "/home/clauz/.config/awesome/defaultcla0/layouts/magnifierw.png"
theme.layout_max = "/home/clauz/.config/awesome/defaultcla0/layouts/maxw.png"
theme.layout_fullscreen = "/home/clauz/.config/awesome/defaultcla0/layouts/fullscreenw.png"
theme.layout_tilebottom = "/home/clauz/.config/awesome/defaultcla0/layouts/tilebottomw.png"
theme.layout_tileleft   = "/home/clauz/.config/awesome/defaultcla0/layouts/tileleftw.png"
theme.layout_tile = "/home/clauz/.config/awesome/defaultcla0/layouts/tilew.png"
theme.layout_tiletop = "/home/clauz/.config/awesome/defaultcla0/layouts/tiletopw.png"
theme.layout_spiral  = "/home/clauz/.config/awesome/defaultcla0/layouts/spiralw.png"
theme.layout_dwindle = "/home/clauz/.config/awesome/defaultcla0/layouts/dwindlew.png"
theme.layout_cornernw = "/home/clauz/.config/awesome/defaultcla0/layouts/cornernww.png"
theme.layout_cornerne = "/home/clauz/.config/awesome/defaultcla0/layouts/cornernew.png"
theme.layout_cornersw = "/home/clauz/.config/awesome/defaultcla0/layouts/cornersww.png"
theme.layout_cornerse = "/home/clauz/.config/awesome/defaultcla0/layouts/cornersew.png"

theme.awesome_icon = "/usr/share/awesome/icons/awesome16.png"

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
