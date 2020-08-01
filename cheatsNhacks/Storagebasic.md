#### Storage Docker ####
-------------------------

##### Volumes
-------------
A volume can have one to many relationship mapping with the containers, all the created volumes are stored under '/var/lib/docker/volumes/' directory which can only be accessed by docker container processes to which it is associated with but not any host process. When that container stops or is removed, the volume still exists. 
- Multiple containers can mount the same volume simultaneously, either read-write or read-only. Volumes are only removed when you explicitly remove them.
- When you want to store your container’s data on a remote host or a cloud provider, rather than locally.
- When you need to back up, restore, or migrate data from one Docker host to another, volumes are a better choice. You can stop containers using the volume, then back up the volume’s directory (such as /var/lib/docker/volumes/<volume-name>).

The default Storage Driver: overlay2
- : To create a docker volume on the scame system where the daemon is running
        
        docker volume create --driver local <volume-name>

- : To start a container with new named volume mount point [creates if it dosent exist], The created mount point can be shared across multiple containers but not recommended 
        
        docker run -d --name <container-name> -e <Enviornment-Variables> --mount source=<Name-Of-Volume>,destination='PATH_inside_CONTAINER' <Image-Name>

##### Bind Mounts
-----------------
A file or a directory which is mounted inside the container, they can be stored anywhere on the host machine, even a non-docker process can access and modify the state of files and directories inside a Bind volume mount. Configurations can be shared from host machine onto docker container vise versa, but Bind Mount cannot be used inside the Dockerfile.
- Sharing configuration files from the host machine to containers. This is how Docker provides DNS resolution to containers by default, by mounting /etc/resolv.conf from the host machine into each container.

        docker run -d --name <container-name> -e <Enviornment-Variables> --mount type=bind,source='PATH_inside_HOST',target='PATH_inside_CONTAINER' <MySQL>

##### 'tmpfs' Mounts
--------------------
A tmpfs mount is not persisted on disk, either on the Docker host or within a container. It can be used by a container during the lifetime of the container, to store non-persistent state or sensitive information. For instance, internally, swarm services use tmpfs mounts to mount secrets into a service’s containers.

Source: 
- https://docs.docker.com/storage/
- https://docs.docker.com/storage/storagedriver/select-storage-driver/
