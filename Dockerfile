# syntax=docker/dockerfile:1.4
ARG MC_VERSION=5.5.2
ARG MC_DOWNLOAD_BASE_PATH=https://repository.hazelcast.com/download/management-center

FROM alpine:3.20.3 AS builder
ARG MC_VERSION
ARG MC_DOWNLOAD_BASE_PATH

WORKDIR /tmp/build

COPY --link files/hazelcast-management-center.zip* /tmp/build/

RUN echo "Installing new APK packages"\
 && apk add --no-cache wget unzip

RUN if [[ ! -f hazelcast-management-center.zip ]]; then \
       echo "Downloading Management Center"; \
       wget -O hazelcast-management-center.zip -q --show-progress --progress=bar:force ${MC_DOWNLOAD_BASE_PATH}/hazelcast-management-center-${MC_VERSION}.zip; \
    else \
           echo "Using local hazelcast-management-center.zip"; \
    fi \
 && unzip hazelcast-management-center.zip\
 && rm -f hazelcast-management-center.zip

FROM redhat/ubi9-minimal:9.4
ARG MC_VERSION

ENV MC_HOME=/opt/hazelcast/management-center \
    MC_DATA=/data

ENV JAVA_OPTS_DEFAULT="-Dhazelcast.mc.home=${MC_DATA} -Djava.net.preferIPv4Stack=true" \
    USER_NAME="hazelcast" \
    USER_UID=10001 \
    MC_HTTP_PORT="8080" \
    MC_HTTPS_PORT="8443" \
    MC_HEALTH_CHECK_PORT="8081" \
    LOGGING_LEVEL="" \
    MC_CONTEXT_PATH="/" \
    CONTAINER_SUPPORT="true" \
    MIN_HEAP_SIZE="" \
    MAX_HEAP_SIZE="" \
    JAVA_OPTS="" \
    MC_INIT_SCRIPT="" \
    MC_INIT_CMD="" \
    MC_CLASSPATH="" \
    MC_ADMIN_USER="" \
    MC_ADMIN_PASSWORD=""

LABEL name="hazelcast/management-center-openshift-rhel" \
      vendor="Hazelcast, Inc." \
      version="8.1" \
      release="${MC_VERSION}" \
      url="http://www.hazelcast.com" \
      summary="Hazelcast Management Center Openshift Image, certified to RHEL 8" \
      description="Starts Management Center web application dedicated to monitor and manage Hazelcast nodes" \
      io.k8s.description="Starts Management Center web application dedicated to monitor and manage Hazelcast nodes" \
      io.k8s.display-name="Hazelcast Management Center" \
      io.openshift.expose-services="8080:http,8081:health_check,8443:https" \
      io.openshift.tags="hazelcast,java21,kubernetes,rhel8" \
      hazelcast.mc.revision="${MC_VERSION}" \
      org.opencontainers.image.authors="Hazelcast, Inc. Management Center Team <info@hazelcast.com>"

# Add licenses
COPY --link files/licenses /licenses

### Atomic Help File
COPY --link files/help.1 /help.1

RUN echo "Installing new packages"\
 && microdnf -y --nodocs upgrade\
 && microdnf -y --nodocs install java-21-openjdk\
 && rm -rf /var/cache/microdnf\
 && microdnf -y clean all\
 && mkdir -p ${MC_HOME} ${MC_DATA}\
 && echo "Granting full access to ${MC_HOME} and ${MC_DATA} to allow running container as non-root with \"docker run --user\" option"\
 && chmod a+rwx ${MC_HOME} ${MC_DATA}\
 && echo "Adding non-root user"\
 && adduser --uid ${USER_UID} --system --home ${MC_HOME} --shell /sbin/nologin ${USER_NAME}\
 && chown -R ${USER_UID}:0 ${MC_HOME} ${MC_DATA}\
 && chmod -R g=u ${MC_HOME} ${MC_DATA}\
 && chmod -R +r ${MC_HOME} ${MC_DATA}

WORKDIR ${MC_HOME}

COPY --link --from=builder --chown=$USER_UID:0 /tmp/build/hazelcast-management-center-*/*.jar .
COPY --link --from=builder --chmod=775 --chown=$USER_UID:0 /tmp/build/hazelcast-management-center-*/bin/mc-conf.sh /tmp/build/hazelcast-management-center-*/bin/hz-mc /tmp/build/hazelcast-management-center-*/bin/hz-mc ./bin/
COPY --link --chmod=775 --chown=$USER_UID:0 files/mc-start.sh ./bin/mc-start.sh

VOLUME ["${MC_DATA}"]
EXPOSE ${MC_HTTP_PORT} ${MC_HTTPS_PORT} ${MC_HEALTH_CHECK_PORT}

# Switch to hazelcast user
USER ${USER_UID}

# Start Management Center
CMD ["bash", "./bin/mc-start.sh"]
