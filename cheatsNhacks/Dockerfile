FROM alpine:3.7
LABEL "AUTHOR_NAME"="Karthik Nagadevara"
LABEL "AUTHOR_EMAIL"="vnsk.1991@gmail"
LABEL "VER"="00.00.01"
RUN apk update
RUN apk add nginx
EXPOSE 90
CMD [ "nginx" , "-g" , "daemon off;" ]