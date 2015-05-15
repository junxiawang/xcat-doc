<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction to Software Kits on Ubuntu](#introduction-to-software-kits-on-ubuntu)
  - [Kit documentation](#kit-documentation)
  - [Contents of a Software Kit](#contents-of-a-software-kit)
  - [Kit frameworks](#kit-frameworks)
- [Adding a Kit to xCAT](#adding-a-kit-to-xcat)
  - [Completing a partial kit](#completing-a-partial-kit)
    - [Using partial Kits with newer software versions](#using-partial-kits-with-newer-software-versions)
  - [Adding a complete Kit to xCAT](#adding-a-complete-kit-to-xcat)
    - [Listing a kit](#listing-a-kit)
  - [Adding Kit Components to an OS Image Definition](#adding-kit-components-to-an-os-image-definition)
    - [Listing kit components](#listing-kit-components)
  - [Adding Multiple Versions of the Same Kit Component to an OS Image Definition](#adding-multiple-versions-of-the-same-kit-component-to-an-os-image-definition)
  - [Modifying Kit Deployment Parameters for an OS Image Definition](#modifying-kit-deployment-parameters-for-an-os-image-definition)
- [Complete the software update](#complete-the-software-update)
    - [updating diskless images](#updating-diskless-images)
    - [installing diskful (stateful) nodes](#installing-diskful-stateful-nodes)
    - [updating diskful (stateful) nodes](#updating-diskful-stateful-nodes)
- [Kit Cleanup](#kit-cleanup)
  - [Removing Kit Components from an OS Image Definition](#removing-kit-components-from-an-os-image-definition)
  - [Removing a Kit from the xCAT Management Node](#removing-a-kit-from-the-xcat-management-node)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Introduction to Software Kits on Ubuntu

xCAT already support software kits on RPM based Linux distros, such as Red Hat, or SuSE. See [Using_Software_Kits_in_OS_Images] for more details about software kit support on these distros. Now, in xCAT 2.9 and later, xCAT expand the software kits feature to Debian based Linux distros.

Note: This xCAT document is for Ubuntu 14.04.1 only.

### Kit documentation

Introduction to Kits: [Using_Software_Kits_in_OS_Images]

Building a Kit: [Building_Software_Kits]

Using an HPC software Kit: [IBM_HPC_Software_Kits]

### Contents of a Software Kit

Software Kits are deployed to xCAT nodes through the standard xCAT OS image deployment mechanisms. Various pieces of a kit component are inserted into the attributes of a Linux OS image definition. Some of the attributes that are modified are:

* **kitcomponents** - A list of the kitcomponents assigned to the OS image
* **serverrole** - The role of this OS image that must match one of the supported serverroles of a kitcomponent**
* **otherpkglist** - Includes kitcomponent meta package names
* **postinstall** - Includes kitcomponent scripts to run during genimage
* **postbootscripts** - Includes kitcomponent scripts
* **exlist** - Exclude lists for diskless images
* **otherpkgdir** - Kit repositories are linked as subdirectories to this directory

When a kitcomponent is added to an OS image definition, these attributes are automatically updated.

You can then use the genimage command to install the kitcomponents into the diskless OS image, the standard node deployment process for statefull nodes, or the xCAT updatenode command to update the OS on an active compute node. Since the kitcomponent meta package defines the product packages as dependencies, the OS package manager (apt) automatically installs all the required product packages during the xCAT otherpkgs install process.

### Kit frameworks

Over time it is possible that the details of the Kit package contents and support may change. For example, there may be a need for additional information to be added etc. We refer to a particular instance of the kit support as its "framework". A particular framework is identified by a numerical value.

In order for a kit command to process a kit properly it must be compatible with the level of code that was used to build the kit.

Both the kit commands and the actual kits contain the current framework they support as well as any backlevel versions also supported.

You can view the supported framework and compatible framework values for a command by using the "-v|--version" option.

~~~~
    addkit -v
    addkit - xCAT Version 2.8.3 (built Sat Aug 31 11:11:31 EDT 2013)
           kitframework = 2
           compatible_frameworks = 0,1,2
~~~~


When a Kit is being used to update an osimage, the Kit commands will check to see if the Kit framework value is compatible. To be compatible at least one of the Kit compatible_frameworks must match one of the compatible frameworks the command supports.

If the commands you are using are not compatible with the Kit you have, you will have to update xCAT to get the appropriate framework. Typically this will amount to updating xCAT to the most recent release.

## Adding a Kit to xCAT

Software product Kits are available through the regular software distribution channels.

Typically, a software kit will contain all of the product package files. However, in some instances, software kits may be delivered as partial or incomplete kits, and will not include all of the product deb packages.

Before you can use a partial kits you must convert it to a complete Kit by adding product software.

A partial kit will be indicated by including the string "NEED_PRODUCT_PKGS" in its name.


~~~~
    ex. testprod-1.0.0-x86_64.NEED_PRODUCT_PKGS.tar.bz2
~~~~





### Completing a partial kit

Follow these steps to complete the kit build process for a partial kit.

  1. Install the xCAT-buildkit deb package on your server. (This is automatically install on an xCAT version 2.8.3 management node.) This deb package requires the **debuild** and **apt-ftparchive** commands to be available. For Ubuntu, these commands are provided by the **devscripts** and **apt-utils** deb packages respectively.
  2. copy the partial kit to a working directory
  3. copy the product software packages to a convenient location or locations
  4. cd to the working directory
  5. Build the complete kit tarfile:

~~~~
    buildkit addpkgs <kit.NEED_PRODUCT_PKGS.tar.bz2> --pkgdir <product package directories>
~~~~


The complete kit tar file will be created in the working directory.

#### Using partial Kits with newer software versions

If your product packages are for a newer version or release than what you see specified in your partial kit tar file name, you may still be able to build a complete kit with your packages, assuming that the partial kit is compatible with those packages.

**Note**: Basically, the latest partial kit available online will work until there is a newer version available.

To build a complete kit with the new software you can provide the new version and/or release of the software on the buildkit command line.

~~~~
     buildkit addpkgs <kit.NEED_PRODUCT_PKGS.tar.bz2> --pkgdir <product package directories> \
       --kitversion <new version> --kitrelease <new release>
~~~~


For example, if your partial kit was created for a product version of 1.3.0.2 but you wish to complete a new kit for product version 1.3.0.4 then you would add "-k 1.3.0.4" to the buildkit command line.

### Adding a complete Kit to xCAT

A complete kit must be added to the xCAT management node and defined in the xCAT database before its kit components can be added to xCAT osimages or used to update diskful cluster nodes.

To add a kit run the following command:

~~~~
     addkit <complete kit tarfile>
~~~~


The [addkit](http://xcat.sourceforge.net/man1/addkit.1.html) command will expand the kit tarfile. The default location will be &lt;site.installdir&gt;/kits directory but an alternate location may be specified. (Where site.installdir is the value of the installdir attribute in the xCAT site definition.)

It will also add the kit to the xCAT database by creating xCAT object definitions for the kit as well as any kitrepo or kitcomponent definitions included in the kit.

Kits are added to the kit table in the xCAT database keyed by a combination of kit basename and version values. Therefore, you can add multiple kit definitions for the same product. For example, you could have one definition for release 1.2.0.0 and one for 1.3.0.0 of the product. This means that you will be able to add different versions of the kit components to different osimage definitions if desired.

#### Listing a kit

The xCAT kit object definition may be listed using the xCAT [lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html) command.

Example.

~~~~
    lsdef -t kit -l <kit name>
~~~~


The contents of the kit may be listed by using the [lskit](http://xcat.sourceforge.net/man1/lskit.1.html) command.

Example.

~~~~
    lskit <kit name>
~~~~


### Adding Kit Components to an OS Image Definition

In order to add a kitcomponent to an OS image definition, the kitcomponent must support the OS distro, version, architecture, serverrole for that OS image.

Some kitcomponents have dependencies on other kitcomponents. For example, a kit component may have a dependency on the product kit license component. Any kit components they may be required must also be defined in the xCAT database.

Note: A kit component in the latest product kit may have a dependency on a license kit component from an earlier kit version.

To check if a kitcomponent is valid for an existing OS image definition run the [chkkitcomp](http://xcat.sourceforge.net/man1/chkkitcomp.1.html) command:

~~~~
    chkkitcomp -i <osimage> <kitcompname>
~~~~


If the kit component is compatible then add the kitcomponent to the OS image defintion using the [addkitcomp](http://xcat.sourceforge.net/man1/addkitcomp.1.html) command.

For example, to add the kit component and any other kitcomponent dependencies, run:

~~~~
    addkitcomp -a -i <osimage> <kitcompname>
~~~~


When a kitcomponent is added to an OS image definition, the **addkitcomp** command will update several attributes in the xCAT database.

#### Listing kit components

The xCAT kitcomponent object definition may be listed using the xCAT [lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html) command.

Example.

~~~~
    lsdef -t kitcomponent -l <kit component name>
~~~~


The contents of the kit component may be listed by using the [lskitcomponent](http://xcat.sourceforge.net/man1/lskitcomponent.1.html) command.

Example.

~~~~
    lskitcomp <kit component name>
~~~~





### Adding Multiple Versions of the Same Kit Component to an OS Image Definition

xCAT allows you to have multiple versions/releases of a product software kit available in your cluster. Typically, you will build different OS image definitions corresponding to the different versions/releases of a product software stack.

However, in some instances, you may need mulitple versions/releases of the same product available within a single OS image. This is only feasible if the software product supports the install of multiple versions or releases of its product within an OS image.

Currently, it is not possible to install multiple versions of a product into an OS image using xCAT commands. xCAT uses apt-get on Ubuntu to install product deb packages. These package managers do not provide an interface to install different versions of the same package, and will always force an upgrade of the package. We are investigating different ways to accomplish this function for future xCAT releases.

Some software products have designed their packaging to leave previous versions of the software installed in an OS image even when the product is upgraded. This is done by using different package names for each version/release, so that the package manager does not see the new version as an upgrade, but rather as a new package install. In this case, it is possible to use xCAT to install multiple versions of the product into the same image.

By default, when a newer version/release of a kitcomponent is added to an existing OS image definition, **addkitcomp** will automatically upgrade the kitcomponent by removing the old version first and then adding the new one. However, you can force both versions of the kitcomponent to be included in the OS image definition by specifying the full kitcomponent name and using the **addkitcomp -n** (--noupgrade) flag with two separate command calls. For example, to include both myprod_compute.1-0.1 and myprod_compute.1-0.2 into an the compute osimage, you would run in this order:

~~~~
      addkitcomp -i compute myprod_compute.1-0.1
      addkitcomp -i compute -n myprod_compute.1-0.2
~~~~


~~~~
      lsdef -t osimage -o compute -i kitcomponents
         Object name:  compute
            kitcomponents=myprod_compute.1-0.1,myprod_compute.1-0.2
~~~~


When building a diskless image for the first time, or when deploying a diskfull node, xCAT will first install version 1-0.1 of myprod, and then in a separate apt-get call, xCAT will install version 1-0.2. The second install will either upgrade the product deb packages or install the new versions of the deb packages depending on how the product named the packages.

### Modifying Kit Deployment Parameters for an OS Image Definition

Some product software kits include kit deployment parameter files to set environment variables when the product packages are being installed in order to control some aspects of the install process. To determine if a kit includes such a file:

~~~~
      lsdef -t kit -o <kitname> -i kitdeployparams
~~~~


If the kit does contain a deployment parameter file, the contents of the file will be included in the OS image definition when you add one of the kitcomponents to your image. You can view or change these values if you need to change the install processing that they control for the software product:

~~~~
      addkitcomp -i <image> <kitcomponent name>
      vi /install/osimages/<image>/kits/KIT_DEPLOY_PARAMS.otherpkgs.pkglist
~~~~


NOTE: Please be sure you know how changing any kit deployment parameters will impact the install of the product into your OS image. Many parameters include settings for automatic license acceptance and other controls to ensure proper unattended installs into a diskless image or remote installs into a diskfull node. Changing these values will cause problems with genimage, updatenode, and other xCAT deployment commands.

## Complete the software update

#### updating diskless images

For diskless OS images (stateless and statelite), run the [genimage](http://xcat.sourceforge.net/man1/genimage.1.html) command to update the image with the new software. Example:

~~~~
    genimage <osimage>
~~~~


Once the osimage has been updated you may follow the normal xCAT procedures for packing and deploying the image to your diskless nodes.

#### installing diskful (stateful) nodes

For new stateful deployments, the kitcomponent will be installed during the otherpkgs processing. Follow the xCAT procedures for your hardware type. Generally, it will be something like:

~~~~
      chdef <nodelist> provmethod=<osimage>
      nodeset <nodelist> osimage
      rpower <nodelist> reset
~~~~


#### updating diskful (stateful) nodes

For existing active nodes, you may use the **updatenode** command to update the OS on those nodes:

~~~~
      updatenode <nodelist>
~~~~





## Kit Cleanup

### Removing Kit Components from an OS Image Definition

To remove a kit component from an OS image definition, first list the existing kitcomponents to get the name to remove:

~~~~
      lsdef -t osimage -o <image> -i kitcomponents
~~~~


Then, use that name to remove it from the image definition:

~~~~
      rmkitcomp -i <image> <kitcomponent name>
~~~~


Or, if you know the basename of the kitcomponent, simply:

~~~~
      rmkitcomp -i <image> <kitcompent basename>
~~~~


Note that this ONLY removes the kitcomponent from the image definition in the xCAT database, and it will NOT remove any product packages from the actual OS image. To set up for an uninstall of the kitcomponent from the diskless image or the statefull node, specify the uninstall option:

~~~~
      rmkitcomp -u -i <image> <kitcomponent>
~~~~


The next time you run genimage for the diskless image, or updatenode to the fulldisk nodes, the software product will be un-installed.

### Removing a Kit from the xCAT Management Node

To remove a kit from xCAT, you must first make sure that no OS images are assigned any of the kitcomponents. To do this, run the following database queries:

~~~~
     lsdef -t kitcomponent -w 'kitname==<kitname>'
~~~~


For each kitcomponent returned:

~~~~
     lsdef -t osimage -i kitcomponents -c | grep <kitcomponent>
~~~~


If no osimages have been assigned any of the kitcomponents from this kit, you can safely remove the kit by running:

~~~~
     rmkit <kitname>
~~~~
