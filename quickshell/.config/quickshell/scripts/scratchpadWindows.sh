#!/bin/bash

result="$(swaymsg -t get_tree | jq '.. | objects | select(.name == "__i3_scratch") | .floating_nodes | length')"
echo "$result"