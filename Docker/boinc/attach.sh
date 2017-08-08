#!/bin/bash

while true; do

  if grep -q "Initialization complete" /var/lib/boinc-client/log; then
      exec boinccmd --project_attach http://www.worldcommunitygrid.org 1013367_21303863232c651457665d59cf936248 &
      break
  else
      sleep 2
  fi

done
