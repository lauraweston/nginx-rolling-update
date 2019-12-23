#!/usr/bin/env bash
set -e

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROUTE_CONFIG=$1

if [[ ! $ROUTE_CONFIG =~ ^(a|b|ab)$ ]]; then 
  echo "INVALID ROUTE CONFIG ARGUMENT: Must be one of a, b or ab"
  exit 1
fi

echo "Route config is $ROUTE_CONFIG"

$CONFIG_FILE=$CURRENT_DIR/nginx.conf

if [ "$ROUTE_CONFIG" == "a" ]; then
    sed -e -i "s/_a down;/_a;/g; s/_b;/_b down;/g;" $CONFIG_FILE
elif [ "$ROUTE_CONFIG" == "b" ]; then
    sed -e -i "s/_a;/_a down;/g; s/_b down;/_b;/g;" $CONFIG_FILE
else
    sed -e -i "s/_a down;/_a;/g; s/_b down;/_b;/g;" $CONFIG_FILE
fi

echo "Checking new config"
nginx -t -c

echo "Reloading nginx to pick up new config"
nginx -s reload

