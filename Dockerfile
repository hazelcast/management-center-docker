ARG MC_VERSION=3.12.18
ARG MC_INSTALL_NAME="hazelcast-management-center-${MC_VERSION}"
ARG MC_INSTALL_WAR="hazelcast-mancenter-${MC_VERSION}.war"

FROM alpine:3.16.2 AS builder
ARG MC_VERSION
ARG MC_INSTALL_NAME
ARG MC_INSTALL_WAR

WORKDIR /tmp/build

ENV MC_INSTALL_ZIP="${MC_INSTALL_NAME}.zip"

RUN echo "Installing new APK packages" \
    && apk add --no-cache bash wget unzip procps nss

# Comment out following RUN command to build from a local artifact
RUN echo "Downloading Management Center" \
    && wget -O ${MC_INSTALL_ZIP} https://repository.hazelcast.com/download/management-center/${MC_INSTALL_ZIP} \
    && unzip ${MC_INSTALL_ZIP} -x ${MC_INSTALL_NAME}/docs/* \
    && mv ${MC_INSTALL_NAME}/${MC_INSTALL_WAR} ${MC_INSTALL_WAR} \
    && mv ${MC_INSTALL_NAME}/start.sh start.sh \
    && mv ${MC_INSTALL_NAME}/mc-conf.sh mc-conf.sh

# Uncomment following two lines to build from a local artifact
#COPY ${MC_INSTALL_WAR} .
#RUN unzip ${MC_INSTALL_WAR} start.sh mc-conf.sh

RUN chmod +x start.sh mc-conf.sh

FROM alpine:3.16.2
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
    MC_CLASSPATH="" \
    USER_NAME="hazelcast" \
    USER_UID=10001

RUN echo "Installing new APK packages" \
    && apk add --no-cache openjdk11-jre-headless bash \
    && mkdir -p ${MC_HOME} ${MC_DATA} \
    && chmod a+rwx ${MC_HOME} ${MC_DATA}

WORKDIR ${MC_HOME}

COPY --from=builder /tmp/build/${MC_INSTALL_WAR} .
COPY --from=builder /tmp/build/start.sh .
COPY --from=builder /tmp/build/mc-conf.sh .
COPY files/mc-start.sh .

VOLUME ["${MC_DATA}"]
EXPOSE ${MC_HTTP_PORT}
EXPOSE ${MC_HTTPS_PORT}
EXPOSE ${MC_HEALTH_CHECK_PORT}

RUN echo "Adding non-root user" \
    && adduser --uid $USER_UID --system --home $MC_HOME --shell /sbin/nologin $USER_NAME \
    && chown -R $USER_UID:0 $MC_HOME ${MC_DATA} \
    && chmod -R g=u "$MC_HOME" ${MC_DATA} \
    && chmod -R +r $MC_HOME ${MC_DATA}

# Switch to hazelcast user
USER ${USER_UID}

# Start Management Center
CMD ["bash", "mc-start.sh"]
