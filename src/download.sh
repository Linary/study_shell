#!/usr/bin/env bash

function download() {
    local path=$1
    local link_url=$2

    if command -v wget >/dev/null 2>&1; then
        wget --help | grep -q '\--show-progress' && progress_opt="-q --show-progress" || progress_opt=""
        wget ${link_url} -P ${path} $progress_opt
    elif command -v curl >/dev/null 2>&1; then
        curl ${link_url} -o ${path}/${link_url}
    else
        echo "Required wget or curl but they are not installed"
    fi
}
