#!/usr/bin/env bash

htrace() {
  docker run --rm -it --name htrace.sh htrace.sh -u "$@"
}
