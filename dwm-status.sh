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
	strength="$(iwconfig 2> /dev/null |
	            sed -n 's/.*Quality=\([0-9]*\).*/\1/p')"
	essid="$(iwconfig 2> /dev/null | sed -n 's/.*ESSID:"\(.*\)".*/\1/p')"
	if [ -z "$strength" ] || [ -z "$essid" ]; then
		printf 'Off'
	else
		printf '%s %3d' "$essid" "$(( 100 * strength / 70 ))"
	fi
}

cmd_battery()
{
	printf '%3d' "$(cat /sys/class/power_supply/BAT0/capacity)"
	if grep -q Charging < /sys/class/power_supply/BAT0/status; then
		printf '+'
	elif grep -q Discharging < /sys/class/power_supply/BAT0/status; then
		printf '-'
	fi
}

cmd_screen()
{
	brightness="$(xbacklight -get)"
	temp="$(redshift -p 2> /dev/null |
	        sed -n 's/.*temperature: \(.*\)/\1/p')"
	printf '%3.0f %5s' "$brightness" "$temp"
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
		printf '%3d' "$(( volume / n ))"
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
		'ﰵ' "$(cmd_upgrade)" \
		'' "$(cmd_wifi)" \
		'' "$(cmd_battery)" \
		'ﯧ' "$(cmd_screen)" \
		'' "$(cmd_volume)" \
		'' "$(cmd_date)") "
	xsetroot -name "$status"
done
