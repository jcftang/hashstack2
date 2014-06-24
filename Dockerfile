# Dervived from
#
# docker-dna/base/Dockerfile
#
# NAME       wrale/docker-dna_base
# VERSION    12.04.w2
#
# FROM ubuntu:12.04
# MAINTAINER Joshua Dotson, josh@wrale.com

FROM ubuntu:12.04
MAINTAINER Jimmy Tang, jcftang@gmail.com

# Update distribution
RUN ( echo 'deb http://archive.ubuntu.com/ubuntu precise main' && \
      echo 'deb http://archive.ubuntu.com/ubuntu precise-updates main' && \
      echo 'deb http://security.ubuntu.com/ubuntu precise-security main' && \
      echo 'deb http://archive.ubuntu.com/ubuntu precise universe' && \
      echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' \
    ) > /etc/apt/sources.list \
      && apt-mark hold upstart \
      && apt-mark hold initscripts \
      && dpkg-divert --local --rename --add /sbin/initctl \
      && ln -sf /bin/true /sbin/initctl \
      && apt-get update \
      && apt-get upgrade -y \
      && apt-get clean

# Install base dependencies (Ubuntu <= 12.04)
RUN apt-get install curl python-software-properties -y \
      && add-apt-repository ppa:rquillo/ansible -y \
      && apt-get update \
      && apt-get install ansible -y \
      && apt-get clean

# Replace dash's sh with bash's sh, dash may cause problems down the road
RUN ln -sf /bin/bash /bin/sh

RUN apt-get install git -y

# Install minimal dependencies to build apps, this list does not install 'build-essential' as we need to find out what sub packages are really needed
RUN apt-get install gcc -y \
      && apt-get install g++ -y \
      && apt-get install gfortran -y \
      && apt-get install libtool -y \
      && apt-get install make -y \
      && apt-get clean

# Get Hashdist and copy in current *stack*, this could be done in a cleaner way
RUN git clone https://github.com/hashdist/hashdist.git /hashdist
RUN ln -s /hashdist/bin/hit /usr/bin/hit
RUN cd ./hashdist && git pull
ADD . ./hashstack

# Copy in a default stack that a user might do and try building it
# It might be worth mapping a volume to keep the artifacts and also use
# ONBUILD here as well.
RUN cd ./hashstack && cp examples/docker.ubuntu-core.default.yaml core.yaml
RUN cd ./hashstack && hit build core.yaml --verbose

RUN cd ./hashstack && cp examples/docker.ubuntu-numerical.default.yaml numerical.yaml
RUN cd ./hashstack && hit build numerical.yaml --verbose
