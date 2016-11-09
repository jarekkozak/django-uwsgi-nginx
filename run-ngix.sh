#!/bin/bash
. config
docker stop $NGIX
docker rm -f $NGIX
docker run -d -p 0.0.0.0:8000:80 --name=$NGIX $NGIX_IMAGE

