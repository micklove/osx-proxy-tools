#!/bin/bash -e

declare BASE_PATH="/etc/squid/"

#TODO - pass in json config ? (then add username / password)
# e.g.
# j2 --format=json squid.2.conf.j2   <(jq --arg USER $PROXY_USER    --arg PASSWORD $PROXY_PASSWORD    '.proxy=(.proxy + {proxyuser: $USER, proxypassword: $PASSWORD})'    < ../proxy-config.json)
create_squid_config() {

    declare BASE_PATH="/etc/squid/"
    declare OUTPUT_SQUID_CONFIG_PATH="${BASE_PATH}/squid.params.conf"
    declare PARENT_PROXY_USER=${1}
    declare PARENT_PROXY_PASSWORD=${2}
    declare CONFIG_FILE_PATH=${3}

    ## Simply add the user name and password to the "proxy" property in the json
    jq  --arg USER ${PARENT_PROXY_USER} \
        --arg PASSWORD ${PARENT_PROXY_PASSWORD} \
        '.proxy=(.proxy + {proxyuser: $USER, proxypassword: $PASSWORD})' \
        < ${CONFIG_FILE_PATH} \
        > ${OUTPUT_SQUID_CONFIG_PATH}
}

# Render the squid file, using environment variables
env | j2 "${BASE_PATH}/squid.conf.j2"  > "${BASE_PATH}/squid.conf"

# DELETE ME - debug only
#echo 'Rendered squid.conf:'
#cat "${BASE_PATH}/squid.conf"

# squid -z -F
# -X verbose debug logging
# -N Don't run in daemon mode - important for docker
printf  "\n\nAbout to start squid...\n"
squid  -NX
printf  "\n\nStarted squid...\n"
