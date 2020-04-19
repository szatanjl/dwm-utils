#!/bin/sh -eu

if [ "${1-}" = 'down' ]; then
	xbacklight -dec 10 -time 0 -steps 1
elif [ "${1-}" = 'up' ]; then
	xbacklight -inc 10 -time 0 -steps 1
fi

dwm-status brightness
