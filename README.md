##### official git-repository: https://github.com/JSchmiegel/dockerstats
---
# Dockerstats Container 
The purpose of this docker container is it to get the json-objects of the `docker stats` Command. The reason behind it is to use it with a logging management like the EFK-Stack (The EFK-Stack is a comibnation of elasticsearch, Fluentbit und Kibana. More information: https://codefarm.me/2018/06/29/elasticsearch-fluentd-kibana-docker-compose/).

# How to use:
The container can be downloaded and used with the docker hub under `jschmiegel/dockerstats`

When you start the container, you have to connect the socket of the docker deamon as a docker volume. The command for using this container should look simmular to the following command:
```Docker
docker run -v /var/run/docker.sock:/var/run/docker.sock jschmiegel/dockerstats
```
As I meantioned, I recommend using the docker container with the EFK-Stack. If you use the container this way your command should look simular to the following command:
```Docker
docker run -v /var/run/docker.sock:/var/run/docker.sock --log-driver=fluentd jschmiegel/dockerstats
```
Or when you are using `docker-compose` you have to add the following block to your `docker-compose` file:
```Docker
...
dockerstatscontainer: 
  image: jschmiegel/dockerstats
  volumes: 
   - /var/run/docker.sock:/var/run/docker.sock
  logging: 
   driver: fluentd
   options: 
    fluentd-address: localhost:24224
    fluentd-async-connect: 'true'
    fluentd-retry-wait: '1s'
    fluentd-max-retries: '30'
    tag: container.dockerstats
...
```

# How to modify the container
The container is built to log the docker stats of all container every 5 min. If you want to change the intervall you have to build the container by yourself and modify the `crontab.txt` to use the intervall you would like.