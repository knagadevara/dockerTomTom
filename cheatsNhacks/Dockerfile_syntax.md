#### Docker File ####
---------------------
- Dockerile gets executed from Top to Bottom in a step-by-step procedure, if a step changes the corresponding next in line have to be re-build, its ideal to keep the most variable data like the application sources or supportive static files at the bottom.
   - Change the least at the TOP
   - Change the most at the BOTTOM
- If 'CMD' is not declared in the file a default version will be consdered 'FROM <base-image>'

##### Syntax
-----------
       
        FROM <base-image name> 
        LABEL <lablename>="version"
        RUN <What to run> --> new layer will be created and result will be the base image for further processing
        RUN ls -sf /dev/stdout /var/log/app/access.log && ls -sf /dev/sterr /var/log/app/error.log
        EXPOSE <port-no> --> dosent open the ports directly to the external host, '--publish' is used to do that. 
        <runs a curl command to check the health of the application in the container every N1 Seconds>
        HEALTHCHECK --interval=N1s --timeout=N2s --start-period=N3s --retries=N4s
                CMD curl -fs https://URL-PATH:$PORT/healthPage || exit 1
        WORKDIR <instruction to set workdir for add, copy and cmd>
        ENV : env-variables
        ADD <https://> <destination in docker container>
        COPY <source directory> <destination directory>
        CMD ['Executable' , 'param1' , 'param2'] --> <There shall be only one cmd instruction in a docker file.  If there are two CMD the last one will be considered. Execute the application inside the image and make the container live>        

##### Example
------------

        FROM alpine:3.7
        LABEL "AUTHOR_NAME"="Karthik Nagadevara"
        LABEL "AUTHOR_EMAIL"="vnsk.1991@gmail"
        LABEL "VER"="00.00.01"
        RUN apk update
        RUN apk add nginx
        EXPOSE 80, 443
        WORKDIR /usr/share/nginx/html
        COPY htdocs htdocs
        CMD [ "nginx" , "-g" , "daemon off;" ]

- : Best way to deal with logs os to have them directly log out into the container stdout/stderr
        
        RUN ls -sf /dev/stdout /var/log/app/access.log && ls -sf /dev/sterr /var/log/app/error.log