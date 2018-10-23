#!/bin/bash -e

export COMMON_LIB_PATH="$(dirname ${BASH_SOURCE[0]})/common.sh"
#echo "COMMON_LIB_PATH=${COMMON_LIB_PATH}"
source "${COMMON_LIB_PATH}"


# Run the vpn command, using the details from the config file
# On exit, clean up any routes and proxies

vpn_login() {
  declare VPN="${1}"
  sudo -p "${SUDO_PROMPT}" openconnect --juniper "${VPN}"
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

#
# Should only use the vpn config in the network Location from the config file
#
validate_location() {
    declare CONFIG_LOCATION_NAME=$(get_config_key "${CONFIG_FILE_PATH}" '.location.name')
    declare CURRENT_LOCATION="$(networksetup -getcurrentlocation)"
    if [[ "${CURRENT_LOCATION}" == "${CONFIG_LOCATION_NAME}" ]]; then
        echo "Using correct Location, [${CURRENT_LOCATION}]"
    else
        echo "Current location is [${CURRENT_LOCATION}], Switch to Location [${CONFIG_LOCATION_NAME}], before running vpn"
        echo "e.g. run-location.sh proxy-config.json my-vpn "
        exit 1
    fi
}

network_clean_up() {
    # Clear the traps
    trap - EXIT SIGHUP SIGINT SIGQUIT SIGILL SIGABRT SIGFPE SIGTERM
    printf "\nClean up Route:\n========================\nDeleting route for VPN Host [${VPN_HOST}]\n"
    sudo -p "${SUDO_PROMPT}" route delete "${VPN_HOST}"
    reset_DNS
}

validate_location

trap network_clean_up EXIT SIGHUP SIGINT SIGQUIT SIGILL SIGABRT SIGFPE SIGTERM

echo "VPN_URI=${VPN_URI}"
vpn_login "${VPN_URI}"
