#!/bin/sh -eu

dir="$HOME/docs"

cd -- "$dir"

find -L . -name '.?*' -prune -o -type f -print | sort | sed 's|^./||' |
dmenu -p 'Open document:' -r -i -F -s "$@" |
while read -r file; do
	if [ -n "$file" ]; then
		xdg-open "$dir/$file" &
	fi
done
