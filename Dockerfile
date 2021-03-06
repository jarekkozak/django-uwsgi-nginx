# Copyright 2013 Thatcher Peskens
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:trusty

MAINTAINER Dockerfiles

# Install required packages and remove the apt packages cache when done.

RUN apt-get update && apt-get install -y \
	git \
	python3 \
	python3-dev \
	python3-setuptools \
	python3-pip \
	nginx \
	language-pack-en \
	libpq-dev \
	vim \
	supervisor \
	sqlite3 \
  && rm -rf /var/lib/apt/lists/*

#RUN easy_install pip

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN pip3 install --upgrade pip

# install uwsgi now because it takes a little while
RUN pip3 install uwsgi

# setup all the configfiles
RUN echo "daemon off;" >> /etc/nginx/nginx.conf


# COPY requirements.txt and RUN pip install BEFORE adding the rest of your code, this will cause Docker's caching mechanism
# to prevent re-installinig (all your) dependencies when you made a change a line or two in your app. 
# RUN mkdir /home/docker/code/app

RUN mkdir -p /home/docker/code/app

ADD requirements.txt /home/docker/code/app
ADD nginx-app.conf /home/docker/code
ADD supervisor-app.conf /home/docker/code
ADD uwsgi.ini /home/docker/code
ADD uwsgi_params /home/docker/code



ADD run.sh /home/docker/code



#COPY nginx-app.conf /etc/nginx/sites-available/default
#COPY supervisor-app.conf /etc/supervisor/conf.d/

RUN ln -sf /home/docker/code/nginx-app.conf /etc/nginx/sites-enabled/default
RUN ln -sf /home/docker/code/supervisor-app.conf /etc/supervisor/conf.d/app.conf

RUN pip3 install -r /home/docker/code/app/requirements.txt

# add (the rest of) our code
# create unprivileged user

RUN adduser --disabled-password --gecos '' ngixuser

# install django, normally you would remove this step because your project would already
# be installed in the code/app/ directory
RUN django-admin.py startproject website /home/docker/code/app/

# Test application in docer allow to connect from other
RUN sed -i -e "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \['*'\]/g" /home/docker/code/app/website/settings.py

RUN mkdir -p /home/docker/code/media
VOLUME  ["/home/docker/code","/etc/nginx/sites-available","/etc/supervisor/conf.d","/home/docker/code/media"]
EXPOSE 80
ENTRYPOINT ["/bin/bash","/home/docker/code/run.sh"]
