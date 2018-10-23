#!/bin/bash -e

declare PROXY_USER=${1}
declare PROXY_HOST=${2}
declare PROXY_PORT=${3}
declare PROXY_URI=${4}

echo "PROXY_USER=[${PROXY_USER}]"
echo "PROXY_HOST=[${PROXY_HOST}]"
echo "PROXY_PORT=[${PROXY_PORT}]"

export  HTTP_PROXY="${PROXY_URI}"
export  http_proxy="${PROXY_URI}"
export HTTPS_PROXY="${PROXY_URI}"
export https_proxy="${PROXY_URI}"
