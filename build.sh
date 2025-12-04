#!/bin/bash

: ${RPXC_IMAGE:=djaprog/raspberry-pi-cross-compiler}

docker build -t $RPXC_IMAGE .
