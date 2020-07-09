Source: https://docs.docker.com/storage/storagedriver/select-storage-driver/

The default  Storage Driver: overlay2

# To create a docker volume on the scame system where the daemon is running
docker volume create --driver local <volume-name>

# To start a container with new named volume mount point [creates if it dosent exist] 
docker run -d --name <container-name> -e <Enviornment-Variables> --mount source=<Name-Of-Volume>,destination='/var/log/<MountName>' <Image-Name>
# The created mount point can be shared across multiple containers but not recommended

# Bind Mounts: A file or a directory which is mounted inside the container, they can be stored anywhere on the host machine.
## even a non-docker process can access and modify the state of files and directories inside a Bind volume mount. 
### Configurations can be shared from host machine onto docker container vise versa, but Bind Mount cannot be used inside the Dockerfile.
###### 
docker run -d --name <container-name> -e <Enviornment-Variables> --mount type=bind,source='PATH_inside_HOST',target='PATH_inside_CONTAINER' <MySQL>
