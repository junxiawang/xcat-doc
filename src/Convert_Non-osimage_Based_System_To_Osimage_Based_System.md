<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview and Background](#overview-and-background)
- [What is osimage?](#what-is-osimage)
- [Why do I want to convert to osimage based configuration?](#why-do-i-want-to-convert-to-osimage-based-configuration)
- [Procedure for using osimage](#procedure-for-using-osimage)
- [Convert to osimage based configuration](#convert-to-osimage-based-configuration)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**Note: This documentation is written for xCAT 2.8.1 and newer releases. For earlier xCAT versions, see [Convert_Non-osimage_Based_System_To_Osimage_Based_System_Old]**

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)



## Overview and Background

This documentation illustrates how to convert a Linux non-osimage based system to an osimage based system. This doc only works for xCAT on Linux, xCAT on AIX system uses a different mechanism and is not covered by this doc.

In the old xCAT releases, the Linux os provisioning configuration was determined by the node attributes "os", "arch", "profile" and "provmethod"; xCAT code will internally use these four attributes to setup the os provisioning configuration, for example, if the node attributes are set to:

     os=rhels6.3
     arch=x86_64
     profile=compute
     provmethod=install


The os provisioning configuration for this node will look like:

     kickstart template(template): /opt/xcat/share/xcat/install/rh/compute.rhels6.x86_64.tmpl or /install/custom/install/rh/compute.rhels6.x86_64.tmpl
     os repository(pkgdir): /install/rhels6.3/x86_64
     package list file(pkglist): /opt/xcat/share/xcat/install/rh/compute.rhels6.x86_64.pkglist or /install/custom/install/rh/compute.rhels6.x86_64.pkglist
     otherpkgs directory(otherpkgdir) /install/post/otherpkgs/rhels6.3/x86_64/
     otherpkgs list(otherpkgslist): /install/custom/install/rh/compute.rhels6.x86_64.otherpkgs.pkglist
     synclist file(synclists): /install/custom/install/rh/compute.rhels6.x86_64.pkglist


We can see that the path of configuration files are determined implicitly based on the node attributes "os", "arch", "profile" and "provmethod"; furthermore, the search for some of the configuration files like template and pkglist uses the longest prefix matching algorithm, which will sometimes confuse administrators and users. Another drawback is that you could not customize as much for the os provisioning configuration.

In some recent xCAT release(actually not that recent, it was first announced with xCAT 2.3 in year 2009, and a lot of enhancements were done later.), a new "osimage" concept was introduced to address all of the problems with the old way of using "os", "arch", "profile" and "provmethod". Since then, the osimage feature has been tested thoroughly and has been used widely by different teams in many different types of xCAT clusters.

## What is osimage?

The osimage is an xCAT object definition type that can be managed through mkdef,lsdef,chdef,and rmdef commands. The osimage object contains the configuration information for the os provisioning, including the information in the example mentioned above. After the osimage is created and customized correctly, it can be associated with any node that uses the os provisioning configuration defined in the osimage. When you run the copycds command, xCAT will create some default osimage definitions for that OS and architecture. The osimage information is stored in xCAT tables osimage and linuximage. For more details about these tables, see the [osimage](http://xcat.sourceforge.net/man5/osimage.5.html) and [linuximage](http://xcat.sourceforge.net/man5/linuximage.5.html) manpages.

## Why do I want to convert to osimage based configuration?

**xCAT team strongly recommends using the osimage configuration instead of the old methodology that relies on the "os", "arch", "profile" and "provmethod" attribute settings**. The osimage methodology has several advantages in comparison to the previous one:

1\. It is cleaner: All the configuration information is set explicitly in the osimage object in the xCAT database. You do not need to calculate or remember the location of the configuration files. You will not run into problems whenthe os provisioning actually uses a different configuration file than you expected because of the implicit way of calculating the path and configuration files.

2\. It is easier: You can use *def commands to manage the osimage easily. The command syntax is exactly the same as for node management, except that you need to add the flag "-t osimage" to let the *def commands know that you are managing osimage objects.

3\. It is more flexible: The osimage provides many configurable options that can be used to customize the os provisioning configuration. If you do not want to customize too much, the default osimage objects created by copycds should be able to satisfy your requirements.

## Procedure for using osimage

The use of osimage does not change the general Linux os provisioning procedure, the only difference is that you need to specify the osimage when you run the genimage and nodeset commands. The procedure of using osimage has been covered by different xCAT docs like
[XCAT_iDataPlex_Cluster_Quick_Start](XCAT_iDataPlex_Cluster_Quick_Start) and [XCAT_pLinux_Clusters](XCAT_pLinux_Clusters), here is only a summary of the procedure of using osimage:

1\. Select or Create an osimage Definition

The copycds command also automatically creates several osimage defintions in the database that can be used for node deployment. To see them:

~~~~
    lsdef -t osimage          # see the list of osimages
    lsdef -t osimage <osimage-name>          # see the attributes of a particular osimage
~~~~

From the list above, select the osimage for your distro, architecture, provisioning method (in this case install), and profile (compute, service, etc.). Although it is optional, we recommend you make a copy of the osimage, changing its name to a simpler name. For example:

~~~~
    lsdef -t osimage -z rhels6.2-x86_64-install-compute | sed 's/^[^ ]\+:/myosimage:/' | mkdef -z
~~~~

This displays the osimage "rhels6.2-x86_64-install-compute" in a format that can be used as input to mkdef, but on the way there it uses sed to modify the name of the object to "myosimage".


2\. Customize the osimage definitions

Initially, this osimage object points to templates, pkglists, etc. that are shipped by default with xCAT. And some attributes, for example otherpkglist and synclists, won't have any value at all because xCAT doesn't ship a default file for that. You can now change/fill in any [osimage attributes](http://xcat.sourceforge.net/man7/osimage.7.html) that you want. A general convention is that if you are modifying one of the default files that an osimage attribute points to, copy it into /install/custom and have your osimage point to it there. (If you modify the copy under /opt/xcat directly, it will be over-written the next time you upgrade xCAT.)

You can use chdef command to change the osimage definitions, there are a lot of configurable options for osimage definitions, you can use

~~~~
     lsdef -t osimage -h
~~~~

to list the attributes of osimage definitions. To change an attribute, run the command like:

~~~~
     chdef -t osimage myosimage pkglist=/install/custom/install/rh/myosimage.pkglist
~~~~

For diskless (provmethod=netboot) and statelite (provemethod=statelite) osimages, one important attribute to set is rootimgdir. You will want to make sure this value does not conflict with any other osimage definition,since it is the target location genimage will use to build your OS image chroot filesystem.

~~~~
      chdef -t osimage myosimage rootimgdir=/install/netboot/rhels6.3/x86_64/myosimage
~~~~

3\. Create diskless images

~~~~
     genimage <osimage_name>
     packimage <osimage_name>
     or
     liteimg <osimage_name>
~~~~

4\. Associate the osimage with nodes

nodeset command now accepts the osimage as a parameter, you can run nodeset command to associate the osimage with nodes.

~~~~
     nodeset <noderange> osimage=<osimage_name>
~~~~

The nodeset command will set the node attribute provmethod to be the osimage name, if the nodes' provmethod has already been set to be an osimage, or you need to run nodeset against nodes with different osimages in one invocation, you can run nodeset command with the keyword osimage(this is a feature available only in xCAT 2.8 and later releases):

~~~~
     nodeset <noderange> osimage
~~~~

## Convert to osimage based configuration

The core part of converting to osimage based configuration is to translate the current os provisioning configuration into the osimage definitions.

1\. Categorize the current os provisioning configurations

The existing os provisioning configuration is determined by the node attributes "os", "arch", "profile" and "provmethod". The following commands can be used to categorize the os provisioning configuration:

~~~~
    lsdef -t node -i os,arch,profile,provmethod -c | xdshbak -c

     or

     tabdump nodetype | awk -F',' '{print $2,$3,$4,$5,$1}' | sort
~~~~

Here is an example output of the _lsdef -t node -i os,arch,profile,provmethod -c | xdshbak -c_:

    [root@xcatmn ~]# lsdef -t node -i os,arch,profile,provmethod -c | xdshbak -c

    HOSTS:
    -------------------------------------------------------------------------
    node01,node02,node03,node04,node05,node06,node07,node08,node09,node10
    -------------------------------------------------------------------------------
    arch=x86_64
    os=rhels6.3
    profile=compute
    provmethod=install

    HOSTS:
    -------------------------------------------------------------------------
    node11,node12,node13,node14,node15,node16,node17,node18,node19,node20
    -------------------------------------------------------------------------------
    arch=x86_64
    os=rhels6.3
    profile=compute
    provmethod=netboot

    HOSTS:
    -------------------------------------------------------------------------
    node21,node22,node23,node24,node25,node26,node27,node28,node29,node30
    -------------------------------------------------------------------------------
    arch=x86_64
    os=rhels6.3
    profile=compute
    provmethod=statelite
    [root@xcatmn ~]#



According to the output, there are three os provisioning configuration categories, and each category has 10 nodes.

2\. (Optional) Create node groups for each os provisioning configuration category

To simplify the subsequent steps, it is a good idea to add these nodes in each os provisioning configuration category to different node groups.

     chdef node01-node10 -p groups=osimage1
     chdef node11-node20 -p groups=osimage2
     chdef node21-node30 -p groups=osimage3


3\. Select or create an osimage for each os provisioning configuration

Before creating new osimages manually, you might want to check if the default osimage definitions created by xCAT could match your requirements.

     [root@xcatmn ~]# lsdef -t osimage
     rhels6.3-x86_64-install-compute  (osimage)
     rhels6.3-x86_64-install-compute_ad  (osimage)
     rhels6.3-x86_64-install-hpc  (osimage)
     rhels6.3-x86_64-install-iscsi  (osimage)
     rhels6.3-x86_64-install-kvm  (osimage)
     rhels6.3-x86_64-install-service  (osimage)
     rhels6.3-x86_64-install-storage  (osimage)
     rhels6.3-x86_64-install-xen  (osimage)
     rhels6.3-x86_64-netboot-compute  (osimage)
     rhels6.3-x86_64-netboot-kvm  (osimage)
     rhels6.3-x86_64-netboot-nfsroot  (osimage)
     rhels6.3-x86_64-netboot-service  (osimage)
     rhels6.3-x86_64-netboot-xen  (osimage)
     rhels6.3-x86_64-statelite-compute  (osimage)
     rhels6.3-x86_64-statelite-kvm  (osimage)
     rhels6.3-x86_64-statelite-nfsroot  (osimage)
     rhels6.3-x86_64-statelite-service  (osimage)
     rhels6.3-x86_64-statelite-xen  (osimage)
     [root@xcatmn ~]# lsdef -t osimage rhels6.3-x86_64-install-compute
     Object name: rhels6.3-x86_64-install-compute
       imagetype=linux
       osarch=x86_64
       osdistroname=rhels6.3-x86_64
       osname=Linux
       osvers=rhels6.3
       otherpkgdir=/install/post/otherpkgs/rhels6.3/x86_64
       pkgdir=/install/rhels6.3/x86_64
       pkglist=/opt/xcat/share/xcat/install/rh/compute.rhels6.x86_64.pkglist
       profile=compute
       provmethod=install
       template=/opt/xcat/share/xcat/install/rh/compute.rhels6.x86_64.tmpl
     [root@xcatmn ~]#


If the default osimage definitions created by xCAT do not match your requirements, or the default osimage definitions are not created on your xCAT management node at all, you need to create one osimage definition for each os provisioning configuration, following the instructions above.

     mkdef -t osimage osimage1 -u
       osarch=x86_64 \
       osvers=rhels6.3 \
       profile=compute \
       provmethod=install


     mkdef -t osimage osimage2 -u
       osarch=x86_64 \
       osvers=rhels6.3 \
       profile=compute \
       provmethod=netboot


     mkdef -t osimage osimage3 -u
       osarch=x86_64 \
       osvers=rhels6.3 \
       profile=compute \
       provmethod=statelite


4\. Create diskless images

For stateless and statelite osimages, you will need to run genimage and packimage/liteimg to create the diskless image.

     genimage osimage1
     genimage osimage2
     genimage osimage3


     packimage osimage1
     packimage osimage2
     packimage osimage3


     or


     liteimg osimage1
     liteimg osimage2
     liteimg osimage3


5\. Associate the osimage with the nodes

You can run:

     nodeset node01-node10 osimage=osimage1
     nodeset node11-node20 osimage=osimage2
     nodeset node21-node30 osimage=osimage3

     or if you are running xCAT 2.8 or later release:

     chdef node01-node10 provmethod=osimage1
     chdef node11-node20 provmethod=osimage2
     chdef node21-node30 provmethod=osimage3
     nodeset node01-node30 osimage


**Note:** for diskful nodes, you might not want to run nodeset to avoid re-provisioning when the diskful nodes are rebooted. If this is the case, run chdef to set the node's provmethod attribute to the osimage name. Then, when you are ready to re-provision the node you can use the short 'nodeset &lt;noderange&gt; osimage' command to provision this image.



