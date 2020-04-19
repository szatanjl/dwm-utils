#!/bin/sh -eu

if [ "${1-}" = 'toggle' ]; then
	amixer -qD default set Master toggle
elif [ "${1-}" = 'down' ]; then
	amixer -qD default set Master 5%-
elif [ "${1-}" = 'up' ]; then
	amixer -qD default set Master 5%+
fi

dwm-status volume
