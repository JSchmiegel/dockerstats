##### official git-repository: https://github.com/JSchmiegel/dockerstats
---
# **Dockerstats Container** 
The purpose of this docker container is it to get the json-objects of the `docker stats` Command. The motivation behind this is to use a log management system like the EFK Stack. <br>
(The EFK-Stack is a comibnation of elasticsearch, Fluentd\Fluentbit und Kibana. More information: https://codefarm.me/2018/06/29/elasticsearch-fluentd-kibana-docker-compose/; November 2019 of the IT-Administrator page 90 to 95 (especially to use Fluentbit instead of Fluentd))

# **How to use:**
## **How to use stand alone:**
The container can be downloaded and used with the docker hub under `jschmiegel/dockerstats`

When you start the container, you have to connect the socket of the docker deamon as a docker volume. The command for using this container should look simmular to the following command:
```Docker
docker run -v /var/run/docker.sock:/var/run/docker.sock jschmiegel/dockerstats
```

## **How to use with EFK-Stack (Fluentbit):**
### **1. Use start the docker container:**
As I meantioned, I recommend using the docker container with the EFK-Stack. If you use the container this way your command should look simular to the following command:
```Docker
docker run -v /var/run/docker.sock:/var/run/docker.sock --log-driver=fluentd jschmiegel/dockerstats --log-opt tag="container.dockerstats"
```
Or when you are using `docker-compose` (recommended) you have to add the following block to your `docker-compose` file:
```Docker
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
```

### **2. Add a Parser:**
Use the following parser into the `parsers.conf` to get the cpu-usage out of the resulting json-object by filtering for the `containerPrevCpuUsage` and the `containerTotalCpuUsage` 
```
[PARSER]
    Name     dockerstatscustom
    Format   regex
    Regex    "cpu_stats":{"cpu_usage":{"total_usage":(?<containerTotalCpuUsage>[0-9]*).*"precpu_stats":{"cpu_usage":{"total_usage":(?<containerPrevCpuUsage>[0-9]*).*"name":"(?<containerName>[^"]*)
    Types    containerTotalCpuUsage:integer containerPrevCpuUsage:integer
```

### **3. Add a Filter:**
Add the following filter in the `fluent-bit.conf` to filter the log-stream for the json-object of the dockerstats container and use the created parser.
```
[FILTER]
 Name parser
 Match container.dockerstats
 Key_Name log
 Parser dockerstatscustom
 Reserve_data On
```

### **4. Create a Graph (in Kibana):**
Open kibana and add a scripted field to your index. This scripted field should substract the `containerPrevCpuUsage` from the `containerTotalCpuUsage` to get the current CPU usage. Now you only have to make a linear graph (y-Axe = time) which displays the scripted field and is subdivided by the `containerName` field. (To see the individual CPU usage of each container.)

# How to modify the container
The container is built to log the docker stats of all container every 5 min. If you want to change the intervall you have to build the container by yourself and modify the `crontab.txt` to use the intervall you would like.