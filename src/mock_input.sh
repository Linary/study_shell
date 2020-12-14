#!/bin/bash

set -ev

# 选择时区，模拟输入，放到 XXG 区间
sudo tzselect << XXG
5
9
1
1
XXG
sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

sudo date -R
sudo timedatectl set-timezone "Asia/Shanghai"
