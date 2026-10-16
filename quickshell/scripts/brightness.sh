#!/usr/bin/env bash

pkill -f "inotifywait -m -e modify /sys/class/backlight"

MAX=$(brightnessctl m)
STATE=$(brightnessctl g)
VALUE=$(( (STATE * 100) / MAX ))
echo "$VALUE"


inotifywait -m -e modify /sys/class/backlight/amdgpu_bl1/brightness -q |
while read -r f; do
    STATE=$(brightnessctl g)
    VALUE=$(( (STATE * 100) / MAX ))
    echo "$VALUE"
done