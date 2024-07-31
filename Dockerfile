# Use Ubuntu 16.04 as the base image
FROM ubuntu:16.04

# Install Python and other dependencies as root before switching to user
RUN apt-get update && apt-get install -y \
    python2.7 \
    python-pip \
    zlib1g-dev \
    libjpeg8 \
    libjpeg62-dev \
    curl \
    sudo

# Create cuckoo user with no password and add to sudo group
RUN adduser --disabled-password --gecos "" cuckoo && \
    usermod -aG sudo cuckoo

# Switch to cuckoo user
USER cuckoo

# Ensure the user cuckoo can access Python and pip
ENV PATH=$PATH:/usr/bin:/home/cuckoo/.local/bin

# Download and install pip for Python 2.7
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o /tmp/get-pip.py
RUN /usr/bin/python2.7 /tmp/get-pip.py
RUN rm /tmp/get-pip.py

# Install Cuckoo and setuptools using pip
RUN pip install -U setuptools cuckoo

# Copy the vbox-client to the appropriate location for use as vboxmanage
COPY bin/vbox-client /usr/bin/vboxmanage

# Set the working directory to /home/cuckoo
WORKDIR /home/cuckoo

# Set the entrypoint to cuckoo
CMD ["cuckoo"]