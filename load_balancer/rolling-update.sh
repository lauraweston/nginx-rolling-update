#!/usr/bin/env bash
#
# Perform rolling update to apps by stopping proxying traffic to A or B node and gracefully reloading nginx config (without restarting nginx).
#
# This script takes an argument of the node(s) for nginx to route traffic to: 'a', 'b' or 'ab'.
# The script is idempotent, so you can run './rolling-update.sh a' multiple times and the file will stay the same.
#
# Example:
# This will update the nginx config to mark all servers on 'a' node as up and all servers on 'b' node as down, making them unavailable to new traffic.
# All new traffic will be routed to node A.
#./rolling-update.sh a
#
# This will update the nginx config to mark all servers on 'b' node as up and all servers on 'a' node as down, making them unavailable to new traffic.
# All new traffic will be routed to node B.
#./rolling-update.sh b
#
# This will update the nginx config to mark all servers on 'a' and 'b' nodes as up (once the release has been completed).
# All traffic will be routed to both nodes A and B.
#./rolling-update.sh ab

# Exit on error
set -e

# Get current directory the script is in
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Assign first argument of script to ROUTE_CONFIG
ROUTE_CONFIG=$1

# Invalid arg error message
if [[ ! $ROUTE_CONFIG =~ ^(a|b|ab)$ ]]; then 
  echo "INVALID ROUTE CONFIG ARGUMENT: Must be one of a, b or ab"
  exit 1
fi

echo "Route config is $ROUTE_CONFIG"

# Regex used to edit nginx.conf
A_UP="s/_a down;/_a;/g" # E.g. globally substitute "_a down" with "_a"; see nginx docs: http://nginx.org/en/docs/http/ngx_http_upstream_module.html#server
A_DOWN="s/_a;/_a down;/g"
B_UP="s/_b down;/_b;/g"
B_DOWN="s/_b;/_b down;/g"

###################################################################################
# Updates the nginx.conf in place using the given regex arguments $1, $2
# Args: $1 = regex used to edit A node, $2 = regex used to edit B node
# Notes: 
# - sed command requires .bak backup file suffix to be given in order to work
# - To change nginx configurations, the nginx config file must be edited in place and reloaded, rather than providing a new .conf file to load. 
#   See: https://docs.nginx.com/nginx/admin-guide/basic-functionality/runtime-control/
###################################################################################
function updateNginxConfigFile {
  CONFIG_FILE="$CURRENT_DIR/nginx.conf"
  echo "Updating $CONFIG_FILE"
  sed -i.bak -e "$1" -e "$2" $CONFIG_FILE
}

# Determine which node to route traffic to during apps release
if [ "$ROUTE_CONFIG" == "a" ]; then
  updateNginxConfigFile "$A_UP" "$B_DOWN"
elif [ "$ROUTE_CONFIG" == "b" ]; then
  updateNginxConfigFile "$A_DOWN" "$B_UP"
else
  updateNginxConfigFile "$A_UP" "$B_UP"
fi

# Reload nginx config with updated routing configuration
echo "Checking new nginx config and reloading"
# -t validates config file, -s sends signal to reload config file
nginx -t && nginx -s reload
