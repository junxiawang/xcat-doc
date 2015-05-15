<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT imaging with Partimage](#xcat-imaging-with-partimage)
  - [Introduction](#introduction)
  - [Image Capture process](#image-capture-process)
  - [Image Restore Process](#image-restore-process)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)


# xCAT imaging with Partimage

NOTE: This is not quite finished yet and I don't know when I'll get time to fix it in xCAT. So if you want to try it now, email vallard at gmail dot com. 

This is a port from xCAT 1.3 imaging to xCAT 2.1 and above. The nice thing about this method is that it requires little setup on the users part and can be run at anytime in a working xCAT environment. 

## Introduction

It is occasionally required to copy a hard drive for installation purposes, often because the OS does not support automated unattended script-based installation or because the applications do not support automated unattended script-based installs.  
If at all possible a scripted installation is preferred (i.e. RH Kickstart and SuSE Autoyast). Cloned and imaged installations usually contain no documentation on the what, why, or how the OS was prepared. Scripted installations can also suffer from this, however the scripts _are_ self documenting. If a scripted installation does not meet your requirements consider using SystemImager first before using Imaging.  
xCAT uses Partimage ([partimage.org](http://partimage.org/)) for Imaging.  
xCAT has two imaging modes: 

  1. imagecapture. The node saves an image to a NFS server. 
  2. imagerestore. The node restores an image from an NFS server. 

## Image Capture process

1\. Set up xCAT and be sure it works for normal installs. This is documented throughout this wiki and in the documents. Also, please verify this on a non-critical machine. This support is new and while it has been tested you should also ensure your critical environment is not damaged. We are not responsible for your data losses. So please use at your own risk! 

2\. Make sure you have enough space on your hard drive that you wish to copy to. By default xCAT imaging will copy contents to the xCAT management server in /install/partimage We'll show you how to change this if needed later. 

3\. Determine the disks you want to capture. In most cases this will just be /dev/sda. If you need something more or less, than modify the templates in /opt/xcat/share/xcat/install/partimage 

For example, you may wish to capture /dev/sda &amp; /dev/sdb. In which case, you would change the line: 
    
    export DISKS="sda"

To be: 
    
    export DISKS="sda sdb"

You may also decide you want to save the image on some other NFS server. In which case, you can change the NFS_SERVER &amp; NFS_DIR variables. Save this template. We will assume for this example that you use the compute template (compute.tmpl). You're now ready to capture the image 

4\. Run the command: 
    
    rinstall &lt;node&gt; -o imagecapture -a x86 -p compute

Note that imaging only supports x86. This works for x86_64 and x86 machines. 

5\. Reboot the node. Once the imaging process is complete, it will drop to a shell and you will be in the xCAT service ramdisk/kernel. If you are satisfied with the results you can reboot the node, or you can rerun the /etc/init.d/S80partimage.sh script. This is the script that does all the imaging. Run the following commands to get your old node back: 
    
    nodeset &lt;node&gt; boot
    rpower &lt;node&gt; boot

  


## Image Restore Process

1\. Capture an image using the above steps. You need to be restore from an image that you captured with xCATs partimaging support. 

2\. For the nodes you wish to image run: 
    
    rinstall &lt;node&gt; -o imagerestore -a x86 -p compute

Even if the image you copied is an x86_64 bit OS, the x86 will still work to restore that image. 

3\. Reboot the node. Once the image has been restored xCAT will drop into a shell. Use rpower to reboot the node and run: 
    
    nodeset &lt;node&gt; boot
    rpower &lt;node&gt; boot

  
Happy Imaging! For support, please contact the xCAT mailing list. 
