FROM knagadevara/todo_base_image:0.1 AS todo_base_image
LABEL imgType="todo_dev_image"
MAINTAINER Bruce Wayne

## Escaping Terminal Errors
ENV TERM=xterm-256color

RUN apt-get update && \
    apt-get install -qy apt-get install -qy python-dev python3-dev libmysqlclient-dev libssl-dev libffi-dev 

## Activate virtual enviornment and install Wheel
RUN . /appenv/bin/activate && \
    pip install wheel --upgrade

## Wheel Enviornment
ENV WHEELHOUSE=/wheelhouse PIP_WHEEL_DIR=/wheelhouse PIP_FIND_LINKS=/wheelhouse XDG_CACHE_HOME=/cache

## Volume for /wheelhouse
VOLUME /wheelhouse
VOLUME /reports

## Copy testing parameters
COPY scripts/test.sh /usr/local/bin/test.sh
RUN  chmod +x /usr/local/bin/test.sh

## Testing entrypoint
ENTRYPOINT ["test.sh"]
CMD ["python" , "manage.py" , "test" ]

## Copying the application Source code
COPY src /application
WORKDIR /application
