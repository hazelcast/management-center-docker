ARG MC_VERSION=4.2020.11-BETA-1
ARG MC_INSTALL_NAME="hazelcast-management-center-${MC_VERSION}"
ARG MC_INSTALL_JAR="hazelcast-management-center-${MC_VERSION}.jar"

FROM alpine:3.12.1 AS builder
ARG MC_VERSION
ARG MC_INSTALL_NAME
ARG MC_INSTALL_JAR

WORKDIR /tmp/build

ENV MC_INSTALL_ZIP="${MC_INSTALL_NAME}.zip"

# Comment out following RUN command to build from a local artifact
RUN echo "Installing new APK packages" \
    && apk add --no-cache bash wget unzip procps nss \
    && echo "Downloading Management Center" \
    && wget -O ${MC_INSTALL_ZIP} http://download.hazelcast.com/management-center/${MC_INSTALL_ZIP} \
    && unzip ${MC_INSTALL_ZIP} -x ${MC_INSTALL_NAME}/docs/* \
    && mv ${MC_INSTALL_NAME}/${MC_INSTALL_JAR} ${MC_INSTALL_JAR} \
    && mv ${MC_INSTALL_NAME}/bin/start.sh start.sh \
    && mv ${MC_INSTALL_NAME}/bin/mc-conf.sh mc-conf.sh

# Uncomment following two lines to build from a local artifact
#COPY ${MC_INSTALL_JAR} .
#RUN unzip ${MC_INSTALL_JAR} start.sh mc-conf.sh

RUN chmod +x start.sh mc-conf.sh

FROM alpine:3.12.1
ARG MC_VERSION
ARG MC_INSTALL_NAME
ARG MC_INSTALL_JAR

ENV MC_HOME=/opt/hazelcast/management-center \
    MC_DATA=/data

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

RUN echo "Installing new APK packages" \
    && apk add --no-cache openjdk11-jre bash \
    && apk add --no-cache rocksdb --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    && mkdir -p ${MC_HOME} ${MC_DATA} \
    && echo "Granting full access to ${MC_HOME} and ${MC_DATA} to allow running" \
        "container as non-root with \"docker run --user\" option" \
    && chmod a+rwx ${MC_HOME} ${MC_DATA}

WORKDIR ${MC_HOME}

COPY --from=builder /tmp/build/${MC_INSTALL_JAR} .
COPY --from=builder /tmp/build/start.sh ./bin/start.sh
COPY --from=builder /tmp/build/mc-conf.sh ./bin/mc-conf.sh
COPY files/mc-start.sh ./bin/mc-start.sh

VOLUME ["${MC_DATA}"]
EXPOSE ${MC_HTTP_PORT} ${MC_HTTPS_PORT} ${MC_HEALTH_CHECK_PORT}

RUN echo "Adding non-root user" \
    && adduser --uid $USER_UID --system --home $MC_HOME --shell /sbin/nologin $USER_NAME \
    && chown -R $USER_UID:0 $MC_HOME ${MC_DATA} \
    && chmod -R g=u "$MC_HOME" ${MC_DATA} \
    && chmod -R +r $MC_HOME ${MC_DATA}

# Switch to hazelcast user
USER ${USER_UID}

# Start Management Center
CMD ["bash", "./bin/mc-start.sh"]
