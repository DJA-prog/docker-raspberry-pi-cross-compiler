#!/bin/bash

: ${RPXC_IMAGE:=djaprog/raspberry-pi-cross-compiler}

# Default build arguments - can be overridden by environment variables
: ${INSTALL_WIRINGPI:=true}
: ${INSTALL_PIGPIO:=true}
: ${INSTALL_CROW:=true}
: ${INSTALL_SQLITE:=true}
: ${INSTALL_TGBOT:=true}

docker build \
    --build-arg INSTALL_WIRINGPI=$INSTALL_WIRINGPI \
    --build-arg INSTALL_PIGPIO=$INSTALL_PIGPIO \
    --build-arg INSTALL_CROW=$INSTALL_CROW \
    --build-arg INSTALL_SQLITE=$INSTALL_SQLITE \
    --build-arg INSTALL_TGBOT=$INSTALL_TGBOT \
    -t $RPXC_IMAGE .
