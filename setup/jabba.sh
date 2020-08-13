#!/usr/bin/env bash

if [ -d ~/.jabba ]; then
  echo 'jabba installed...skipping'
else
  echo 'Installing jabba'
  # shellcheck source=/dev/null
  curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash && . ~/.jabba/jabba.sh
fi
