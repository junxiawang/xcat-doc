<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
  - [Kit framework](#kit-framework)
  - [Kit documentation](#kit-documentation)
- [Building a Kit](#building-a-kit)
  - [Install the xCAT-buildkit RPM](#install-the-xcat-buildkit-rpm)
  - [Create a Kit directory structure](#create-a-kit-directory-structure)
  - [Edit the kit configuration file.](#edit-the-kit-configuration-file)
    - [buildkit.conf stanzas](#buildkitconf-stanzas)
    - [buildkit.conf substitution directives](#buildkitconf-substitution-directives)
    - [Partial vs. complete Kits](#partial-vs-complete-kits)
    - [Support for product licenses](#support-for-product-licenses)
      - [Creating a license kitcomponent](#creating-a-license-kitcomponent)
      - [Removing the product license from a kit](#removing-the-product-license-from-a-kit)
    - [Specific buildkit.conf example](#specific-buildkitconf-example)
  - [Copy Files into the Kit directory structure](#copy-files-into-the-kit-directory-structure)
    - [Substitution directives for Plugins, Scripts, and Other Files](#substitution-directives-for-plugins-scripts-and-other-files)
  - [Validate the Kit configuration](#validate-the-kit-configuration)
  - [Build the Kit Package Repositories](#build-the-kit-package-repositories)
  - [Build the Kit Tarfile](#build-the-kit-tarfile)
  - [Test the Kit](#test-the-kit)
- [Publish a PTF kit to Fix Central](#publish-a-ptf-kit-to-fix-central)
- [Building a complete kit from a partial kit](#building-a-complete-kit-from-a-partial-kit)
- [Update packages in a complete kit](#update-packages-in-a-complete-kit)
- [Sample buildkit.conf file](#sample-buildkitconf-file)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

**New in xCAT 2.8.  Supported for Linux OS images only.**
**xCAT 2.9 and newer releases also support Software Kits for Ubuntu OS images.**



## Introduction

This document describes how to build a product Kit package that can be used to install software on the nodes of an xCAT cluster.

The value of a Kit package is that it makes it much simpler for a user to install and update cluster software.

A Kit contains the product software packages, configuration and control information, and install and customization scripts.

The xCAT **buildkit** command provides a collection of subcommands that may be used build a product Kit

You will need to run the **buildkit** command several times with different subcommands to step through the process of building a kit.

See the [buildkit](http://xcat.sourceforge.net/man1/buildkit.1.html) manpage for details.

The xCAT Kit support also includes commands that may be used to add Kit packages to existing OS images that may then be used to install or update cluster nodes.

Note: The xCAT support for Kits is only available for Linux operating systems.




### Kit framework

Over time it is possible that the details of the Kit package contents and support may change. For example, there may be a need for additional information to be added etc. We refer to a particular instance of the kit support as it's "framework". A particular framework is identified by a numerical value.

Care must be taken to make sure the framework of the code that builds a Kit ([buildkit](http://xcat.sourceforge.net/man1/buildkit.1.html) ) is compatible with the framework of the code that uses the kit ([addkit](http://xcat.sourceforge.net/man1/addkit.1.html), [addkitcomp](http://xcat.sourceforge.net/man1/addkitcomp.1.html) etc.).

The kit commands contain the framework value supported by this code and also a list of other frameworks it is compatible with. When you build a new Kit these values are placed in a configuration file that is included in the Kit tar file.

You can view the framework values for the **buildkit** command by running:

~~~~
    > buildkit -v
    xCAT-buildkit:  2.8.2-snap201306181421
           kitframework = 1
           compatible_frameworks = 0,1
~~~~


When this Kit is being used to update an osimage the Kit commands (**addkit**, **addkitcomp** etc.) will check to see if the Kit framework value is compatible. To be compatible at least one of the Kit compatible_frameworks must match one of the compatible frameworks the command supports.

The Kit frameworks do not necessarily change with each new release of xCAT. The framework will only change when new kit support is required. For example, adding a new rpm to the kit would not require a framework change whereas adding a new attribute to the kit configuration file would.

If possible a new product kit should always be built using use the latest xCAT (and therefore the latest framework supported).

The xCAT kit support will be backward compatible. That is, the latest version of the xCAT kit commands will handle kits built with old frameworks (unless otherwise documented).

When building a new Kit you should consider whether or not the user of the Kit will have (or need) compatible kit commands.

For example, if the new kit contains features that are not available in the older kit frameworks then the user will be required to upgrade the level of XCAT in order to get the new framework support.

### Kit documentation

Introduction to Kits: [Using_Software_Kits_in_OS_Images]

Building a Kit: [Building_Software_Kits]

Using an HPC software Kit: [IBM_HPC_Software_Kits]

## Building a Kit

### Install the xCAT-buildkit RPM

Install the xCAT-buildkit RPM on your build server.

This rpm does not have any other dependencies on xCAT, and does not necessarily have to be installed on an xCAT management node.

The xCAT-buildkit RPM requires **rpmbuild** and **createrepo** which are available from the Linux distribution..

Starting with xCAT version 2.8.2 the xCAT-buildkit RPM will be installed automatically as part of installing base xCAT.

If you are using an older version of xCAT or your build server is not an xCAT management node, then you will have to either:

    1) Download the the xCAT tar file and install the xCAT-buildkit RPM
       from the local repository.
    OR

    2) Install the RPM directly from the internet-hosted repository.


This general process is decribed in: [Install_xCAT_on_the_Management_Node].

Once the repositories are set up you would either:

[RH]: Use **yum** to install xCAT-buildkit and all its dependencies:

~~~~
    yum clean metadata
    yum install xCAT-buildkit
~~~~


[SLES]: Use **zypper** to install xCAT-buildkit and all its dependencies:

~~~~
    zypper install xCAT-buildkit
~~~~


### Create a Kit directory structure

To create a Kit template directory structure use the **buildkit** command..

~~~~
    buildkit create <kit_basename>
~~~~


This will create a sub-directory called "&lt;kit_basename&gt;" in your current directory.

If you wish to have your Kit directory in a different location you can specify it on the **buildkit** command line by using the "-l" option. See the [buildkit](http://xcat.sourceforge.net/man1/buildkit.1.html) manpage for details.

This Kit directory location will be automatically populated with additional subdirectories and samples.

~~~~
                                    <kit directory location>
               ----------------------------------------------------------------------------------
              /           /          /         \           \            \          \             \
     source_packages   scripts    plugins   other_files   docs         build      <kitname>    buildkit.conf file
     ---------------   -------    -------   -----------   ----     -----------    ---------
           /  \          |          |          |                        |
      subdir sample  sample     sample     sample                  kit_repodir
      ------ ------  ------     ------     ------                  -----------
         |
        RPMs

~~~~

~~~~
    **<kit directory location>** - The full path name of either the location specified on the command line,
               or the current working directory where you ran the **buildkit** command plus the <kit_basename>
               you provided.
     **buildkit.conf** -  The sample Kit build configuration file.
     **source_packages** - This directory stores the source packages for Kit Packages and Non-Native Packages.
               The **buildkit** command will search these directories for source packages when building packages.
               This directory stores:
                   * RPM spec and tarballs. (A sample spec file is provided.)
                   * Source RPMs.
                   * Pre-built RPMs (contained in a subdirectory of source_packages)
                   * Non-Native Packages
     **scripts** - This directory stores the Kit Deployment Scripts. 
                   Samples are provided for each type of script.
     **plugins** - This directory stores the Kit Plugins. Samples are provided 
                    for each type of plugin.
     **docs** - This directory stores the Kit documentation files.
     **other_files**
                  * **kitdeployparams.lst**: Kit Deployment parameters file
                  * **exclude.lst**: File containing files/dirs to exclude in stateless image.
     **build** - This directory stores files when the Kit is built.
     **build/kit_repodir** - This directory stores the fully built Kit Package Repositories
     **build/<kitbasename>** -  This directory stores the contents of the Kit tarfile before 
                                it is tar'red up.
     **<kit directory location>/<kitname>** - The kit tar file, partial kit name or 
        complete kit tar file name (ex. kitname.tar.bz2)

~~~~

### Edit the kit configuration file.

To build a Kit, you need to modify the Kit build configuration file which is used to build the Kit tarfile, Kit Package Repositories, Kit Component Meta-Packages, and individual Kit Packages.

The name of the file is "buildkit.conf" and the sample version is located in the Kit directory location that you just created.

~~~~
    <kit directory location>/buildkit.conf
~~~~


The sample buildkit.conf file contains a description of all the supported attributes and an indication of whether or not they are required or optional. The information is provided in a stanza format.

#### buildkit.conf stanzas

The buildkit.conf file consists of the following stanza types.

    **kit**: This stanza defines general information for the Kit. There must be exactly one kit stanza
                    in a kit build file.

    **kitrepo**: This stanza defines a Kit Package Repository. There must be at least one kitrepo
                    stanza in a kit build file. If you want to support multiple OSes, you should create
                    a separate repository for each OS.  Also, no two repositories can be defined with
                    the same OS name, major/minor version, and arch. For example, you cannot have two repos
                    for RHEL 6.2 x86_64 in the same kit.

    **kitcomponent**: This stanza defines one Kit Component. A kitcomponent definition is a way of
                    specifying a subset of the product Kit that may be installed into an xCAT osimage.
                    A kitcomponent may or may not be dependent on other kitcomponents.If you want to
                    build a component which supports multiple OSes, you should create one kitcomponent
                    stanza for each OS.

    **kitpackage**: This stanza defines one Kit Package (ie. RPM). There can be zero or more kitpackage stanzas.
                    If you want to build a package which can run on multiple OSes,you have two options:
                         1. Build a separate package for each OS you want to support. For this option,
                            you need to define one kitpackage section per supported OS.
                         2. Build one package that can run on multiple OSes. If you are building an
                            RPM package, you are responsible for creating an RPM spec file that can run
                            on multiple OSes. For this option, you need to define one kitpackage stanza
                            which contains multiple kitrepoid lines.


See [Building_Software_Kits/#sample-buildkitconf-file](Building_Software_Kits/#sample-buildkitconf-file) for additional details.

You wiil have to modify the file as needed for the product kit you are building.




#### buildkit.conf substitution directives

You can specify the following directives in your buildkit.conf file and buildkit will substitute the corresponding values when your buildkit.conf file is loaded for processing. This will allow maintaining your buildkit.conf file easier for future changes, avoid the possibility of typos, and also provide the correct values when a partial kit is built into a complete kit for a new version or release:

~~~~
     <<<INSERT_kitbasename_HERE>>>
     <<<INSERT_kitrepoid_HERE>>>
     <<<INSERT_osbasename_HERE>>>
     <<<INSERT_osmajorversion_HERE>>>
     <<<INSERT_osminorversion_HERE>>>
     <<<INSERT_osarch_HERE>>>
     <<<INSERT_kitcomponent_basename_HERE>>>
~~~~


#### Partial vs. complete Kits

A [Complete] software kit includes all the product software.

A [Partial] kit is one that does NOT include the product packages.

You will normally want to build a complete kit.

However, if you want a partial kit, you need to leave out the RPMs and set "isexternalpkg=yes" in the "kitpackage" stanzas of your buildkit.conf file.

For example:

~~~~
    kitpackage:
        filename=foobar_runtime-*.x86_64.rpm
        kitrepoid=rhels6_x86_64
        isexternalpkg=yes
~~~~


In this case, the user of the kit will have to download both the kit tarfiles and the product packages in order tocomplete the kit before using the it in an xCAT cluster. See [Using_Software_Kits_in_OS_Images]

#### Support for product licenses

If you do not have to deal with product licenses then skip this section.

Different products may have different ways of handling product licenses (or entitlement).

If a product ships a license RPM then they may be able to use the basic license support provide by the xCAT Kit support.

**Note**: If a product has a unique licensing requirement or process then that product kit will have to be modified to handle it as needed.

The basic product license support uses the concept of a kitcomponent to define a license kitcomponent for the product. The license kitcomponent would include the license RPM.

A kitcomponent definition is a way of specifying a subset of the product Kit that may be installed into an xCAT osimage. A kitcomponent may or may not be dependent on other kitcomponents. When you run the **addkit** command to add a Kit to the xCAT database the kitcomponents included in the Kit are automatically defined.

To include the license RPM in an xCAT osimage you would simply use the **addkitcomp** command to add the license kitcomponent to the xCAT osimage.

##### Creating a license kitcomponent

To create a license kitcomponent you must:

(1) Create a "kitpackage" stanza for the license RPM in the buildkit.conf file.

For example:

~~~~
    kitpackage:
       filename=ppe_rte_license-*.x86_64.rpm
       kitrepoid=rhels6_x86_64
       isexternalpkg=no
       rpm_prebuiltdir=pperte1.3.0.7
~~~~


In this example, "isexternalpkg=no" means that this RPM will be built into the kit and "rpm_prebuiltdir=pperte1.3.0.7" specifies the subdirectory under &lt;Kit Build Directory&gt;/source_packages where the RPM is located.

Notice that the filename is specified using a wildcard for the version. This is done so that this stanza would not have to be modified for future releases of the product.


(2) Add a kitcomponent stanza to the buildkit.conf file.

For example:

~~~~
    kitcomponent:
       basename=pperte_license
       description=PE RTE for compute nodes
       serverroles=compute
       ospkgdeps=at,rsh,rsh-server,xinetd,sudo,libibverbs(x86-32),libibverbs(x86-64),redhat-lsb
       kitrepoid=rhels6_x86_64
       kitpkgdeps=ppe_rte_license
~~~~


In this case "ppe_rte_license" is the base name of the license RPM shipped for the product.

(3) Add the line "kitcompdeps=pperte_license" to the stanzas for other components that require the license. This will ensure that the license is included when it is a dependency for installing other product RPMs.

(4) Make sure the product license RPM is available along with the other product RPMs before building the new kit.


**Note**: When this kit is defined to xCAT each of the kit components is also define. The license kit component that is defined may also be used to satisfy the license dependency for future PTF product kits.

##### Removing the product license from a kit

A product kit that is created for a PTF should NOT include the license.

If the product kit included the general release of the product included a license kit component then you must make sure you remove it.

To remove the license from a kit:

(1) Remove the "kitpackage" stanza for the license rpm from the buildkit.conf file.

(2) Remove the license kitcomponent stanza from the buildkit.conf file.

(3) Leave the "kitcompdeps=pperte_license" value set for the kitcomponent stanzas. The PTF RPMs still need to have a dependency on the product license.


**Note**: This product update kit would not include the license but it would automatically pull in the license kitcomponent that was defined when the GA release product kit was previously defined in xCAT.

#### Specific buildkit.conf example

The following is the contents of the of the buildkit.conf file for building the Parallel Environment Developer Edition Kit. (Commented lines were left out of this example for easier readability.)

~~~~
    kit:
      basename=pperte
      description=Parallel Environment Runtime Edition
      version=1.3.0.6
      release=0
      ostype=Linux
      osarch=x86_64
      url=Null
      kitlicense=ILAN
      kitdeployparams=pe.env

    kitrepo:
      kitrepoid=rhels6_x86_64
      osbasename=rhels
      osmajorversion=6
      osarch=x86_64

    kitrepo:
      kitrepoid=sles11_x86_64
      osbasename=sles
      osmajorversion=11
      osarch=x86_64

    kitcomponent:
       basename=pperte_license
       description=PE RTE for compute nodes
       serverroles=compute
       ospkgdeps=at,rsh,rsh-server,xinetd,sudo,libibverbs(x86-32),libibverbs(x86-64),redhat-lsb
       kitrepoid=rhels6_x86_64
       kitpkgdeps=ppe_rte_license

    kitcomponent:
       basename=pperte_compute
       description=PE RTE for compute nodes
       serverroles=compute
       kitrepoid=rhels6_x86_64
       kitcompdeps=pperte_license
       kitpkgdeps=pperte,pperteman,ppertesamples,src
       exlist=pe.exlist
       postinstall=pperte_postinstall
       postupgrade=pperte_postinstall
       postbootscripts=pperte_postboot

    kitcomponent:
       basename=min_pperte_compute
       description=Minimal PE RTE for compute nodes
       serverroles=compute
       kitrepoid=rhels6_x86_64
       kitcompdeps=pperte_license
       kitpkgdeps=pperte,src
       exlist=pe.exlist
       postinstall=pperte_postinstall
       postupgrade=pperte_postinstall
       postbootscripts=pperte_postboot

    kitcomponent:
       basename=pperte_login
       description=PE RTE for login nodes
       serverroles=login
       kitrepoid=rhels6_x86_64
       kitcompdeps=pperte_license
       kitpkgdeps=pperte,pperteman,ppertesamples,src
       exlist=pe.exlist
       postinstall=pperte_postinstall
       postupgrade=pperte_postinstall
       postbootscripts=pperte_postboot

    kitcomponent:
       basename=pperte_license
       description=PE RTE for compute nodes
       serverroles=compute
       ospkgdeps=at,rsh-server,xinetd,sudo,libibverbs-32bit,libibverbs,insserv
       kitrepoid=sles11_x86_64
       kitpkgdeps=ppe_rte_license

    kitcomponent:
       basename=pperte_compute
       description=PE RTE for compute nodes
       serverroles=compute
       kitrepoid=sles11_x86_64
       kitcompdeps=pperte_license
       kitpkgdeps=pperte,pperteman,ppertesamples,src
       exlist=pe.exlist
       postinstall=pperte_postinstall
       postupgrade=pperte_postinstall
       postbootscripts=pperte_postboot

    kitcomponent:
       basename=min_pperte_compute
       description=Minimal PE RTE for compute nodes
       serverroles=compute
       kitrepoid=sles11_x86_64
       kitcompdeps=pperte_license
       kitpkgdeps=pperte,src
       exlist=pe.exlist
       postinstall=pperte_postinstall
       postupgrade=pperte_postinstall
       postbootscripts=pperte_postboot

    kitcomponent:
       basename=pperte_login
       description=PE RTE for login nodes
       serverroles=login
       kitrepoid=sles11_x86_64
       kitcompdeps=pperte_license
       kitpkgdeps=pperte,pperteman,ppertesamples,src
       exlist=pe.exlist
       postinstall=pperte_postinstall
       postupgrade=pperte_postinstall
       postbootscripts=pperte_postboot

    kitpackage:
       filename=pperte-*.x86_64.rpm
       kitrepoid=rhels6_x86_64,sles11_x86_64

    kitpackage:
       filename=pperteman-*.x86_64.rpm
       kitrepoid=rhels6_x86_64,sles11_x86_64

    kitpackage:
       filename=ppertesamples-*.x86_64.rpm
       kitrepoid=rhels6_x86_64,sles11_x86_64

    kitpackage:
       filename=ppe_rte_*.x86_64.rpm
       kitrepoid=rhels6_x86_64,sles11_x86_64

    kitpackage:
       filename=ppe_rte_man-*.x86_64.rpm
       kitrepoid=rhels6_x86_64,sles11_x86_64

    kitpackage:
       filename=ppe_rte_samples-*.x86_64.rpm
       kitrepoid=rhels6_x86_64,sles11_x86_64

    kitpackage:
       filename=src-*.i386.rpm
       kitrepoid=rhels6_x86_64,sles11_x86_64

    ### License rpm gets placed in all repos
    kitpackage:
       filename=ppe_rte_license-*.x86_64.rpm
       kitrepoid=rhels6_x86_64,sles11_x86_64

~~~~

The kitrepo stanzas define two Kit repos, one for RHEL and one for SLES, both for x86_64 architecture.

There are four kitcomponent stanzas for each kitrepo: "ppedev_compute", "min_pperte_compute", "pperte_login", and "pperte_license".

### Copy Files into the Kit directory structure

After editing the buildkit configuration file (buildkit.conf), you need to copy files into the Kit directory structure.

The types of files you need to copy are:

**Source Packages** \- IBM HPC Product RPM packages. \- These files should be copied to: &lt;Kit directory location&gt;/source_packages \- if building a complete kit

**Deployment Scripts** \- These files should be copied to: &lt;Kit directory location&gt;/scripts

**Plugins** \- For IBM HPC Products in this first release, no plugins will be developed. However, future support may be considered by the product packaging developers. For example, GPFS may choose to implement a nodemgmt.pm plugin that would add a new node to the GPFS cluster. \- These files should be copied to: &lt;Kit directory location&gt;/plugins

**Doc Files** \- These files should be copied to: &lt;Kit directory location&gt;/docs

**Other Files** \- These include: kit deployment parameter file, exclude lists \- These files should be copied to: &lt;Kit directory location&gt;/other_files

When you copy these files, make sure their location matches what is in the buildkit.conf File. For example, if the location of an RPM spec file is .pkg2/pkg2.spec. in the file, then the actual spec file should be found in this location:

~~~~
    <Kit directory location>/source_packages/pkg2/pkg2.spec

~~~~




#### Substitution directives for Plugins, Scripts, and Other Files

You can specify the following directives in your plugin files buildkit will substitute the corresponding values when your file is copied to the kit. This will allow you to build a plugin that specifically uses this kit name, will allow maintaining your plugin file easier for future changes, and will provide the correct values when a partial kit is built into a complete kit for a new version or release:

~~~~
      <<<buildkit_WILL_INSERT_kitname_HERE>>>
      <<<buildkit_WILL_INSERT_modified_kitname_HERE>>>
~~~~


For the modified kitname, all dashes '-' and periods '.' are converted to underscores '_' to prevent Perl syntax errors when your plugin is loaded by xCAT.


You can specify the following directives in the files provided in your scripts and other_files directory, and buildkit will substitute the corresponding values when your file is copied to the kit. This will allow you to build scripts that specifically use this kit name, will allow maintaining your script file easier for future changes, and will provide the correct values when a partial kit is built into a complete kit for a new version or release

~~~~
     <<<buildkit_WILL_INSERT_kit_name_HERE>>>
     <<<buildkit_WILL_INSERT_kit_basename_HERE>>>
     <<<buildkit_WILL_INSERT_kit_version_HERE>>>
     <<<buildkit_WILL_INSERT_kit_release_HERE>>>
     <<<buildkit_WILL_INSERT_kitcomponent_name_HERE>>>
     <<<buildkit_WILL_INSERT_kitcomponent_basename_HERE>>>
     <<<buildkit_WILL_INSERT_kitcomponent_version_HERE>>>
     <<<buildkit_WILL_INSERT_kitcomponent_release_HERE>>>
~~~~


### Validate the Kit configuration

After you copy the files to your kit directories, you can use the "chkconfig" subcommand to validate that the build configuration is correct:

~~~~
    buildkit chkconfig
~~~~


This will verify that all required fields are specified, that all internally referenced attributes are defined, and that all referenced files exist.

Fix any errors that are reported.

### Build the Kit Package Repositories

After the buildkit configuration file is validated, you can build the Kit Package Repositories.

Note that if you need to build repositories for OS distributions, versions, or architectures that do not match the current system, you may need to copy your kit template directory to an appropriate server to build that repository, and then copy the results back to your main build server.

For IBM HPC Products, since you are using pre-built rpms, you should be able to build all repositories on the same server since there should not be anything OS/arch specific in the kitcomponent meta-package rpm build.

**Note**: These examples assume you are running the commands in the &lt;Kit directory location&gt;/ directory.

To list the repos defined in your buildkit configuration file run:

~~~~
    buildkit listrepo
~~~~


To build the repositories you could either specify a particular repository or just build them all.

~~~~
    buildkit buildrepo <Kit Repo name>
~~~~


or

~~~~
    buildkit buildrepo all
~~~~


The repository would be built in &lt;Kit directory location&gt;/build/kit_repodir/ subdirectory.

If the Kit Package Repository is already fully built, then this command performs no operation.

If the Kit Package Repository is _not_ fully built, the command builds it as follows:

  1. Create the Kit Package Repository directory .&lt;Kit directory location&gt;/build/kit_repodir/&lt;Kit Pkg Repo&gt; .
  2. Build the Component Meta-Packages associated with this Kit Package Repository. Create the packages under the Kit Package Repository directory
  3. Build the Kit Packages associated with this Kit Package Repository. Create the packages under the Kit Package Repository directory
  4. Build the repository meta-data for the Kit Package Repository. The repository meta-data is based on the OS native package format. For example, for RHEL, we build the YUM repository meta-data with the **createrepo** command.

### Build the Kit Tarfile

After you build the Kit Package Repositories, you can build the final Kit tarfile. Run the following command in the &lt;Kit directory location&gt;/ directory.

~~~~
    buildkit buildtar
~~~~


The tar file will be copied to the kit directory location.

**Note**:

    A complete kit will be named something like:

~~~~
         testprod-1.0.0-x86_64.tar.bz2
~~~~


    A partial kit will be indicated by including the "NEED_PRODUCT_PKGS" string in its name.

~~~~
         testprod-1.0.0-x86_64.NEED_PRODUCT_PKGS.tar.bz2
~~~~


### Test the Kit

To test the Kit you just built you should verify that it can be used to update an xCAT osimage. Refer to [Using_Software_Kits_in_OS_Images] for details.

## Publish a PTF kit to Fix Central

\- TBD

## Building a complete kit from a partial kit

If a partial kit already exists for a product you can use it to build a complete kit.The **buildkit** command:

~~~~
    buildkit [-V|--verbose] addpkgs kit_tarfile [-p|--pkgdir package_directory_list] [-k|--kitversion version] [-r|--kitrelease release] [-l|--kitloc
          kit_location]

~~~~

For example:

~~~~
    buildkit addpkgs testkit-1.0-1.NEED_PRODUCT_PKGS.tar.bz2 -p testkit-1.0-1
~~~~


Optionally, change the kit release and version values when building the new kit tarfile, for example:

~~~~
    buildkit addpkgs testkit-1.0-1.NEED_PRODUCT_PKGS.tar.bz2 -p testkit-1.0-2 -k 1.0 -r 2
~~~~


The basic process is described in: [Using_Software_Kits_in_OS_Images/#completing-a-partial-kit](Using_Software_Kits_in_OS_Images/#completing-a-partial-kit)




## Update packages in a complete kit

If there is a complete kit available and there are product PTFs without a supporting kit, **buildkit** can update RPMs in a complete kit, and create a new complete kit.For example:

~~~~
    buildkit addpkgs gpfs-3.5.0-12-x86_64.tar.bz2 -p gpfs3.5.0.13 -k 3.5.0 -r 13
~~~~


After the command,a complete kit named gpfs-3.5.0-13-x86_64.tar.bz2 is created.And in new complete kit gpfs-3.5.0-13-x86_64.tar.bz2,old RPMs are not deleted,above command just add new RPMs into complete kit.

## Sample buildkit.conf file

**Note**: The sample buildkit.conf file may change over time. To get the latest version of the file look for it in the /opt/xcat/share/xcat/kits/kit_template directory after you have installed the xCAT_buildkit RPM.


~~~~
    # Kit Build File
    #
    # A unique version of this file is automatically generated for a new Kit
    # when you run the **buildkit** command to create a new Kit. The basic template
    # for this file is contained in the /opt/xcat/share/xcat/kits/kit_template
    # directory.  Once the initial version of this file is generated you will
    # have to modify it by adding the details needed to build your new Kit.
    #
    # Refer to the buildkit manpage for further details.
    #
    # kit: This stanza defines general information for the Kit.
    #      There must be exactly one kit stanza in a buildkit.conf file.
    #
    # kit attributes:
    #    basename        (mandatory) Kit base name. (ex. "myproduct")
    #
    #    description     (optional)  Kit description.
    #
    #    version         (mandatory) Kit version. ( template default "1.0")
    #
    #    release         (optional)  Kit release. (template default "1")
    #
    #    ostype          (mandatory) Kit OS type.  (template default "Linux")
    #                      (AIX is currently not supported.)
    #
    #    vendor          (optional) The vendor tag is used to define the name of
    #                                the entity that is responsible for packaging
    #                                the software.
    #
    #    packager        (optional) The packager tag is used to hold the name and
    #                                contact information for the person or persons
    #                                who built the package.
    #
    #    url             (optional) The url tag is used to provide a location to
    #                                obtain additional information about the
    #                                packaged software.
    #
    #    osbasename      (optional) OS distro base name. (ex. "rhels")
    #
    #    osmajorversion  (optional) OS major version. (ex. "6")
    #
    #    osminorversion  (optional) OS minor version.
    #
    #    osarch          (optional) OS architecture. (ex. "x86_64")
    #
    #    isinternal      (optional)  PCM use only.
    #                      Indicate if Kit is for internal use.
    #                      Use 1 for yes, 0 for no. Default: 0
    #
    #    kitdeployparams (optional)  Filename containing a list of kit deployment
    #                       parameters.  The name should be the full path name of
    #                       the file relative to <Kit Build Directory>/other_files
    #
    #    kitlicense      (mandatory) Kit license string to be built into all
    #                       kitcomponent packages.  (template default "EPL")
    #
    #    kittarfilename  (optional) Filename.tar.bz2 to be used for the generated
    #                       kit.  (ex. "myproduct-1.4.0.6-0-x86_64.tar.bz2")
    #                       The default format is:
    #  <basename>-<version>-<opt-release>-<opt-osbasename>-<opt-osmajorversion>-<opt-osminorversion>-<opt-osarch>.tar.bz2
    #
    kit:
      basename=<<<INSERT_kitbasename_HERE>>>
      description=description for <<<INSERT_kitbasename_HERE>>>
      version=1.0
      release=1
      ostype=Linux
      kitlicense=EPL
      # vendor=
      # packager=
      # url=
      # osbasename=
      # osmajorversion=
      # osminorversion=
      # osarch=
      # isinternal=
      # kitdeployparams=sample/kitdeployparams.lst
      # kittarfilename=
    #
    # kitrepo: This stanza defines a Kit Package Repository.
    #          There must be at least one kitrepo stanza in a kit build file.
    #          If you want to support multiple OSes, you should create a separate
    #          repo for each OS.  Also, no two repos can be defined with the same
    #          OS name, major/minor version and arch. For example, you cannot have
    #          two repos for RHEL 6.2 x86_64 in the same kit.
    #
    # kitrepo attributes:
    #    kitrepoid          (mandatory) Kit package repository ID. Must be unique within
    #                       this file.  A typical name may be something like:
    #                       "<osbasename><osmajorversion>.<osminorversion>_<osarch>".
    #                       (ex. "rhels6.4_x86_64")
    #
    #    osbasename         (mandatory) OS distro base name. (ex. "rhels")
    #
    #    osmajorversion     (mandatory) OS major version. (ex. "6")
    #
    #    osminorversion     (optional)  OS minor version. (ex. "4")
    #
    #    osarch             (mandatory) OS architecture. (ex. "x86_64")
    #
    #    compat_osbasenames (optional)  Comma-separated list of compatible
    #                         OS distribution base names. (ex. "centos")
    kitrepo:
      kitrepoid=<<<INSERT_kitrepoid_HERE>>>
      osbasename=<<<INSERT_osbasename_HERE>>>
      osmajorversion=<<<INSERT_osmajorversion_HERE>>>
      osminorversion=<<<INSERT_osminorversion_HERE>>>
      osarch=<<<INSERT_osarch_HERE>>>
      # compat_osbasenames=
    #
    # kitcomponent: This stanza defines one Kit Component.
    #               There can be zero or more kitcomponent stanzas.
    #               If you want to build a component which supports multiple OSes,
    #               you should create one kitcomponent section for each OS.
    #               You can define multiple kit components with the same base name
    #               only if each kit component using this base name meets these
    #               requirements:
    #                 - Each kit component must be defined with the same version
    #                   and release number
    #                 - Each kit component must be defined with a unique kitrepoid
    #
    # kitcomponent attributes:
    #    basename        (mandatory) Kit component base name (ex. "myproduct_compute")
    #
    #    description     (optional)  Kit component description
    #
    #    version         (optional)  Kit component version.  The default is the kit version.
    #
    #    release         (optional)  Kit component release.  The default is the kit release.
    #
    #    serverroles     (mandatory) Comma-separated list of node types that this
    #                      component could be installed on. (Valid values:
    #                         mgtnode,servicenode,compute,login,storage,utility)
    #                      (template default: "compute")
    #
    #    kitrepoid       (mandatory) The ID of the kit package repository this
    #                      component belongs to.
    #
    #    kitcompdeps     (optional)  Comma-separated list of kit component
    #                       dependencies.  These kit components can be included in
    #                       this kit or in other kits.
    #
    #    ospkgdeps       (optional)  Comma-separated list of OS RPM dependency basenames.
    #                       These packages must be shipped with the OS distro.
    #
    #    kitpkgdeps      (mandatory IF product RPMs will be included in this Kit)
    #                       Comma-separated list of RPM basenames. Each RPM must
    #                       be defined in a separate kitpackage stanza. Each RPM
    #                       package must be in the same kitrepo as this kit component.
    #
    #    non_native_pkgs (optional)
    #                       Comma-separated list of non-native package
    #                       paths that will be included as files in this kit
    #                       component. All filenames are relative to
    #                       <Kit Build Directory>/source_packages and may contain
    #                       wildcards.  If a filename is prefixed by 'EXTERNALPKGS:'
    #                       the file will not be built into the kit tarfile, but
    #                       will need to be added later with a 'buildkit addpkgs'
    #                       command.
    #                       Files will be placed in
    #                         /opt/xcat/kits/<kitbasename>/<kitcomponent_name>
    #                       when the kitcomponent package is deployed to an
    #                       OS image.
    #                       Kit component deployment scripts must be specified
    #                       to manage these files.
    #
    #   driverpacks      (optional) Comma-separated list of driver package filenames
    #                       Each driverpack must be defined in a separate kitpackage
    #                       section.
    #
    #   exlist           (optional) Exclude list file for stateless image, relative
    #                       to <Kit Build Directory>/other_files
    #
    #   Kit component deployment scripts (optional)  Each attribute specifies
    #                       script path relative to <Kit Build Directory>/scripts
    #                       Script attributes:
    #                         preinstall, postinstall, preuninstall, postuninstall,
    #                         preupgrade, postupgrade, postbootscripts,
    #                         genimage_postinstall
    kitcomponent:
       basename=<<<INSERT_kitcomponent_basename_HERE>>>
       description=description for component <<<INSERT_kitcomponent_basename_HERE>>>
       serverroles=compute
       kitrepoid=<<<INSERT_kitrepoid_HERE>>>
       kitpkgdeps=pkg1basename,pkg2basename
       # kitcompdeps=myproduct_license
       # ospkgdeps=dep1,dep2
       # non_native_pkgs=a_kitcomponent.file
       # non_native_pkgs=EXTERNALPKGS:a_kitcomponent.file
       # driverpacks=
       # exlist=sample/exclude.lst
       # preinstall=sample/pre.sh
       # postinstall=sample/post.sh
       # preuninstall=sample/preun.sh
       # postuninstall=sample/postun.sh
       # preupgrade=sample/preup.sh
       # postupgrade=sample/postup.sh
       # postbootscripts=sample/postboot.sh
       # genimage_postinstall=sample/genimage_post.sh
    #
    # kitpackage: This stanza defines one Kit Package.
    #             There can be zero or more kitpackage stanzas.
    #
    #             If you want to build a package which can run on multiple OSes,
    #             you have two options:
    #               1. Build a separate package for each OS you want to support.
    #                  For this option, you need to define one kitpackage stanza
    #                  per supported OS.
    #               2. Build one package that can run on multiple OSes.
    #                  If you are building an RPM package, you are responsible for
    #                  creating an RPM spec file that can run on multiple OSes.
    #                  For this option, you need to define one kitpackage stanza
    #                  which contains multiple kitrepoid lines.
    #
    #
    # kitpackage attributes:
    #    filename   (mandatory) Package filename. The filename may contain wildcards to avoid needing to
    #                       specify an explicit package version-release filename.
    #
    #    kitrepoid  (mandatory) A comma-separated list of kit repo names this package
    #                 belongs to.  If multiple repos are defined, the package will
    #                 be built for the first repo only. For the other repos,
    #                 a symlink is created to the package built for the first repo.
    #
    #    isexternalpkg  (mandatory) Indicates if the package will be included in this kit or added later.
    #                   'no' or '0' means the package is included.
    #                   'yes' or '1'  means the packages will be added later.
    #                   The default if not set is 'no'.
    #
    #    rpm_prebuiltdir  (mandatory IF isexternalpkg=no)  Path to the directory containing the pre-built RPMs relative to
    #                   <Kit Build Directory>/source_packages directory.
    #                   For example, if the file is "<Kit Build Directory>/source_packages/foobar/foo.rpm"
    #                   then set "rpm_prebuiltdir=foobar".
    kitpackage:
       filename=pkg1-*.noarch.rpm
       kitrepoid=<<<INSERT_kitrepoid_HERE>>>
       isexternalpkg=no
       rpm_prebuiltdir=<path>

~~~~

