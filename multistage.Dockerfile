ARG MC_VERSION=3.12.13-SNAPSHOT
ARG MC_INSTALL_NAME="hazelcast-management-center-${MC_VERSION}"
ARG MC_INSTALL_WAR="hazelcast-mancenter-${MC_VERSION}.war"

FROM alpine:3.12.1 AS builder
ARG MC_VERSION
ARG MC_INSTALL_NAME
ARG MC_INSTALL_WAR

WORKDIR /tmp/build

ENV MC_INSTALL_ZIP="${MC_INSTALL_NAME}.zip"

COPY ${MC_INSTALL_WAR} .

RUN echo "Installing new APK packages" \
    && apk add --no-cache unzip \
    && unzip ${MC_INSTALL_WAR} start.sh
    && chmod +x start.sh




FROM alpine:3.12.1
ARG MC_VERSION
ARG MC_INSTALL_NAME
ARG MC_INSTALL_WAR

ENV MC_HOME=/opt/hazelcast/mancenter \
    MC_DATA=/data

ENV MC_HTTP_PORT=8080 \
    MC_HTTPS_PORT=8443 \
    MC_HEALTH_CHECK_PORT=8081 \
    MC_CONTEXT=hazelcast-mancenter \
    MC_RUNTIME="${MC_HOME}/${MC_INSTALL_WAR}" \
    JAVA_OPTS_DEFAULT="-Dhazelcast.mancenter.home=${MC_DATA} -Djava.net.preferIPv4Stack=true" \
    MIN_HEAP_SIZE="" \
    MAX_HEAP_SIZE="" \
    JAVA_OPTS="" \
    MC_INIT_SCRIPT="" \
    MC_INIT_CMD="" \
    MC_CLASSPATH=""

RUN echo "Installing new APK packages" \
    && apk add --no-cache openjdk11-jre bash \
    && mkdir -p ${MC_HOME} ${MC_DATA} \
    && chmod a+rwx ${MC_HOME} ${MC_DATA}

WORKDIR ${MC_HOME}

COPY --from=builder /tmp/build/${MC_INSTALL_NAME}/${MC_INSTALL_WAR} .
COPY --from=builder /tmp/build/${MC_INSTALL_NAME}/start.sh .

VOLUME ["${MC_DATA}"]
EXPOSE ${MC_HTTP_PORT}
EXPOSE ${MC_HTTPS_PORT}
EXPOSE ${MC_HEALTH_CHECK_PORT}

# Start Management Center
CMD ["bash", "start.sh"]
