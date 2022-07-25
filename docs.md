# LXD config

Read user data from config file in pwd and create container. You can point this wherever you want

```bash
lxc launch ubuntu:focal my-test --config=user.user-data="$(cat config.yaml)"
```

Launch shell in container

```bash
lxc shell my-test
```

```bash
lxc exec my-test bash
```

Login to container

```
lxc exec x11-container -- sudo --user ubuntu --login
```

Verify cloud-init ran successfully

```bash
cloud-init status
```

Wait for cloud-init to finish

```bash
cloud-init status --wait
```

Update the user-data, the cloud-init settings, for a profile from a file

```bash
lxc profile set dev-test2 user.user-data="$(cat cloud-config.yaml)"
```

Create and write new profile

```
lxc profile create x11
lxc profile edit x11 < x11.profile
```

Add folder into container

```
lxc profile device add x11 test disk source=~/docker-test2 path=/home/ubuntu/test
```

# x11 in LXD containers

LXD GUI profile
Here is the updated LXD profile to setup a LXD container to run X11 application on the host’s X server. Copy the following text and put it in a file, x11.profile. Note that the bold text below (i.e. X1) should be adapted for your case; the number is derived from the environment variable $DISPLAY on the host. If the value is :1, use X1 (as it already is below). If the value is :0, change the profile to X0 instead.

```
config:
  environment.DISPLAY: :0
  environment.PULSE_SERVER: unix:/home/ubuntu/pulse-native
  nvidia.driver.capabilities: all
  nvidia.runtime: "true"
  user.user-data: |
    #cloud-config
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
    security.gid: "1000"
    security.uid: "1000"
    uid: "1000"
    gid: "1000"
    mode: "0777"
    type: proxy
  X0:
    bind: container
    connect: unix:@/tmp/.X11-unix/X1
    listen: unix:@/tmp/.X11-unix/X0
    security.gid: "1000"
    security.uid: "1000"
    type: proxy
  mygpu:
    type: gpu
name: x11
used_by: []
```

Then, create the profile with the following commands. This creates a profile called x11.

$ lxc profile create x11
Profile x11 created
$ cat x11.profile | lxc profile edit x11
$
To create a container, run the following.

lxc launch ubuntu:18.04 --profile default --profile x11 mycontainer
To get a shell in the container, run the following.

lxc exec mycontainer -- sudo --user ubuntu --login
Once we get a shell inside the container, you run the diagnostic commands.

$ glxinfo -B
name of display: :0
display: :0  screen: 0
direct rendering: Yes
OpenGL vendor string: NVIDIA Corporation
...
$ nvidia-smi
 Mon Dec  9 00:00:00 2019
+-------------------------------------------------------------------------+
| NVIDIA-SMI 430.50       Driver Version: 430.50       CUDA Version: 10.1 |    |---------------------------+----------------------+----------------------+
| GPU  Name    Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|     Memory-Usage | GPU-Util  Compute M. |
|===========================+======================+======================|
...
$ pactl info
 Server String: unix:/home/ubuntu/pulse-native
 Library Protocol Version: 32
 Server Protocol Version: 32
 Is Local: yes
 Client Index: 43
 Tile Size: 65472
 User Name: myusername
 Host Name: mycomputer
 Server Name: pulseaudio
 Server Version: 11.1
 Default Sample Specification: s16le 2ch 44100Hz
 Default Channel Map: front-left,front-right
 Default Sink: alsa_output.pci-0000_01_00.1.hdmi-stereo-extra1
 Default Source: alsa_output.pci-0000_01_00.1.hdmi-stereo-extra1.monitor
 Cookie: f228:e515
$
You can run xclock which is an Xlib application. If it runs, it means that unaccelerated (standard X11) applications are able to run successfully.
You can run glxgears which requires OpenGL. If it runs, it means that you can run GPU accelerated software.
You can run paplay to play audio files. This is the PulseAudio audio play.
If you want to test with Alsa, install alsa-utils and use aplay to play audio files.
