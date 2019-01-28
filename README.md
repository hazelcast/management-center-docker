
# Hazelcast Management Center

Hazelcast Management Center enables you to monitor and manage your cluster members running Hazelcast IMDG. In addition to monitoring the overall state of your clusters, you can also analyze and browse your data structures in detail, update map configurations and take thread dumps from members. You can run scripts (JavaScript, Groovy, etc.) and commands on your members with its scripting and console modules.

You can check [Hazelcast IMDG Documentation](http://docs.hazelcast.org/docs/latest/manual/html-single/) and [Management Center Documentation](http://docs.hazelcast.org/docs/management-center/latest/manual/html/index.html) for more information.

## Quick Start

You can launch Hazelcast Management Center by simply running the following command. please check available versions for $MANAGEMENT_CENTER on [Docker Store](https://store.docker.com/community/images/hazelcast/management-center/tags)

```
docker run -p 8080:8080 hazelcast/management-center:$MANAGEMENT_CENTER
```

Now you can reach Hazelcast Management Center from your browser using the URL `http://localhost:8080/hazelcast-mancenter`. 

If you are running the Docker image in the cloud, you should use a public IP of your machine instead of `localhost`. 

`docker ps` and `docker inspect <container-id>` can be used to find `host-ip`. Once you find out `host-ip`, you can browse Hazelcast Management Center using the URL: `http://host-ip:8080/hazelcast-mancenter`.

### Management Center Default Context Path

Before version 3.10, default context path was `/mancenter`, so you would access Hazelcast Management 
Center by using `http://localhost:8080/mancenter`. Starting with version 3.10, it is changed to
`/hazelcast-mancenter`, so you can access it by using `http://localhost:8080/hazelcast-mancenter`.

You can overwrite this default by setting the environment variable `MC_CONTEXT`.

## Mounting Management Center Home Directory

Management Center uses the file system to store persistent data. However, that is by default inside the docker container and destroyed in case of container restarts. If you want to store Management Center data externally, you need to create a mount to a folder named `/data`. See the following for how to create a mount point. `PATH_TO_PERSISTENT_FOLDER` must be replaced by your persistent folder.

```
docker run -p 8080:8080 -v PATH_TO_PERSISTENT_FOLDER:/data hazelcast/management-center:$MANAGEMENT_CENTER
```

To provide a license key the system property `hazelcast.mc.license` can be used (requires version >= 3.9.3):

```
docker run -e JAVA_OPTS='-Dhazelcast.mc.license=<key>' -p 8080:8080 hazelcast/management-center:$MANAGEMENT_CENTER
```

## Hazelcast Member Configuration

For the Hazelcast member configuration and the sample Hello World example, please refer to [Hazelcast Docker repository](https://github.com/hazelcast/hazelcast-docker).

## Using Custom Logback Configuration File

Management Center can use your custom Logback configuration file. You need to create a mount to a folder named `/opt/hazelcast/mancenter_ext`, see the following on how to do it. `PATH_TO_PERSISTENT_FOLDER` must be replaced with the path to the folder that your custom Logback configuration file resides in. `CUSTOM_LOGBACK_FILE` must be replaced with the name of your custom Logback configuration file, for example `logback-custom.xml`.

```
docker run -e JAVA_OPTS='-Dlogback.configurationFile=/opt/hazelcast/mancenter_ext/CUSTOM_LOGBACK_FILE' -v PATH_TO_LOCAL_FOLDER:/opt/hazelcast/mancenter_ext -p 8080:8080 hazelcast/management-center
```
