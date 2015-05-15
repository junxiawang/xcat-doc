<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Overview](#overview)
- [apt-get install docker.io](#apt-get-install-dockerio)
  - [Get xCAT Docker Image From Docker Hub](#get-xcat-docker-image-from-docker-hub)
- [docker search xcat](#docker-search-xcat)
- [docker pull -a daniceexi/xcat](#docker-pull--a-daniceexixcat)
- [docker images daniceexi/xcat](#docker-images-daniceexixcat)
- [docker run -it --privileged daniceexi/xcat:centos6_xcat2.9](#docker-run--it---privileged-daniceexixcatcentos6_xcat29)
- [....](#)
- [lsdef compute1](#lsdef-compute1)
- [chdef compute1 bmc=10.1.1.1 bmcusername=m](#chdef-compute1-bmc10111-bmcusernamem)
- [rpower compute1 stat](#rpower-compute1-stat)
- [rvitals compute1](#rvitals-compute1)
- [# rinv compute1](##-rinv-compute1)
- [rinv compute1](#rinv-compute1)
- [lsdef compute1](#lsdef-compute1-1)
  - [Create a xCAT Docker Image](#create-a-xcat-docker-image)
- [vi xCAT-core.repo](#vi-xcat-corerepo)
- [vi xCAT-dep.repo](#vi-xcat-deprepo)
- [! /bin/bash](#-binbash)
- [This script will be run as the ENTRYPOINT of xCAT docker image](#this-script-will-be-run-as-the-entrypoint-of-xcat-docker-image)
- [to start xcatd and depended services](#to-start-xcatd-and-depended-services)
- [Start the rsyslog service](#start-the-rsyslog-service)
- [Start the sshd service](#start-the-sshd-service)
- [Start the httpd service](#start-the-httpd-service)
- [remove the network entries so that it will be recreated later](#remove-the-network-entries-so-that-it-will-be-recreated-later)
- [Start the xCAT service](#start-the-xcat-service)
- [find the current IP of eth0 and set it as xCAT master ip](#find-the-current-ip-of-eth0-and-set-it-as-xcat-master-ip)
- [recreate networks object](#recreate-networks-object)
- [Create a test node](#create-a-test-node)
- [cat Dockerfile](#cat-dockerfile)
  - [Configure xCAT Container to Enable OS Deployment Function](#configure-xcat-container-to-enable-os-deployment-function)
    - [Create my Customized Bridge](#create-my-customized-bridge)
    - [Configure a static IP for the container](#configure-a-static-ip-for-the-container)
    - [Enable /etc/hosts and /etc/resolv.conf](#enable-etchosts-and-etcresolvconf)
    - [Confgiure xCAT Service](#confgiure-xcat-service)
    - [Run OS deployment](#run-os-deployment)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

##Overview
Docker image is an easy and hot way to manage application deployment on Linux. This document describes how to create and use docker image for xCAT application, you also can download the released xCAT docker image from docker hub.

**Prerequisites to Use xCAT Docker Image:**

* **Setup a docker host**

Find a physical server and install the latest Ubuntu Operating System (In this example, we use Ubuntu OS, you could choose any OS which supports Docker). Then install docker packages:

~~~~
#apt-get install docker.io
~~~~
 
##Get xCAT Docker Image From Docker Hub 
An experimental xCAT docker image **daniceexi/xcat** has been pushed to docker hub. You can download and use it with following steps.

**Note:** This xCAT docker image will NOT assign a static public IP (The public IP means it can be accessed from outside of docker host) for the new created container. That means you cannot enable http, dhcp, tftp service in this xCAT container. For this reason, the OS deployment function is NOT available. You can just use this container to experiment xCAT commands and do hardware control. If you want to enable the FULL xCAT functions, following the steps in section **Configure xCAT Container to Enable OS Deployment**.

* **Search the xcat repository from docker hub**

Try to search 'xcat' repository on docker hub repository.

~~~~
# docker search xcat
NAME             DESCRIPTION   STARS     OFFICIAL   AUTOMATED
daniceexi/xcat                 0
~~~~
* **Pull this xcat repository to local server**

Pull the xcat repository from remote docker bub repository to local server.

~~~~
# docker pull -a daniceexi/xcat
Pulling repository daniceexi/xcat
c99b15b7ed8d: Download complete
....
~~~~

* **Display the xcat image which you got from docker hub**

After the 'docker pull' operation finished, you can display the xCAT image which you just pulled from remote docker hub.

~~~~
# docker images daniceexi/xcat
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
daniceexi/xcat      centos6_xcat2.9     c99b15b7ed8d        18 hours ago        638.7 MB
~~~~

* **Run this xcat docker image**

Start a Linux container from xCAT docker image, then you will get an xCAT environment to experiment xCAT commands.

~~~~
# docker run -it --privileged daniceexi/xcat:centos6_xcat2.9
....
=================================================================================
This is a Linux container with xCAT service.
You can follow below steps to experience how to use xCAT to manage a x86 server.
For any question, send to <xcat-user@lists.sourceforge.net>

1. Display the predefined node <compute1>
# lsdef compute1

2. Map <compute1> to one of your real x86 machine
     If bmc ip of you machine is '10.1.1.1',
     and <username> of bmc is 'myuser',
     and <password> of bmc is 'mypassword'
# chdef compute1 bmc=10.1.1.1 bmcusername=m

3. Check the Power stat
# rpower compute1 stat

4. Get the vitals information for the node
# rvitals compute1

5. Get the inventory information for the no
# rinv compute1
===========================================
bash-4.1#
~~~~

* **Try xCAT commands**

The running container from image 'daniceexi/xcat:centos6_xcat2.9' displays a simple guide of how to experiment some xCAT commands and enabled an interactive bash shell. In this shell, you try any xCAT command.

~~~~
# lsdef compute1
Object name: compute1
    bmc=192.168.1.1
    bmcpassword=PASSW0RD
    bmcusername=USERID
    groups=compute
    mgt=ipmi
    postbootscripts=otherpkgs
    postscripts=syslog,remoteshell,syncfiles
~~~~

##Create a xCAT Docker Image
This section will describe how to use 'Dockerfile' to create xCAT docker image. The selected base docker image is 'centos6' and xCAT release is 'xCAT2.9'.

* **Create a directory to perform the docker build**

Create a working directory on docker host.

~~~~
mkdir /xcatdocker/
cd /xccatdocker/
~~~~

* **Create the yum repository files for xCAT and xCAT-dep**

Add xCAT yum repository files for Docker builder to know where's the install repositories of xCAT and dependencies.

~~~~
# vi xCAT-core.repo
[xcat-2-core]
name=xCAT 2 Core packages
baseurl=https://sourceforge.net/projects/xcat/files/yum/2.9/xcat-core
enabled=1
gpgcheck=1
gpgkey=https://sourceforge.net/projects/xcat/files/yum/2.9/xcat-core/repodata/repomd.xml.key

# vi xCAT-dep.repo
[xcat-dep]
name=xCAT 2 depedencies
baseurl=https://sourceforge.net/projects/xcat/files/yum/xcat-dep/rh6/x86_64
enabled=1
gpgcheck=1
gpgkey=https://sourceforge.net/projects/xcat/files/yum/xcat-dep/rh6/x86_64/repodata/repomd.xml.key
~~~~

* **Create a startup file to enable and configure xCAT service**

This script file will be run at the beginning of running an xCAT container. It will try to start services and display a simple xCAT usage guide.

~~~~
#! /bin/bash

# This script will be run as the ENTRYPOINT of xCAT docker image
# to start xcatd and depended services

# Start the rsyslog service
service rsyslog start

# Start the sshd service
service sshd start

# Start the httpd service
service httpd start

# remove the network entries so that it will be recreated later
rm -f /etc/xcat/networks.sqlite

# Start the xCAT service
. /etc/profile.d/xcat.sh
service xcatd start

# find the current IP of eth0 and set it as xCAT master ip
myip=$(ip addr show dev eth0 | grep inet | grep eth0 | awk -F' ' '{print $2}' | sed -e 's/\/.*//')
chdef -t site master=$myip

# recreate networks object
makenetworks

# Create a test node
mkdef -t node compute1 groups=compute mgt=ipmi bmc=192.168.1.1 bmcusername=USERID bmcpassword=PASSW0RD

echo
echo
echo
echo "================================================================================="
echo "This is a Linux container with xCAT service."
echo "You can follow below steps to experience how to use xCAT to manage a x86 server."
echo "For any question, send to <xcat-user@lists.sourceforge.net>"
echo
echo "1. Display the predefined node <compute1>"
echo "# lsdef compute1"
echo
echo "2. Map <compute1> to one of your real x86 machine"
echo "     If bmc ip of you machine is '10.1.1.1',"
echo "     and <username> of bmc is 'myuser',"
echo "     and <password> of bmc is 'mypassword'"
echo "# chdef compute1 bmc=10.1.1.1 bmcusername=myuser bmcpassword=mypassword"
echo
echo "3. Check the Power stat"
echo "# rpower compute1 stat"
echo
echo "4. Get the vitals information for the node"
echo "# rvitals compute1"
echo
echo "5. Get the inventory information for the node"
echo "# rinv compute1"
echo "================================================================================="

/bin/bash
~~~~

* **Create a Dockerfile**

This is the docker configure file for docker builder to know how to build xCAT docker image.

~~~~
# cat Dockerfile

FROM centos:centos6

MAINTAINER wxp@cn.ibm.com

COPY xCAT-core.repo /etc/yum.repos.d/
COPY xCAT-dep.repo /etc/yum.repos.d/

RUN yum -y install openssh-server.x86_64
RUN yum -y install rsyslog
RUN yum -y install xCAT

VOLUME ["/iso/", "/iso"]

COPY startservice.sh /startservice.sh
ENTRYPOINT ["/startservice.sh"]
~~~~
* **Execute the docker build process**

Build the xcat docker image with name 'xcat:xcat2.9' (it means the repository name is 'xcat' and image tag is 'xcat2.9').

~~~~
docker build -t xcat:xcat2.9 .

Show the new created docker image:
docker images
~~~~

##Configure xCAT Container to Enable OS Deployment Function
The xCAT image which you downloaded from docker hub is using the default dynamic assigned IP. If you want to enable xCAT OS deployment service for compute node (physical machines or virtual machine), you need to configure a static public IP for the xCAT container.

The configuration example that will be used in this section:

~~~~
    Docker host: dhost1
    The interface which is used to communicate with other physical machine or virtual machine: eth0
    The IP of eth0: 192.168.1.100/24
    The default docker bridge: docker0
    My customized bridge for OS deployment: mydocker0
    The static IP for xCAT container: 192.168.1.200/24
~~~~

###Create my Customized Bridge
On the docker host 'dhost1', create the new bridge 'mydocker0' and move the IP '192.168.1.100/16' from eth0 to mydocker0.

~~~~
    brctl addbr mydocker0
    brctl setfd mydocker0 0
    ip addr del dev eth0 192.168.1.100/24
    brctl addif mydocker0 eth0
    ip link set mydocker0 up
    ip addr add dev mydocker0 192.168.1.100/24
~~~~

###Configure a static IP for the container
Use the namespace mechanism to change the IP of container from docker host.

~~~~
    Get the pid of xCAT container
         1. Find the running xCAT container on docker host 'dhost1' by 'docker ps'.
         2. Find the process id of the xCAT container: 'docker inspect <container id> | grep Pid'
    mkdir /var/run/netns
    ln -s /proc/$pid/ns/net /var/run/netns/$pid
    ip netns exec $pid ip addr del dev eth0 ${old_ip_which_assigned_by_docker}
    ip netns exec $pid ip addr add dev eth0 192.168.1.200/24
~~~~

###Enable /etc/hosts and /etc/resolv.conf
By default, the /etc/hosts and /etc/resolv.conf in the container are mounted in readonly from docker host. xCAT needs to change these two files to define new xCAT node, so we need remove the readonly mount and create new files.

Run the docker image with '--privileged=true' parameter for xCAT container has the privilege to handle the specific files '/etc/hosts' and '/etc/resolv.conf'.

~~~~
docker run -it --privileged=true daniceexi/xcat:centos6_xcat2.9
~~~~

In the running xCAT container, manipulate the files:

~~~~
umount /etc/hosts
umount /etc/resolv.conf
Change /etc/hosts as you wanted.
~~~~
 
###Confgiure xCAT Service

Since the IP of xCAT container has been changed, you need run following steps to take the IP change.

~~~~
1. Change the 'master' and 'nameserver' attributes in site table to the new IP of container.
2. Delete the original network definition in the networks table.
3. Create a new network object: 
    #makenetworks
~~~~

###Run OS deployment
Follow the common xCAT doc to know how to use xCAT. 

**NOTE:** A volume named '/iso' has been created in container, this /iso directory is mounted to the /iso of docker host. So you can copy the .iso file of tartget OS in the /iso of docker host, and use it in the /iso of xCAT container (e.g. run copycds command).