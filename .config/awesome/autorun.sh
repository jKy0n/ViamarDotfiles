#!/bin/sh

run() {
  if ! pgrep -f "$1" ;
  then
    "$@"&
  fi
}

picom --daemon &
sleep 1 && /usr/libexec/polkit-gnome-authentication-agent-1 &