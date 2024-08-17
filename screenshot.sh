#!/bin/sh -eu

if [ -z "${HOME-}" ]; then
	echo 'dwm-screenshot: $HOME not set' >&2
	exit 1
fi

dir="$HOME/tmp/screenshots"
bname="$dir/$(date '+%Y-%m-%d-%H-%M-%S')"
fname="$bname"

while [ -e "$fname.png" ]     || [ -e "$fname.scr.png" ] ||
      [ -e "$fname.mon.png" ] || [ -e "$fname.win.png" ]; do
	n="$(( ${n:-0} + 1 ))"
	fname="$bname.$n"
done

mkdir -p -- "$dir"

if [ "${1-}" = 'select' ]; then
	maim -um 1 -s -lc '0.3,0.3,0,0.1' -- "$fname.png"
else
	maim -um 1 -- "$fname.scr.png"
	if [ -n "${1-}" ]; then
		mon="$(xrandr --listmonitors | sed -e "/$1:/!d; s|/[0-9]*||g" \
		           -e 's/^.*: [^ ]* \([^ ]*\).*/\1/')"
		maim -um 1 -g "$mon" -- "$fname.mon.png"
	fi
	if [ -n "${2-}" ]; then
		maim -um 1 -i "$2" -- "$fname.win.png"
	fi
fi
