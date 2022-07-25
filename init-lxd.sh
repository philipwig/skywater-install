#!/bin/bash

# exit when command fails
set -eu

# name of the lxc profile to be created
PROFILE_NAME="skywater"

# get the uid and gui of the host
HOST_UID=$(id -u)
HOST_GID=$(id -g)

mkdir -p $PWD/work


# set up a separate key to make sure we can log in automatically via ssh
# with $HOME mounted
KEY=$HOME/.ssh/id_lxd_$USER
PUBKEY=$KEY.pub
AUTHORIZED_KEYS=$HOME/.ssh/authorized_keys
[ -f $PUBKEY ] || ssh-keygen -f $KEY -N '' -C "key for local lxds"
# grep "$(cat $PUBKEY)" $AUTHORIZED_KEYS -qs || cat $PUBKEY >> $AUTHORIZED_KEYS
SSH_KEY=$(cat $PUBKEY)

# create lxc profile
# ignore output because profile might already exist
lxc profile create $PROFILE_NAME &> /dev/null || true

echo "Created profile"

# configure profile
# will overwrite existing profile 
cat << EOF | lxc profile edit $PROFILE_NAME
config:
  # this part maps uid/gid on the host to the same on the container
  raw.idmap: |
    uid $HOST_UID 1000
    gid $HOST_GID 1000
  environment.DISPLAY: :0
  environment.PULSE_SERVER: unix:/home/ubuntu/pulse-native
  nvidia.driver.capabilities: all
  nvidia.runtime: "true"
  user.user-data: |
    #cloud-config
    users:
        - default
        - name: philip
          shell: /usr/bin/bash
          ssh_authorized_keys:
            - $SSH_KEY
          sudo: ALL=(ALL:ALL) NOPASSWD:ALL
    runcmd:
      - 'sed -i "s/; enable-shm = yes/enable-shm = no/g" /etc/pulse/client.conf'
    packages:
      - x11-apps
      - mesa-utils
      - pulseaudio
description: GUI LXD profile
devices:
  PASocket1:
    bind: container
    connect: unix:/run/user/1000/pulse/native
    listen: unix:/home/ubuntu/pulse-native
    security.gid: "$HOST_GID"
    security.uid: "$HOST_UID"
    uid: "1000"
    gid: "1000"
    mode: "0777"
    type: proxy
  X0:
    bind: container
    connect: unix:@/tmp/.X11-unix/X1
    listen: unix:@/tmp/.X11-unix/X0
    security.gid: "$HOST_GID"
    security.uid: "$HOST_UID"
    type: proxy
  mygpu:
    type: gpu
  eth0:
    name: eth0
    network: lxdbr0
    type: nic
  root:
    path: /
    pool: default
    type: disk
  setup:
    # Needs to be an absolute path
    source: $PWD/setup
    path: /remote/setup
    type: disk
  work:
    # Needs to be an absolute path
    source: $PWD/work
    path: /remote/work
    type: disk
name: $PROFILE_NAME
used_by: []
EOF

echo "Wrote profile configuration"

# launch a container using this profile
lxc launch ubuntu:lts --profile $PROFILE_NAME skywater2

echo "Launched container"

# # Wait a bit for container to launch
sleep 2

# Copy bash config into container
# lxc file push profile.txt skywater/home/ubuntu/.profile
# lxc file push bashrc.txt skywater/home/ubuntu/.bashrc
# lxc file push bash_logout.txt skywater/home/ubuntu/.bash_logout

# lxc exec skywater2 --user $HOST_UID -- ./remote/setup/install.sh ~/tools

# to login to the container 
echo "To login to the container use: lxc exec skywater2 -- sudo --user philip --login"
echo "Edit /remote/setup/config.toml to configure installed tools"
echo "To install skywater pdk and tools use: python /remote/setup/skywater.py build"
