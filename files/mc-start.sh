#!/usr/bin/env bash

set -euo pipefail
if [ -n "${JAVA_OPTS}" ]; then
    export JAVA_OPTS="${JAVA_OPTS_DEFAULT} ${JAVA_OPTS}"
else
    export JAVA_OPTS="${JAVA_OPTS_DEFAULT}"
fi

if [ -n "${MIN_HEAP_SIZE}" ]; then
    export JAVA_OPTS="${JAVA_OPTS} -Xms${MIN_HEAP_SIZE}"
fi

if [ -n "${MAX_HEAP_SIZE}" ]; then
    export JAVA_OPTS="${JAVA_OPTS} -Xms${MAX_HEAP_SIZE}"
fi

echo "########################################"
echo "# JAVA_OPTS=${JAVA_OPTS}"
echo "# starting now...."
echo "########################################"

set -x
exec java \
    -server ${JAVA_OPTS} \
    -jar ${MC_RUNTIME} \
    ${MC_HTTP_PORT} \
    ${MC_HTTPS_PORT} \
    ${MC_CONTEXT}

