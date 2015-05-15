<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [BackGround](#background)
- [Features](#features)
- [](#)
  - [1. Dockerize xCAT (Low Priority)](#1-dockerize-xcat-low-priority)
    - [Discussion:](#discussion)
    - [Conclusion:](#conclusion)
    - [A experience of dockerizing xCAT from a customer](#a-experience-of-dockerizing-xcat-from-a-customer)
- [](#-1)
  - [2. Deploy docker host (High Priority)](#2-deploy-docker-host-high-priority)
- [](#-2)
  - [3. Container Management (High Priority)](#3-container-management-high-priority)
- [](#-3)
  - [4. Docker Image Management](#4-docker-image-management)
- [](#-4)
  - [5. Network Setting Cross Docker Host](#5-network-setting-cross-docker-host)
- [](#-5)
  - [6. Storage Management](#6-storage-management)
- [](#-6)
- [----------](#----------)
- [Additional Discussion](#additional-discussion)
  - [Enable Docker image in xCAT diskless system](#enable-docker-image-in-xcat-diskless-system)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

## BackGround
The docker technology is very hot in 2014, xCAT is planning to support the docker too. Following are the proposal list that will be supported in xCAT

## Features

----

### 1. Dockerize xCAT (Low Priority)

 1. To include xCAT in docker image. Create a docker image to include 'xCAT' and xCAT dependency packages so that xCAT service can be easily enabled by pulling and running a docker image.  
 2. Create a Dockerfile for xCAT so that customer can easily create a docker image for xCAT.

#### Discussion: 

* Pros:
    1. Customer can easily pull a xCAT docker image from public docker register and run it directly to get a xCAT environment.
    2. It will be easy to backup the whole xCAT management node. 
    3. It will be easy to implement HA for xCAT management node.
    4. Easy to deploy an environment for testing and traning.
    
* Cons:
    1. Customer might want to have a physical and individual server for xCAT MN;
    2. Use Yum or Zypper to install xCAT is not hard.
    3. Even with xCAT docker, customer still needs to run a lot configuration to enable a xCAT MN.
    4. The docker image is not easy to update packages or fix bugs.

#### Conclusion:
 1. A dockerized xCAT can be useful for small cluster or leaning/training.
 2. It also can be used to create diskless image for the one which OS isn't same with the xCAT management node.

#### A experience of dockerizing xCAT from a customer

The work was surprisingly easy. We have a Dockerfile of about 15 lines that does a a setup of xCAT inside a container. In the initialization we setup a default table configuration. Directories that contain state are exported as docker volumes. For process management we use supervisord. For image generation we inject iso files into the container at start time. Then on our login node we install the xCAT client package and we are done. 

We have tested by running Docker with the guest host's network stack. 

The details can be found https://github.com/clustervision/trinity/, notably in the ha-xcat folder.

----

### 2. Deploy docker host (High Priority)

Deploy and configure docker host. 
 1. Prepare docker packages for docker host;
 2. Install docker packages on docker host during OS deployment or updatenode.
 3. Configure network bridges on the docker host. This step is used to enable the network connection for dockers cross host.

After this step, the dock host is ready to initiate container.

----

### 3. Container Management (High Priority)

Create, Remove, Start and Stop Containers on docker host. Also will support the status check and remote console for containers.

*Comments*: We are arguing that using the 'mkvm, rmvm' which are used for virtual machine might NOT suitable for container management. 

 3.1 Define a Container in xCAT

 * Description: Make the definition of container. Add the necessary attributes for a container object.
        
        Definition Example: 
            Object name: host1c1        #Container 1 on Host 1
              mac=xx:xx:xx:xx:xx:xx
              mgt=docker
              ip=xxx.xxx.xxx.xxx
              provmethod=<docker image name>
              vmhost=<docker host>
              vmcpu=xx
              vmmemory=xx
              ... # The docker parameters like 'port', 'volume' and 'link containers' are the considered ones.

 3.2 Create a Container

 * Description: Create a container on target host. e.g. 'mkvm host1c1'. Create a container named c1 on host1 base on the attributes defined in host1c1 object.
 * xcat   CMD: mkvm
 * docker CMD: docker run

 3.3 Remove a Container
        
 * Description: Remove a container from target host. e.g. 'rmvm host1c1'. Remove the container named c1 from host1.
 * xcat   CMD: rmvm
 * docker CMD: docker rm

 3.4 Start a Container

 * Description: Start a container from target host. e.g. 'rpower host1c1 on'. Start the container named c1 on host1.
 * xcat   CMD: rpower <container node> on
 * docker CMD: docker start

 3.5 Stop a Container

 * Description: Stop a container from target host. e.g. 'rpower host1c1 off'. Stop the container named c1 from host1.
 * xcat   CMD: rpower <container  node> off
 * docker CMD: docker stop
    
 3.6 Check the Status for a Container
        
 * Description: Display the status of a container. e.g. 'rpower host1c1 state'. Check the status for the container named c1 from host1.
 * xcat   CMD: rpower <container  node> state
 * docker CMD: docker ps

 3.7 Start Remote Console for a Container
        
 * Description: Remote connect to container from target host. e.g. 'rcons host1c1'. Remote connect to the console of the container named c1 on host1.
 * xcat   CMD: rcons 
 * docker CMD: docker attach

 Comment: This might require the container to have a tty output so that rcons can display something.

----

### 4. Docker Image Management

Maintain a local docker image Register in xCAT cluster.

 4.1 Maintain a local docker image register on xCAT management node. (xCAT will help to install and configure this local register)
 4.2 Trigger docker host to download docker image from local image register.
        Remotely run 'docker pull' on docker host.
 4.3 For a updated container, support the 'commit' and 'push' command to convert the changed container to an image and push the image to local register.

 Comment: In the phase one, it requires customer to create docker image manually by docker 'commit', 'pull', 'build', or 'import'. In the phase 2, xCAT might implement some commands to help customer to create image.

----

### 5. Network Setting Cross Docker Host

 5.1 Enable the cross hosts/cluster network communication for containers. (use the bridge mode)
        Assign predefined IP for each container.
        The container can ping each other in the whole cluster.

 5.2 Enable the docker container link between containers. (Need requirement scenarios)

 5.3 Support openvswitch as network switch

----

### 6. Storage Management

Enable volumes for containers. (Need requirement scenarios)

----------
----------
## Additional Discussion

### Enable Docker image in xCAT diskless system

It sounds useful to support docker image in xCAT diskless since we can leverage the available docker image which has application configured and ready for using. I did some tries to enable docker image in diskless image. But the result was not good as we expected.

 1. I captured the whole file system from a running container.
 2. I tried to add lacked packages like 'kernel' to this captured file system.
  * Use the captured file system as base, run xCAT 'genimage' command to add the lacked packages.
  * Run 'genimage' command to generate a base file system, then use the captured file system to override the one which generated by 'genimage'.

With both ways, I found several issues to enable the produced file system.
 1. Some packages which installed in docker image conflict with the ones from xCAT repo. To solve this problem, we have to require the packages which used to generate docker image must be same with the ones in the xCAT osimage repository.
 2. Some package like fakesystemd is for docker specific. They must be removed.
 3. Some container configurations for network are different with a general OS. The result was the merged osimage cannot start network service like nfs server, sshd.


## Other Design Considerations

  * **Required reviewers**: 
  * **Required approvers**: Guang Cheng 
  * **Database schema changes**: N/A 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: N/A 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 