#### Docker Compose ####
------------------------

        version: <major.minor> ## If no version is specified then system assumes it to be ver1.0

        networks: ## create custom networks as many needed under this network tag
          NetworkName: ## name of the network
            aliases:
              - aliases
            driver: ## type of network driver
              driver-opts:

        volumes:  ## create custom volumes as many needed under this volume tag
          VolumeName: ## Name of volume
            driver: ## type of network driver
              driver-opts:

        services: ## Containers and their defination
          
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
