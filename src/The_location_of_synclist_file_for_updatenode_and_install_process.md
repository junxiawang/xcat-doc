For Linux and AIX nodes, xCAT uses different approach to figure out the location of the common synclist file, the method for each platform will be introduced respectively. 

**The sync file function is not supported for statelite installations.** For statelite installations to sync files you should use the read-only option for files/directories listed in litefile table with source location specified in the litetree table. For more information on using setting up Statelite installs, see XCAT_Linux_Statelite . 

  
**[Linux]**

In the installation process or updatenode process, xCAT needs to figure out the location of the synclist file automatically, so the synclist should be put into the specified place with the proper name. 

**If the provisioning method for the node is an osimage name**, then the path to the synclist will be read from the osimage definition synclists attribute. You can display this information by running the following command, supplying your osimage name. 
    
    lsdef -t osimage -l rhels6-x86_64-netboot-compute
    Object name: rhels6-x86_64-netboot-compute
       exlist=/opt/xcat/share/xcat/netboot/rhels6/compute.exlist
       imagetype=linux
       osarch=x86_64
       osname=Linux
       osvers=rhels6
       otherpkgdir=/install/post/otherpkgs/rhels6/x86_64
       pkgdir=/install/rhels6/x86_64
       pkglist=/opt/xcat/share/xcat/netboot/rhels6/compute.pkglist
       profile=compute
       provmethod=netboot
       rootimgdir=/install/netboot/rhels6/x86_64/compute
       **synclists=/install/custom/netboot/compute.synclist**
    

You can set the synclist path using the following command: 
    
    chdef -t osimage -o  rhels6-x86_64-netboot-compute synclists="/install/custom/netboot
    /compute.synclist"
    

  
**If the provisioning method for the node is install,or netboot** then the path to the synclist should be of the following format: 

  

    
    /install/custom/&lt;inst_type&gt;/&lt;distro&gt;/&lt;profile&gt;.&lt;os&gt;.&lt;arch&gt;.synclist
    &lt;inst_type&gt;: "install", "netboot"
    &lt;distro&gt;: "rh", "centos", "fedora", "sles"
    &lt;profile&gt;,&lt;os&gt; and &lt;arch&gt; are what you set for the node
    

  
For example: 

The location of synclist file for the diskfull installation of sles11 with 'compute' as the profile 
    
    /install/custom/install/sles/compute.sles11.synclist
    

The location of synclist file for the diskless netboot of sles11 with 'service' as the profile 
    
    /install/custom/netboot/sles/service.sles11.synclist
    

  
**[AIX]**

For the AIX platform, the common synclist file is created base on the definition of nim image. The nim images are defined in the 'osimage' table, and the attribute of osimage.synclists is used to identify the location of the common synclist for the nodes which use this nim image to install/netboot the system. 

  
For example: 

If you want to sync files to the node 'node1' which uses the '61cosi' nim image as its profile (The profile attribute is set the osimage for an AIX node), you need to do following things to set the synclist. 

Create a synclist file in any directory. For example: /tmp/61cosi.AIX.synclist Set the full path of the synclist file in the attribute osimage.synclists for the nim image '61cosi' in the osimage table. 
    
    chdef -t osimage -o 61cosi synclists=/tmp/61cosi.AIX.synclist
    
