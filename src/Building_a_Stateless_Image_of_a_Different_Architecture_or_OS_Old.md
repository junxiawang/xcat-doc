The genimage command that builds a stateless image needs to be run on a node of the same architecture and OS major release level as the nodes that will ultimately be booted with this image. Usually the management node is the same architecture and OS as the compute nodes, so you can run genimage on the management node. This is the easiest case because all of the information that genimage needs is right there. But if you need to build an image for an architecture or OS level different than the management node, follow the steps below. For example, if your management node was RHEL6.3 and you wanted to build images for RHEL5.7, you would need to follow this process. You would have to genimage on a node installed with RHEL5.7. 

This example is for building the same OS but a different architecture. In the example commands below, the management node name is xcatmn. It is also assumed that you already defined your osimage object on the management node using RHEL 6.3 and the compute profile and you copied compute.rhels6.x86_64.pkglist and compute.exlist from /opt/xcat/share/xcat/netboot/rh/ to /install/custom/netboot/rh/ in order to customize them. 

  
Login to a node or the correct architecture and make the management node's /install available to it: 
    
    ssh &lt;node&gt;
    mkdir /install
    mount xcatmn:/install /install     # the mount needs to be rw
    

Create rhels6.repo: 
    
    cd /etc/yum.repos.d
    mkdir save
    mv *.repo save
    vi rhels6.repo
    

Put the following lines in /etc/yum.repos.d/rhels6.repo: 
    
    [rhels6]
    name=rhels6 $releasever - $basearch
    baseurl=file:///install/rhels6.3/x86_64
    enabled=1
    gpgcheck=0
    

Test that yum is set up correctly with: yum search gcc 

Copy the executables and files needed from the Management Node: 
    
    mkdir -p /opt/xcat/share/xcat/
    cd /opt/xcat/share/xcat/
    scp -r xcatmn:/opt/xcat/share/xcat/netboot .  
    
