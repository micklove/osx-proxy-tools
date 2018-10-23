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

declare COMMON_LIB_PATH="$(dirname ${BASH_SOURCE[0]})/../common.sh"
#echo "COMMON_LIB_PATH=${COMMON_LIB_PATH}"
ls ${COMMON_LIB_PATH}
source "${COMMON_LIB_PATH}"


declare CONFIG_FILE_PATH="${1}"
#echo "CONFIG_FILE_PATH=${CONFIG_FILE_PATH}"
validate_config_file "${CONFIG_FILE_PATH}"

export PROXY_LOCAL_LISTENING_PORT="3128"
declare PROXY_USERNAME_REGEX=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy."proxy-username-regex"')
declare PROXY_SERVICE_NAME_IN_KEYCHAIN=$(get_config_key "${CONFIG_FILE_PATH}" '.keychain."proxy-service-name-in-keychain"')

export PROXY_USER="$(get_proxy_user_from_keychain "${PROXY_SERVICE_NAME_IN_KEYCHAIN}" "${PROXY_USERNAME_REGEX}")"
export PROXY_PASSWORD="$(get_proxy_password_from_keychain "${PROXY_SERVICE_NAME_IN_KEYCHAIN}")"
export PROXY_PARENT_HOST=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy.host')
export PROXY_PARENT_PORT=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy.port')
export PROXY_BYPASS_DOMAINS=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy."bypass-domains"')
export PROXY_BYPASS_ACL=$(get_config_key "${CONFIG_FILE_PATH}" '.localproxy."acl"')

