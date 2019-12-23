#!/usr/bin/env bash
set -e

ROUTE_CONFIG=$1

if [[ ! $ROUTE_CONFIG =~ ^(a|b|ab)$ ]]; then 
  echo "INVALID ROUTE CONFIG ARGUMENT: Must be one of a, b or ab"
  exit 1
fi

echo "Route config is $ROUTE_CONFIG"

if [ "$ROUTE_CONFIG" == "a" ]; then
    DOWN_NODE="b"
elif [ "$ROUTE_CONFIG" == "b" ]; then
    DOWN_NODE="a"
fi

CONFIG_FILE="nginx-${ROUTE_CONFIG}.conf"

if [ -n "${DOWN_NODE+set}" ]; then
    echo "Creating $CONFIG_FILE that sets all $DOWN_NODE nodes down"
    sed -e "s/_$DOWN_NODE;/_$DOWN_NODE down;/g" nginx_AB.conf > $CONFIG_FILE
fi

