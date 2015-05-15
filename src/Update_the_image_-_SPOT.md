<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Update options**](#update-options)
  - [**Add or update software**](#add-or-update-software)
  - [**Update system configuration files**](#update-system-configuration-files)
  - [**Run commands in the SPOT using xcatchroot**](#run-commands-in-the-spot-using-xcatchroot)
    - [**Run the AIX "trustchk" command (optional)**](#run-the-aix-trustchk-command-optional)
- [**Adding required software**](#adding-required-software)
  - [**Copy the software**](#copy-the-software)
  - [**Create NIM installp_bundle resources**](#create-nim-installp_bundle-resources)
  - [**Check the osimage (optional)**](#check-the-osimage-optional)
  - [**Install the software into the SPOT**](#install-the-software-into-the-spot)
- [**Adding Power 775 required software for Diskless Images**](#adding-power-775-required-software-for-diskless-images)
  - [**Include additional files for Power 775 support**](#include-additional-files-for-power-775-support)
  - [**Install the Power 775 software into the SPOT**](#install-the-power-775-software-into-the-spot)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

The SPOT created in the previous step should be considered the basic minimal diskless AIX operating system image. It does not contain all the software that would normally be installed as part of AIX, if you were installing a standalone system from the AIX product media. (The "nim -o showres ..." command mentioned above will display what software is contained in the SPOT.) 

You must install any additional software you need and make any customizations to the image before you boot the nodes. 

For more information on updating a diskless image see the document called [Updating_AIX_Software_on_xCAT_Nodes] 


#### **Update options**

There are basically three types of updates you can do to a SPOT. 

##### **Add or update software**

The SPOT created in the previous step should be considered the basic minimal diskless AIX operating system image. It does not contain all the software that would normally be installed as part of AIX, if you were installing a standalone system from the AIX product media. (The "nim -o showres ..." command mentioned above will display what software is contained in the SPOT.) 

You can use the **mknimimage** "-u" option to update software in the diskless image (SPOT). 

To do this you can update your xCAT osimage definition with any "installp_bundles", "otherpkgs" you wish to add and then run the **mknimimage -u** command. 

Use the **chdef** command to update the osimage definition. For example: 

~~~~    
    chdef -t osimage -o 61cosi installp_bundle="hpcbnd,labbnd"
~~~~     

Once the osimage definition is updated you can run **mknimimage**. 

~~~~     
    mknimimage -u 61cosi
~~~~     

You can also specify "installp_bundle" and "otherpkgs" on the command line. However in this case you wouldn't have a record (in the database) of what software was added to the SPOT. 

**WARNING:** Installing random RPM packages in a SPOT may have unpredictable consequences. The SPOT is a very restricted environment and some RPM packages may corrupt the SPOT or even hang your management system. Try to be very careful about the packages you install. When installing RPMs, if the mknimimage command hangs or if there are file systems left mounted after the command completes you may need to reboot your management node. This is a limitation of the current AIX support for diskless systems. 

##### **Update system configuration files**

You can also add other configuration files such as /etc/passwd etc. These files will then be available to every node that boots with this image. 

This can be done manually or by setting the "synclists" attribute of the osimage definition to point to a synclists file. This file contains a list of configuration files etc. that you wish to have copied into the SPOT. 

For more information on using the synchronization file function see the document: [Sync-ing_Config_Files_to_Nodes] 

Syncfiles is currently supported for diskfull or diskless installations. The function is not supported for statelite installations. For statelite installations to sync files you should use the read-only option for files/directories listed in litefile table with source location specified in the litetree table. 

Use the **chdef** command to update the osimage definition. For example: 

~~~~     
    chdef -t osimage -o 61cosi synclists="/u/test/mysyncfiles"
~~~~     

Once the osimage definition is updated you can run **mknimimage**. 

~~~~    
    mknimimage -u 61cosi
~~~~     

Note: You can do BOTH the software updates and configuration file updates at the same time with one call to **mknimimage**. 

##### **Run commands in the SPOT using xcatchroot**

Starting with xCAT 2.5 and AIX 6.1.6 the **xcatchroot** command can be used to modify the SPOT using the AIX **chroot** command. 

The **xcatchroot** command will take care of any of the required setup so that the command you provide will be able to run in the spot chroot environment. It will also mount the lpp_source resource listed in the osimage definition so that you can access additional software that you may wish to install. 

For example, to set the root password to "cluster" in the spot, (so that when the diskless node boots it will have a root password set), you could run a command similar to the following. 
 
~~~~    
    xcatchroot -i 61cosi "/usr/bin/echo root:cluster | /usr/bin/chpasswd -c"
~~~~     

See the **xcatchroot** man page for more details. 

**Caution: **

Be very careful when using **chroot** on a SPOT. It is easy to get the SPOT into an unusable state! It may be adviseable to make a copy of the SPOT before you try to run any commands that have an uncertain outcome. 

When you are done updating a NIM spot resource you should always run the NIM check operation on the spot. 

~~~~     
    nim -Fo check 61cosi
~~~~     

For more information on updating a diskless image see the document called&nbsp;: [Updating_AIX_Software_on_xCAT_Nodes] 

See the section titled "Updating diskless nodes" 

###### **Run the AIX "trustchk" command (optional)**

The contents of the /etc/security/privcmds file created in the NIM SPOT does not include many of the entries you would normally get when installing a standalone (diskful) system. If you require the /etc/security/privcmds on a diskless node to have a complete set of entries you must run the AIX "trustchk" command on the SPOT. You can use the xCAT "xcatchroot" command to do this. 

For example, assuming the name of your xCAT osimage is "71Bdskls" then you could run the following command. 
 
~~~~    
    xcatchroot -i 71Bdskls "/usr/sbin/trustchk  -ry ALL > /dev/null 2>&1"
~~~~     

#### **Adding required software**

You will have to install openssl and openssh along with several additional requisite software packages. 

The basic process is: 

  * Copy the required software to the lpp_source resource that you used to create your SPOT. 
  * Create NIM installp_bundle resources 
  * Check the lpp_source and bundle files 
  * Install the software in the SPOT. 

##### **Copy the software**

You will have to update the SPOT with additional software required for xCAT. 

The required software is specified in the sample bundle file discussed below. The **installp** filesets should be available from the AIX product media. The prerequisite rpms are available in the dep-aix-&lt;version&gt;.tar.gz tar file that you downloaded from the xCAT download page. 

The required software must be copied to the NIM lpp_source resource that is being used for this OS image. The easiest way to do this is to use the "nim -o update" command. 

For example, assume the dep-aix* .tar.gz file has been copied and unwrapped in the /tmp/images directory and that the name of the NIM lpp_source resource is "61cosi_lpp_source". 

In more recent versions of the dep-aix* tar file the software will be found in subdirectories corresponding to the level of AIX you are using. (ex. ./dep-aix/5.3, ./dep-aix/6.1). 

**Note:** Typically all the rpms are copied to the lpp_source resource even though they are not all used when installing a compute node. 

For example, to copy all the rpms from the dep-aix package you could run the following command. 
  
~~~~   
    nim -o update -a packages=all -a source=/tmp/images/dep-aix/6.1 61cosi_lpp_source
~~~~     

The NIM command will find the correct directories and update the lpp_source resource. 

##### **Create NIM installp_bundle resources**

To get all this additional software installed we need a way to tell NIM to include it in the installation. To facilitate this, xCAT provides sample NIM installp bundle files. 

Note: Always make sure that the contents of the bundle files you use are the packages you want to install and that they are all in the appropriate lpp_source directory. 

Starting with xCAT version 2.4.3 there will be a set of bundle files to use for installing a compute node. They are in "_/opt/xcat/share/xcat/installp_bundles_". There is a version corresponding to the different AIX OS levels. (xCATaixCN53.bnd, xCATaixCN61.bnd etc.) Just use the one that corresponds to the version of AIX you are running. 

**Note: **For earlier versions of xCAT the sample bundle files are shipped as part of the xCAT tarball file. 

**Note: **There are two versions of perl-Net_SSLeay.pm rpm listed in the sample bundle files, use perl-Net_SSLeay.pm-1.30-3* for AIX 7.1.2 and older version, use perl-Net_SSLeay.pm-1.55-3* for AIX 7.1.3 and above, see details in xCATaixCN71.bnd and xCATaixSN71.bnd. 

To use the bundle file you need to define it as a NIM resources and add it to the xCAT osimage definition. 

Copy the bundle file ( say xCATaixCN61.bnd ) to a location where it can be defined as a NIM resource, for example "/install/nim/installp_bundle". 

To define the NIM resource you can run the following command. 

~~~~     
    nim -o define -t installp_bundle -a server=master -a
     location= /install/nim/installp_bundle/xCATaixCN61.bnd xCATaixCN61
~~~~     

To add this bundle resource to your xCAT osimage definition run: 

~~~~     
    chdef -t osimage -o 610SNimage installp_bundle="xCATaixSN61"
~~~~     

##### **Check the osimage (optional)**

This command is available in xCAT 2.4.3 and beyond. 

  
To avoid potential problems when installing a node it is adviseable to verify that all the software that you wish to install has been copied to the appropriate NIM lpp_source directory. 

Any software that is specified in the "otherpkgs" or the "installp_bundle" attributes of the osimage definition must be available in the lpp_source directories. 

Also, if your bundle files include rpm entries that use a wildcard (*) you must make sure the lpp_source directory does not contain multiple packages that will match that entry. (NIM will attempt to install multiple version of the same package and produce an error!) 

To find the location of the lpp_source directories run the "lsnim -l &lt;lpp_source_name&gt;" command. For example: 

~~~~     
    lsnim -l 610image_lpp_source
~~~~     

If the location of your lpp_source resource is "/install/nim/lpp_source/610image_lpp_source/" then you would find rpm packages in "/install/nim/lpp_source/610image_lpp_source/RPMS/ppc" and you would find your installp and emgr packages in "/install/nim/lpp_source/610image_lpp_source/installp/ppc". 

To find the location of the installp_bundle resource files you can use the NIM "lsnim -l" command. For example, 

~~~~     
    lsnim -l xCATaixSSH
~~~~     

Starting with xCAT version 2.4.3 you can use the xCAT **chkosimage** command to do this checking. For example: 

~~~~     
    chkosimage -V 61cosi
~~~~     

See the **chkosimage** man page for details. 

##### **Install the software into the SPOT**

You can install and update software in a NIM SPOT resource by using NIM commands directly or you can use the xCAT **mknimimage** command. 

If you wish to use the NIM support directly you can check the NIM documentation for information on the NIM "cust" and "maint" operations. 

In this example the xCAT **mknimimage** command will be used. 

Run the **mknimimage** command to update the SPOT using the information saved in the xCAT "61cosi" osimage definition. 
  
~~~~   
    mknimimage -u 61cosi
~~~~     

See the **mknimimage** man page for more options that are available for updating diskless images (SPOT resources). 

**Note**: You cannot update a SPOT that is currently allocated. To check to see if the SPOT is allocated you could run the following command. 
 
~~~~    
    lsnim -l <spot name>
~~~~     

  


#### **Adding Power 775 required software for Diskless Images**
    
    **NOTE**:  This support will be available in xCAT 2.6 and beyond.
    

**Please note that the HFI device driver packages are shipped with base AIX71 TL2 and later. It is important that these AIX HFI fileset packages are included as part of the AIX71 LPPsource.**

We will require to have the HFI and ML device drivers included in the AIX71B diskless lpp_source images. This will create the proper HFI and ML device drivers to be part of AIX71B compute node diskless SPOT image. This is the same software that was installed in the xCAT SN image. 
    

~~~~     
    devices.chrp.IBM.HFI
    devices.common.IBM.hfi
    devices.common.IBM.ml 
    devices.msg.en_US.chrp.IBM.HFI
    devices.msg.en_US.common.IBM.hfi
    devices.msg.en_US.common.IBM.ml
~~~~     

  
Update the latest HFI and ML device drivers to your AIX71B compute node lpp source: Place the required packages into a directory called /hfi and execute nim -o update command to load images to lpp_source. 
 
~~~~    
    nim -o update -a packages=all -a source=/hfi/ 71BCNimage_lpp_source
~~~~   

The HFI device driver installp bundle should have already have been created as part of the xCAT service node section. We will include the information here just to be safe. 

Create the bundle file /install/nim/installp_bundle/xCATaixHFIdd.bnd to look like the following: 
    
 
~~~~    
    # HFI and ML installp packages
    I:devices.chrp.IBM.HFI.rte
    I:devices.common.IBM.hfi.rte
    I:devices.common.IBM.ml 
    I:devices.msg.en_US.chrp.IBM.HFI.rte
    I:devices.msg.en_US.common.IBM.hfi.rte
    I:devices.msg.en_US.common.IBM.ml
~~~~     

Execute the nim -o define command to create the nim HFI installp bundle file. 
 
~~~~    
    nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle \
          /xCATaixHFIdd.bnd xCATaixHFIdd
~~~~     

Assign HFI devices drivers isntallp bundle to service node image so they will be installed during service node installation. 

~~~~     
    chdef -t osimage -o 71BCNimage installp_bundle=xCATaixHFIdd
~~~~     

  


##### **Include additional files for Power 775 support**

The Power 775 service node requires additional files. These are all specified in the /install/postscripts/synclist file. 

To include them in the xCAT osimage used for the xCAT compute nodes you can run a command similar to the following. 
 
~~~~    
    chdef -t osimage -o 71BCNimage synclists=/install/postscripts/synclist
~~~~     

  


##### **Install the Power 775 software into the SPOT**

You can install and update software in a NIM SPOT resource by using NIM commands directly or you can use the xCAT **mknimimage** command. 

If you wish to use the NIM support directly you can check the NIM documentation for information on the NIM "cust" and "maint" operations. 

In this example the xCAT **mknimimage** command will be used. 

Run the **mknimimage** command to update the SPOT using the information saved in the xCAT "61cosi" osimage definition. 
 
~~~~    
    mknimimage -u 71BCNimage
~~~~     

See the **mknimimage** man page for more options that are available for updating diskless images (SPOT resources). 

**Note**: You cannot update a SPOT that is currently allocated. To check to see if the SPOT is allocated you could run the following command. 

~~~~     
    lsnim -l <spot name>
~~~~     
