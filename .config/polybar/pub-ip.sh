#! /bin/bash

IP=$(drill)


if pgrep -x openvpn > /dev/null; then
    echo VPN: $IP
else
    echo   $IP
fi
