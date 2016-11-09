#!/bin/bash
. config
docker stop $NGIX
docker rm -f $NGIX
docker rmi -f $NGIX_IMAGE
docker build -t $NGIX_IMAGE .



