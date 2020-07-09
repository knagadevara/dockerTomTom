## Components of Swarm ##
-------------------------

##### The Discovery Service
----------------------
It is a Key-Value Store, which keeps track of the cluster state and its configuration.
Swarm supports a varity of key-value backends like consul, etcd, zookeeper which runs through libvkv
if by any chance the discovery service dies, bring up a new service and let docker generate required metadata.
To avoid such it is recommended to go HA

##### Swarm Manager
-------------
Swarm manager which is a cluster administrator implements Swarm API where all docker commands intended to the cluster go. acts based on the availablity of resource and its health.
In HA it will always be 1 Primary and bunch of secondary managers, If Swarm manager dies, 
secondary will be elected as master if there is no secondary new containers cannot be created but existing runs well.
Implements RAFT protocol to share information persistently and stores data persistently in a common raft database which is only accessable to the manager nodes. Fault Tolerant 

##### Filtering
---------
Gathers runtime requirements
Affinity: 	start a container on a same node or particular node or where abc or xyz image exists or where there are xyz containers.
Resource: 	start a container where a particular resource is free/available.
Constraint:	mostly based on the putput returned by 'docker info' command. 
Custom lables can be created at the image level, container level and daemon level.

##### Scheduling
----------
Scheduling is a swarm wide strategy which decides where to run the container after the filtering rules are satisfied.
Random:  Picks out random hosts to deploy container Not Recomended.
Spread:   Default swarm scheduler, as it aims to evenly balance containers on nodes across the clusrter.
Binpack:  Allocates containers to smallest node in a cluster till it gets maxed out on resources, then it hops to next smallest node and repeat's. Irrespective of container state[start/stop] allocated system resource is considered as used.

##### Worker Nodes
------------
Worker nodes will implement a communication/advertising protocal based on their backend or by default it will be 'gossip'. The communication between manager's and worker nodes is implemented gRPC.

##### Swarm Ingress Network
---------------------
All the docker hosts can have a single overlay network with different subnets on each of the host.
Service discovery enables each container app service to be discoverable, resolution name will be the tag-name.
Ingress loadbalancing will enable apps to take in traffic from all the hosts where the app is deployed[replicas].


**_Docker basic architecture is a client server Model, where in docker commands are sent as commands through prompt to the daemon docker.service which implements docker remote API._**

#### Single Data Center Deployment ####
###### Swarm Infra HA Design, recomended to deploy docker engine on different racks. #####
------------------------------------------------------------------------------------------

|   Rack1       |   Rack2       |   Rack3       |
|   :---:       |   :---:       |   :---:       |
|   NW-SW1      |   NW-SW2      |   NW-SW3      |
|   BM-Server1  |   BM-Server3  |   BM-Server3  |
| docker-engine | docker-engine | docker-engine |
-------------------------------------------------

### Docker Swarm Ops ###
------------------------
- : To start a generic swarm and advertise the IP, not recomended in production
		
		docker swarm init --advertise-addr 192.168.56.101

- : To get tokens for manager/worker
		
		docker swarm join-token <manager/worker>

- : To list the nodes in swarm
		
		docker node ls

- : To check what services are running in swarm
		
		docker service ls

- : To check where the service is deployed
		
		docker service ps <app> --filter state=running

- : To create a service with high 4 replicas on a worker node
		
		docker service create --replicas 4 --name web --publish 8080:80 --constraint node.role==worker nginx

- : To update the existing service
		
		docker service update --publish-rm  8080 --publish-add 9090:80 web

- : To update node parameters
		
		docker node update --label-rm="zone=admin" <node-name>

- : To chang the availablity of the node to drain, which removes the existing container  
		
		docker node update --availability drain

- : To install 'jq' on docker worker nodes multiple nodes
		
		for dkr_host in $(docker node ls  --filter role=worker --format "{{json . }}" | jq '.Hostname' | tr -d 	'"') ; do ssh root@${dkr_host} 'yum install -y jq' ; done
		
		docker node ls --filter role=worker  --format "{{json ."Hostname"}}"

- : To update labels in swarm for more than 1 node
		
		for dkr_node in $(docker node ls -q --filter role=worker) ; do docker node update --label-rm "zone" --label-add "dmz=true" --label-add "public=true" ${dkr_node} ; done

- : To get a JSON output out of the docker command
		
		docker node ls --filter role=worker --format "{{json . }}" | jq '.Hostname' | tr -d '"'

- : To remove all the exited containers in the swarm nodes
		
		docker container rm -f $(/usr/bin/docker ps --filter status=exited --format "{{json . }}" | jq '. "Names"' | 	tr -d '"')

- : To deploy excatly one container on every node that satisfies the constraint
		
		docker service create --mode global --name web --publish 8080:80 --constraint node.role==worker nginx

- : To update labels in services
		
		docker node update --label-add "DC=IN-MUM-1" --label-add "vDC=2" W192168056103.k8x77-wkr-prd.PyDevRa.zone
		
		docker node update --label-add "DC=IN-MUM-2" --label-add "vDC=3" W192168056104.k8x77-wkr-prd.PyDevRa.zone
		
		docker node update --label-add "DC=IN-MUM-3" --label-add "vDC=4" W192168056105.k8x77-wkr-prd.PyDevRa.zone

- : To deploy a service based on the catogorical count of a constraint
		
		docker service create --name web2 --publish 8081:80 --placement-pref=spread=node.labels.vDC --replicas 2 	nginx


|**'docker logs' will show what is happening inside the container**|
|------------------------------------------------------------------|
|**'docker events' will show what is happening with docker engine**|


- : To save a configuration out side of the image in HA using 'Swarm Configs'
		
		docker config create <conf-name> <conf-file>

- : To map the created config file 
		
		docker service create --config source=<conf-name>,target=<conf-path-in-container> 

### Process to update ###

1. It is not possible to edit or override the existing one, so create a new config
		
		docker config create <conf-name.ver2> <conf-file>

2. Updating it through service update command
		
		docker service update --config-rm <old-conf-name> --config-add source=<conf-name.ver2>,target=<conf-path-in-container> <service-name>

These config's will be available on all the systems which heave raft concensus

#### Rolling updates and Releases on existing services (Day2 Ops) ####
###### Options for extended parameters for release ######
---------------------------------------------------------
- The main command in focus is 'docker service update'
	* _--stop-grace-period Time to wait before forcefully killing a container and moving ahead values in numetic units of ( ms | s | m | h )_
	* _--stop-signal-string signal to stop the container_
	* _--update-delay Delay between updates_
	* _--update-failure-action ( pause | continue | rollback )_
	* _--update-max-failure-ratio - would be a anything between 0 to 1 ( .1 , .25 , .5 , .75 )_
	* _--update-order ( start-first | stop-first ) - used mostly in dev and testing phases_
	* _--update-parallelism - number of replicas to update and release, defaults to 1 at a time_

- : To monitor X minutes before going to update the next replica and rollback if failure.
		
		docker service update --update-failure-action rollback --update-monitor 2m

- : To update 5 replicas and upto 25% of failure accepteance
		
		docker service update --update-parallelism 5 --update-max-failure-ratio .25

* Updating the below would while doing 'service update' will remove the present runnng container & release new,
	-   A new image, change in storage/network drivers
	-	_--constraint-add, --constraint-rm_
	-	_--env-add, --env-rm_
	-	_--replicas, --replicas-max-per-node_
	-	_--publish-add, --publish-rm_
	-	_--config-add, --config-rm_
	-	_--secret-add, --secret-rm_
	-	_--health-cmd, --health-interval, --health-retries, --health-start-period, --health-timeout_
