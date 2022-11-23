#!/bin/bash
version=`cat root/Documents/version.txt`
puente=`brctl show | egrep lan1`
if [ -z "$puente" ]
then
	brctl addbr lan1
	brctl addbr lan2
	brctl addbr lan3
	brctl addbr ppp1
	brctl addbr ppp2
	brctl addbr man1
fi

ip link set dev lan1 up
ip link set dev lan2 up
ip link set dev lan3 up
ip link set dev ppp1 up
ip link set dev ppp2 up
ip link set dev man1 up

montaje=`df -h | egrep docker`
if [ -z "$montaje" ]
then
	service docker stop
	mount $1 /var/lib/docker
	service docker start
fi
/sbin/iptables -P FORWARD ACCEPT
contenedores=`docker ps -aq|wc -l`

if [ $contenedores -gt 0 ]
then
	docker stop $(docker ps -aq)
	docker rm $(docker ps -aq)
fi

imagenes=`docker images| egrep fire | wc -l`
if [ $imagenes -gt 0 ]
then
	docker rmi fire-latoma
	docker rmi fire-merlo
	docker rmi fire-potrero
	docker rmi fire-laflorida
	docker rmi fire-desaguadero
	docker rmi fire-nogoli
	docker rmi fire-carrizal
	docker rmi fire-laslenias
fi



docker run --detach --hostname latoma -it --name latoma --cap-add NET_ADMIN --privileged servidor:$version bash
docker run --detach --hostname merlo -it --name merlo --cap-add NET_ADMIN cliente-cli:$version bash
docker run --detach --hostname potrero -it --name potrero --cap-add NET_ADMIN --privileged servidor:$version bash
docker run --detach --hostname laflorida -it --name laflorida --cap-add NET_ADMIN --privileged servidor:$version bash
docker run --detach --hostname desaguadero -it --name desaguadero --cap-add NET_ADMIN --privileged servidor:$version bash
docker run --detach --hostname nogoli -it --name nogoli --cap-add NET_ADMIN --privileged servidor:$version bash

docker exec -it latoma ip ro del default
docker exec -it merlo ip ro del default
docker exec -it potrero ip ro del default
docker exec -it laflorida ip ro del default
docker exec -it desaguadero ip ro del default
docker exec -it nogoli ip ro del default

#pipework lan2 -i lan2 latoma 0.0.0.0/24
#pipework lan1 -i lan1 merlo  0.0.0.0/24
#pipework lan1 -i lan1 potrero 0.0.0.0/24
#pipework lan2 -i lan2 potrero 0.0.0.0/24
#pipework ppp1 -i ppp1 potrero 0.0.0.0/24
#pipework ppp1 -i ppp1 laflorida 0.0.0.0/24
#pipework man1 -i man1 laflorida 0.0.0.0/24
#pipework man1 -i man1 nogoli 0.0.0.0/24
#pipework man1 -i man1 desaguadero 0.0.0.0/24
#pipework ppp1 -i ppp1 desaguadero 0.0.0.0/24
#pipework ppp1 -i ppp1 carrizal 0.0.0.0/24
#pipework lan3 -i lan3 carrizal 0.0.0.0/24
#pipework lan3 -i lan3 laslenias 0.0.0.0/24

pipework lan2 -i lan2 latoma 172.16.4.10/23
pipework lan1 -i lan1 merlo 192.168.1.48/24
pipework lan1 -i lan1 potrero 192.168.1.1/24
pipework lan2 -i lan2 potrero 172.16.4.1/23
pipework ppp1 -i ppp1 potrero 200.8.4.18/30
pipework ppp1 -i ppp1 laflorida 200.8.4.17/30
pipework man1 -i man1 laflorida 8.8.8.14/28
pipework man1 -i man1 nogoli 8.8.8.8/28
pipework man1 -i man1 desaguadero 8.8.8.1/28


docker exec -it latoma ip ro add default via 172.16.4.1
docker exec -it merlo ip ro add default via 192.168.1.1
docker exec -it potrero ip ro add default via 200.8.4.17

docker exec -it laflorida ip ro add 192.168.1.0/24 via 200.8.4.18
docker exec -it laflorida ip ro add 172.16.4.0/23 via 200.8.4.18

docker exec -it desaguadero ip ro add 192.168.1.0/24 via 8.8.8.14
docker exec -it desaguadero ip ro add 172.16.4.0/23 via 8.8.8.14

docker exec -it nogoli ip ro add 192.168.1.0/24 via 8.8.8.14
docker exec -it nogoli ip ro add 172.16.4.0/23 via 8.8.8.14
docker exec -it nogoli ip ro add 200.8.4.16/30 via 8.8.8.14
docker exec -it nogoli ip ro add 170.0.2.4/30 via 8.8.8.1

xterm -T "latoma" -fa monaco -fs 11 -e "docker attach latoma" &
xterm -T "merlo" -fa monaco -fs 11 -e "docker attach merlo" &
xterm -T "potrero" -fa monaco -fs 11 -e "docker attach potrero" &
xterm -T "laflorida" -fa monaco -fs 11 -e "docker attach laflorida" &
xterm -T "desaguadero" -fa monaco -fs 11 -e "docker attach desaguadero" &
xterm -T "nogoli" -fa monaco -fs 11 -e "docker attach nogoli" &


#para saber los nombres de los contenedores que estan corriendo
# docker ps  --format "table {{.Names}}"
