#!/usr/bin/env bash
picom --experimental-backend &
sleep 1 && /usr/libexec/polkit-gnome-authentication-agent-1 &
nice -n 15 dwmblocks &
feh --bg-scale ~/Pictures/WallPapers/Andromeda.jpg 
