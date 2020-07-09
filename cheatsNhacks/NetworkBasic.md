
##### Networking in Docker #####
--------------------------------

- : To access the json elements in docker

        docker container inspect -f '{{.NetworkSettings.IPAddress}}' <container-id>

- : To list out all the networks on host
    
        docker network ls

- : To check a specific driver

        docker network --filter drive=<bridge/macvlan>

- : To find all the network drivers and their id's
    
        docker network ls --format "{{.ID}}:{{.Driver}}"

- : To get more info about the network, It will give us info about containers using the network What is the IP range Subnet, Gateway
    
        docker network inspect <network-ID>

- : To create a new network
    
        docker network create <network-name>

- : To attach a containter to network while running ot creation
 
        docker container run --publish <hostPort>:<containerPort> --detached --network <network-ID/network-name> --name <container-name> <image-id>

- : To connect an existing container which is in stopped state with a network
        
        docker network connect <network-ID/network-name> <container-id/container-name>

- : To disconnect a container with a network
    
        docker network disconnect <network-ID/network-name> <container-id/container-name>  

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
