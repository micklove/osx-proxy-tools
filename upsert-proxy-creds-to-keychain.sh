#!/bin/bash -e

source common.sh

# Usage
# $1 - Path to the json config file
# $2 - username

# script invokes the "add-generic-password" keychain method, to store proxy password details,
# under the service name given in the configuration file

# jq is a pre-requisite, for retrieving config from the json file
has_jq

declare CONFIG_FILE_PATH="${1}"
echo "CONFIG_FILE_PATH=${CONFIG_FILE_PATH}"
validate_config_file "${CONFIG_FILE_PATH}"

declare PROXY_USER="${2}"
declare PROXY_SERVICE_NAME_IN_KEYCHAIN=$(get_config_key "${CONFIG_FILE_PATH}" '.keychain."proxy-service-name-in-keychain"')
declare PROXY_USERNAME_REGEX=$(get_config_key "${CONFIG_FILE_PATH}" '.proxy."proxy-username-regex"')

usage()
{
  echo "Usage : ${0} <proxy user>"
  echo "where proxy user matches the following regex ${PROXY_USERNAME_REGEX}"
  exit 1
}

register_exit_handler
validate_proxy_user_name "${PROXY_USER}" "${PROXY_USERNAME_REGEX}"

# write password to osx keychain
#  - nb:
#    -w , with no value, will prompt user
#    -U , Update, if details already present
security add-generic-password \
  -a "${PROXY_USER}" \
  -s "${PROXY_SERVICE_NAME_IN_KEYCHAIN}" \
  -U \
  -w

if [[ $? == 0 ]]; then
  echo "Keychain for ${PROXY_SERVICE_NAME_IN_KEYCHAIN} updated with new password for ${PROXY_USER}"
else
  echo "Error, unable to update keychain service, ${PROXY_SERVICE_NAME_IN_KEYCHAIN}, with new password for ${PROXY_USER}"
fi
