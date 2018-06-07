#!/usr/bin/env bash

sudo find /etc/apt/sources.list.d -name '*.list' -type f -exec sed -i 's/^\([^#].*\)$/#\1/' {} \;
