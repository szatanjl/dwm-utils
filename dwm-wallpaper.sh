#!/bin/sh -eu

while true; do
	feh --no-fehbg --bg-scale --randomize "$HOME/img/background"
	sleep "$(( 1 * 60 * 60 ))"
done
