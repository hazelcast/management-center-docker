FROM openjdk:11-jre-slim-sid

ENV MC_VERSION 3.12.10
ENV MC_HOME /opt/hazelcast/mancenter
ENV MC_DATA /data

ENV MC_HTTP_PORT 8080
ENV MC_HTTPS_PORT 8443
ENV MC_HEALTH_CHECK_PORT 8081
ENV MC_CONTEXT hazelcast-mancenter

ARG MC_INSTALL_NAME="hazelcast-management-center-${MC_VERSION}"
ARG MC_INSTALL_ZIP="${MC_INSTALL_NAME}.zip"
ARG MC_INSTALL_WAR="hazelcast-mancenter-${MC_VERSION}.war"

ENV MC_RUNTIME "${MC_HOME}/${MC_INSTALL_WAR}"

# Install wget to download management center
RUN apt-get update \
 && apt-get install --no-install-recommends --yes \
      wget unzip \
 && rm -rf /var/lib/apt/lists/*

# chmod allows running container as non-root with `docker run --user` option
RUN mkdir -p ${MC_HOME} ${MC_DATA} \
 && chmod a+rwx ${MC_HOME} ${MC_DATA}
WORKDIR ${MC_HOME}

# Prepare Management Center
RUN wget -O ${MC_HOME}/${MC_INSTALL_ZIP} \
          http://download.hazelcast.com/management-center/${MC_INSTALL_ZIP} \
 && unzip ${MC_INSTALL_ZIP} \
      -x ${MC_INSTALL_NAME}/docs/* \
 && rm -rf ${MC_INSTALL_ZIP} \
 && mv ${MC_INSTALL_NAME}/* . \
 && rm -rf ${MC_INSTALL_NAME}

# Runtime environment variables
ENV JAVA_OPTS_DEFAULT "-Dhazelcast.mancenter.home=${MC_DATA} -Djava.net.preferIPv4Stack=true"

ENV MIN_HEAP_SIZE ""
ENV MAX_HEAP_SIZE ""

ENV JAVA_OPTS ""
ENV MC_INIT_SCRIPT ""
ENV MC_INIT_CMD ""

ENV MC_CLASSPATH ""

COPY files/mc-start.sh /mc-start.sh
RUN chmod +x /mc-start.sh

VOLUME ["${MC_DATA}"]
EXPOSE ${MC_HTTP_PORT}
EXPOSE ${MC_HTTPS_PORT}
EXPOSE ${MC_HEALTH_CHECK_PORT}

# Start Management Center
CMD ["bash", "/mc-start.sh"]
