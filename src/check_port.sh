#!/usr/bin/env bash

# check the port of rest server is occupied
function check_port() {
    local port=$1
    lsof -i :"$port" >/dev/null

    if [ $? -eq 0 ]; then
        echo "The port $port has already used"
        exit 1
    fi
}
