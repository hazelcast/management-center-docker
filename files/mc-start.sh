#!/usr/bin/env bash

set -euo pipefail
if [ -n "${JAVA_OPTS}" ]; then
    export JAVA_OPTS="${JAVA_OPTS_DEFAULT} ${JAVA_OPTS}"
else
    export JAVA_OPTS="${JAVA_OPTS_DEFAULT}"
fi

if [ "${CONTAINER_SUPPORT:-true}" = "false" ] ;then
    echo "using manual heap sizing by specifying MIN_HEAP_SIZE or MAX_HEAP_SIZE or custom settings configure by JAVA_OPTS"
    if [ -n "${MIN_HEAP_SIZE}" ]; then
        export JAVA_OPTS="${JAVA_OPTS} -Xms${MIN_HEAP_SIZE}"
    fi
    if [ -n "${MAX_HEAP_SIZE}" ]; then
        export JAVA_OPTS="${JAVA_OPTS} -Xmx${MAX_HEAP_SIZE}"
    fi
else
    echo "using automatic sizing of heap size by up to 80% of available memory and starting with container support"
    export JAVA_OPTS="${JAVA_OPTS} -XX:+UseContainerSupport -XX:MaxRAMPercentage=80"
fi

if [ -n "${MC_CLASSPATH}" ]; then
    export MC_CLASSPATH="${MC_RUNTIME}:${MC_CLASSPATH}"
else
    export MC_CLASSPATH="${MC_RUNTIME}"
fi

if [ -n "${MC_INIT_CMD}" ]; then
   echo "executing command specified by MC_INIT_CMD for container initialization"
   eval "${MC_INIT_CMD}"
fi

if [ -n "${MC_INIT_SCRIPT}" ]; then
    echo "loading script $MC_INIT_SCRIPT specified by MC_INIT_SCRIPT for container initialization"
    source ${MC_INIT_SCRIPT}
fi

if [ -n "${MC_ADMIN_USER}" ] && [ -n "${MC_ADMIN_PASSWORD}" ]; then
  echo "Creating admin user"
  source ./mc-conf.sh user create -H=${MC_DATA} -n=${MC_ADMIN_USER} -p=${MC_ADMIN_PASSWORD} -r=admin
  if [ $? -eq 0 ]; then
    echo "User created successfully"
  else
    exit 1
  fi
fi

echo "##################################################"
echo "# initialisation complete, starting now...."
echo "##################################################"

# --add-opens flag is required to prevent this issue: https://jira.spring.io/browse/SPR-15859
set -x
exec java \
    --add-opens java.base/java.lang=ALL-UNNAMED \
    -server ${JAVA_OPTS} \
    -cp "${MC_CLASSPATH}" \
    -Dhazelcast.mc.contextPath=${MC_CONTEXT_PATH} \
    -Dhazelcast.mc.http.port=${MC_HTTP_PORT} \
    -Dhazelcast.mc.https.port=${MC_HTTPS_PORT} \
    com.hazelcast.webmonitor.Launcher
