#!/bin/bash

# Screen Toogle script
[ -z "$DISPLAY" ] && export DISPLAY=:0

# Find active output and all connected outputs
ALL_OUTPUTS=()
while IFS= read -r line; do
    ALL_OUTPUTS+=("$line")
done < <(xrandr | grep ' connected' | cut -f1 -d' ')
ACTIVE_OUTPUT=$(xrandr | awk '/ connected/ && /[[:digit:]]x[[:digit:]].*+/{print $1}')

# Find the next connected output to currently active one
for i in "${!ALL_OUTPUTS[@]}"; do
    if [ "${ALL_OUTPUTS[i]}" == "$ACTIVE_OUTPUT" ]; then
        if [ $((i+1)) == "${#ALL_OUTPUTS[@]}" ]; then
            NEXT_OUTPUT="${ALL_OUTPUTS[0]}"
        else
            NEXT_OUTPUT="${ALL_OUTPUTS[i+1]}"
        fi
    fi
done

# Write next connected output to config file
CONFIG_PATH=${XDG_CONFIG_HOME:-$HOME/.config}
CONFIG_FILE="$CONFIG_PATH/steamos-compositor-plus"
sed -i "s/.*OUTPUT_NAME.*/OUTPUT_NAME=$NEXT_OUTPUT/" $CONFIG_FILE

# Enable next output and disable everything else
XRANDRCMD="xrandr"
for i in "${ALL_OUTPUTS[@]}"; do
    if [ "$i" == "$NEXT_OUTPUT" ]; then
        XRANDRCMD="$XRANDRCMD --output $i --auto"
    else
        XRANDRCMD="$XRANDRCMD --output $i --off"
    fi
done 
$XRANDRCMD

# Run modesetting script for changed config file
export PATH=/usr/share/steamos-compositor-plus/bin:${PATH}
set_hd_mode.sh >> $HOME/.set_hd_mode.log

# Restart compositor
COMPOSITORCMD="steamcompmgr"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi
killall -w $COMPOSITORCMD
$COMPOSITORCMD &
