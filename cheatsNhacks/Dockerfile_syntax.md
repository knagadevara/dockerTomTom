## Docker File ##
-----------------

#### Syntax
-----------
       
        FROM <base-image name> 
        LABEL <lablename>="version"
        RUN <What to run> --> new layer will be created and result will be the base image for further processing
        CMD ['Executable' , 'param1' , 'param2'] --> <There shall be only one cmd instruction in a docker file.  If there are two CMD the last one will be considered.
        Execute the application inside the image and make the container live>
        EXPOSE <port-no>
        ENV : env-variables
        ADD <src> <dst>
        VOLUME <can define storage configuration, mount points, DB Storage>
        WORKDIR <instruction to set workdir for run,cmd and add>

#### Example
------------

        FROM alpine:3.7
        LABEL "AUTHOR_NAME"="Karthik Nagadevara"
        LABEL "AUTHOR_EMAIL"="vnsk.1991@gmail"
        LABEL "VER"="00.00.01"
        RUN apk update
        RUN apk add nginx
        EXPOSE 90
        CMD [ "nginx" , "-g" , "daemon off;" ]
