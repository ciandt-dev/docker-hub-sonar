FROM sonarqube:6.1

# define Docker image label information
LABEL com.ciandt.vendor="CI&T Software SA" \
      com.ciandt.release-date="2016-11-15" \
      com.ciandt.maintainers.1="Ivan Pinatti - @ivan_pinatti" \
      com.ciandt.maintainers.2="Thomas Bryan - @thobryan"

# copy Sonar plugins
COPY plugins /opt/sonarqube/extensions/plugins

# defines root user, to perform privileged operations
USER root

# upgrade packages, install security updates and required packages
RUN readonly PACKAGES=" \
                make \
                " \
    && apt-get update \
    && apt-get upgrade --assume-yes \
    && apt-get install --no-install-recommends \
                        --assume-yes \
                        ${PACKAGES} \
    # remove apt cache in order to improve Docker image size
    && apt-get clean

# receive arguments, otherwise use default
ARG SONAR_URL="sonar.local"
ARG SONAR_HTTPS_PORT="9000"
ARG KEYSTORE_PASSWORD="password"
ARG SSL_CERTIFICATE_COUNTRY="BR"
ARG SSL_CERTIFICATE_STATE="SP"
ARG SSL_CERTIFICATE_LOCATION="Campinas"
ARG SSL_CERTIFICATE_ORGANIZATION="CiandT Software SA"

# transform arguments in environment variables
ENV SONAR_URL ${SONAR_URL}
ENV SONAR_HTTPS_PORT ${SONAR_HTTPS_PORT}
ENV KEYSTORE_PASSWORD ${KEYSTORE_PASSWORD}
ENV SSL_CERTIFICATE_COUNTRY ${SSL_CERTIFICATE_COUNTRY}
ENV SSL_CERTIFICATE_STATE ${SSL_CERTIFICATE_STATE}
ENV SSL_CERTIFICATE_LOCATION ${SSL_CERTIFICATE_LOCATION}
ENV SSL_CERTIFICATE_ORGANIZATION ${SSL_CERTIFICATE_ORGANIZATION}
ENV SONAR_PROPERTIES_FILE=${SONARQUBE_HOME}/conf/sonar.properties

# copy scripts
RUN mkdir --parents /root/ciandt
COPY ciandt /root/ciandt

# configure Sonar to use HTTPS only
# RUN cd /root/ciandt && \
#     make configure-https
