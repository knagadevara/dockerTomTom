
### Networking in Docker ###
----------------------------

Docker Network 'defaults'
- Each container is connected to a private virtual network called 'Bridge'.
- Each Virtual network will make use of NAT firewall setup 'many to one' [ vnetwork mapped to Host IP ]
- Containers which belong to same network can communicate 

- : To access the json elements in docker

        docker container inspect --format '{{.NetworkSettings.IPAddress}}' <container-id>

- : To list out all the networks on host
    
        docker network ls

- : To check a specific driver

        docker network --filter drive=<bridge/macvlan>

- : To find all the network drivers and their id's
    
        docker network ls --format "{{.ID}}:{{.Driver}}"

- : To get more info about the network, It will give us info about containers using the network What is the IP range Subnet, Gateway
    
        docker network inspect <network-ID>

- : To create a new network. [ Ideally only one application stack should be isolated to a custom-network ] 
    
        docker network create <network-name> --driver

- : To attach a containter to network while running ot creation
 
        docker container run --publish <hostPort>:<containerPort> --detached --network <network-ID/network-name> --name <container-name> <image-id>

- : To connect an existing container [ better if it is in stopped state ] with a network
        
        docker network connect <network-ID/network-name> <container-id/container-name>

- : To disconnect a container with a network
    
        docker network disconnect <network-ID/network-name> <container-id/container-name>

- : To check which ports are exposed on the container
        
        docker container port <app-name>

Example:
--------
   
   
        docker network create --driver bridge  --subnet 192.168.10.0/24 overnet
        35d10d9881c770fa0095dcc9a196942258b167334ee9b822d584fe0b899e2dea

        docker network ls
        NETWORK ID          NAME                DRIVER              SCOPE
        6f4a817fe6e2        bridge              bridge              local
        72f2bbba0b59        host                host                local
        d6225d984a50        none                null                local
        35d10d9881c7        overnet             bridge              local

        docker inspect overnet
        [
            {
                "Name": "overnet",
                "Id": "35d10d9881c770fa0095dcc9a196942258b167334ee9b822d584fe0b899e2dea",
                "Created": "2020-06-02T11:18:58.54135637+05:30",
                "Scope": "local",
                "Driver": "bridge",
                "EnableIPv6": false,
                "IPAM": {
                    "Driver": "default",
                    "Options": {},
                    "Config": [
                        {
                            "Subnet": "192.168.10.0/24"
                        }
                    ]
                },
                "Internal": false,
                "Attachable": false,
                "Ingress": false,
                "ConfigFrom": {
                    "Network": ""
                },
                "ConfigOnly": false,
                "Containers": {},
                "Options": {},
                "Labels": {}
            }
        ]

- As containers are ephimeral in nature, inter-communicating through static IP is not standard. Every container/service/stack name should be unique as it will be mapped to a internal container IP, which would be updated later if container gets destroyed.

- Communication between container/service/stack belonging to the same custom-defined network is possible without a need to expose/publish the ports, but the default 'bridge' network will not allow that for security reasons, so, to enable inter-communication '--link' option is used.
        docker container run --name <container-1> --link <container-2> <image>

- : Senario DNS Round-Robin

        docker network create web-layer

        docker volume create webs1-docs
        docker volume create webs2-docs


        docker container create --name webServer1 --network-alias aixweb --network web-layer --expose 80 --volume webs1-docs:/usr/local/apache2/htdocs/ httpd:2.4-alpine

        docker container create --name webServer2 --network-alias aixweb --network web-layer --expose 80 --volume webs2-docs:/usr/local/apache2/htdocs/ httpd:2.4-alpine

        docker container start webServer1
        docker container start webServer2

        docker container run --detach --tty --name proxy_testr --network web-layer --publish 80:80 --volume /opt/docker/conf/nginx.conf:/etc/nginx/nginx.conf:ro nginx:stable-alpine

        docker container run --detach --tty --name curl_testr --network web-layer centos

        docker container exec curl_testr curl -sS aixweb