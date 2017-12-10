#!/bin/bash
echo "# RUN SUPERVISORD/NGINX #"

if ! [ -z "$NGIX_REDIRECT" ]; then
echo "Replace redirect:$NGIX_REDIRECT"
RPL="s#http://www.example.com#$NGIX_REDIRECT#g"
sed -i -e $RPL /home/docker/code/nginx-app.conf
fi

if ! [ -z "$NGIX_DOMAIN" ]; then
echo "Replace domain:$NGIX_DOMAIN"
RPL="s#www.example.com#$NGIX_DOMAIN#g"
sed -i -e $RPL /home/docker/code/nginx-app.conf
fi

if ! [ -z "$NGIX_WSGI_MODULE" ]; then
echo "Replace uwsgi:$NGIX_WSGI_MODULE"
RPL="s/website.wsgi:application/$NGIX_WSGI_MODULE/g"
sed -i -e $RPL /home/docker/code/uwsgi.ini
fi

/usr/bin/supervisord -n

