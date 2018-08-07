#!/usr/bin/env bash

function process_num() {
    num=`ps -ef | grep $1 | grep -v grep | wc -l`
    return $num
}

function process_id() {
    pid=`ps -ef | grep $1 | grep -v grep | awk '{print $2}'`
    return $pid
}

# wait_for_startup friendly_name host port timeout_s
function wait_for_startup() {
    local server_name="$1"
    local server_url="$2"
    local timeout_s="$3"

    local now_s=`date '+%s'`
    local stop_s=$(( $now_s + $timeout_s ))

    local status

    echo -n "Connecting to $server_name ($server_url)"
    while [ $now_s -le $stop_s ]; do
        echo -n .
        status=`curl -o /dev/null -s -w %{http_code} $server_url`
        if [ $status -eq 200 ]; then
            echo "OK"
            return 0
        fi
        sleep 2
        now_s=`date '+%s'`
    done

    echo "The operation timed out when attempting to connect to $server_url" >&2
    return 1
}

function free_memory() {
    local free=""
    local os=`uname`
    if [ "$os" == "Linux" ]; then
        local distributor=`lsb_release -a | grep 'Distributor ID' | awk -F':' '{print $2}' | tr -d "\t"`
        if [ "$distributor" == "CentOS" ]; then
            free=`free -m | grep '\-\/\+' | awk '{print $4}'`
        elif [ "$distributor" == "Ubuntu" ]; then
            free=`free -m | grep 'Mem' | awk '{print $7}'`
        else
            echo "Unsupported Linux Distributor " $distributor
        fi
    elif [ "$os" == "Darwin" ]; then
        free=`top -l 1 | head -n 10 | grep PhysMem | awk -F',' '{print $2}' \
             | awk -F'M' '{print $1}' | tr -d " "`
    else
        echo "Unsupported operating system " $os
        exit 1
    fi
    echo $free
}

function calc_xmx() {
    local min_mem=$1
    local max_mem=$2
    # Get machine available memory
    local free=`free_memory`
    local half_free=$[free/2]

    local xmx=$min_mem
    if [[ "$free" -lt "$min_mem" ]]; then
        exit 1
    elif [[ "$half_free" -ge "$max_mem" ]]; then
        xmx=$max_mem
    elif [[ "$half_free" -lt "$min_mem" ]]; then
        xmx=$min_mem
    else
        xmx=$half_free
    fi
    echo $xmx
}

function remove_with_prompt() {
    local path=$1
    local tips=""

    if [ -d "$path" ]; then
        tips="Remove directory '$path' and all sub files [y/n]?"
    elif [ -f "$path" ]; then
        tips="Remove file '$path' [y/n]?"
    else
        return 0
    fi

    read -p "$tips " yn
    case $yn in
        [Yy]* ) rm -rf "$path";;
        * ) ;;
    esac
}

function ensure_package_exist() {
    local path=$1
    local dir=$2
    local tar=$3
    local link=$4

    if [ ! -d ${path}/${dir} ]; then
        if [ ! -f ${path}/${tar} ]; then
            echo "Downloading the compressed package '${tar}'"
            download ${path} ${link}
            if [ $? -ne 0 ]; then
                echo "Failed to download, please ensure the network is available and link is valid"
                exit 1
            fi
            echo "[OK] Finished download"
        fi
        echo "Unzip the compressed package '$tar'"
        tar -zxvf ${path}/${tar} -C ${path} >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "Failed to unzip, please check the compressed package"
            exit 1
        fi
        echo "[OK] Finished unzip"
    fi
}

###########################################################################

function wait_for_shutdown() {
    local process_name="$1"
    local pid="$2"
    local timeout_s="$3"

    local now_s=`date '+%s'`
    local stop_s=$(( $now_s + $timeout_s ))

    echo -n "Killing $process_name(pid $pid)" >&2
    while [ $now_s -le $stop_s ]; do
        echo -n .
        process_status "$process_name" "$pid" >/dev/null
        if [ $? -eq 1 ]; then
            echo "OK"
            return 0
        fi
        sleep 2
        now_s=`date '+%s'`
    done
    echo "$process_name shutdown timeout(exceeded $timeout_s seconds)" >&2
    return 1
}

function process_status() {
    local process_name="$1"
    local pid="$2"

    ps -p "$pid"
    if [ $? -eq 0 ]; then
        echo "$process_name is running with pid $pid"
        return 0
    else
        echo "The process $process_name does not exist"
        return 1
    fi
}

function kill_process() {
    local process_name="$1"
    local pid="$2"

    if [ -z "$pid" ]; then
        echo "The process $pid does not exist"
        return 0
    fi

    case "`uname`" in
        CYGWIN*) taskkill /F /PID "$pid" ;;
        *)       kill "$pid" ;;
    esac
}

function kill_process_and_wait() {
    local process_name="$1"
    local pid="$2"
    local timeout_s="$3"

    kill_process "$process_name" "$pid"
    wait_for_shutdown "$process_name" "$pid" "$timeout_s"
}
