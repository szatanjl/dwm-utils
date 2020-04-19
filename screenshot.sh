#!/bin/sh -eu

if [ -z "${HOME-}" ]; then
	echo 'dwm-screenshot: $HOME not set' >&2
	exit 1
fi

dir="$HOME/img/screenshots"
bname="$dir/$(date '+%Y-%m-%d-%H-%M-%S')"
fname="$bname.png"

while [ -e "$fname" ]; do
	n="$(( ${n:-0} + 1 ))"
	fname="$bname.$n.png"
done

mkdir -p -- "$dir"

if [ "${1-}" = 'select' ]; then
	maim -um 1 -s -lc '0.3,0.3,0,0.1' -- "$fname"
elif [ "${1-}" = 'monitor' ] && [ -n "${2-}" ]; then
	mon="$(xrandr --listmonitors | sed -e "/$2:/!d; s|/[0-9]*||g" \
	           -e 's/^.*: [^ ]* \([^ ]*\).*/\1/')"
	maim -um 1 -g "$mon" -- "$fname"
elif [ "${1-}" = 'window' ] && [ -n "${2-}" ]; then
	maim -um 1 -i "$2" -- "$fname"
else
	maim -um 1 -- "$fname"
fi
