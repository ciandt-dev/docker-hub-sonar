#!/bin/bash

: ' Configure SonarQube to LDAP auth
    More information at: http://docs.sonarqube.org/display/PLUG/LDAP+Plugin

    '

# bash parameters
set -e  #   errexit  - Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
set -u  #   nounset  - Attempt to use undefined variable outputs error message, and forces an exit
set -x  #   xtrace   - Enable print commands and their arguments as they are executed.

# binaries
CAT=$(which cat)

# get and check environment variables
_SONAR_PROPERTIES_FILE="${SONAR_PROPERTIES_FILE}"
_LDAP_REALM="${LDAP_REALM}"
_LDAP_SERVER="${LDAP_SERVER}"
_LDAP_PORT="${LDAP_PORT}"
_LDAP_USER="${LDAP_USER}"
_LDAP_PASSWORD="${LDAP_PASSWORD}"

"${CAT}" >> "${_SONAR_PROPERTIES_FILE}" << EOM

# LDAP General Configuration
sonar.security.realm=LDAP
sonar.authenticator.createUsers=true
sonar.security.savePassword=true
sonar.security.updateUserAttributes=true
ldap.realm=${_LDAP_REALM}
ldap.windows.auth=false
ldap.url=ldap://${_LDAP_SERVER}:${_LDAP_PORT}
ldap.bindDn=${_LDAP_USER}
ldap.bindPassword=${_LDAP_PASSWORD}

# LDAP User Configuration
ldap.user.request=(&(objectClass=user)(sAMAccountName={login}))
ldap.user.realNameAttribute=cn
ldap.user.emailAttribute=mail
EOM

"${CAT}" << EOM

LDAP is set in your Sonar configuration file
However, before be able to use it you need to restart Sonar
The easiest way is to restart your Docker container

docker stop sonar && docker start sonar

And finally, congratulations!!
LDAP is now configured in your Sonar!

EOM
