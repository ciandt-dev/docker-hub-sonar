# define phony targets
.PHONY: all configure-https configure-ldap

# define behavior for; make AND make all
all: configure-https configure-ldap

# configure SonarQube to use HTTPS only
configure-https:
	/root/ciandt/scripts/configure-https.sh

# configure SonarQube to use LDAP auth
configure-ldap:
	/root/ciandt/scripts/configure-ldap.sh
