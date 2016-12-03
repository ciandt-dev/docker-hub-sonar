#!/bin/bash

: ' Configure SonarQube to use HTTPS
    More information at: http://docs.sonarqube.org/display/SONARQUBE52/Running+SonarQube+Over+HTTPS

    '

# bash parameters
set -e  #   errexit  - Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
set -u  #   nounset  - Attempt to use undefined variable outputs error message, and forces an exit
set -x  #   xtrace   - Enable print commands and their arguments as they are executed.

# binaries
KEYTOOL=$(which keytool)
SED=$(which sed)

# get and check environment variables
_SONAR_PROPERTIES_FILE="${SONAR_PROPERTIES_FILE}"
_KEYSTORE_PASSWORD="${KEYSTORE_PASSWORD}"
_SONAR_URL="${SONAR_URL}"
_SONAR_HTTPS_PORT="${SONAR_HTTPS_PORT}"
_SSL_CERTIFICATE_COUNTRY="${SSL_CERTIFICATE_COUNTRY}"
_SSL_CERTIFICATE_STATE="${SSL_CERTIFICATE_STATE}"
_SSL_CERTIFICATE_LOCATION="${SSL_CERTIFICATE_LOCATION}"
_SSL_CERTIFICATE_ORGANIZATION="${SSL_CERTIFICATE_ORGANIZATION}"

# delete a pre-existing keystore
if [ -e "/root/.keystore" ]; then

  rm --force "/root/.keystore"

fi

# generate a rsa certificate
# more information at: http://docs.sonarqube.org/display/SONARQUBE52/Running+SonarQube+Over+HTTPS
"${KEYTOOL}"  -genkey \
              -keyalg RSA \
              -noprompt \
              -alias sonar \
              -dname "C=${_SSL_CERTIFICATE_COUNTRY}, ST=${_SSL_CERTIFICATE_STATE}, L=${_SSL_CERTIFICATE_LOCATION}, O=${_SSL_CERTIFICATE_ORGANIZATION}, OU=Org, CN=${_SONAR_URL}" \
              -keystore /root/.keystore \
              -storepass "${_KEYSTORE_PASSWORD}" \
              -keypass "${_KEYSTORE_PASSWORD}"

# disable http / enable https
"${SED}" --in-place \
          --regexp-extended \
          --expression \
            "s/.*sonar.web.port=.*/sonar.web.port=-1/g" \
          --expression \
            "s/.*sonar.web.https.port=-1/sonar.web.https.port="${SONAR_HTTPS_PORT}"/g" \
          --expression \
            "s/.*sonar.web.https.keyAlias=.*/sonar.web.https.keyAlias=sonar/g" \
          --expression \
            "s/.*sonar.web.https.keyPass=.*/sonar.web.https.keyPass="${_KEYSTORE_PASSWORD}"/g" \
          --expression \
            "s/.*sonar.web.https.keystorePass=.*/sonar.web.https.keystorePass="${_KEYSTORE_PASSWORD}"/g" \
          "${_SONAR_PROPERTIES_FILE}"
