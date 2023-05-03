-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

--local helpers = require "helpers"

-- Load Debian menu entries
--local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

local vicious = require("vicious")
local lain = require("lain")
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
local volume_widget = require('awesome-wm-widgets.volume-widget.volume')
local logout_menu_widget = require("awesome-wm-widgets.logout-menu-widget.logout-menu")

local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")

-- Global Menu by Fenetre
local fenetre = require("fenetre")
local titlebar = fenetre {
     title_edit = function()
        -- Remove " - Mozilla Firefox" from the ends of firefox's titles
        local firefox = " - Mozilla Firefox"
        local pri_brow = firefox .. " (Private Browsing)"
        if title:sub(-firefox:len()) == firefox or title:sub(-pri_brow:len()) == pri_brow then
            title = title:gsub(" %- Mozilla Firefox", "")
        end
    end,
    order = { "max", "ontop", "sticky", "floating", "title" }
 }


local free_focus = true
local function custom_focus_filter(c) return free_focus and awful.client.focus.filter(c) end


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
beautiful.init("/home/jkyon/.dotfiles/.config/awesome/themes/jKyon/theme.lua")



-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. "nano"
browser = "firefox"
fm = "thunar"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
     awful.layout.suit.tile,
     awful.layout.suit.floating,
     awful.layout.suit.tile.left,
--    awful.layout.suit.tile.bottom,
     awful.layout.suit.tile.top,
     awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
     awful.layout.suit.max,
--    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier,
--    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
     awful.layout.set(lain.layout.termfair, tag)

}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after =  { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
--                  { "Debian", debian.menu.Debian_menu.Debian },
                  menu_terminal,
                }
    })
end


mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
-- mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

local cw = calendar_widget({
    theme = 'nord',
    placement = 'top_right',
    start_sunday = true,
    radius = 8,
-- with customized next/previous (see table above)
    previous_month_button = 1,
    next_month_button = 3,
})
mytextclock:connect_signal("button::press",
    function(_, _, _, button)
        if button == 1 then cw.toggle() end
    end)

----------------------------------------------

tbox_separator_dash = wibox.widget.textbox (" - ")
tbox_separator = wibox.widget.textbox (" | ")
tbox_separator_space = wibox.widget.textbox (" ")
tbox_separator_temp = wibox.widget.textbox ("Temp:")
tbox_separator_Celsius = wibox.widget.textbox ("ºC")


local cpu = lain.widget.cpu {
    settings = function()
        widget:set_markup("CPU:" .. cpu_now.usage .. "%")
    end
}

local mem = lain.widget.mem {
    settings = function()
        widget:set_markup("MEM:" .. mem_now.perc .. "%")
    end
}


----------------------------------------------


-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
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

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)


--- Funcionou! Tá bom? não, mas funcionou ---
    awful.tag.add(" System ", {
    --    icon = "/home/jkyon/.dotfiles/.config/awesome/icons/system-run.svg",
        layout = awful.layout.suit.tile,
        selected = true,
        screen = s,
    })
    
    awful.tag.add(" Media ", {
--        icon = "/home/jkyon/.dotfiles/.config/awesome/icons/web-browser.png",
        layout = awful.layout.suit.tile,
        screen = s,
    })

    awful.tag.add(" Social ", {
--        icon = "/home/jkyon/.dotfiles/.config/awesome/icons/whatsie-tray.svg",
        layout = awful.layout.suit.tile,
        screen = s,
    })
    
    awful.tag.add(" Work ", {
--    --    icon = "/home/jkyon/.dotfiles/.config/awesome/icons/suitcase.png",
        layout = awful.layout.suit.tile.left,
        screen = s,
    })

    awful.tag.add(" Monitor ", {
--        icon = "/home/jkyon/.dotfiles/.config/awesome/icons/bar-graph.png",
        layout = awful.layout.suit.tile,
        screen = s,
    })

    awful.tag.add(" Free =) ", {
--        icon = "/home/jkyon/.dotfiles/.config/awesome/icons/bar-graph.png",
        layout = awful.layout.suit.tile,
        screen = s,
    })


awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
---    awful.tag({ " System ", " Midia ", " Social " , " Work ", " Monitor " }, s, awful.layout.layouts[1])    


    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top",
                              screen = s,
                              opacity = 0.9,
                              border_width = 2,
                              shape = gears.shape.rounded_bar
                    })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            tbox_separator_space,
            s.mylayoutbox,
            tbox_separator_space,
            tbox_separator_space,
--            mylauncher,
            s.mytaglist,
            s.mypromptbox,
            tbox_separator_space,
        },


        s.mytasklist, -- Middle widget
       
       
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
--            mykeyboardlayout,
            
            tbox_separator_space,
            tbox_separator_space,
            wibox.widget.textbox('  '),
            awful.widget.watch('bash -c "sh /home/jkyon/ShellScript/dwmBlocksUpdates"', 7200),
            tbox_separator,
            wibox.widget.textbox('  '),
            cpu.widget,
            wibox.widget.textbox('  '),
            awful.widget.watch('bash -c "sh /home/jkyon/ShellScript/dwmBlocksCpuTemp"', 2),            
            tbox_separator,
            tbox_separator_space,
            cpu_widget(),
            tbox_separator_space,
            -- tbox_separator,
            -- tempwidget,
            tbox_separator,
            wibox.widget.textbox('  '),
            mem.widget,
            tbox_separator_space,
            ram_widget({ color_used = '#2E3D55', color_buf = '#4B5B73' }),
            tbox_separator,
            volume_widget({ widget_type = 'arc' , thickness = 2 }),
            tbox_separator_space,
            tbox_separator_space,
            wibox.widget.systray(),
            tbox_separator_space,
  
            mytextclock,

            logout_menu_widget{
                 font = 'sans 9',
                 onlogout   =  function() awesome.quit() end,
                 onlock     =  function() awful.spawn.with_shell('xscreensaver-command -lock') end,
                 onsuspend  =  function() awful.spawn.with_shell("loginctl suspend") end,
                 onreboot   =  function() awful.spawn.with_shell("loginctl reboot") end,
                 onpoweroff =  function() awful.spawn.with_shell("loginctl poweroff") end,
            },
            tbox_separator_space

        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(


awful.key({}, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -D pulse sset Master 5%+", false) end),
awful.key({}, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -D pulse sset Master 5%-", false) end),
awful.key({}, "XF86AudioMute", function () awful.util.spawn("amixer -D pulse sset Master toggle", false) end),

awful.key({}, "XF86AudioNext", function () awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous", false) end),
awful.key({}, "XF86AudioPrev", function () awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next", false) end),

awful.key({}, "XF86AudioPlay", function () awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause", false) end),
awful.key({}, "XF86AudioStop", function () awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause", false) end),




    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
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
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

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

    awful.key({ }, "Print", function () awful.util.spawn("gnome-screenshot -i") end),
     
    awful.key({ modkey, "Control" }, "Escape", function () awful.util.spawn("loginctl suspend") end),



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
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

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
    -- awful.key({ modkey }, "p", function() menubar.show() end,
    --           {description = "show the menubar", group = "launcher"})


    awful.key({ modkey, }, "p", function ()
         awful.util.spawn("rofi -config ~/.config/rofi/config -show combi -combi-modi \"window,run\" -modi combi -theme ~/.config/rofi/config.rasi") end)
)

clientkeys = gears.table.join(
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
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
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

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

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
                     focus = custom_focus_filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     --placement = awful.placement.no_overlap+awful.placement.no_offscreen
                     placement = awful.placement.centered
     }
    },


    ---------      My rules    ---------
    
    { rule = { class = "Code" },
    properties = { floating = false, ontop = false,
    tag =  screen[1].tags[1],
    focus = false, placement = awful.placement.centered }},
    
    --  Try to make dialogs open floating at center
    -- { rule = { name = "Visual Studio Code" },
    -- properties = { floating = false, ontop = true,
    -- focus = true, placement = awful.placement.centered }},
    
    
    { rule = { name = "Discord" },
    properties = { floating = false, ontop = false,
    tag =  screen[1].tags[3],
    focus = false, placement = awful.placement.centered }},
    
    { rule = { instance = "gnome-calculator" },
    properties = { floating = true, ontop = false, 
    focus = true, placement = awful.placement.centered }},
    
    { rule = { class = "Gnome-screenshot" },
    properties = { floating = true, ontop = false, 
    focus = true, placement = awful.placement.centered }},
    
    { rule = { name = "Joplin" },
    properties = { floating = false, ontop = false,
    tag =  screen[1].tags[4],
    focus = false, placement = awful.placement.centered }},
    
    { rule = { instance = "lxappearance" },
    properties = { floating = true, ontop = false, 
    focus = true, placement = awful.placement.centered }},
    
    { rule = { instance = "openrgb" },
    properties = { floating = true, ontop = false, 
    focus = true, placement = awful.placement.centered }},
    
    { rule = { class = "rambox" },
    properties = { floating = false, ontop = false,
    tag =  screen[1].tags[3],
    focus = true, placement = awful.placement.centered }},
    
    { rule = { name = "Spotify" },
    properties = { floating = false, ontop = false,
    tag =  screen[1].tags[4],
    focus = false, placement = awful.placement.centered }},
    
    { rule = { instance = "Thunar" },
    properties = { floating = true, ontop = false, 
    focus = true, placement = awful.placement.centered }},
    
    { rule = { name = "Thunderbird" },
    properties = { floating = false, ontop = false,
    tag =  screen[1].tags[3],
    focus = false, placement = awful.placement.centered }},
    
    { rule = { instance = "virt-manager" },
    properties = { floating = true, ontop = false, 
    focus = true, placement = awful.placement.centered }},
    
    { rule = { class = "xpad" },
    properties = { floating = false, ontop = false, focus = false,
    placement = awful.placement.centered,
    tag =  screen[1].tags[1] },
    callback = function(c) c:geometry({x=25, y=25}) end },


  -- Fenetre GlobalMenu add
{ rule_any = { type = { "dialog", "normal" } }, properties = { titlebars_enabled = false } },


    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true },
      placement = awful.placement.centered
    },


-- {
--     rule = { class = "Plasma-desktop" },
--     properties = { floating = true },
--     callback = function(c)
--         c:geometry( { width = 600 , height = 500 } )
--     end,
-- },


    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end


          --- Rounded Corners ---
------------------------------------------------
client.connect_signal("manage", function (c)
    c.shape = gears.shape.rounded_rect
end)

client.connect_signal("manage", function (c)
    c.shape = function(cr,w,h)
        gears.shape.rounded_rect(cr,w,h,6)
    end
end)
-------------------------------------------------


    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )



   --  awful.titlebar(c, { position = "bottom" }) : setup {
   --       { -- Left
   --       awful.titlebar.widget.closebutton    (c),
   --       awful.titlebar.widget.floatingbutton (c),
   --       awful.titlebar.widget.maximizedbutton(c),
   --       --            awful.titlebar.widget.stickybutton   (c),
   --       --            awful.titlebar.widget.ontopbutton    (c),
   --       layout = wibox.layout.fixed.horizontal()
   --       },
   --       { -- Middle
   --          { -- Title
   --              align  = "center",
   --              widget = awful.titlebar.widget.titlewidget(c)
   --          },
   --          buttons = buttons,
   --          layout  = wibox.layout.flex.horizontal
   --      },
   --      { -- Right
   --      awful.titlebar.widget.iconwidget(c),
   --      buttons = buttons,
   --      layout  = wibox.layout.fixed.horizontal
   -- },
   --      layout = wibox.layout.align.horizontal
   --  }
end)



-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


--------------------  MyAdds   --------------------


--- Add gaps
beautiful.useless_gap = 2
beautiful.notification_position = bottom_right    -- not working

beautiful.systray_icon_spacing = 8

beautiful.tasklist_shape_urgent = gears.shape.rounded_rect
beautiful.tasklist_shape_minimized = gears.shape.rounded_rect
beautiful.tasklist_shape_bg = gears.shape.rounded_rect
beautiful.tasklist_shape_focus = gears.shape.rounded_rect
beautiful.taglist_shape_urgent = gears.shape.rounded_rect
beautiful.taglist_shape_bg = gears.shape.rounded_rect
beautiful.taglist_shape_focus = gears.shape.rounded_rect

beautiful.notification_shape = gears.shape.rounded_rect

beautiful.systray_icon_spacing = 10

awful.spawn.with_shell("~/.config/awesome/autorun.sh")
