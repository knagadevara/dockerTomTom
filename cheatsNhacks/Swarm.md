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
1. In HA it will always be 1 Primary and bunch of secondary managers, If Swarm manager dies, secondary will be elected as master if there is no secondary new containers cannot be created but existing runs well.
2. Implements RAFT protocol to share information persistently and stores data persistently in a common raft database which is only accessable to the manager nodes. Fault Tolerant 

##### Filtering
---------
Gathers runtime requirements
- Affinity: 	start a container on a same node or particular node or where abc or xyz image exists or where there are xyz containers.
- Resource: 	start a container where a particular resource is free/available.
- Constraint:	mostly based on the putput returned by 'docker info' command. 
- Custom lables can be created at the image level, container level and daemon level with _--label-add, --label-rm_ extened tags.

Examples: all the below commands will be extension 'docker service create/update'

		--filter state=( running | exited | preparing )
		--placement-pref [ can be controlled through multiple prameters and label's ]
		--constraint "node.hostname==xyz" --constraint "node.role==worker" --constraint node.label.<label1>==DC3

##### Scheduling
----------
Scheduling is a swarm wide strategy which decides where to run the container after the filtering rules are satisfied.
- Random:  Picks out random hosts to deploy container Not Recomended.
- Spread:   Default swarm scheduler, as it aims to evenly balance containers on nodes across the clusrter.
- Binpack:  Allocates containers to smallest node in a cluster till it gets maxed out on resources, then it hops to next smallest node and repeat's. Irrespective of container state[start/stop] allocated system resource is considered as used.

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

- : To scale up the containers without --replicas

		docker service scale <service-name>=N

- : 'docker logs' will show what is happening inside the container, will pull uplogs from all the places where the service is deployed. Logs will persist till the container is completely desroyed and removed.

		docker service logs <service-name>

- : 'docker events' will show what is happening with docker engine, will capture only 1000 events happened in swarm

		docker events
		docker events --filter service=<service-name>

- : To inspect the service

		docker inspect --pretty <service-name>

- : To save a configuration out side of the image in HA using 'Swarm Configs'
		
		docker config create <conf-name> <conf-file>

- : To map the created config file 
		
		docker service create --config source=<conf-name>,target=<conf-path-in-container>

### Process of Rolling-Releases (Day2 Ops) ###
##### config-updates, version-upgrade #####
---------------------------------------------------------

Recomended to maintain the system configuration via cmdb tool, so these config files can be tracked and controlled through templates.

1. It is not possible to edit or override the existing one, so create a new config
		
		docker config create <conf-name.ver2> <conf-file>

2. Updating it through service update command
		
		docker service update --config-rm <old-conf-name> --config-add source=<conf-name.ver2>,target=<conf-path-in-container> <service-name>

These config's will be available on all the systems which heave raft concensus

Options for extended parameters,

- The main command in focus is 'docker service update'

	* _--stop-grace-period_ Time to wait before forcefully killing a container and moving ahead values in numetic units of ( ms | s | m | h )
	* _--stop-signal-string_ A string key-word signal to stop the container
	* _--update-delay_ Delay between killing existing --> successfully starting a container --> hopping on to next container to repeat the same updates
	* _--update-failure-action_ accepted arguments ( pause | continue | rollback )
	* _--update-max-failure-ratio_  would be a anything between 0 to 1 ( .1 , .25 , .5 , .75 )
	* _--update-order_ ( start-first | stop-first ) - used mostly in dev and testing phases
		- _start-first_ - creates container x1 -> starts x1 -> destroys old container
		- _stop-first_  - destroys old container ->  creates container x1 -> starts x1
	* _--update-parallelism_ - number of replicas to update and release, defaults to 1 at a time
	* _--update-monitor_ - startup delay for the services, useful in casees where the application takes time to start before going healthy.

- : To monitor X minutes before going to update the next replica and rollback if failure.
		
		docker service update --update-failure-action rollback --update-monitor 2m

- : To update 5 replicas and upto 25% of failure accepteance
		
		docker service update --update-parallelism 5 --update-max-failure-ratio .25

- : A complete update paramerer which would not interrupt the existing container structure (no-op)

		docker service update --update-delay 15s --update-failure-action rollback --update-max-failure-ratio .1 --update-order stop-first --update-parallelism 3 --update-monitor 20s firefly
		overall progress: 12 out of 12 tasks
		1/12: running   [==================================================>]
		2/12: running   [==================================================>]
		3/12: running   [==================================================>]
		4/12: running   [==================================================>]
		5/12: running   [==================================================>]
		6/12: running   [==================================================>]
		7/12: running   [==================================================>]
		8/12: running   [==================================================>]
		9/12: running   [==================================================>]
		10/12: running   [==================================================>]
		11/12: running   [==================================================>]
		12/12: running   [==================================================>]
		verify: Service converged

		docker inspect firefly
		[
			{
				"ID": "wwp5uomszssbjxywqd57m2dyl",
				"Version": {
					"Index": 1248
				},
				"CreatedAt": "2020-07-13T09:27:22.45667939Z",
				"UpdatedAt": "2020-07-13T09:30:01.703001399Z",
				"Spec": {
					"Name": "firefly",
					"Labels": {},
					"TaskTemplate": {
						"ContainerSpec": {
							"Image": "bretfisher/browncoat:healthcheck@sha256:1ef307dff10f94c8f0254a81b329c200c0b1e09732c65317ee2adc892fb550d0",
							"Init": false,
							"StopGracePeriod": 10000000000,
							"DNSConfig": {},
							"Isolation": "default"
						},
						"Resources": {
							"Limits": {},
							"Reservations": {}
						},
						"RestartPolicy": {
							"Condition": "any",
							"Delay": 5000000000,
							"MaxAttempts": 0
						},
						"Placement": {
							"Platforms": [
								{
									"Architecture": "amd64",
									"OS": "linux"
								}
							]
						},
						"ForceUpdate": 0,
						"Runtime": "container"
					},
					"Mode": {
						"Replicated": {
							"Replicas": 12
						}
					},
					"UpdateConfig": {
						"Parallelism": 3,
						"Delay": 15000000000,
						"FailureAction": "rollback",
						"Monitor": 20000000000,
						"MaxFailureRatio": 0.1,
						"Order": "stop-first"
					},
					"RollbackConfig": {
						"Parallelism": 1,
						"FailureAction": "pause",
						"Monitor": 5000000000,
						"MaxFailureRatio": 0,
						"Order": "stop-first"
					},
					"EndpointSpec": {
						"Mode": "vip"
					}
				},
				"PreviousSpec": {
					"Name": "firefly",
					"Labels": {},
					"TaskTemplate": {
						"ContainerSpec": {
							"Image": "bretfisher/browncoat:healthcheck@sha256:1ef307dff10f94c8f0254a81b329c200c0b1e09732c65317ee2adc892fb550d0",
							"Init": false,
							"DNSConfig": {},
							"Isolation": "default"
						},
						"Resources": {
							"Limits": {},
							"Reservations": {}
						},
						"Placement": {
							"Platforms": [
								{
									"Architecture": "amd64",
									"OS": "linux"
								}
							]
						},
						"ForceUpdate": 0,
						"Runtime": "container"
					},
					"Mode": {
						"Replicated": {
							"Replicas": 12
						}
					},
					"EndpointSpec": {
						"Mode": "vip"
					}
				},
				"Endpoint": {
					"Spec": {}
				}
			}
		]


- Updating the below through 'service update' will remove the present runnng container & release new,
		
	Syntax:
		docker service update --image <next-ver> <service-name>
	Example: We have update with an image which always fails health-check
		docker service update --image  bretfisher/browncoat:v3.healthcheck firefly
		firefly
		overall progress: rolling back update: 12 out of 12 tasks
		1/12: running   [>                                                  ]
		2/12: running   [>                                                  ]
		3/12: running   [>                                                  ]
		4/12: running   [>                                                  ]
		5/12: running   [>                                                  ]
		6/12: running   [>                                                  ]
		7/12: running   [>                                                  ]
		8/12: running   [>                                                  ]
		9/12: running   [>                                                  ]
		10/12: running   [>                                                  ]
		11/12: running   [>                                                  ]
		12/12: running   [>                                                  ]
		rollback: update rolled back due to failure or early termination of task tgrlopqzwf63fbsvcndnx6ltw
		verify: Service converged		

	-   _--image_
	-   _--network-add, --network-rm_ 
	-	_--constraint-add, --constraint-rm_
	-   _--reserve-cpu, --reserve-memory_
	-	_--env-add, --env-rm_
	-	_--replicas, --replicas-max-per-node_
	-	_--publish-add, --publish-rm_
	-	_--config-add, --config-rm_
	-	_--secret-add, --secret-rm_
	-   _--force_

- It is always recomended to keep the default health checks in simple state instead of making it complex as it hoggg's up container 		resource. Enterprise level monitoring should be done by other 3rd party tools like Prometheus or New Relic or Zabbix.

	- _--health-cmd_ - a custom command to determine if the app is healthy, depends on the application type.
	- _--health-interval_ - time between the health checks.
	- _--health-retries_ - number of retries after a failure.
	- _--health-start-period_ - N amount of time given to he container at the start and become healthy.
	- _--health-timeout_ - Command response wait time, to determine if the app is healthy.

-  If the 'service update' fails, There are multiple options for rolling back an update if the health check is failing or the container is failing to launch. Rollback will always go to the previous successfull image, but if that fails in some case and if another rollback is executed it would the machanism would **rolls-forward** releasing the present updated image. Below options can be used to have more controll on rollbacks

		docker service update --rollback-order stop-first --rollback-parallelism 2  <app-name>

	- _--rollback-delay_ - delay between task rollbacks (ms | s | m | h)
	- _--rollback-failure-action_ - ( pause | continue )
	- _--rollback-max-failure-ratio_ - maximum tollerance rate for a rollback container failure state.
	- _--rollback-monitor_ - Duration after each container rollback to monitor for failure.
	- _--rollback-order_ - ( start-first | stop-first )
	- _--rollback-parallelism_ - Maximum number of tasks rolled back simultaneously.


- : In a senario where automatic rollback is set, a new release update has more failure rate it would roll back to a previous service working spec [ i.e the existing/running version] , but if a manual roll back is attempted it would return the below,


		[root@M192168056101 ~]# docker service rollback firefly
		Error response from daemon: rpc error: code = FailedPrecondition desc = service wwp5uomszssbjxywqd57m2dyl does not have a previous spec
