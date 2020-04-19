#!/bin/sh -eu

progname=dwm-cmd
libexecdir="@libexecdir@"

if [ "${1:--h}" = '-h' ]; then
	printf 'Usage: %s CMD [ARGS...]\n' "$progname" >&2
	exit 2
fi

bin="$1"
shift

if [ ! -f "$libexecdir/$bin" ] || [ ! -x "$libexecdir/$bin" ]; then
	exit 1
fi

exec "$libexecdir/$bin" "$@"
