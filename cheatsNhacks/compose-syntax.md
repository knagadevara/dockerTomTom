#### Docker Compose ####
------------------------
- If no version is specified then system assumes it to be ver1.0

        version: <major.minor>

- Create custom networks as many needed under this network tag, with desired name, alias and functional driver.

        networks:
          NetworkName: 
            aliases:
              - aliases
            driver:
              driver-opts:

- Create custom volumes as many needed under this volume tag, with desired name and functional driver

        volumes:
          VolumeName:
            driver:
              driver-opts:

- Containers and their Definations

        services:         
          Service1: ## Name of the container
            image: <Image-Name> ## what would be containers image to be used. This would become optional parameter if 'build:' is used
            networks: ## to which list of networks container should be asssociated
              - net1
              - net2
            volumes: ## to which list of volumes container should be asssociated
              - vol1:<path-inside-container>
              - vol2:<path-inside-container>
            environment: ## list of require enviornment variables for the service inside the container
              - env-key=env-val
              - env-key=env-val
              - env-key=env-val
            ports: ## a List of Ports that are to be mapped on to host machine to access the service counter used with 'expose:'[ The ports where the service will be accessable but not mapped on host machine] 
              - port1
              - port2
            healthcheck: ## To check if the container/service is healthy
              test: ["CMD", "curl", "-f", "http://localhost"]
              interval: 1m30s
              timeout: 10s
              retries: 3
              start_period: 40s

##### compose - commandline

- : Methods to bring up a compose file
        
        docker-compose up 
        docker stack deploy -c docker-compose.yml <stack-name>

- : To Build an image and then bring it up
        
        docker-compose up --build -d

note: stack commands do not work if they have build included
        Ignoring unsupported options: build
