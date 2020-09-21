FROM ubuntu:latest
RUN apt-get install -qy software-properties-common && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt-get update -qy && apt-get install -qy ansible
VOLUMES /ansible
WORKDIR /ansible
ENTRYPOINT ["ansible-playbook"]