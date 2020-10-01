
# Hazelcast Management Center

Hazelcast Management Center enables you to monitor and manage your cluster members running Hazelcast IMDG. In addition to monitoring the overall state of your clusters, you can also analyze and browse your data structures in detail, update map configurations and take thread dumps from members. You can run scripts (JavaScript, Groovy, etc.) and commands on your members with its scripting and console modules.

You can check [Hazelcast IMDG Documentation](http://docs.hazelcast.org/docs/latest/manual/html-single/) and [Management Center Documentation](http://docs.hazelcast.org/docs/management-center/latest/manual/html/index.html) for more information.

## Table of Content
 - [Quick Start]
 - [Mounting Management Center Home Directory]
 - [Enabling TLS/SSL](enabling-tls-ssl)
 - [Hazelcast Member Configuration]
 - [Using Custom Logback Configuration File]
 - [Starting with an Extra Classpath]
 - [Enabling Health Check Endpoint]
 - [Customizing container setup]
 - [Start with a preconfigured admin user]
 - [JVM heap configuration]
 - [Configuring management center inside you custome Docker image]

## Quick Start
[Quick Start]: #quick-start

You can launch Hazelcast Management Center by simply running the following command. Please check available versions for $MANAGEMENT_CENTER on [Docker Store](https://store.docker.com/community/images/hazelcast/management-center/tags)

```
docker run --rm -m 512m -p 8080:8080 hazelcast/management-center:$MANAGEMENT_CENTER
```

Now you can reach Hazelcast Management Center from your browser using the URL `http://localhost:8080`. 

If you are running the Docker image in the cloud, you should use a public IP of your machine instead of `localhost`. 

`docker ps` and `docker inspect <container-id>` can be used to find `host-ip`. Once you find out `host-ip`, you can browse Hazelcast Management Center using the URL: `http://host-ip:8080`.

By default the container automatically sizes the java heap memory suitable to the specified resource limit or available memory.

### Management Center Default Context Path

Before version 4.0, default context path was `/hazelcast-mancenter`, so you would access Hazelcast 
Management Center by using `http://localhost:8080/hazelcast-mancenter`. Starting with the version 4.0, 
it is changed to root context path (i.e. `/`), so you can access it by using `http://localhost:8080`.

You can overwrite this default by setting the environment variable `MC_CONTEXT_PATH`.

## Mounting Management Center Home Directory
[Mounting Management Center Home Directory]: #mounting-management-center-home-directory

Management Center uses the file system to store persistent data. However, that is by default inside the docker container and destroyed in case of container restarts. If you want to store Management Center data externally, you need to create a mount to a folder named `/data`. See the following for how to create a mount point. `PATH_TO_PERSISTENT_FOLDER` must be replaced by your persistent folder.

```
docker run --rm -m 512m -p 8080:8080 -v PATH_TO_PERSISTENT_FOLDER:/data hazelcast/management-center:$MANAGEMENT_CENTER
```

To provide a license key the system property `hazelcast.mc.license` can be used (requires version >= 3.9.3):

```
docker run --rm -m 512m -e JAVA_OPTS='-Dhazelcast.mc.license=<key>' -p 8080:8080 hazelcast/management-center:$MANAGEMENT_CENTER
```

## Enabling TLS/SSL
[Enabling TLS SSL]: #enabling-tls-ssl

To enable TLS/SSL, you need to provide the keystore and expose the default port (`8443`):

```
docker run --rm -m 512m \
         -e JAVA_OPTS='-Dhazelcast.mc.tls.enabled=true \
         -Dhazelcast.mc.tls.keyStore=/keystore/yourkeystore.jks \
         -Dhazelcast.mc.tls.keyStorePassword=yourpassword' \
         -v PATH_TO_KEYSTORE_DIR:/keystore \
         -p 8443:8443 \
         hazelcast/management-center
```

The default port can be changed by overriding the `MC_HTTPS_PORT` environment variable. For example, to use port `8444` you can run the following command:

```
docker run --rm -m 512m -e MC_HTTPS_PORT=8444 \
        -e JAVA_OPTS='-Dhazelcast.mc.tls.enabled=true \
        -Dhazelcast.mc.tls.keyStore=/keystore/yourkeystore.jks \
        -Dhazelcast.mc.tls.keyStorePassword=yourpassword' \
        -v PATH_TO_KEYSTORE_DIR:/keystore \
        -p 8444:8444 \
        hazelcast/management-center
```

Please refer to [the Management Center documentation](https://docs.hazelcast.org/docs/management-center/3.12/manual/html/index.html#enabling-tslssl-when-starting-with-war-file) for more information on available options.

## Hazelcast Member Configuration
[Hazelcast Member Configuration]: #hazelcast-member-configuration

For the Hazelcast member configuration and the sample Hello World example, please refer to [Hazelcast Docker repository](https://github.com/hazelcast/hazelcast-docker).

## Using Custom Logback Configuration File
[Using Custom Logback Configuration File]: #using-custom-logback-configuration-file

Management Center can use your custom Logback configuration file. You need to create a mount to a folder named `/opt/hazelcast/mc_ext`, see the following on how to do it. `PATH_TO_PERSISTENT_FOLDER` must be replaced with the path to the folder that your custom Logback configuration file resides in. `CUSTOM_LOGBACK_FILE` must be replaced with the name of your custom Logback configuration file, for example `logback-custom.xml`.

```
docker run -m 512m \
         -e JAVA_OPTS='-Dlogback.configurationFile=/opt/hazelcast/mc_ext/CUSTOM_LOGBACK_FILE' \
         -v PATH_TO_LOCAL_FOLDER:/opt/hazelcast/mc_ext \
         -p 8080:8080 \
         hazelcast/management-center
```

## Starting with an Extra Classpath
[Starting with an Extra Classpath]: #starting-with-an-extra-classpath

You can start the Management Center with an extra classpath entry (for example, when using JAAS authentication) by using the `MC_CLASSPATH` environment variable:

```
docker run -m 512m -e MC_CLASSPATH='/path/to/your-extra.jar' -p 8080:8080 hazelcast/management-center
```

## Enabling Health Check Endpoint
[Enabling Health Check Endpoint]: #enabling-health-check-endpoint

When running the Management Center, you can enable the Health Check endpoint:

```
docker run -m 512m -p 8080:8080 -p 8081:8081 \
         -e JAVA_OPTS='-Dhazelcast.mc.healthCheck.enable=true' \
         hazelcast/management-center:$MANAGEMENT_CENTER
```

This endpoint may be used in container-orchestraction systems, like Kubernetes. Refer to [the Management Center documentation](https://docs.hazelcast.org/docs/management-center/3.12.5/manual/html/index.html#enabling-health-check-endpoint) for more information.

## Customizing container setup
[Customizing container setup]: #customizing-container-setup

You can make modifications to the container on container startup by defining environment variables.

* `MC_INIT_CMD`: Execute one or more commands separated by semicolons.
* `MC_INIT_SCRIPT`: Execute a script in bash syntax in the context of the [entry-script](files/mc-start.sh). Make this file available by layering to a new container or by assigning a docker volume.

The commands defined by the variables are executed before starting the Management Center in the listed order.

## Start with a preconfigured admin user
[Start with a preconfigured admin user]: #start-with-a-preconfigured-admin-user

You can start the Management Center with an administrative user by setting the following optional environmental variables:
```
docker run -m 512m -ti  --name hazelcast-mc \
         --env MC_ADMIN_USER=admin \
         --env MC_ADMIN_PASSWORD=myPassword11 \
         --rm hazelcast/management-center
```

## JVM heap configuration
[JVM heap configuration]: #jvm-heap-configuration

By default the container uses the `-XX:+UseContainerSupport -XX:MaxRAMPercentage=80` java options to automatically size the memory available to the jvm.
If you don't use the memory resource limit (i.e. `docker run -m 512m ...`, or the limit of a docker orchestration solutions like [Kubernetes](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/)) the container might use up to 80% percent of the available system memory.

You can define the following variables:

* `CONTAINER_SUPPORT="true"` (default) : use automatic memory resource configuration
* `CONTAINER_SUPPORT="false"` : suppress automatic resource configuration and configure the limits by using the following environment variables:
   * `MIN_HEAP_SIZE` : set the minium heap by `-Xms ...` 
   * `MAX_HEAP_SIZE` : set the maximum heap by `-Xmx ...`
   * `JAVA_OPTS` : use a custom configuration like `-Xms64m -Xmn1024m -Xmx2G -XX:MaxGCPauseMillis=200`

Example:
```
docker run -ti  --name hazelcast-mc \
         -e CONTAINER_SUPPORT='false' -e MIN_HEAP_SIZE='512M' -e MAX_HEAP_SIZE='1024M' -e JAVA_OPTS='-XX:MaxGCPauseMillis=200' \
         --rm hazelcast/management-center
```

## Configuring management center inside you custome Docker image
[Configuring management center inside you custome Docker image]: #configuring-management-center-inside-you-custome-docker-image

If you are creating Docker imange with `hazelcast/management-center` as a base image and want to make additional configuration using `mc-conf.sh` you have to specify `--home=${MC_DATA}` flag for each `mc-conf` command. That makes sure that `mc-conf` stores data to the same folder that management-center will use at runtime

For example:

```
FROM hazelcast/management-center:4.2020.08

# Preconfigure cluster connections
ENV MC_CLUSTER1_NAME=my-cluster
ENV MC_CLUSTER1_ADDRESSLIST=127.0.0.1:5701

# Start Management Center
CMD ["bash", "-c", "set -euo pipefail \
      && ./mc-conf.sh cluster add --cluster-name=${MC_CLUSTER1_NAME} --member-addresses=${MC_CLUSTER1_ADDRESSLIST} --home=${MC_DATA} \
      && /mc-start.sh \
     "]
```
