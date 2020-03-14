#! /usr/bin/bash
# Sets right perspective when monitor is plugged in
# Needed by udev rule /etc/udev/rules.d/95-hotplug-monitor
export DISPLAY=:0
export XAUTHORITY=/home/archie/.Xauthority

function connect(){
    xrandr --output DP1 --right-of eDP1 --preferred --primary --output eDP1 --preferred
}

function disconnect(){
      xrandr --output DP1 --off
}

#xrandr | grep -w "DP1 connected" &> /dev/null && connect || disconnect

if [ $(cat /sys/class/drm/card0-DP-1/status) == "connected" ] ; then
  connect
elif [ $(cat /sys/class/drm/card0-DP-1/status) == "disconnected" ] ; then
  disconnect
else
  exit
fi

