#!/bin/sh -eu

dir="$HOME/docs"

cd -- "$dir"

find -L . -type f | sort | sed 's|^./||' |
dmenu -p 'Open document:' -r -i -F -s "$@" |
while read -r file; do
	if [ -n "$file" ]; then
		xdg-open "$dir/$file" &
	fi
done
