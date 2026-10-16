#!/bin/bash

if pgrep -x "qs" > /dev/null; then
    qs ipc call applauncher toggle
else
    rofi -config ~/.config/rofi/menu_app/config.rasi -show drun -modes "drun,run"
fi
