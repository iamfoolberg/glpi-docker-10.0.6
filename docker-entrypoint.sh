#this docker comes from https://github.com/luckman666/deploy_glpi
#we upgrade the php and glpi versions.

#create a docker net 
#  in swarm
docker network create --subnet=192.168.110.0/24 --driver=overlay --attachable mydockernet;
#  no swarm
docker network create --subnet=192.168.110.0/24 --attachable mydockernet;

#use the following to deploy a portainer
mkdir -p /docker/data/portainer;
docker run -itd \
--name portainer-srv \
--publish 9000:9000 \
--mount type=bind,src=/docker/data/portainer,dst=/data \
--mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \
portainer/portainer \
-H unix:///var/run/docker.sock

#init admin password 1qaz@WSX3edc
#to delete
#  docker service rm portainer-srv
http://seuom.com:9000

#use the following to deploy the juputer editor:
docker run -d --name jupyter \
  -v /docker/data:/root/notebook \
  -p 8090:8888 \
  -e JUPYTER_ENABLE_LAB=yes  \
brokyz/notebook_py


#in host's /docker/data/glpi, use the following to build the GLPI docker
docker build -t berg/glpi:10.0.6-1 .


#to deploy the GLPI container.
docker run -d --name glpi-srv \
  -v glpi-files:/var/www/html/files \
  -v glpi-plugins:/var/www/html/plugins \
  -v /etc/localtime:/etc/localtime:ro \
  -p 8121:80 \
berg/glpi:10.0.6-1

#enter the container
docker exec -it glpi-srv /bin/bash


 默认 登录名/密码是：

    默认管理员帐号是 glpi/glpi
    技术员帐号是 tech/tech
    普通帐号是 normal/normal
    只能发布的帐号是 post-only/postonly

您可以删除或修改这些帐号和初始数据。 

/usr/sbin/apache2ctl -D FOREGROUND
CMD ["sleep", "infinity"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
#	wget ${GLPI_URL} && \
    
https://github.com/glpi-project/glpi/releases/download/10.0.6/glpi-10.0.6.tgz

glpi:
    image: registry.cn-hangzhou.aliyuncs.com/yangb/glpi-web
    container_name: glpi
    volumes:
    - glpi-files:/var/www/html/files
    - glpi-plugins:/var/www/html/plugins
    - /etc/localtime:/etc/localtime:ro
    links:
    - mariadb:mysql
    ports:
    - 80:80/tcp
    restart: always    
    
    CMD ["apache2-foreground"]
    
    devilbox/php-fpm:8.0-prod
    
 apt-get install bzip2
tar -zxvf *.tar.gz
tar -xvjf *.tar.bz2
ls *.tar.gz | xargs -n1 tar xzvf
ls *.tar.bz2 | xargs -n1 tar xvjf
    
