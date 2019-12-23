#!/usr/bin/env bash
set -e

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROUTE_CONFIG=$1

if [[ ! $ROUTE_CONFIG =~ ^(a|b|ab)$ ]]; then 
  echo "INVALID ROUTE CONFIG ARGUMENT: Must be one of a, b or ab"
  exit 1
fi

echo "Route config is $ROUTE_CONFIG"

CONFIG_FILE="$CURRENT_DIR/nginx.conf"
echo "Config file is $CONFIG_FILE"

A_UP="s/_a down;/_a;/g"
A_DOWN="s/_a;/_a down;/g"
B_UP="s/_b down;/_b;/g"
B_DOWN="s/_b;/_b down;/g"

function updateConfigFile {
    sed -i.bak -e "$1" -e "$2" $CONFIG_FILE
}

if [ "$ROUTE_CONFIG" == "a" ]; then
    updateConfigFile "$A_UP" "$B_DOWN"
elif [ "$ROUTE_CONFIG" == "b" ]; then
    updateConfigFile "$A_DOWN" "$B_UP"
else
    updateConfigFile "$A_UP" "$B_UP"
fi

echo "Checking new config and reloading "
nginx -t && nginx -s reload
