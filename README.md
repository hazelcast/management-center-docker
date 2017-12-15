# Hazelcast Management Center

You can pull the Hazelcast Management Center Docker image from the Docker registry by running the following command:

```
docker pull hazelcast/management-center:latest
```

After that you can run the Hazelcast Management Center Docker image using the following command:

```
docker run -ti -p 8080:8080 hazelcast/management-center:latest
```

Now you can reach Hazelcast Management Center from your browser using the URL `http://localhost:8080/mancenter`. 

If you are running the Docker image in the cloud, you should use a public IP of your machine instead of `localhost`. 

If you are using `docker-machine`, you can learn the Docker host IP using the following command:

```
docker-machine ls
```

If you are using `boot2docker`, you can learn the Docker host IP using the following command:

```
boot2docker ip
```

Then, you can run Hazelcast Management Center using the URL `http://host-ip:8080/mancenter`.
