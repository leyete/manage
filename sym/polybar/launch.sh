#!/usr/bin/bash
#
# Launch script for Polybar
set -eu -o pipefail

# terminate all polybar instances
killall -q polybar && while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# launch polybar on all monitors
for m in $(polybar --list-monitors | cut -d':' -f1); do
    WIRELESS=$(ls /sys/class/net/ | grep ^wl | awk 'NR==1{print $1}') \
    MONITOR=$m \
    polybar --reload top &

    WIRELESS=$(ls /sys/class/net/ | grep ^wl | awk 'NR==1{print $1}') \
    MONITOR=$m \
    polybar --reload bottom &
done
