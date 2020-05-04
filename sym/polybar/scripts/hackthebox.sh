#!/bin/sh
#
# Custom script for the 'hackthebox-vpn' module. Requires dmenu and iproute2.


prepare_module() {
    # create the polybar_scripts temp folder
    [ ! -d "/tmp/polybar_scripts/hackthebox-vpn" ] && mkdir -p "/tmp/polybar_scripts/hackthebox-vpn"

    # check for dmenu and iproute2
    type dmenu >/dev/null 2>&1 || (echo "dmenu is missing"; exit)
    type ip >/dev/null 2>&1 || (echo "iproute2 is missing"; exit)

    # directory to store temp files (store data)
    module_home="/tmp/polybar_scripts/hackthebox-vpn"
}

hackthebox_ip () {
    case "$version" in
        4) ip -4 a show $1 2>/dev/null | grep inet | awk '{print $2}' | cut -d'/' -f1 ;;
        6) ip -6 a show $1 2>/dev/null | grep inet | awk '{print $2}' | cut -d'/' -f1 | head -1 ;;
        *) echo -n "ERROR: unknown protocol" ;;
    esac
}

module_run() {
    if [ ! -f "$module_home/connection" ]; then
        # disconnected
        echo "%{F#4C566A}%{A:$0 -d "$vpn_dir" -i "$hackthebox_iface" c:} %{A}%{F-}"
    else
        # connected
        echo "%{A:$0 d:}%{A3:$0 -i "$hackthebox_iface" -v $([ "$version" -eq 4 ] && echo "6" || echo "4"):}$(hackthebox_ip) %{F#A3BE8C} %{F-}%{A}%{A}"
    fi
}

vpn_connect() {
    [ -f "$module_home/connection" ] || [ ! -d "$vpn_dir" ] && return

    c=$(for i in "$vpn_dir"/*; do echo "$(basename $i)"; done | dmenu -fn 'Inconsolata Nerd Font:pixelsize=30' -i -p 'Select ovpn: ')
    if [ -f "$vpn_dir/$c" ]; then
        sudo -A openvpn "$vpn_dir/$c" > "$module_home/openvpn.log" 2>&1 &
        echo "$!" > "$module_home/connection"
    fi
}

vpn_disconnect() {
    [ ! -f "$module_home/connection" ] && return

    sudo -A kill -TERM "$(cat "$module_home/connection")"
    rm -f "$module_home/connection"
}


hackthebox_iface="tun0"
vpn_dir="$HOME/CTF/htb/vpn"
version="4"

while getopts ":d:i:v" op; do
    case "$op" in
        d) vpn_dir="$OPTARG" ;;
        i) hackthebox_iface="$OPTARG" ;;
        v) version="$OPTARG" ;;
        :) echo "ERROR: -$OPTARG requires an argument"; exit 1 ;;
        *) echo "ERROR: unknown option"; exit 1 ;;
    esac
done
shift $((OPTIND-1))

if [ "$#" -gt 0 ]; then
    case "$1" in
        c) vpn_connect ;;
        d) vpn_disconnect ;;
    esac
fi

module_run
