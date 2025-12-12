#!/bin/bash

./build.sh && docker run djaprog/raspberry-pi-cross-compiler > ~/.bin/rpxc && chmod +x ~/.bin/rpxc