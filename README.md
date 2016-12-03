## CI&T SonarQube Docker base image

This Docker image intends to be a containerized baseline solution for SonarQube with pre-loaded plugins and scripts for easy deploy and management.

The source code is available under GPLv3 at Bitbucket in this [link](https://bitbucket.org/ciandt_it/docker-hub-sonar).

Basically, this image utilizes [SonarQube official Docker image](https://hub.docker.com/_/sonarqube/) as a source, then copy plugins (listed below), add scripts and configure it to run only HTTPS with a self-signed SSL certificate.

* * *

## [SonarQube Plugins](#plugins)

These are the plugins bundled.

- [Android 1.1](https://github.com/SonarQubeCommunity/sonar-android)
- [Csharp 5.2](http://docs.sonarqube.org/display/PLUG/C%23+Plugin)
- [CSS](https://github.com/SonarQubeCommunity/sonar-css)
- [Java 3.13.1](http://docs.sonarqube.org/display/PLUG/Java+Plugin)
- [Javascript 2.11](http://docs.sonarqube.org/display/PLUG/JavaScript+Plugin)
- [LDAP 1.5.1](http://docs.sonarqube.org/display/PLUG/LDAP+Plugin)
- [PhP 2.8](http://docs.sonarqube.org/display/PLUG/PHP+Plugin)
- [Resharper 2.0](http://docs.sonarqube.org/display/PLUG/ReSharper+Plugin)
- [Stylecop 1.1](http://docs.sonarqube.org/pages/viewpage.action?pageId=1441942)
- [Web-frontend-scss-2.0-SNAPSHOT](http://docs.sonarqube.org/display/PLUG/Web+Plugin)
- [Widget-lab 1.8.1](http://docs.sonarqube.org/display/DEV/Build+Plugin)

* * *

### [*Quick Start*](#quickstart)

__Download the image__

```
docker pull ciandtsoftware/sonar:5.4
```

__Run a container__

```
docker run \
  --name \
    myContainer \
  --detach \
    ciandtsoftware/sonar:5.4
```

__Check running containers__

```
docker ps --all
```

 * * *

## [CI&T scripts](#scripts)

There are available scripts to help customize SonarQube container:

- configure-https
- configure-ldap

Scripts are composed by two parts;

- one executable file *script-name*__.sh__
- one variables file *script-name*__.env__

The *script-name* __.env__ contains the variables that *script-name* __.sh__ requires to perform its task.

All scripts are located inside folder __/root/ciandt__ and must be declared in the *__Makefile__*. Thus, it is easy to run any of them.

Furthermore, it is possible to merge all the environment variables together and use an __env_file__ approach when running Docker, it is highly recommended!
More information about it can be found [here](https://docs.docker.com/compose/env-file/).

Since ***configure-https*** variables are already shiped in the image, you can run the container and compare environment variables with the ones in __configure-https.env__ by running:
```
export
```

Then you can run the commands to see the outcome:
```
cd /root/ciandt
make configure-https
```

It will gather required variables from environment, execute and produce the according output.

* * *

## [Running standalone](#running-standalone)

The simplest way of running the container without any modification

```
docker run ciandtsoftware/sonar:5.4
```

* * *

## [Customizing](#customizing)

As intended, you can take advantage from this image to build your own and already configure everything that a project requires.

Just to have an example, a Dockerfile sample downstream this image and configuring SonarQube to use LDAP (Microsoft Active Directory) authentication.

```
FROM ciandtsoftware/sonar:5.4

## configure-ldap
# define environment variables
ENV LDAP_REALM=contoso.local
ENV LDAP_SERVER=server.contoso.local
ENV LDAP_PORT=3268
ENV LDAP_USER=weird_admin@contoso.local
ENV LDAP_PASSWORD=MyStrongPassword1

# configure Sonar LDAP
RUN cd /root/ciandt && \
    make configure-ldap
```

* * *

## [Running in Docker-Compose](#running-docker-compose)

Since a project is not going to use solely SonarQube, it may need a Docker-Compose file.

Just to exercise, follow an example of __SonarQube__ running behind a __Nginx__ proxy. Create a new folder and fill with these 3 files and respective folders;

#### [__conf/sonar.local.env__](#sonar-env)

```
### SonarQube official environment variables
# database
SONARQUBE_JDBC_USERNAME=sonar
SONARQUBE_JDBC_PASSWORD=sonar
SONARQUBE_JDBC_URL=jdbc:h2:tcp://localhost:9092/sonar

## Nginx proxy configuration
# https://hub.docker.com/r/jwilder/nginx-proxy/
VIRTUAL_HOST=sonar.local
VIRTUAL_PORT=9000
VIRTUAL_PROTO=https
```

#### [__app/sonar/Dockerfile__](#dockerfile)

```
FROM ciandtsoftware/sonar:5.4

## configure-ldap
# define environment variables
ENV LDAP_REALM=contoso.local
ENV LDAP_SERVER=server.contoso.local
ENV LDAP_PORT=3268
ENV LDAP_USER=weird_admin@contoso.local
ENV LDAP_PASSWORD=MyStrongPassword1

# configure Sonar LDAP
RUN cd /root/ciandt && \
    make configure-ldap
```

#### [__docker-compose.yml__](#docker-compose)

```
sonar:
  build: ./sonar
  container_name: sonar
  env_file: ../conf/sonar.local.env

nginx:
  image: jwilder/nginx-proxy:latest
  container_name: nginx
  volumes:
    - /var/run/docker.sock:/tmp/docker.sock:ro
  ports:
    - "80:80"
    - "443:443"
```

Then just spin-up your Docker-Compose with the command:

```
docker-compose up -d
```

Inspect Nginx container IP address:

```
docker inspect --format \
              "{{.NetworkSettings.Networks.bridge.IPAddress }}" \
              "nginx"
```

Use the IP address to update __hosts__ file. Let's suppose that was 172.17.0.2.

Then, add an entry to __/etc/hosts__.
> 172.17.0.2 sonar.local

And now, try to access in the browser
> http://sonar.local

Voilà!
Your project now have Nginx and SonarQube up and running.
\\o/

* * *

## [Contributing](#contributing)

If you want to contribute, suggest improvements and report issues.
Please go to our [Bitbucket repository](https://bitbucket.org/ciandt_it/docker-hub-sonar).

* * *

Please feel free to drop a message in the comments section.

Happy coding, enjoy!!

"We develop people before we develop software" - Cesar Gon, CEO
