#!/bin/bash -e

source common.sh


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
        echo "Cleaning up env proxy vars and quitting."
        clean_env_vars
    fi
}

declare CONFIG_FILE_PATH="${1}"
validate_config_file "${CONFIG_FILE_PATH}"


declare PROXY_HOST=$(scutil --proxy | grep HTTPProxy | awk {'print $3'})
declare PROXY_PORT=$(scutil --proxy | grep HTTPPort | awk {'print $3'})
declare PROXY_USERNAME_REGEX=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy."proxy-username-regex"')
declare PROXY_SCHEME=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy.scheme')
declare PROXY_SERVICE_NAME_IN_KEYCHAIN=$(get_config_key "${CONFIG_FILE_PATH}" '.keychain."proxy-service-name-in-keychain"')
declare PROXY_USER="$(get_proxy_user_from_keychain "${PROXY_SERVICE_NAME_IN_KEYCHAIN}" "${PROXY_USERNAME_REGEX}")"
declare PROXY_PASSWORD="$(get_proxy_password_from_keychain "${PROXY_SERVICE_NAME_IN_KEYCHAIN}")"

echo "CONFIG_FILE_PATH=${CONFIG_FILE_PATH}"
echo "PROXY_USER=${PROXY_USER}"
echo "PROXY_HOST=${PROXY_HOST}"
echo "PROXY_PORT=${PROXY_PORT}"

declare PROXY_URI=${PROXY_SCHEME}://"${PROXY_USER}:${PROXY_PASSWORD}"\@${PROXY_HOST}:${PROXY_PORT}/
export  HTTP_PROXY="${PROXY_URI}"
export  http_proxy="${PROXY_URI}"
export HTTPS_PROXY="${PROXY_URI}"
export https_proxy="${PROXY_URI}"

validate_location
