#!/bin/bash
now=$(date +"%T")
echo "Container Start Time : $now" >> /tmp/start.txt
pip3 install -r /home/docker/code/app/requirements.txt >> /tmp/start.txt
/usr/bin/supervisord -n -c /etc/supervisord.conf
