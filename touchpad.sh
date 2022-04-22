#!/bin/sh -eu

dev="$(xinput list --name-only | grep -i touchpad)"
action="$(xinput list-props "$dev" |
          sed -n -e 's/.*Device Enabled.*:.*0.*/enable/p' \
                 -e 's/.*Device Enabled.*:.*1.*/disable/p')"
xinput "$action" "$dev"
