#!/bin/bash -e

# Script needs to be source'd to unset the vars in the current shell
unset HTTP_PROXY
unset HTTPS_PROXY
unset http_proxy
unset https_proxy

# Clean any proxy env vars created by these scripts
unset PROXY_USER
unset PROXY_PASSWORD
unset PROXY_BYPASS_ACL
unset PROXY_BYPASS_DOMAINS
unset PROXY_PARENT
unset PROXY_LOCAL_LISTENING_PORT
unset PROXY_PARENT_HOST
unset PROXY_PARENT_PORT

