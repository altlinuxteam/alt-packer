#!/usr/bin/env bash
CMD="sed -i 's|^.*\(WHEEL_USERS ALL=(ALL) NOPASSWD: ALL\)$|\1|' /etc/sudoers"
sh -c "sleep 1; echo $PASS" \
    | script -qc "su -c \"${CMD}\""
