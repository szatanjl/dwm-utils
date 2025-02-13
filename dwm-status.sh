#!/bin/sh -eu

cmd_upgrade()
{
	if [ -d /var/lib/pacman/update ]; then
		pacman --dbpath /var/lib/pacman/update -Qu
	else
		pacman -Qu
	fi | wc -l
}

cmd_wifi()
{
	essid="$(iwconfig 2> /dev/null | sed -n 's/.*ESSID:"\(.*\)".*/\1/p')"
	strength="$(iwconfig 2> /dev/null |
	            sed -n 's/.*Quality=\([0-9]*\).*/\1/p')"
	if [ -z "$essid" ] || [ -z "$strength" ]; then
		printf 'Off'
	else
		strength="$(( 100 * strength / 70 ))"
		if [ "$strength" -ge 100 ]; then
			strength=X0
		fi
		printf '%s %2s' "$essid" "$strength"
	fi
}

cmd_battery()
{
	capacity="$(cat /sys/class/power_supply/BAT0/capacity)"
	if [ "$capacity" -ge 100 ]; then
		printf 'X0 '
		return
	fi
	printf '%2d' "$capacity"
	if grep -q Charging < /sys/class/power_supply/BAT0/status; then
		printf '+'
	elif grep -q Discharging < /sys/class/power_supply/BAT0/status; then
		printf '-'
	else
		printf ' '
	fi
}

cmd_screen()
{
	brightness="$(xbacklight -get)"
	if [ "$brightness" -ge 100 ]; then
		brightness=X0
	fi
	temp="$(redshift -p 2> /dev/null |
	        sed -n 's/.*temperature: \(.*\)/\1/p')"
	printf '%2s %5s' "$brightness" "$temp"
}

cmd_volume()
{
	volume=0
	n=0
	if amixer -D default get Master 2> /dev/null | grep -q off; then
		printf 'Off'
		return 0
	fi
	for vol in $(amixer -D default get Master 2> /dev/null |
	             sed -n 's/.*\[\(.*\)%\].*/\1/p'); do
		volume="$(( volume + vol ))"
		n="$(( n + 1 ))"
	done
	if [ "$n" -eq 0 ]; then
		printf 'Error'
	else
		volume="$(( volume / n ))"
		if [ "$volume" -ge 100 ]; then
			volume=X0
		fi
		printf '%2s' "$volume"
	fi
}

cmd_date()
{
	date '+%a %d.%m %H:%M'
}

if [ -z "${XDG_RUNTIME_DIR:-${XDG_CACHE_HOME:-${HOME-}}}" ]; then
	printf '%s: cannot access or create pipe\n' "$(basename -- "$0")" >&2
	exit 1
fi

dir="${XDG_RUNTIME_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}}"
pipe="$dir/$(basename -- "$0")"

if [ "$#" -gt 0 ]; then
	[ -p "$pipe" ] || exit 1
	printf '%s\n' "$@" > "$pipe"
	exit 0
fi

mkdir -p -- "$dir"
[ -p "$pipe" ] || mkfifo -- "$pipe"

while true; do
	printf '*\n' > "$pipe"
	sleep 5
done &

while true; do
	cmd="$(cat -u -- "$pipe")"
	status="$(printf '@F#5294e2@ %s @F@%s' \
		'󰜷' "$(cmd_upgrade)" \
		'󰖩' "$(cmd_wifi)" \
		'' "$(cmd_battery)" \
		'󰛩' "$(cmd_screen)" \
		'' "$(cmd_volume)" \
		'󱑎' "$(cmd_date)")"
	xsetroot -name "$status"
done
