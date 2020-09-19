FROM ubuntu:latest
MAINTAINER Tony Stark

## Escaping Terminal Errors
ENV TERM=xterm-256color

## Changing the local repository to Indian
RUN sed -i "s/http:\/\/archive./http:\/\/in.archive./g" /etc/apt/sources.list

## Install only required and needed
RUN apt-get update && \
    apt-get upgrade -y \
    -o APT::Install-Recommend=false \
    -o APT::Install-Suggested=false \
    python virtualenv

## Activating virtual enviornment, which later can be used for 'wheel' installations
RUN virtualenv /appenv && \
    . /appenv/bin/activate && \
    pip install pip --upgrade

## Adding entrypoint script into /use/local/bin so it would be available from all locations
ADD scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]