<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [How To Capture Image from the Running Diskful Linux Node](#how-to-capture-image-from-the-running-diskful-linux-node)
  - [Prepare one diskful Linux node](#prepare-one-diskful-linux-node)
  - [Prepare the configuration files](#prepare-the-configuration-files)
    - [The .pkglist, .exlist and .postinstall files](#the-pkglist-exlist-and-postinstall-files)
    - [The exlist file](#the-exlist-file)
- [Define the osimage object (Optional)](#define-the-osimage-object-optional)
- [Run imgcapture](#run-imgcapture)
- [The usage of imgcapture and examples](#the-usage-of-imgcapture-and-examples)
- [Generate stateless/statelite images](#generate-statelessstatelite-images)
  - [Generate stateless images](#generate-stateless-images)
  - [Generate statelite images](#generate-statelite-images)
- [Set the node status ready for network boot](#set-the-node-status-ready-for-network-boot)
- [Notes](#notes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## How To Capture Image from the Running Diskful Linux Node

xCAT provides the **imgcapture** command to capture an OS image from a running diskful Linux node, and prepares the rootimg directory, kernel and initial ramdisks for **liteimg**/**packimage** to generate the statelite/stateless rootimg.

This command is very helpful, especially when there's already one diskful Linux node in which all the necessary applications are installed and configured, or the user needs to migrate the diskful environment to the diskless environment (including **statelite**/**stateless**).

See man page [imgcapture](http://xcat.sourceforge.net/man1/imgcapture.1.html).


The following are the steps to capture image.

### Prepare one diskful Linux node

The diskful Linux node to be captured must be managed by the xCAT MN, and the remote shell between the xCAT MN and this node must be configured.

### Prepare the configuration files



#### The .pkglist, .exlist and .postinstall files

The following files will be used by the **imgcapture** command. And, they work the same as when genimage command is running. Refer to [Deploying Stateless Nodes](XCAT_iDataPlex_Cluster_Quick_Start/#deploying-stateless-nodes) to see how to configure these files.

~~~~
  <profile>.<osver>.<arch>.pkglist
  <profile>.<osver>.<arch>.exlist
  <profile>.<osver>.<arch>.postinstall
~~~~

#### The exlist file

The file is named:

~~~~
   <profile>.<osver>.<arch>.imgcapture.exlist file
~~~~

During **imgcapture** is running, the user might need to exlude some files/directories from the image to be captured.

xCAT provides the &lt;profile&gt;.&lt;osver&gt;&lt;arch&gt;.imgcapture.exlist configuration file, the user can add any files/directories into this file.

For example, there's one directory (/root/test/), which should be excluded from the image to be captured, the user can add the following line into the &lt;profile&gt;.&lt;osver&gt;.&lt;arch&gt;.imgcapture.exlist file:

~~~~
     ./root/test*
~~~~

## Define the osimage object (Optional)

If the image to be captured needs to be associated with one specific osimage object, you can use the existing osimage objects, or you can use the

~~~~
    chdef -t osimage -o <osimgname> .... command to set the attributes for <osimgname>.
~~~~

## Run imgcapture

## The usage of imgcapture and examples

  See man page [imgcapture](http://xcat.sourceforge.net/man1/imgcapture.1.html).



## Generate stateless/statelite images

After the image (rootimg), kernel (kernel) and initial ramdisks (initrd-stateless.gz and initrd-statelite.gz)has been generated and put into $installroot/netboot/&lt;osver&gt;/&lt;arch&gt;/&lt;profile&gt;/, you can customize the image by running **packimage**/**liteimg** with the options you want.

### Generate stateless images

Run packimage:

~~~~
     packimage <osimagename>
~~~~


For more info about packimage, please refer to the manpage of packimage.

### Generate statelite images

Run liteimg:

~~~~
     liteimg <osimagename>
~~~~


For more info about liteimg, please refer to the manpage of liteimg.

## Set the node status ready for network boot

Run nodeset to set the node status ready for network boot.

~~~~
     nodeset node1 netboot
~~~~


Or:

~~~~
     nodeset node1 statelite
~~~~


Or:

~~~~
     nodeset node1 osimage=<osimagename>
~~~~


## Notes

If the node is set to stateless or RAMdisk-based statelite status, before booting the node up, please make sure the node has enough memory capabilities. In order to boot up the LPAR with the redhat6/PPC64 Linux image, the node should have about 5120MB memory.


