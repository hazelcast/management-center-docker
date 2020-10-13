FROM openjdk:11.0.7-jre-slim

ARG MC_VERSION=4.2020.08
ARG MC_JAR="hazelcast-management-center-${MC_VERSION}.jar"
ARG MC_JAR_LOCATION="https://download.hazelcast.com/management-center/${MC_JAR}"

# Runtime constants / variables
ENV MC_HOME="/opt/hazelcast/management-center" \
    MC_JAR="${MC_JAR}" \
    MC_DATA="/data" \
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

RUN echo "Installing new APT packages" \
    && apt-get update \
    && apt-get install --no-install-recommends --yes curl \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ${MC_HOME} ${MC_DATA} \
    && echo "Granting full access to ${MC_HOME} and ${MC_DATA} to allow running" \
        "container as non-root with \"docker run --user\" option" \
    && chmod a+rwx ${MC_HOME} ${MC_DATA} \
    && echo "Downloading Hazelcast Management Center" \
    && curl --silent -o "${MC_HOME}/${MC_JAR}" -L "${MC_JAR_LOCATION}" \
    && cd ${MC_HOME}

VOLUME ["${MC_DATA}"]
EXPOSE ${MC_HTTP_PORT} ${MC_HTTPS_PORT} ${MC_HEALTH_CHECK_PORT}

COPY files/mc-start.sh /mc-start.sh

# Start Management Center
CMD ["bash", "/mc-start.sh"]
