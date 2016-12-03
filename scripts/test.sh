#!/usr/bin/env bash

: ' Tests a running Docker container

    TODO: Improve tests, maybe try to use Behat as testing tool
    '

# bash parameters
set -u  #   nounset  - Attempt to use undefined variable outputs error message, and forces an exit
set -e  #   errexit  - Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
#set -x  #   xtrace   - Enable print commands and their arguments as they are executed.

# binaries
DOCKER=$(which docker)
CURL=$(which curl)
JQ=$(which jq)

## simple login test
# more information at: http://docs.sonarqube.org/pages/viewpage.action?pageId=2392176
# parameters
SONAR_USER="admin"
SONAR_PASS="admin"

# test start message
echo "  _______________________________________________________________________________"
echo -e "\n  -- Docker Test - SonarQube\n\n  Performing simple login test\n  Please wait..."

# get container ip address
DOCKER_CONTAINER_IP=$("${DOCKER}" inspect --format \
                        "{{ .NetworkSettings.Networks.bridge.IPAddress }}" \
                        "${DOCKER_CONTAINER_NAME}" \
                        )

# get container sonar https port
DOCKER_SONAR_HTTPS_PORT=$("${DOCKER}" exec "${DOCKER_CONTAINER_NAME}"\
                          bash -c 'echo "${SONAR_HTTPS_PORT}"' \
                          )

# create a tmp file for cookie-jar
COOKIE_JAR=$(mktemp)

# disable bash errexit
set +e

# retrieve the login form from Sonar and initialize the cookie-jar
"${CURL}" --insecure \
          --silent \
          --retry 5 \
          --retry-delay 0 \
          --retry-max-time 60 \
          --cookie-jar \
            "${COOKIE_JAR}" \
          --output \
            /dev/null \
          https://"${DOCKER_CONTAINER_IP}":"${DOCKER_SONAR_HTTPS_PORT}"/api/authentication/validate

# create a tmp output file
OUTPUT_FILE=$(mktemp)

# tries to log in
"${CURL}" --insecure \
          --silent \
          --retry 5 \
          --retry-delay 0 \
          --retry-max-time 60 \
          --cookie-jar \
            "${COOKIE_JAR}" \
          --cookie \
            "${COOKIE_JAR}" \
          --location \
          --user \
            "${SONAR_USER}":"${SONAR_PASS}" \
          --output \
            "${OUTPUT_FILE}" \
          https://"${DOCKER_CONTAINER_IP}":"${DOCKER_SONAR_HTTPS_PORT}"/api/authentication/validate \
          > /dev/null

# check if login was OK and exit
if [ $("${JQ}" -r ".valid" "${OUTPUT_FILE}") == true ]; then

  echo -e "\n  SonarQube simple login test was successful!"
  echo -e "\n  _______________________________________________________________________________\n"

else

  echo -e "\n  ERROR! SonarQube simple login test was unsuccessful!"
  echo -e "\n  _______________________________________________________________________________\n"
  exit 1

fi
