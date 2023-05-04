#!/bin/sh

run() {
  if ! pgrep -f "$1" ;
  then
    "$@"&
  fi
}

#picom -b --animations --animation-window-mass 0.5 --animation-for-open-window zoom --animation-stiffness 350 &
picom --daemon &
nice -n 19 xscreensaver &
sleep 1 && /usr/libexec/polkit-gnome-authentication-agent-1 &