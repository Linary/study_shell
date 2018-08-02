#!/usr/bin/env bash

function ip() {
    local os=`uname`
    local loopback="127.0.0.1"
    local ip=""
    case $os in
        Linux) ip=`ifconfig | grep 'inet addr:'| grep -v "$loopback" | cut -d: -f2 | awk '{ print $1}'`;;
        FreeBSD|OpenBSD|Darwin) ip=`ifconfig  | grep -E 'inet.[0-9]' | grep -v "$loopback" | awk '{ print $2}'`;;
        SunOS) ip=`ifconfig -a | grep inet | grep -v "$loopback" | awk '{ print $2} '`;;
        *) ip=$loopback;;
    esac
    echo $ip
}
