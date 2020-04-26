#!/bin/sh
#
# Custom script for the 'hackthebox-vpn' module. Requires dmenu and iproute2.

set -o pipefail

# create the polybar_scripts temp folder
[ ! -d "/tmp/polybar_scripts/hackthebox-vpn" ] && mkdir -p "/tmp/polybar_scripts/hackthebox-vpn"

# check for dmenu and iproute2
type dmenu >/dev/null 2>&1 || (echo "dmenu is missing"; exit)
type ip >/dev/null 2>&1 || (echo "iproute2 is missing"; exit)

# directory to store temp files (store data)
module_home="/tmp/polybar_scripts/hackthebox-vpn"

# ==============================================================================

hackthebox_save_version () {
    echo "$1" > $module_home/ipversion
}

hackthebox_cycle () {
    current="$(cat $module_home/ipversion 2>/dev/null || echo '4')"

    case "$current" in
        4) hackthebox_save_version 6 ;;
        6) hackthebox_save_version 4 ;;
        *) echo "ERROR: unknown protocol"; hackthebox_save_version 4 ;;
    esac

    hackthebox_show
}

hackthebox_show () {
    current="$(cat $module_home/ipversion 2>/dev/null || echo '4')"

    [ ! -f "$module_home/connection" ] && (echo "%{F#4C566A} %{u-}"; exit)

    case "$current" in
        4) echo "$(ip -4 a show $1 2>/dev/null | grep inet | awk '{print $2}' | cut -d'/' -f1) %{F#A3BE8C} %{u-}" ;;
        6) echo "$(ip -6 a show $1 2>/dev/null | grep inet | awk '{print $2}' | cut -d'/' -f1 | head -1) %{F#A3BE8C} %{u-}" ;;
        *) echo -n "ERROR: unknown protocol" ;;
    esac
}

hackthebox_toggle_connection () {
    if [ ! -f "$module_home/connection" ]; then  # start a connection
        [ ! -d "$datadir" ] && (echo "ERROR: datadir ($datadir) missing"; exit 1)

        choice=$(for i in $datadir/*; do echo "$(basename $i)"; done | dmenu -i -p 'Select ovpn: ')

        if [ -f "$datadir/$choice" ]; then
            sudo -A openvpn $datadir/$choice >"$module_home/openvpn.log" 2>&1 &
            echo "$!" > "$module_home/connection"
        else
            echo "ERROR: missing ovpn file ($datadir/$choice)"
        fi

    else  # disconnect
        sudo -A kill -TERM "$(cat "$module_home/connection")"
        rm -f "$module_home/connection"
    fi
}

hackthebox_iface="tun0"
datadir="$HOME/CTF/htb/vpn"

while getopts ":d:xcsi:" op; do
    case "$op" in
        c) action=cycle ;;
        s) action=show ;;
        x) action=toggle ;;
        d) datadir="$OPTARG" ;;
        i) hackthebox_iface="$OPTARG" ;;
        :) echo "ERROR: -$OPTARG requires an argument"; exit 1 ;;
        *) echo "ERROR: unknown option"; exit 1 ;;
    esac
done

case "$action" in
    cycle) hackthebox_cycle ;;
    show) hackthebox_show "${hackthebox_iface:-tun0}" ;;
    toggle) hackthebox_toggle_connection ;;
    *) echo "ERROR: unknown action '$action'"; exit 1 ;;
esac
