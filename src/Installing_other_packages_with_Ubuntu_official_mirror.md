<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [A1: Compute nodes can access the internet](#a1-compute-nodes-can-access-the-internet)
- [A2: Compute nodes can not access the internet](#a2-compute-nodes-can-not-access-the-internet)
  - [optional 1:  Use apt proxy](#optional-1--use-apt-proxy)
  - [Optional 2: Use local mirror](#optional-2-use-local-mirror)
      - [See more details steps in doc [Rsyncmirror](https://help.ubuntu.com/community/Rsyncmirror)](#see-more-details-steps-in-doc-rsyncmirrorhttpshelpubuntucomcommunityrsyncmirror)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

The Ubuntu iso is being used to install the compute nodes only include packages to run a base operating system, it is likely that users will need to install additional Ubuntu packages from the internet Ubuntu repo or local repo, this section describes how to install additional Ubuntu packages.

**Note: the procedure of updating Ubuntu kernel is a little bit different with the update of general Ubuntu packages, if you need to update Ubuntu kernel on the compute nodes, you need to either add the specific version of kernel packages like "linux-image-extra-3.13.0-39-generic linux-headers-3.13.0-39-generic linux-headers-3.13.0-39 linux-generic linux-image-generic" in the otherpkglist file, or write a user customized postscript to run "apt-get -y --force-yes dist-upgrade" on the compute nodes.**


#### A1: Compute nodes can access the internet

step1: Specify the repository

You can generate internet repository source list, refer to [Ubuntu Sources List Generator](http://repogen.simplylinux.ch/).Use the internet repository directly when define the otherpkgdir attribute, take an example on Ubuntu14.04: 

~~~~    
    chdef -t osimage <osimage name> otherpkgdir="http://ports.ubuntu.com/ubuntu-ports/ trusty main,http://ports.ubuntu.com/ubuntu-ports/ trusty-updates main,http://ports.ubuntu.com/ubuntu-ports/ trusty universe,http://ports.ubuntu.com/ubuntu-ports/ trusty-updates universe"
~~~~    

step2: Specify otherpkglist file, for example

create an otherpkglist file,for example, /install/custom/install/ubuntu/compute.otherpkgs.pkglist. Add the packages' name into thist file. And modify the otherpkglist attribute for osimage object. 

~~~~    
    chdef -t osimage <osimage name> otherpkglist=/install/custom/install/ubuntu/compute.otherpkgs.pkglist
~~~~    

step3: Use optional (a) updatenode or optional (b) os provision to install/update the packages on the compute nodes;

optional (a): If OS is already provisioned, run "updatenode <nodename> -S" or "updatenode <nodename> -P otherpkgs" 

    Run updatenode -S to install/update the packages on the compute nodes

~~~~
    updatenode <nodename> -S
~~~~

    Run updatenode otherpkgs to install/update the packages on the compute nodes

~~~~
    updatenode <nodename> -P otherpkgs 
~~~~

optional (b): OS is not provisioned

run rsetboot to instruct them to boot from the network for the next boot:

~~~~
    rsetboot <nodename> net
~~~~

The nodeset command tells xCAT what you want to do next with this node, and powering on the node starts the installation process:

~~~~
    nodeset <nodename> osimage=<osimage name>
    rpower <nodename> boot
~~~~ 

### A2: Compute nodes can not access the internet

If compute nodes cannot access the internet, there are two ways to install additional packages:use apt proxy or use local mirror;

#### optional 1:  Use apt proxy 

Step 1: Install Squid on the server which can access the internet (Here uses management node as the proxy server) 

~~~~    
    apt-get install squid
~~~~    

Step 2: Edit the Squid configuration file /etc/squid3/squid.conf, find the line "#http_access deny to_localhost". Add the following 2 lines behind this line. 

~~~~    
    acl cn_apt src <compute node sub network>/<net mask length>
    http_access allow cn_apt
~~~~    

For more refer [Squid configuring](http://wiki.squid-cache.org/SquidFaq/ConfiguringSquid). 

Step 3: Restart the proxy service 
 
~~~~   
    service squid3 restart
~~~~    

Step 4: Create a postscript under /install/postscripts/ directory, called aptproxy, add following lines 

~~~~    
    #!/bin/sh
    PROXYSERVER=$1
    if [ -z $PROXYSERVER ];then
        PROXYSERVER=$MASTER
    fi
    
    PROXYPORT=$2
    if [ -z $PROXYPORT ];then
        PROXYPORT=3128
    fi
    
    if [ -e "/etc/apt/apt.conf" ];then
        sed '/^Acquire::http::Proxy/d' /etc/apt/apt.conf &gt; /etc/apt/apt.conf.new
        mv -f /etc/apt/apt.conf.new /etc/apt/apt.conf
    fi
    echo "Acquire::http::Proxy \"http://${PROXYSERVER}:$PROXYPORT\";" &gt;&gt; /etc/apt/apt.conf
~~~~    

Step 5: add this postscript to compute nodes, the [proxy server ip] and [proxy server port] are optional parameters for this postscript. If they are not specified, xCAT will use the management node ip and 3128 by default. 
 
~~~~   
    chdef <node range> -p postscripts="aptproxy [proxy server ip] [proxy server port]"
~~~~    

Step 6: Edit the otherpkglist file, for example, /install/custom/install/ubuntu/compute.otherpkgs.pkglist. Add the packages' name into thist file. And modify the otherpkglist attribute for osimage object. 

~~~~    
    chdef -t osimage <osimage name> otherpkglist=/install/custom/install/ubuntu/compute.otherpkgs.pkglist
~~~~  

Step 7: Edit the otherpkgdir attribute for os image object, can use the internet repositories directly. For example on Ubuntu14.04:

~~~~    
    chdef -t osimage <osimage name> otherpkgdir="http://ports.ubuntu.com/ubuntu-ports/ trusty main,http://ports.ubuntu.com/ubuntu-ports/ trusty-updates main,http://ports.ubuntu.com/ubuntu-ports/ trusty universe,http://ports.ubuntu.com/ubuntu-ports/ trusty-updates universe"
~~~~  

Step 8: 

If OS is not provisioned,run nodeset, rsetboot, rpower commands to provision the compute nodes.  

~~~~
    rsetboot <nodename> net
    nodeset <nodename> osimage=<osimage name>
    rpower <nodename> boot
~~~~

If OS is already provisioned,run "updatenode <nodename> -S" or "updatenode <nodename> -P otherpkgs" 

    Run updatenode -S to install/update the packages on the compute nodes

~~~~
    updatenode <nodename> -S
~~~~

    Run updatenode otherpkgs to install/update the packages on the compute nodes

~~~~
    updatenode <nodename> -P otherpkgs 
~~~~

#### Optional 2: Use local mirror 

Find a server witch can connect the internet, and can be accessed by the compute nodes.
######See more details steps in doc [Rsyncmirror](https://help.ubuntu.com/community/Rsyncmirror)

step 1: Install apt-mirror 

~~~~    
    apt-get install apt-mirror
~~~~    

step 2: Configure apt-mirror, refer to [Rsyncmirror](https://help.ubuntu.com/community/Rsyncmirror) 

~~~~    
    vim /etc/apt/mirror.list
~~~~    

step 3: Run apt-mirror to download the repositories(The needed space can be found in [Ubuntu Mirrors ](https://wiki.ubuntu.com/Mirrors?action=show&redirect=Archive)) 

~~~~    
    apt-mirror /etc/apt/mirror.list
~~~~    

step 4: Install apache 
 
~~~~   
    apt-get install apache2
~~~~    

step 5: Setup links to link our local repository folder to our shared apache directory 
 
~~~~   
    ln -s /var/spool/apt-mirror/mirror/archive.ubuntu.com /var/www/archive-ubuntu
~~~~    

When setting the otherpkgdir attribute for the osimages, can use http://&lt;local mirror server ip&gt;/archive-ubuntu/ precise main 

For more information about setting local repository mirror can refer [How to Setup Local Repository Mirror](http://ubuntuforums.org/showthread.php?t=599479)
