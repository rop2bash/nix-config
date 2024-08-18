#!/usr/bin/env bash
#
# the script does the following:
# 1. turn off monitor/s after 60 sec
# 2. sleep after 120 sec
# 3. lock before sleep
    # timeout 120 'systemctl suspend' \
swayidle -w \
    timeout 60 'hyprctl dispatch dpms off ' \
    resume 'hyprctl dispatch dpms on' \
    before-sleep 'swaylock'
