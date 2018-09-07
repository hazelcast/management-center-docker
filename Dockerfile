FROM openjdk:8-jre-slim

ENV MC_VERSION 3.10.3
ENV MC_HOME /opt/hazelcast/mancenter
ENV MC_DATA /data

ENV MC_HTTP_PORT 8080
ENV MC_HTTPS_PORT 8443
ENV MC_CONTEXT hazelcast-mancenter

ARG MC_INSTALL_NAME="hazelcast-management-center-${MC_VERSION}"
ARG MC_INSTALL_ZIP="${MC_INSTALL_NAME}.zip"
ARG MC_INSTALL_DIR="${MC_HOME}/${MC_INSTALL_NAME}"
ARG MC_INSTALL_WAR="hazelcast-mancenter-${MC_VERSION}.war"

ENV MC_RUNTIME "${MC_INSTALL_DIR}/${MC_INSTALL_WAR}"

# Install curl to download management center
RUN apt-get update \
 && apt-get install --no-install-recommends --yes \
      curl \
 && rm -rf /var/lib/apt/lists/*

# Comment out assistive_technologies configuration
# Without commenting this out, a "headless" Java installation causes a traceback on Management Center start
# Ref: https://askubuntu.com/a/723503
RUN sed -i -e 's/^assistive_technologies=/#assistive_technologies=/g' /etc/java-8-openjdk/accessibility.properties

# chmod allows running container as non-root with `docker run --user` option
RUN mkdir -p ${MC_HOME} ${MC_DATA} \
 && chmod a+rwx ${MC_HOME} ${MC_DATA}
WORKDIR ${MC_HOME}

# Prepare Management Center
RUN curl -svf -o ${MC_HOME}/${MC_INSTALL_ZIP} \
         -L http://download.hazelcast.com/management-center/${MC_INSTALL_ZIP} \
 && unzip ${MC_INSTALL_ZIP} \
      -x ${MC_INSTALL_NAME}/docs/* \
 && rm -rf ${MC_INSTALL_ZIP}

# Runtime environment variables
ENV JAVA_OPTS_DEFAULT "-Dhazelcast.mancenter.home=${MC_DATA} -Djava.net.preferIPv4Stack=true"

ENV MIN_HEAP_SIZE ""
ENV MAX_HEAP_SIZE ""

ENV JAVA_OPTS ""

VOLUME ["${MC_DATA}"]
EXPOSE 8080
EXPOSE 8443

# Start Management Center
CMD ["bash", "-c", "set -euo pipefail \
      && if [[ \"x${JAVA_OPTS}\" != \"x\" ]]; then export JAVA_OPTS=\"${JAVA_OPTS_DEFAULT} ${JAVA_OPTS}\"; else export JAVA_OPTS=\"${JAVA_OPTS_DEFAULT}\"; fi \
      && if [[ \"x${MIN_HEAP_SIZE}\" != \"x\" ]]; then export JAVA_OPTS=\"${JAVA_OPTS} -Xms${MIN_HEAP_SIZE}\"; fi \
      && if [[ \"x${MAX_HEAP_SIZE}\" != \"x\" ]]; then export JAVA_OPTS=\"${JAVA_OPTS} -Xms${MAX_HEAP_SIZE}\"; fi \
      && echo \"########################################\" \
      && echo \"# JAVA_OPTS=${JAVA_OPTS}\" \
      && echo \"# starting now....\" \
      && echo \"########################################\" \
      && set -x \
      && exec java -server ${JAVA_OPTS} -jar ${MC_RUNTIME} \
                ${MC_HTTP_PORT} ${MC_HTTPS_PORT} ${MC_CONTEXT} \
     "]
