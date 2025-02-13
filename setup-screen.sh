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
		elif [ "$r" -lt 530 ]; then
			echo '21x9'
		else
			echo '32x9'
		fi
	}
}

mon="${1-}"
alt="${2-}"

# Setup monitors
case "$mon-$alt" in
	1-|1-alt)
		xrandr --output eDP-1 --primary --auto \
		       --output DP-1 --off \
		       --output DP-2 --off \
		       --output HDMI-1 --off \
		       --output HDMI-2 --off
		primary='eDP-1'
		;;
	2-|2-alt)
		xrandr --output eDP-1 --off \
		       --output DP-1 --off \
		       --output DP-2 --off \
		       --output HDMI-1 --primary --auto \
		       --output HDMI-2 --off
		primary='HDMI-1'
		;;
	3-|3-alt)
		xrandr --output eDP-1 --primary --auto \
		       --output DP-1 --off \
		       --output DP-2 --off \
		       --output HDMI-1 --same-as eDP-1 \
		       --output HDMI-2 --off
		primary='eDP-1'
		;;
	4-|4-alt)
		xrandr --output eDP-1 --off \
		       --output DP-1 --primary --mode 5120x1440 --rate 75 \
		       --output DP-2 --off \
		       --output HDMI-1 --off \
		       --output HDMI-2 --off
		primary='DP-1'
		;;
	*)
		echo "setup-screen: incorrect arguments: $*" >&2
		exit 2
		;;
esac

# Remove monitor split
xrandr --delmonitor MON-a --delmonitor MON-b --delmonitor MON-c

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
case "$mon-$alt" in
	4-)
		xrandr --setmonitor MON-a "1920/446x1440/340+0+0" "$primary" \
		       --setmonitor MON-b "1920/446x1440/340+1920+0" none \
		       --setmonitor MON-c "1280/298x1440/340+3840+0" none
		;;
	4-alt)
		xrandr --setmonitor MON-a "1280/298x1440/340+0+0" "$primary" \
		       --setmonitor MON-b "2560/595x1440/340+1280+0" none \
		       --setmonitor MON-c "1280/298x1440/340+3840+0" none
		;;
esac
