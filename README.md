
# Hazelcast Management Center

Hazelcast Management Center enables you to monitor and manage your cluster members running Hazelcast IMDG. In addition to monitoring the overall state of your clusters, you can also analyze and browse your data structures in detail, update map configurations and take thread dumps from members. You can run scripts (JavaScript, Groovy, etc.) and commands on your members with its scripting and console modules.

You can check [Hazelcast IMDG Documentation](http://docs.hazelcast.org/docs/latest/manual/html-single/) and [Management Center Documentation](http://docs.hazelcast.org/docs/management-center/latest/manual/html/index.html) for more information.

## Table of Content
 - [Quick Start]
 - [Mounting Management Center Home Directory]
 - [Enabling TLS/SSL]
 - [Hazelcast Member Configuration]
 - [Changing Logging Level]
 - [Using Custom Log4j Configuration File]
 - [Starting with an Extra Classpath]
 - [Enabling Health Check Endpoint]
 - [Customizing Container Setup]
 - [Start with a Preconfigured Admin User]
 - [JVM Heap Configuration]
 - [Configuring Management Center Inside Your Custom Docker Image]

## Quick Start
[Quick Start]: #quick-start

You can launch Hazelcast Management Center by simply running the following command. Please check available 
versions for `$MANAGEMENT_CENTER` on [Docker Hub](https://hub.docker.com/r/hazelcast/management-center/tags).

```
docker run --rm -p 8080:8080 hazelcast/management-center:$MANAGEMENT_CENTER
```

**NOTE:** Please, make sure you are not using `latest` tag, because 3.x and 4.x versions are not compatible. 
You can check [Supported Environments](https://docs.hazelcast.org/docs/management-center/latest/manual/html/index.html#supported-environments)
section for more info on version compatibility between Management Center and Hazelcast/Hazelcast Jet clusters.

Now you can access Hazelcast Management Center from your browser using the URL `http://localhost:8080`. 

If you are running the Docker image in the cloud, you should use a public IP of your machine instead of `localhost`. 

Both `docker ps` and `docker inspect <container-id>` can be used to find `host-ip`. Once you find out `host-ip`, 
you can browse Hazelcast Management Center using the URL: `http://host-ip:8080`.

By default, the container automatically sizes the Java heap memory suitable to the specified resource limit or 
available memory.

### Management Center Default Context Path

Before version 4.0, default context path was `/hazelcast-mancenter`, so you would access Hazelcast 
Management Center by using `http://localhost:8080/hazelcast-mancenter`. Starting with version 4.0, 
it is changed to root context path (i.e. `/`), so you can access it by using `http://localhost:8080`.

You can override this default by setting the environment variable `MC_CONTEXT_PATH`.

## Mounting Management Center Home Directory
[Mounting Management Center Home Directory]: #mounting-management-center-home-directory

Management Center uses the file system to store persistent data. However, that is by default inside the Docker 
container and destroyed in case of container restarts. If you want to store Management Center data externally, 
you need to create a mount to a folder named `/data`. See the following for how to create a mount point. 
`PATH_TO_PERSISTENT_FOLDER` must be replaced by your persistent folder.

```
docker run --rm -p 8080:8080 -v PATH_TO_PERSISTENT_FOLDER:/data hazelcast/management-center:$MANAGEMENT_CENTER
```

To provide a license key, the command line argument `-Dhazelcast.mc.license` can be used (requires version 3.9.3 or newer):

```
docker run --rm -e JAVA_OPTS='-Dhazelcast.mc.license=<key>' -p 8080:8080 hazelcast/management-center:$MANAGEMENT_CENTER
```

## Enabling TLS/SSL
[Enabling TLS/SSL]: #enabling-tlsssl

To enable TLS/SSL, you need to provide the keystore and expose the default port (`8443`):

```
docker run --rm \
         -e JAVA_OPTS='-Dhazelcast.mc.tls.enabled=true \
         -Dhazelcast.mc.tls.keyStore=/keystore/yourkeystore.jks \
         -Dhazelcast.mc.tls.keyStorePassword=yourpassword' \
         -v PATH_TO_KEYSTORE_DIR:/keystore \
         -p 8443:8443 \
         hazelcast/management-center
```

The default port can be changed by overriding the `MC_HTTPS_PORT` environment variable. For example, 
you can run the following command to use port `8444`:

```
docker run --rm -e MC_HTTPS_PORT=8444 \
        -e JAVA_OPTS='-Dhazelcast.mc.tls.enabled=true \
        -Dhazelcast.mc.tls.keyStore=/keystore/yourkeystore.jks \
        -Dhazelcast.mc.tls.keyStorePassword=yourpassword' \
        -v PATH_TO_KEYSTORE_DIR:/keystore \
        -p 8444:8444 \
        hazelcast/management-center
```

Please refer to 
[Management Center Reference Manual](https://docs.hazelcast.org/docs/management-center/latest/manual/html/index.html#enabling-tslssl-when-starting-with-jar-file) 
for more information on available options.

## Hazelcast Member Configuration
[Hazelcast Member Configuration]: #hazelcast-member-configuration

For the Hazelcast member configuration and the sample Hello World example, please refer to 
[Hazelcast Docker repository](https://github.com/hazelcast/hazelcast-docker).

## Changing Logging Level
[Changing Logging Level]: #changing-logging-level

The logging level can be changed using the `LOGGING_LEVEL` environment variable. For example, to see the `DEBUG` logs:

```
$ docker run -e LOGGING_LEVEL=DEBUG hazelcast/management-center
```

Available logging levels are (from highest to lowest): `OFF`, `FATAL`, `ERROR`, `WARN`, `INFO`, `DEBUG`, `TRACE` and `ALL`. 
Invalid levels will be assumed `OFF`.

Note that if you need a more customized logging configuration, you can specify a configuration file.

```
$ docker run -v <config-file-path>:/opt/hazelcast/log4j2-custom.properties hazelcast/hazelcast
```

## Using Custom Log4j Configuration File
[Using Custom Log4j Configuration File]: #using-custom-log4j-configuration-file

Management Center can use your custom Log4j configuration file. You need to create a mount to a folder named 
`/opt/hazelcast/mc_ext`, see the following on how to do it. `PATH_TO_PERSISTENT_FOLDER` must be replaced with 
the path to the folder that your custom Log4j configuration file resides in. `CUSTOM_LOG4J_FILE` must be 
replaced with the name of your custom Log4j configuration file, for example `log4j2-custom.properties`.

```
docker run -e JAVA_OPTS='-Dlog4j.configurationFile=/opt/hazelcast/mc_ext/CUSTOM_LOG4J_FILE' \
           -v PATH_TO_LOCAL_FOLDER:/opt/hazelcast/mc_ext \
           -p 8080:8080 \
           hazelcast/management-center
```

## Starting with an Extra Classpath
[Starting with an Extra Classpath]: #starting-with-an-extra-classpath

You can start Management Center with an extra classpath entry (for example, when using JAAS authentication) 
by using the `MC_CLASSPATH` environment variable:

```
docker run -e MC_CLASSPATH='/path/to/your-extra.jar' -p 8080:8080 hazelcast/management-center
```

## Enabling Health Check Endpoint
[Enabling Health Check Endpoint]: #enabling-health-check-endpoint

When running Management Center, you can enable the Health Check endpoint:

```
docker run -p 8080:8080 -p 8081:8081 \
           -e JAVA_OPTS='-Dhazelcast.mc.healthCheck.enable=true' \
           hazelcast/management-center:$MANAGEMENT_CENTER
```

You can use this endpoint with container orchestraction systems, like Kubernetes. Refer to 
[Management Center Reference Manual](https://docs.hazelcast.org/docs/management-center/latest/manual/html/#enabling-health-check-endpoint) 
for more information.

## Customizing Container Setup
[Customizing Container Setup]: #customizing-container-setup

You can make modifications to the container on container startup by defining environment variables.

* `MC_INIT_CMD`: Execute one or more commands separated by semicolons.
* `MC_INIT_SCRIPT`: Execute a script in Bash syntax in the context of the [entry-script](files/mc-start.sh). 
Make this file available by layering to a new container or by assigning a Docker volume.

The commands defined by the variables are executed before starting the Management Center in the listed order.

## Start with a Preconfigured Admin User
[Start with a Preconfigured Admin User]: #start-with-a-preconfigured-admin-user

You can start Management Center with an administrative user by setting the following optional environment variables:

```
docker run --name hazelcast-mc \
         --env MC_ADMIN_USER=admin \
         --env MC_ADMIN_PASSWORD=myPassword11 \
         --rm hazelcast/management-center
```

## JVM Heap Configuration
[JVM Heap Configuration]: #jvm-heap-configuration

By default, the container uses `-XX:+UseContainerSupport -XX:MaxRAMPercentage=80` Java options to automatically size 
the memory available to the JVM. If you don't use the memory resource limit (i.e. `docker run -m 512m ...`, or the 
limit of a Docker orchestration solution like 
[Kubernetes](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)), the container might 
use up to 80% percent of the available system memory.

You can define the following variables to change this behavior:

* `CONTAINER_SUPPORT="true"` (default) : use automatic memory resource configuration
* `CONTAINER_SUPPORT="false"` : suppress automatic resource configuration and configure the limits by using the 
following environment variables:
   * `MIN_HEAP_SIZE` : set the minium heap by `-Xms ...` 
   * `MAX_HEAP_SIZE` : set the maximum heap by `-Xmx ...`
   * `JAVA_OPTS` : use a custom configuration like `-Xms64m -Xmn1024m -Xmx2G -XX:MaxGCPauseMillis=200`

Example:

```
docker run --rm --name hazelcast-mc \
           -e CONTAINER_SUPPORT='false' \
           -e MIN_HEAP_SIZE='512M' \
           -e MAX_HEAP_SIZE='1024M' \
           -e JAVA_OPTS='-XX:MaxGCPauseMillis=200' \
           hazelcast/management-center
```

## Configuring Management Center Inside Your Custom Docker Image
[Configuring Management Center Inside Your Custom Docker Image]: #configuring-management-center-inside-your-custom-docker-image

If you create a Docker image with `hazelcast/management-center` as the base image and want to configure it further 
using `mc-conf.sh`, you need to specify `--home="${MC_DATA}"` flag for each `mc-conf` command. It makes sure that 
`mc-conf` stores data in the same directory that Management Center will use at runtime.

For example:

```
FROM hazelcast/management-center:4.2020.08

# Preconfigure cluster connections
ENV MC_CLUSTER1_NAME=my-cluster
ENV MC_CLUSTER1_ADDRESSLIST=127.0.0.1:5701

# Start Management Center
CMD ["bash", "-c", "set -euo pipefail \
      && ./mc-conf.sh cluster add --cluster-name=\"${MC_CLUSTER1_NAME}\" --member-addresses=\"${MC_CLUSTER1_ADDRESSLIST}\" --home=\"${MC_DATA}\" \
      && /mc-start.sh \
     "]
```

**NOTE:** `$MC_DATA` env variable comes from `hazelcast/management-center`. It is used to save the configuration and 
any other data needed when running Management Center.
