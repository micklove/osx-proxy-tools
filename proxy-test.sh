#!/bin/bash

echo "Proxy Test"
CURL_TEST="curl -Is www.google.com | grep HTTP"
echo "${CURL_TEST}"
eval ${CURL_TEST}

