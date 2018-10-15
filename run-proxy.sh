#!/bin/bash -e

source common.sh

# Prerequisite - upsert script has been run to add user / pass to osx keychain
# Creates a web proxy and secure proxy, in the Location, host, port, bypass domains, etc... mentioned in the config file
# nb: Uses proxy username and password from the keychain.

create_proxy() {

    declare CONFIG_FILE_PATH=${1}
    # nb: See below, json properties with a - in their name need to be quoted during filtering (see jq manual)
    declare PROXY_SERVICE_NAME_IN_KEYCHAIN=$(get_config_key "${CONFIG_FILE_PATH}" '.keychain."proxy-service-name-in-keychain"')
    declare PROXY_HOST=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy.host')
    declare PROXY_PORT=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy.port')
    declare PROXY_BYPASS_DOMAINS=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy."bypass-domains"')
    declare PROXY_USERNAME_REGEX=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy."proxy-username-regex"')

    declare PROXY_USER="$(get_proxy_user_from_keychain "${PROXY_SERVICE_NAME_IN_KEYCHAIN}" "${PROXY_USERNAME_REGEX}")"
    declare PROXY_PASSWORD="$(get_proxy_password_from_keychain "${PROXY_SERVICE_NAME_IN_KEYCHAIN}")"
    declare NETWORK_SERVICE_NAME="Wi-Fi"
    declare AUTH="on"
    declare PROXY_OWNER=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy.owner')

    #TODO - testing only
#    echo "CONFIG_FILE_PATH=${CONFIG_FILE_PATH}"
#    echo "PROXY_USER=${PROXY_USER}"
#    echo "PROXY_HOST=${PROXY_HOST}"
#    echo "PROXY_PORT=${PROXY_PORT}"
#    echo "PROXY_BYPASS_DOMAINS=${PROXY_BYPASS_DOMAINS}"

    echo "Creating proxy config for [${PROXY_OWNER}]"

    #e.g. networksetup -setwebproxy <networkservice> <domain> <port number> <authenticated> <username> <password>
    # ignore any errors written to stderr, as the return code appears to always be 0 :(
    sudo -p "${SUDO_PROMPT}" networksetup -setwebproxy "${NETWORK_SERVICE_NAME}" "${PROXY_HOST}" "${PROXY_PORT}" "${AUTH}" "${PROXY_USER}" "${PROXY_PASSWORD}" 2>/dev/null
    declare RET=$?
    if [ ${RET} -ne 0 ]; then
        printf "\n$(date '+%Y-%m-%d %H:%M:%S') - ERROR - Command failed with return code [${RET}]"
        exit ${RET}
    fi

    sudo -p "${SUDO_PROMPT}" networksetup -setsecurewebproxy "${NETWORK_SERVICE_NAME}" "${PROXY_HOST}" "${PROXY_PORT}" "${AUTH}" "${PROXY_USER}" "${PROXY_PASSWORD}" 2>/dev/null
    declare SECURE_RET=$?
    if [ ${SECURE_RET} -ne 0 ]; then
        printf "\n$(date '+%Y-%m-%d %H:%M:%S') - ERROR - Command failed with return code [${SECURE_RET}]"
        exit ${SECURE_RET}
    fi

    sudo -p "${SUDO_PROMPT}" networksetup -setproxybypassdomains "${NETWORK_SERVICE_NAME}" "${PROXY_BYPASS_DOMAINS}"
    dump_details_for_service "${NETWORK_SERVICE_NAME}"
}

#
# Should only create the proxies against the network Location from the config file
#
validate_location() {
    declare CONFIG_LOCATION_NAME=$(get_config_key "${CONFIG_FILE_PATH}" '.location.name')
    declare CURRENT_LOCATION="$(networksetup -getcurrentlocation)"
    if [[ "${CURRENT_LOCATION}" == "${CONFIG_LOCATION_NAME}" ]]; then
        echo "Using correct Location, [${CURRENT_LOCATION}]"
    else
        echo "Current location is [${CURRENT_LOCATION}], Switch to Location [${CONFIG_LOCATION_NAME}], before setting up proxy config"
        echo "e.g. run-location.sh proxy-config.json my-vpn "
        exit 1
    fi
}

# jq is a pre-requisite, for retrieving config from the json file
has_jq

declare CONFIG_FILE_PATH="${1}"
validate_config_file "${CONFIG_FILE_PATH}"

validate_location

#sudo -p "${SUDO_PROMPT}" create_proxy "${CONFIG_FILE_PATH}"
create_proxy "${CONFIG_FILE_PATH}"


