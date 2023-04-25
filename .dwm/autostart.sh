#!/usr/bin/env bash
feh --bg-scale ~/Pictures/WallPapers/Andromeda.jpg 
picom --experimental-backend &
nice -n 15 dwmblocks &
sleep 1 && /usr/libexec/polkit-gnome-authentication-agent-1 &