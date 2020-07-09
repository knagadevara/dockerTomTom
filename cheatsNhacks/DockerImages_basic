Docker is a combination of files and directories which are seperated as branches. 
Every single image which is saved as a repository[with a identifiable name/tag] consists series of integrated layers which use Union file system.

#pull docker images syntax
docker pull <registery>:<repository>:<tag>

#adding an -a or --all will pull all the tags in the 'repository'

#To see all the info about images
docker images --digests <image-name>

#To check howmany layers an image is made up of
#Basic
docker image history --human <image-name>
#Detail
docker image inspect <image-name>

As Docker doesn't allow naming, 'tags' are used, basically they are version's of a image.
To explicitly set a tag to repository.[ The image-id will still be the same]
#docker image tag SourceRepositoryName/[:TAG] username/DestinationRepositoryName/[:TAG]

 To upload the user created image process
 #docker login
 #docker image push <username/image-repository-name/tag-name>
 #docker logout
 
 Authorization Key will be saved at /root/.docker.config.json
 