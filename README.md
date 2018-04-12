
# Hazelcast Management Center

Hazelcast Management Center enables you to monitor and manage your cluster members running Hazelcast IMDG. In addition to monitoring the overall state of your clusters, you can also analyze and browse your data structures in detail, update map configurations and take thread dumps from members. You can run scripts (JavaScript, Groovy, etc.) and commands on your members with its scripting and console modules.

You can check [Hazelcast IMDG Documentation](http://docs.hazelcast.org/docs/latest/manual/html-single/) and [Management Center Documentation](http://docs.hazelcast.org/docs/management-center/latest/manual/html/index.html) for more information.

## Quick Start

You can launch Hazelcast Management Center by simply running the following command. please check available versions for $MANAGEMENT_CENTER on [Docker Store](https://store.docker.com/community/images/hazelcast/management-center/tags)

```
docker run -ti -p 8080:8080 hazelcast/management-center:$MANAGEMENT_CENTER
```

Now you can reach Hazelcast Management Center from your browser using the URL `http://localhost:8080/hazelcast-mancenter`. 

If you are running the Docker image in the cloud, you should use a public IP of your machine instead of `localhost`. 

`docker ps` and `docker inspect <container-id>` can be used to find `host-ip`. Once you find out `host-ip`, you can browse Hazelcast Management Center using the URL: `http://host-ip:8080/hazelcast-mancenter`.

## Mounting Management Center Home Directory

Management Center uses the file system to store persistent data. However, that is by default inside the docker container and destroyed in case of container restarts. If you want to store Management Center data externally, you need to create a mount to a folder named `/data`. See the following for how to create a mount point. `PATH_TO_PERSISTENT_FOLDER` must be replaced by your persistent folder.

```
docker run -ti -p 8080:8080 -v PATH_TO_PERSISTENT_FOLDER:/data hazelcast/management-center:$MANAGEMENT_CENTER
```

To provide a license key the system property `hazelcast.mc.license` can be used (requires version >= 3.9.3):

```
docker run -e JAVA_OPTS='-Dhazelcast.mc.license=<key>' -ti -p 8080:8080 hazelcast/management-center:$MANAGEMENT_CENTER
```

## Hazelcast Member Configuration

As a prerequisite, Hazelcast Cluster Member Containers should be launched with Management Center Enabled mode. This can be achieved by using a custom `hazelcast.xml` configuration file while launching the Hazelcast Member Container. For more information please refer to the [Using Hazelcast Configuration File](https://github.com/hazelcast/hazelcast-docker#using-custom-hazelcast-configuration-file) section.
