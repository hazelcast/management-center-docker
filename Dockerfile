ARG MC_VERSION=latest-snapshot

FROM alpine:3.17.2 AS builder
ARG MC_VERSION

WORKDIR /tmp/build

RUN echo "Installing new APK packages"\
 && apk add --no-cache wget tar

RUN echo "Downloading Management Center"\
 && wget -q --show-progress --progress=bar:force\
 https://repository.hazelcast.com/download/management-center/hazelcast-management-center-${MC_VERSION}.tar.gz -O -\
 | tar --extract --ungzip --wildcards --no-anchored --strip-components 1\
 '*/bin/start.sh' '*/bin/mc-conf.sh' '*/bin/hz-mc' '*/hazelcast-management-center-*.jar'

FROM redhat/ubi8-minimal:8.7-1085
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
      io.openshift.tags="hazelcast,java17,kubernetes,rhel8" \
      hazelcast.mc.revision="${MC_VERSION}" \
      org.opencontainers.image.authors="Hazelcast, Inc. Management Center Team <info@hazelcast.com>"

# Add licenses
COPY files/licenses /licenses

### Atomic Help File
COPY files/help.1 /help.1

RUN echo "Installing new packages" \
 && microdnf upgrade --nodocs \
 && microdnf -y --nodocs install java-17-openjdk \
 && rm -rf /var/cache/microdnf \
 && microdnf -y clean all \
 && mkdir -p ${MC_HOME} ${MC_DATA} \
 && echo "Granting full access to ${MC_HOME} and ${MC_DATA} to allow running container as non-root with \"docker run --user\" option" \
 && chmod a+rwx ${MC_HOME} ${MC_DATA}

WORKDIR ${MC_HOME}

COPY --from=builder /tmp/build/*.jar .
COPY --from=builder --chmod=755 /tmp/build/bin/* ./bin/
COPY --chmod=755 files/mc-start.sh ./bin/mc-start.sh

VOLUME ["${MC_DATA}"]
EXPOSE ${MC_HTTP_PORT} ${MC_HTTPS_PORT} ${MC_HEALTH_CHECK_PORT}

RUN echo "Adding non-root user" \
 && adduser --uid $USER_UID --system --home $MC_HOME --shell /sbin/nologin $USER_NAME \
 && chown -R $USER_UID:0 $MC_HOME ${MC_DATA} \
 && chmod -R g=u $MC_HOME ${MC_DATA} \
 && chmod -R +r $MC_HOME ${MC_DATA}

# Switch to hazelcast user
USER ${USER_UID}

# Start Management Center
CMD ["bash", "./bin/mc-start.sh"]
