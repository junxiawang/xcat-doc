<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Configure postinstall files for Power 775 (Optional)](#configure-postinstall-files-for-power-775-optional)
- [Generate/Pack your image for Power 775](#generatepack-your-image-for-power-775)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

##### Configure postinstall files for Power 775 (Optional)

IF not using Power 775 hardware, skip this section. **** The HFI kernel can be installed by xCAT automatically. Other packages, such as hfi_util and nettools, require the rpm options --nodeps or --force respectively, which xCAT cannot handle automatically. We need to modify the postinstall file to install those packages during the diskless image generation. 

Add the following lines to /install/test/netboot/rh/hfi.postinstall. (You can use any name you desire for the file, this is an example.

~~~~ 
    
    cp /hfi/dd/* /install/test/netboot/rh/ppc64/compute/rootimg/tmp/
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/dhclient-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/dhcp-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/kernel-headers-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/net-tools-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/hfi_ndai-*.rpm' --force
    chroot /install/test/netboot/rh/ppc64/compute/rootimg/ /bin/rpm -ivh '/tmp/hfi_util-*.rpm' --force

~~~~ 
    

Now update the image definition with the postinstall file location: 

~~~~     
    chdef -o osimage -t redhat6img postinstall=/install/test/netboot/rh/hfi.postinstall
~~~~     

##### Generate/Pack your image for Power 775

If not using Power 775 hardware, skip this section. In Power 775, there is a HFI enabled kernel required in the diskless image. The compute nodes could boot from this customized kernel and boot from HFI interfaces. 
 
~~~~    
    chdef -t osimage -o redhat6img kerneldir=/install/kernels
    cp /hfi/dd/kernel-2.6.32-71.el6.20110617.ppc64.rpm /install/kernels/
    genimage -i hf0 -n hf_if  -k 2.6.32-71.el6.20110617.ppc64 redhat6img
~~~~     

Sync /etc/hosts to the diskless image for Power 775 

This is used by the postscript hficonfig to configure all the HFI interfaces on the compute nodes. Setup a synclist file containing this line: 

~~~~ 
    
    /etc/hosts -> /etc/hosts
~~~~     

The file can be put anywhere, but let's assume you name it /tmp/synchosts. 

Make sure you have an OS image object in the xCAT database associated with your nodes and issue command: 

~~~~     
    xdcp -i <imagepath> -F /tmp/synchosts
~~~~     

&lt;imagepath&gt; stands for the OS image path. This is the directory we defined when we setup our image. To find the path run: 

~~~~     
    lsdef -t image -o redhat6img | grep rootimgdir
      /install/netboot/rhels6/ppc64/compute
~~~~     

Then run the following command: 
  
~~~~   
    xdcp -i /install/netboot/rhels6/ppc64/compute/rootimg -F /tmp/synchosts
~~~~     

Now pack the image: 

~~~~     
    packimage redhat6img
~~~~     
