#!/bin/sh -eu

ratio() {
	printf '%s' "$1" |
	sed -n "s/^$2"' .* \([0-9]*\)x\([0-9]*\)+.*/\1 \2/p' | {
		IFS=' ' read -r width height
		height="${height:-1}"
		lcm=90  # Least common multiple of 2,3,9,10
		r="$(( 2 * lcm * width / height ))"

		if [ "$r" -lt 255 ]; then
			echo '4x3'
		elif [ "$r" -lt 279 ]; then
			echo '3x2'
		elif [ "$r" -lt 304 ]; then
			echo '16x10'
		elif [ "$r" -lt 370 ]; then
			echo '16x9'
		else
			echo '21x9'
		fi
	}
}

mon="${1-}"
alt="${2-}"

# Setup monitors
case "$mon-$alt" in
	1-)
		xrandr --output eDP-1 --primary --auto \
		       --output DP-1 --off \
		       --output DP-2 --off \
		       --output HDMI-1 --off \
		       --output HDMI-2 --off
		primary='eDP-1'
		;;
	1-alt)
		xrandr --output eDP-1 --primary --auto \
		       --output DP-1 --off \
		       --output DP-2 --off \
		       --output HDMI-1 --same-as eDP-1 \
		       --output HDMI-2 --off
		primary='eDP-1'
		;;
	2-|2-alt)
		xrandr --output eDP-1 --off \
		       --output DP-1 --primary --auto \
		       --output DP-2 --off \
		       --output HDMI-1 --off \
		       --output HDMI-2 --off
		primary='DP-1'
		;;
	3-|3-alt)
		xrandr --output eDP-1 --off \
		       --output DP-1 --off \
		       --output DP-2 --off \
		       --output HDMI-1 --primary --auto \
		       --output HDMI-2 --off
		primary='HDMI-1'
		;;
	4-|4-alt)
		xrandr --output eDP-1 --off \
		       --output DP-1 --primary --auto \
		       --output DP-2 --off \
		       --output HDMI-1 --right-of DP-1 --auto \
		       --output HDMI-2 --off
		primary='DP-1'
		secondary='HDMI-1'
		;;
	*)
		echo "setup-screen: incorrect arguments: $*" >&2
		exit 2
		;;
esac

# Remove monitor split
xrandr --delmonitor MON-a --delmonitor MON-b

# Setup wallpaper
if [ -z "${XDG_DATA_HOME-}" ] && [ -z "${HOME-}" ]; then
	echo 'setup-screen: cannot set wallpaper' >&2
else
	wallpapers="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers"
	secondary="${secondary:-$primary}"
	setup="$(xrandr | sed '/^ /d')"
	wallpaper1="$wallpapers/$(ratio "$setup" "$primary")"
	wallpaper2="$wallpapers/$(ratio "$setup" "$secondary")"
	feh --no-fehbg --bg-scale "$wallpaper1" "$wallpaper2"
fi

# Split monitor
if [ -z "$alt" ] && [ "$mon" != 1 ]; then
	xrandr --setmonitor MON-a "2064/480x1440/330+0+0" "$primary" \
	       --setmonitor MON-b "1376/320x1440/330+2064+0" none
fi
