#!/bin/bash

# Volume Mute script
pactl set-sink-mute @DEFAULT_SINK@ toggle
aplay $HOME/.steam/tenfoot/resource/sounds/volume_change.wav &>/dev/null
