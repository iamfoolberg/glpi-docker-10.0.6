#this docker comes from https://github.com/luckman666/deploy_glpi

#we upgrade the php and glpi versions.

# To build your docker image

#1. download the GLPI zip/gz from github, if you can not access it freely.

#--put the file in this directory, and the Dockerfile will COPY it

#--else, replace the "COPY glpi-10.0.6.tgz /var/www/html/glpi-10.0.6.tgz"

#----as "RUN cd /var/www/html && wget ${GLPI_URL}"

#2. patch the Agent.php after the Dockerfile unzip it

#--by adding "COPY Agent.php /var/www/html/src/Agent.php"

#--IF your fusioninventory does not work.

#--the following are modifications.

```
        //$atype->getFromDBByCrit(['name' => 'Core']);
        if (!$atype->getFromDBByCrit(['name' => 'Core'])) {
            $atype->add([
                'name' => 'Core',
            ]);
            $atype->getFromDBByCrit(['name' => 'Core']);
        }
```

# To create your container/service

#create a docker net 

#--in swarm
```
docker network create --subnet=192.168.110.0/24 --driver=overlay --attachable mydockernet;
```
#--no swarm
```
docker network create --subnet=192.168.110.0/24 --attachable mydockernet;
```

#use the following to deploy a portainer, if you want a webui to inspect your images/containers
```
mkdir -p /docker/data/portainer;
docker run -itd \
--name portainer-srv \
--publish 9000:9000 \
--mount type=bind,src=/docker/data/portainer,dst=/data \
--mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \
portainer/portainer \
-H unix:///var/run/docker.sock
```
#init admin password,do not forget it.
#to delete
#  docker service rm portainer-srv
http://your-server-ip:9000

#use the following to deploy the juputer editor, if you want to debug the source files.
```
docker run -d --name jupyter \
  -v /docker/data:/root/notebook \
  -p 8090:8888 \
  -e JUPYTER_ENABLE_LAB=yes  \
brokyz/notebook_py
```

#in host's /docker/data/glpi(this directory), use the following to build the GLPI docker
```
docker build -t berg/glpi:10.0.6-1 .
```

#to deploy the GLPI container.
```
docker run -d --name glpi-srv \
  -v glpi-files:/var/www/html/files \
  -v glpi-plugins:/var/www/html/plugins \
  -v /etc/localtime:/etc/localtime:ro \
  -p 8121:80 \
berg/glpi:10.0.6-1
```
#enter the container
```
docker exec -it glpi-srv /bin/bash
```

#THe default users in GLPI：

#----system admin: glpi/glpi

#----technical admin: tech/tech

#----normal account: normal/normal

#----poster's account: post-only/postonly

#You should have a database, to install the GLPI system. It requires 400+ tables to be created.
