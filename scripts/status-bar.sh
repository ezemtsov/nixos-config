#!/usr/bin/env bash

# Define the clock
Clock() {
    DATETIME=$(date "+%a %b %d | %H:%M")
    printf "$DATETIME"
}

# Define the batter
Battery() {
	  battery="$(</sys/class/power_supply/BAT0/capacity)"
	  printf "%s" "$battery%"
}

Network() {
    network=$(iw wlp61s0 link | grep -oP '(?<=SSID: ).*')
    if [ -z "$network" ]
    then
        network="Not connected"
    fi
    printf "%s" "$network"
}

Keyboard() {
    layout=$(xkblayout-state print %s)
    printf "%s" "$layout"
}

# Print the clock
while true; do
    status=(
        " | $(Clock) |"
        "$(Battery) |"
        "$(Keyboard) |"
        "$(Network) |"
    )
    echo "${status[*]}"
    sleep 1
done
