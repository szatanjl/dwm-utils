#!/bin/sh -eu

if [ "${1-}" = 'prev' ]; then
	cmus-remote -r
elif [ "${1-}" = 'next' ]; then
	cmus-remote -n
elif [ "${1-}" = 'play' ]; then
	cmus-remote -u
fi

dwm-status music
