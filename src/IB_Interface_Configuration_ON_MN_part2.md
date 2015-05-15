<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Update the xCAT postscripts table](#update-the-xcat-postscripts-table)
- [Update permission for modeprobe.conf and sysctl.conf](#update-permission-for-modeprobeconf-and-sysctlconf)
- [Add perl packages](#add-perl-packages)
  - [Add perl packages(Only for xCAT version below 2.6.6)](#add-perl-packagesonly-for-xcat-version-below-266)
  - [Add perl packages(Only for xCAT 2.6.6 later version )](#add-perl-packagesonly-for-xcat-266-later-version-)
- [Start to install the nodes or update the nodes for IB configuration](#start-to-install-the-nodes-or-update-the-nodes-for-ib-configuration)
- [Check the result of IB configuration](#check-the-result-of-ib-configuration)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


### Update the xCAT postscripts table

Add your modified ib setup script to the postscripts list for your node install. 
 
~~~~   
    chdef xcat01 -p postscripts=configiba
~~~~    

  


### Update permission for modeprobe.conf and sysctl.conf

In statelite images, /etc/infiniband/, /etc/modprobe.conf and /etc/sysctl.conf are not writable by default, which will be modified by configiba script. You must make sure /etc/infiniband/, /etc/modprobe.conf and /etc/sysctl.conf are writable in the statelite image. For more detailed information on statelite configuration, check statelite documentation: 

[XCAT_Linux_Statelite] 

### Add perl packages

#### Add perl packages(Only for xCAT version below 2.6.6)

Since perl is not by default installed on Linux nodes. Postscripts configiba which is written in perl would failed. The admin needs to add perl in diskless image or add the perl install rpms for diskfull nodes. 

Also, for diskless boot on Linux, remove the following line in /opt/xcat/share/xcat/netboot/&lt;os&gt;/compute.exlist to add perl packages: 

~~~~      
    ./usr/lib/perl5*
~~~~      

#### Add perl packages(Only for xCAT 2.6.6 later version )

The configiba has been written by SHELL. But for Mellanox OFED on sles, there are some packages which are dependent on the perl modules. So for diskless/statelite boot on sles, we should remove the following line in /opt/xcat/share/xcat/netboot/sles/compute.exlist to add perl packages: 

~~~~      
    ./usr/lib/perl5*
~~~~      

### Start to install the nodes or update the nodes for IB configuration

Now all the preparation work for IB configuration has been done, you can use the updatenode command to update the nodes if the nodes have been installed 

~~~~      
    updatenode xcat01 configiba
~~~~      

  
or continue with the node installation process, 

**For diskless Linux nodes:**

You have to install the IB device driver packages into diskless image before node installation, for more details, check section&nbsp;: 

[XCAT_pLinux_Clusters/#stateless-node-deployment](XCAT_pLinux_Clusters/#stateless-node-deployment)



After doing this run: 
 
~~~~     
    nodeset xcat01 osimage=<osver>-<arch>-netboot-compute
    rnetboot xcat01
~~~~      

  
**For diskful Linux nodes:**

~~~~  
    
    nodeset xcat01 osimage=<osver>-<arch>-install-compute
    rnetboot xcat01
~~~~      

  
To install diskful AIX nodes: 

~~~~  
    
    nimnodeset -i <nimimage> xcat01
    rnetboot xcat01
~~~~      

  
To install diskless boot AIX nodes: 

~~~~  
    
    mkdsklsnode -i <nimimage> xcat01
    rnetboot xcat01
~~~~      

### Check the result of IB configuration

It's assumed that there are IB adapters in MN. Use a ping test from management node to the IB interfaces on compute nodes to see if the IB adapter works. 
  
~~~~    
    ping xcat01-ib0
~~~~      

  
**Note:**

On SLES there is an issue with openibd that a **compute node reboot or openbid restart** resets two settings in /etc/sysctl.conf, which have been modified by configiba script. So for every reboot or openibd restart, the admin will have to update the settings manually. The following three commands help to do that efficiently from the management node: 
 
~~~~     
    xdsh xcat01 sed -i 's/net.ipv4.conf.ib0.arp_filter=0/net.ipv4.conf.ib0.arp_filter=1/g'
    /etc/sysctl.conf   
    
    xdsh xcat01 sed -i 's/net.ipv4.conf.ib0.arp_ignore=0/net.ipv4.conf.ib0.arp_ignore=1/g'
    /etc/sysctl.conf   
    
    xdsh xcat01 sysctl -p
~~~~      
