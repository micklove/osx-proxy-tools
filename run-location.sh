#!/bin/bash -e

export COMMON_LIB_PATH="$(dirname ${BASH_SOURCE[0]})/common.sh"
#echo "COMMON_LIB_PATH=${COMMON_LIB_PATH}"
source "${COMMON_LIB_PATH}"


# e.g. ./run-location.sh ../proxy-config.json my-vpn
#      ./run-location.sh ../proxy-config.json home

# Script is used to switch between osx Network Locations.
# Location exists - Switch to it
# If the given Network Location does not exist, using "networksetup -listlocations",  the script will:
#   * Location is mentioned in the config file, but has not been created, it will create it.
#   * Else, the Location will be rejected.

create_location() {

    declare CONFIG_FILE_PATH=${1}
    declare LOCATION_NAME=${2}

    declare DNS_ENTRIES=$(get_config_key "${CONFIG_FILE_PATH}" '.location.dnsservers')

    # turn DNS entries into an array, so that following commands can use them as args
    declare -a DNSSERVERS=("${DNS_ENTRIES}")
    networksetup -createlocation ${LOCATION_NAME} populate
    networksetup -switchtolocation ${LOCATION_NAME}
    networksetup -setdnsservers Wi-Fi ${DNSSERVERS[@]}

    declare WIFI_SERVICE="Wi-Fi"
    if grep -q "${WIFI_SERVICE}" <(networksetup -listallnetworkservices|grep -v asterisk)
    then
        echo "Setting DNS for service [${WIFI_SERVICE}]"
        networksetup -setdnsservers ${WIFI_SERVICE} ${DNSSERVERS[@]}
    fi

    ## Setup LAN DNS
    declare LAN_SERVICE="Ethernet"
    if grep -q "${LAN_SERVICE}" <(networksetup -listallnetworkservices|grep -v asterisk)
    then
        echo "Setting DNS for service [${LAN_SERVICE}]"
        networksetup -setdnsservers ${LAN_SERVICE} ${DNSSERVERS[@]}
    fi
    dump_location_details
}


switch_location() {

    declare CONFIG_FILE_PATH=${1}
    declare LOCATION_NAME=${2}

    # Get the name of our location (to configure DNS, set proxy etc...) from the config file
    declare CONFIG_LOCATION_NAME=$(get_config_key "${CONFIG_FILE_PATH}" '.location.name')

    # have we already got a Location that matches?
    if ! grep -q "^${LOCATION_NAME}$" <(networksetup -listlocations)
    then
        # Location not found, do we need to create it?
        if [[ "${CONFIG_LOCATION_NAME}" == "${LOCATION_NAME}" ]]; then
            echo "Creating Location, [${CONFIG_LOCATION_NAME}],  using config file... ${1} "
            create_location "${CONFIG_FILE_PATH}" "${CONFIG_LOCATION_NAME}"
        else
            echo "[${LOCATION_NAME}] is not a valid network Location"
            exit 1
        fi
    else
        #valid Location found, do we need to switch to it?
        declare CURRENT_LOCATION="$(networksetup -getcurrentlocation)"
        if [[ "${CURRENT_LOCATION}" == "${LOCATION_NAME}" ]]; then
            echo "Already using Location, [${CURRENT_LOCATION}]"
        else
            echo "Switching from Location [${CURRENT_LOCATION}] to Location [${LOCATION_NAME}]"
            networksetup -switchtolocation "${LOCATION_NAME}"
            printf "\nUsing Location [${LOCATION_NAME}]"
            dump_location_details
        fi
    fi


}

validate_location_name() {
    if [ -z "${1}" ]; then
        echo "Location name [${1}] is invalid"
        exit 1
    fi
}

# jq is a pre-requisite, for retrieving config from the json file
has_jq

declare CONFIG_FILE_PATH="${1}"
validate_config_file "${CONFIG_FILE_PATH}"

validate_location_name "${2}"

#sudo create_proxy "${CONFIG_FILE_PATH}"
switch_location "${CONFIG_FILE_PATH}" "${2}"


