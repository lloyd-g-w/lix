#!/usr/bin/env bash
case $(wofi -d -L 7 -l 3 -W 100 -x -75 -y 0 \
    -D dynamic_lines=true << EOF | sed 's/^ *//'
    Shutdown
    Reboot
    Log off
    Sleep
    Lock
    Cancel
EOF
) in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Sleep")
        sh -c 'systemctl suspend && swaylock -l -c 3C3836'
        ;;
    "Lock")
        swaylock -l -c 3C3836
        ;;
    "Log off")
        hyprctl dispatch exit
        ;;
esac
