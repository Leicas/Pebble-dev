FROM ubuntu:16.04
MAINTAINER Antoine Weill

# update system and get base packages
RUN apt-get update && \
    apt-get install -y curl python2.7-dev python-pip libfreetype6-dev \
                       bash-completion libsdl1.2debian libfdt1 libpixman-1-0 \
                       libglib2.0-dev nodejs npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# set the version of the pebble tool
ENV PEBBLE_TOOL_VERSION pebble-sdk-4.5-linux64
# set the version of pre installed
ENV PEBBLE_SDK_VERSION 4.3

# get pebble tool
RUN curl -sSL https://developer.rebble.io/s3.amazonaws.com/assets.getpebble.com/pebble-tool/${PEBBLE_TOOL_VERSION}.tar.bz2 \
        | tar -v -C /opt/ -xj

# prepare python environment 
WORKDIR /opt/${PEBBLE_TOOL_VERSION}
RUN /bin/bash -c " \
        pip install virtualenv && \
        virtualenv --no-site-packages .env && \
        source .env/bin/activate && \
        pip install -r requirements.txt && \
        deactivate " && \
rm -r /root/.cache/
RUN mkdir /root/.pebble-sdk && touch /root/.pebble-sdk/NO_TRACKING

# change to pebble user
# set PATH
ENV PATH /opt/${PEBBLE_TOOL_VERSION}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# install sdk
RUN yes | pebble sdk install https://github.com/aveao/PebbleArchive/raw/master/SDKCores/sdk-core-4.3.tar.bz2

# prepare project mount path
VOLUME /pebble/

# set run command
WORKDIR /pebble/
CMD /bin/bash
