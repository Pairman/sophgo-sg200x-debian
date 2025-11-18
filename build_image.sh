#!/bin/sh
docker run --privileged -it --rm -v `pwd`/configs/:/configs -v `pwd`/image:/output builder make BOARD=licheervnano image
