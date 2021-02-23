FROM registry.access.redhat.com/ubi8/ubi-minimal:8.3

ENV MC_VERSION 4.2021.02
ENV MC_HOME /opt/hazelcast/management-center
ENV MC_DATA /data

ENV MC_HTTP_PORT 8080
ENV MC_HTTPS_PORT 8443
ENV MC_HEALTH_CHECK_PORT 8081
ENV MC_CONTEXT_PATH /

ARG MC_INSTALL_NAME="hazelcast-management-center-${MC_VERSION}"
ARG MC_INSTALL_ZIP="${MC_INSTALL_NAME}.zip"
ARG MC_INSTALL_JAR="hazelcast-management-center-${MC_VERSION}.jar"

ENV MC_RUNTIME "${MC_HOME}/${MC_INSTALL_JAR}"

ENV MC_INSTALL_JAR="${MC_INSTALL_JAR}" \
    USER_NAME="hazelcast" \
    USER_UID=10001 \
    MC_HTTP_PORT="8080" \
    MC_HTTPS_PORT="8443" \
    MC_HEALTH_CHECK_PORT="8081" \
    LOGGING_LEVEL="" \
    MC_CONTEXT_PATH="/" \
    NO_CONTAINER_SUPPORT="false" \
    MIN_HEAP_SIZE="" \
    MAX_HEAP_SIZE="" \
    JAVA_OPTS="" \
    MC_INIT_SCRIPT="" \
    MC_INIT_CMD="" \
    MC_CLASSPATH="" \
    MC_ADMIN_USER="" \
    MC_ADMIN_PASSWORD=""

LABEL name="Hazelcast Management Center" \
      maintainer="info@hazelcast.com" \
      vendor="Hazelcast, Inc." \
      url="http://www.hazelcast.com" \
      version="${MC_VERSION}" \
      release="${MC_VERSION}" \
      summary="Hazelcast Management Center Image" \
      description="Starts Management Center web application dedicated to monitor and manage Hazelcast nodes"

# chmod allows running container as non-root with `docker run --user` option
RUN mkdir -p ${MC_HOME} ${MC_DATA} \
 && chmod a+rwx ${MC_HOME} ${MC_DATA}
WORKDIR ${MC_HOME}

# Add licenses
ADD licenses /licenses

### Atomic Help File
COPY help.1 /help.1

RUN echo "Installing new packages" \
    && microdnf -y --nodocs --disablerepo=* --enablerepo=ubi-8-appstream --enablerepo=ubi-8-baseos \
        --disableplugin=subscription-manager install shadow-utils java-11-openjdk-headless zip wget \
    && microdnf update -y  \
    && rm -rf /var/cache/dnf

# Prepare Management Center
RUN wget -O ${MC_HOME}/${MC_INSTALL_ZIP} \
          http://download.hazelcast.com/management-center/${MC_INSTALL_ZIP} \
 && unzip ${MC_INSTALL_ZIP} \
      -x ${MC_INSTALL_NAME}/docs/* \
 && rm -rf ${MC_INSTALL_ZIP} \
 && mv ${MC_INSTALL_NAME}/* . \
 && rm -rf ${MC_INSTALL_NAME}

# Runtime environment variables
ENV JAVA_OPTS_DEFAULT "-Dhazelcast.mc.home=${MC_DATA} -Djava.net.preferIPv4Stack=true"

ENV MIN_HEAP_SIZE ""
ENV MAX_HEAP_SIZE ""

ENV JAVA_OPTS ""
ENV MC_INIT_SCRIPT ""
ENV MC_INIT_CMD ""

ENV MC_CLASSPATH ""

COPY files/mc-start.sh ./bin/mc-start.sh
RUN chmod +x ./bin/mc-start.sh

VOLUME ["${MC_DATA}"]
EXPOSE ${MC_HTTP_PORT} ${MC_HTTPS_PORT} ${MC_HEALTH_CHECK_PORT}

RUN microdnf remove zip unzip wget \
    && microdnf -y clean all

RUN echo "Adding non-root user" \
    && adduser --uid $USER_UID --system --home $MC_HOME --shell /sbin/nologin $USER_NAME \
    && chown -R $USER_UID:0 $MC_HOME ${MC_DATA} \
    && chmod -R g=u "$MC_HOME" ${MC_DATA} \
    && chmod -R +r $MC_HOME ${MC_DATA}

# Switch to hazelcast user
USER ${USER_UID}

# Start Management Center
CMD ["bash", "./bin/mc-start.sh"]
