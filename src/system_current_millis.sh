#!/usr/bin/env bash

function system_current_millis() {
    # Mac OS should use gdate
    current=`date +%s.%N`
    second_part=`echo "$current" | awk -F '.' '{print $1}'`
    nano_part=`echo "$current" | awk -F '.' '{print $2}' | awk '{print $0+0}'`
    total=$((second_part * 1000000000 + nano_part))
    millis=$((total / 1000000))
    echo "$millis"
}
