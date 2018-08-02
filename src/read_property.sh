#!/usr/bin/env bash

# Read a property from .properties file
function read_property() {
    # file path
    file_name=$1
    key=$2
    # replace "." to "\."
    property_name=`echo $key | sed 's/\./\\\./g'`
    cat $file_name | sed -n -e "s/^[ ]*//g;/^#/d;s/^$property_name=//p" | tail -1
}
