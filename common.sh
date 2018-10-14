#!/bin/bash -e

export SEPARATOR="\n------------\n"

# Utils, shared by the other scripts in this repo

# Simply tests the return code and writes an error on non-zero
on_exit() {
  typeset RET=$?
  if [ ${RET} -ne 0 ]; then
    printf "\n$(date '+%Y-%m-%d %H:%M:%S') - ERROR - Command failed with return code [${RET}]"
  fi
  exit ${RET}
}

#
# add to start of scripts, if exit handler is required
#
register_exit_handler() {
  trap on_exit EXIT SIGHUP SIGINT SIGQUIT SIGILL SIGABRT SIGFPE SIGTERM
}

# Ensure that the given proxy username matches the correct format (regex, from the config)
# - Exits on failure
validate_proxy_user_name() {
  declare PROXY_USER="${1}"
  declare PROXY_USER_REGEX="${2}"
  if [[ ! ${PROXY_USER} =~ ${PROXY_USER_REGEX} ]]; then
    printf "Invalid Username [${PROXY_USER}]\nPROXY_USER should match the regex, \"${2}\" "
    exit 1
  fi
}

has_jq() {
    if ! command -v "jq" 1>/dev/null 2>&1; then
      echo "jq is required, but is not installed, see https://stedolan.github.io/jq/"
      echo "use \"brew install jq\" to install"
      exit 1
    fi
}

# Use jq to retrieve the value, for the given key, from the config file
# e.g. get_config_key /blah/blah.json '.proxy.host'
function get_config_key() {
  declare CONFIG=${1}
  declare JSON_PROPERTY_PATH=${2}
  jq -r "${JSON_PROPERTY_PATH}" "${CONFIG}"
}

function validate_config_file() {
  declare CONFIG=${1}

  if [ ! -f "${CONFIG}" ]; then
    cat <<EOUSAGE
Usage: ${0} <config file>
    Where: config file is a json file, see README for details

Error: The Configuration file you supplied, [${CONFIG}],
does not exist, or you do not have access to it

EOUSAGE
    exit 1
  fi
}

# Retrieve the proxy username from the osx keychain, using the "service name"
# nb: Assumes the upsert script has previously added the key/password details to the osx keychain
function get_proxy_user_from_keychain() {
  declare PROXY_SERVICE_NAME_IN_KEYCHAIN=${1}
  declare PROXY_USERNAME_REGEX=${2}
  declare PROXY_USER=$(security find-generic-password -s "${PROXY_SERVICE_NAME_IN_KEYCHAIN}"  | grep "acct" | sed 's/.*=//g' | sed 's/\"//g')
  validate_proxy_user_name "${PROXY_USER}" "${PROXY_USERNAME_REGEX}"
  echo "${PROXY_USER}"
}

# Retrieve proxy user password from the osx keychain, using the "service name"
# nb: Assumes an upsert script has previously added the proxy username/password details to the osx keychain
function get_proxy_password_from_keychain() {
  declare PROXY_SERVICE_NAME_IN_KEYCHAIN=${1}
  declare PROXY_PASSWORD=$(security find-generic-password -s "${PROXY_SERVICE_NAME_IN_KEYCHAIN}" -w)
  echo "${PROXY_PASSWORD}"
}

function dump_proxy_state() {
    declare NETWORK_SERVICE_NAME=${1}
    printf "\n${NETWORK_SERVICE_NAME} - Web Proxy State:\n================\n"
    networksetup -getwebproxy "${NETWORK_SERVICE_NAME}"

    printf "\n${NETWORK_SERVICE_NAME} - Secure Web Proxy State:\n=======================\n"
    networksetup -getsecurewebproxy "${NETWORK_SERVICE_NAME}"

    printf "\n${NETWORK_SERVICE_NAME} - Bypassed Domains:\n==================\n"
    networksetup -getproxybypassdomains "${NETWORK_SERVICE_NAME}"
}

function set_proxy_state() {
    declare NETWORK_SERVICE_NAME=${1}
    declare PROXY_STATE=${2}

    echo "Set ${NETWORK_SERVICE_NAME} proxies state to [${PROXY_STATE}]"
    sudo networksetup -setwebproxystate "${NETWORK_SERVICE_NAME}" "${PROXY_STATE}"
    sudo networksetup -setsecurewebproxystate "${NETWORK_SERVICE_NAME}" "${PROXY_STATE}"
    dump_proxy_state "${NETWORK_SERVICE_NAME}"
}

function start_proxy() {
    declare NETWORK_SERVICE_NAME=${1}
    set_proxy_state "${NETWORK_SERVICE_NAME}" "on"
}

function stop_proxy() {
    declare NETWORK_SERVICE_NAME=${1}
    set_proxy_state "${NETWORK_SERVICE_NAME}" "off"
}

function status_proxy() {
    declare NETWORK_SERVICE_NAME=${1}
    dump_proxy_state "${NETWORK_SERVICE_NAME}"
}

#
# Dump dns details for service (e.g., WiFi, Ethernet, but only if available
#
dump_details_for_service() {
    declare SERVICE=${1}
    if grep -q "${SERVICE}" <(networksetup -listallnetworkservices|grep -v asterisk)
    then
        printf "\n\n${SERVICE} DNS:${SEPARATOR}$(networksetup -getdnsservers ${SERVICE})\n"
        dump_proxy_state ${SERVICE}
        networksetup -getinfo ${SERVICE}
    fi
}

dump_location_details() {

    printf "\nCurrent Location:${SEPARATOR}$(networksetup -getcurrentlocation)"
    dump_details_for_service "Wi-Fi"
    dump_details_for_service "Ethernet"
    printf "\nAvailable Locations:${SEPARATOR}$(networksetup -listlocations)\n"
}

clean_env_vars() {
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset http_proxy
    unset https_proxy
}

export -f register_exit_handler
export -f validate_proxy_user_name
export -f on_exit
export -f validate_config_file
export -f has_jq
export -f dump_location_details
export -f start_proxy
export -f status_proxy
export -f stop_proxy
export -f clean_env_vars
