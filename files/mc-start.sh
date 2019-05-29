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
    export JAVA_OPTS="${JAVA_OPTS} -Xmx${MAX_HEAP_SIZE}"
fi

if [ -n "${MC_CLASSPATH}" ]; then
    export MC_CLASSPATH="${MC_RUNTIME}:${MC_CLASSPATH}"
else
    export MC_CLASSPATH="${MC_RUNTIME}"
fi

echo "########################################"
echo "# JAVA_OPTS=${JAVA_OPTS}"
echo "# MC_CLASSPATH=${MC_CLASSPATH}"
echo "# starting now...."
echo "########################################"

# --add-opens flag is required to prevent this issue: https://jira.spring.io/browse/SPR-15859
set -x
exec java \
    --add-opens java.base/java.lang=ALL-UNNAMED \
    -server ${JAVA_OPTS} \
    -cp "${MC_CLASSPATH}" \
    Launcher \
    ${MC_HTTP_PORT} \
    ${MC_HTTPS_PORT} \
    ${MC_CONTEXT}
