#!/bin/bash -e

source common.sh

# Run the vpn command, using the details from the config file
# On exit, clean up any routes and proxies

vpn_login() {
  declare VPN="${1}"
  sudo openconnect --juniper "${VPN}"
}

# jq is a pre-requisite, for retrieving config from the json file
has_jq

declare CONFIG_FILE_PATH="${1}"
echo "CONFIG_FILE_PATH=${CONFIG_FILE_PATH}"
validate_config_file "${CONFIG_FILE_PATH}"

# nb: See below, json properties with a - in their name need to be quoted during filtering (see jq manual)
declare VPN_HOST=$(get_config_key "${CONFIG_FILE_PATH}" '.vpn.host')
declare VPN_SCHEME=$(get_config_key "${CONFIG_FILE_PATH}" '.vpn.scheme')
declare VPN_URI="${VPN_SCHEME}://${VPN_HOST}"
declare NETWORK_SERVICE_NAME="Wi-Fi"


route_clean_up() {
    # Clear the traps
    trap - EXIT SIGHUP SIGINT SIGQUIT SIGILL SIGABRT SIGFPE SIGTERM
    printf "\nClean up proxy:\n========================\n"
    stop_proxy "${NETWORK_SERVICE_NAME}"
    printf "\nClean up Route:\n========================\nDeleting route for VPN Host [${VPN_HOST}]\n"
    sudo route delete "${VPN_HOST}"
}

trap route_clean_up EXIT SIGHUP SIGINT SIGQUIT SIGILL SIGABRT SIGFPE SIGTERM

#source ./run-proxy.sh "${CONFIG_FILE_PATH}"

echo "VPN_URI=${VPN_URI}"
vpn_login "${VPN_URI}"
