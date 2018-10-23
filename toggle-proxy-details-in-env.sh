#!/bin/bash -e

# Ensure the script HAS been source'd
# (else the exported variables won't be available in the shell
usage() {
    printf "\nUsage:\n"
    echo "  Re-run the script using the 'source' command"
    printf "  (so that the exported variable(s) will be available in your shell)\n\n"
    echo "  e.g. source ${BASH_SOURCE[0]}"
    echo "  or   . ${BASH_SOURCE[0]}"
    exit 1
}

NOT_SOURCED_ERR_MSG="The script is not being 'sourced', run again with the source command"
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && echo "ERROR the script, ${BASH_SOURCE[0]}, is NOT being sourced ..." && usage

declare BASE_PATH="$(dirname ${BASH_SOURCE[0]})"
export COMMON_LIB_PATH="${BASE_PATH}/common.sh"
#echo "COMMON_LIB_PATH=${COMMON_LIB_PATH}"
source "${COMMON_LIB_PATH}"

declare CONFIG_FILE_PATH="${1}"
validate_config_file "${CONFIG_FILE_PATH}"

declare PROXY_HOST=$(scutil --proxy | grep HTTPProxy | awk {'print $3'})
declare PROXY_PORT=$(scutil --proxy | grep HTTPPort | awk {'print $3'})
declare PROXY_USERNAME_REGEX=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy."proxy-username-regex"')
declare PROXY_SCHEME=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy.scheme')
declare PROXY_SERVICE_NAME_IN_KEYCHAIN=$(get_config_key "${CONFIG_FILE_PATH}" '.keychain."proxy-service-name-in-keychain"')
declare PROXY_USER="$(get_proxy_user_from_keychain "${PROXY_SERVICE_NAME_IN_KEYCHAIN}" "${PROXY_USERNAME_REGEX}")"
declare PROXY_PASSWORD="$(get_proxy_password_from_keychain "${PROXY_SERVICE_NAME_IN_KEYCHAIN}")"
declare CONFIG_LOCATION_NAME=$(get_config_key "${CONFIG_FILE_PATH}" '.location.name')
declare CURRENT_LOCATION="$(networksetup -getcurrentlocation)"

declare USE_LOCAL_PROXY=$(get_config_key "${CONFIG_FILE_PATH}" '.localproxy.enabled')
declare PROXY_URI=""

# Only setup the proxy shell env if the correct osx network "Location" is currently selected
if [[ "${CURRENT_LOCATION}" == "${CONFIG_LOCATION_NAME}" ]]; then
    echo "Using correct Location, [${CURRENT_LOCATION}]"

    # If using local proxy, e.g. cntlm, or squid, on localhost don't use creds
    if [[ "${USE_LOCAL_PROXY}" == "true" ]]; then
        PROXY_USER=""
        PROXY_PASSWORD=""
        PROXY_URI=${PROXY_SCHEME}://${PROXY_HOST}:${PROXY_PORT}/
        echo "Using Local proxy URI=${PROXY_URI}"
    else
        PROXY_URI=${PROXY_SCHEME}://"${PROXY_USER}:${PROXY_PASSWORD}"\@${PROXY_HOST}:${PROXY_PORT}/
    fi

    source "${BASE_PATH}/add-proxy-details-to-shell.sh" "${PROXY_USER}" "${PROXY_HOST}" "${PROXY_PORT}" "${PROXY_URI}"
else
    echo "Current location is [${CURRENT_LOCATION}], Switch to Location [${CONFIG_LOCATION_NAME}], before setting up proxy config"
    echo "e.g. run-location.sh proxy-config.json my-vpn "
    echo "Cleaning up env proxy vars and quitting."
    clean_env_vars
fi
