**Note: The procedure below only works with xCAT 2.8.1 and later.  
For earlier versions, see [Building_a_Stateless_Image_of_a_Different_Architecture_or_OS_Old]**

The genimage command that builds a stateless image needs to be run on a node of the same architecture and OS major release level as the nodes that will ultimately be booted with this image. Usually the management node is running the same architecture and OS as the compute nodes, so you can run genimage directly on the management node. 

However, there are times when you may want to provision a different version of the OS or even a different OS.  In this case, you would need to run genimage on a node installed with the target OS you want to provision.  

The following example is for creating a stateless image of the same OS but different architecture.  The management node is "xcatmn".  It is assumed that the osimage objects are already defined on the management node for the compute profile.  Also any pkglist files have already been created and are configured correctly in the osimage definition.  

On xCAT management node, select the osimage you want to create. Although it is optional, we recommend you make a copy of the osimage, changing its name to a simpler name. For example: 

~~~~    
    lsdef -t osimage -z rhels6.3-x86_64-netboot-compute | sed 's/^[^ ]\+:/mycomputeimage:/' | mkdef -z
~~~~    

Then dry-run the image to get the syntax for generating the image from another machine. 

~~~~    
     genimage --dryrun mycomputeimage
     
~~~~    

The result will look like this: 
       
~~~~
Generating image:
cd /opt/xcat/share/xcat/netboot/rh
./genimage -a x86_64 -o rhels6.3 -p compute --permission 755 --srcdir /install/rhels6.3/x86_64 --pkglist /opt/xcat/share/xcat/netboot/rh/compute.rhels6.x86_64.pkglist --otherpkgdir /install/post/otherpkgs/rhels6.3/x86_64 --postinstall /opt/xcat/share/xcat/netboot/rh/compute.rhels6.x86_64.postinstall --rootimgdir /install/netboot/rhels6.3/x86_64/compute mycomputeimage
~~~~    

  
Login to a target node matching the correct architecture for the image we want to create and mount the /install directory from the xCAT management node: 

~~~~    
    ssh <node>
    mkdir /install
    mount xcatmn:/install /install     # the mount needs to have read-write permission
~~~~    

Copy the executable and files in the netboot directory from the xCAT Management node:

~~~~    
     mkdir -p /opt/xcat/share/xcat/
     cd /opt/xcat/share/xcat/
     scp -r xcatmn:/opt/xcat/share/xcat/netboot . 
~~~~ 
     
If there is any osimage configuration file that is not in directory /opt/xcat/share/xcat or /install, copy the file from the management node to the same directory on this node. You could use lsdef -t osimage to check if there is any osimage configuration file that is not in directory /opt/xcat/share/xcat or /install.

Generate the image using the command printed out from the --dryrun.  This is required since executing from a non xCAT management node will not be able to access the xCAT database to obtain the osimage information.  
~~~~
cd /opt/xcat/share/xcat/netboot/rh
./genimage -a x86_64 -o rhels6.3 -p compute --permission 755 --srcdir /install/rhels6.3/x86_64 --pkglist /opt/xcat/share/xcat/netboot/rh/compute.rhels6.x86_64.pkglist --otherpkgdir /install/post/otherpkgs/rhels6.3/x86_64 --postinstall /opt/xcat/share/xcat/netboot/rh/compute.rhels6.x86_64.postinstall --rootimgdir /install/netboot/rhels6.3/x86_64/compute mycomputeimage

~~~~

Now return to the management node and execute "packimage <osimage>" and continue provisioning your nodes.
