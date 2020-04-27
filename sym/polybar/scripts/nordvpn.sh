#!/bin/sh
#
# Nordvpn status module for the Polybar status bar
# https://github.com/polybar/polybar


nordvpn_connect() {
    if ! type dmenunord >/dev/null 2>&1; then
        # dmenunord not installed, connect to recommended country
        nordvpn connect
        return
    fi

    dmenunord c || echo "%{F#D08770}invalid country%{A}%{F-}"
}


if ! type nordvpn >/dev/null 2>&1; then
    # nordvpn is not installed
    echo "%{F#D08770}nordvpn not installed%{F-}"
    exit
fi

# are we connecting?
if [ "$1" = "c" ]; then
    nordvpn_connect
    exit
fi


# get the current status
status="$(nordvpn status)"

if grep Connected <<< "$status" >/dev/null 2>&1; then
    echo "嬨 %{F#88C0D0}%{A1:nordvpn d:}$(grep City <<< "$status" | cut -d':' -f2)%{A}%{F-}"
else
    echo "%{F#4C566A}%{A1:$0 c:}嬨%{A}%{F-}"
fi
