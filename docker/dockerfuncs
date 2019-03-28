#!/usr/bin/env bash

htrace() {
  docker run --rm -it --name htrace.sh htrace.sh -u "$@"
}

ctop() {
  docker run --rm -it --name=ctop \
    -v /var/run/docker.sock:/var/run/docker.sock \
    quay.io/vektorlab/ctop:latest
}
