#!/bin/sh -eu

synclient TouchpadOff=$(synclient -l | sed -n 's/.*TouchpadOff.*= 0/1/p; s/.*TouchpadOff.*= 1/0/p')
