- To ensure all teh mounted volumes get the correct permissions, so that each of the running and exited containers can use it, run it with a deliberated exit and mount later.

        docker run --rm -v /tmp/cache:/cache --entrypoint none --name volcachetester <image-name>

        :::#on the second run
        docker run --volumes-from volcachetester --name actualContainer <image-name>