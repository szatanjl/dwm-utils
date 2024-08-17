#!/bin/sh -eu

dir="$HOME/.config/cmus/playlists"

cd -- "$dir"

find -L . -name '.?*' -prune -o -type f -print | sort | sed 's|^./||' |
dmenu -p 'Select playlist:' -r -i -F -s "$@" |
while read -r file; do
	if [ -z "${cleared+x}" ]; then
		cmus-remote -c -l
		cmus-remote -c -q
		cleared=1
	fi
	if [ -n "$file" ]; then
		cmus-remote -l "$dir/$file"
	fi
done
