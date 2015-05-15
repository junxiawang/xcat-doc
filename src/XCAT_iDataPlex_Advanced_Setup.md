<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Use the driver update disk**](#use-the-driver-update-disk)
- [**DB Table Regular Expression Example**](#db-table-regular-expression-example)
- [Understanding the chain table](#understanding-the-chain-table)
  - [Task Type](#task-type)
  - [Run Task List During Discovery](#run-task-list-during-discovery)
  - [Run Task List to Configure a Node](#run-task-list-to-configure-a-node)
- [Automatically Deploying Nodes After Discovery](#automatically-deploying-nodes-after-discovery)
- [**Manually setup the node attributes instead of using the templates or switch discovery**](#manually-setup-the-node-attributes-instead-of-using-the-templates-or-switch-discovery)
- [Updating Node Firmware](#updating-node-firmware)
- [Using ASU to Update CMOS, uEFI, or BIOS Settings on the Nodes](#using-asu-to-update-cmos-uefi-or-bios-settings-on-the-nodes)
  - [Download ASU](#download-asu)
  - [Determine CMOS Settings for Your Server Model](#determine-cmos-settings-for-your-server-model)
  - [Run ASU Out-of-Band](#run-asu-out-of-band)
  - [Manually Install ASU on the Nodes](#manually-install-asu-on-the-nodes)
  - [Add ASU to Your Node Image](#add-asu-to-your-node-image)
  - [Run ASU Via the Genesis Boot Kernel](#run-asu-via-the-genesis-boot-kernel)
- [Adding Drivers to the Genesis Boot Kernel](#adding-drivers-to-the-genesis-boot-kernel)
- [**Configuring Secondary Adapters**](#configuring-secondary-adapters)
- [Build a Compressed Image](#build-a-compressed-image)
  - [**Build aufs on Your Sample Node**](#build-aufs-on-your-sample-node)
  - [**Check Memory Usage**](#check-memory-usage)
- [Network Boot Flows](#network-boot-flows)
  - [Network Installation of a x86_64 Stateful Node Using Kickstart](#network-installation-of-a-x86_64-stateful-node-using-kickstart)
  - [Network Installation of a x86_64 Stateful Node using Autoyast](#network-installation-of-a-x86_64-stateful-node-using-autoyast)
  - [Network Boot of a x86_64 Stateless (RAMdisk) Node](#network-boot-of-a-x86_64-stateless-ramdisk-node)
  - [Network Boot of a Statelite (NFS root) Node](#network-boot-of-a-statelite-nfs-root-node)
  - [Network Deployment Diskful Windows Compute Node Using WinPE](#network-deployment-diskful-windows-compute-node-using-winpe)
- [**Appendix A: Network Table Setup Example**](#appendix-a-network-table-setup-example)
- [**Appendix B: Migrate your Management Node to a new Service Pack of Linux**](#appendix-b-migrate-your-management-node-to-a-new-service-pack-of-linux)
- [**Appendix C: Install your Management Node to a new Release of Linux**](#appendix-c-install-your-management-node-to-a-new-release-of-linux)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## **Use the driver update disk**

<!---
this is a markdown comment test
it should not show up in any output
-->

Linux supplies the driver update disk mechanism to support the devices which cannot be driven by the released distribution during the installation process. "driver update disk" is a media which contains the drivers and related configuration files for certain devices.

See [Using_Linux_Driver_Update_Disk] for information on using the driver update disk.

## **DB Table Regular Expression Example**

The xCAT database tables support powerful regular expressions for defining a pattern-based configuration. This can make the tables much smaller in large clusters, and can also help for more dynamic configurations or defining a site-standard set of defaults once and applying to multiple clusters.

Even though the syntax of the regular expressions looks complicated, once you understand the basics of the syntax, it is easy to make changes to the regular expressions to fit your cluster. As an example, we will change the IP addresses of the nodes from **172.20.100+_racknum_._nodenuminrack_** to **10.0.0._nodenum_**. The IP address is defined in the ip attribute and the relevant node group is idataplex, so we first query the regular expression using:

~~~~
    mgt# lsdef -t group idataplex -i ip
    Object name: idataplex
        ip=|\D+(\d+).*$|172.30.(101+(($1-1)/84)).(($1-1)%84+1)|
~~~~


Notice in the expression there are 3 vertical bars. The text between the first 2 vertical bars is what we will match in the node name whose IP address we are trying to get from the database. The pattern match of "&#92;D+(\d+).*$" means that we expect some non-digit characters, then some digits, then any text, then the end. Because the match of the digits is in parentheses, that value will get put into $1. So if we are matching n2, $1 will equal "2". The text between the 2nd and 3rd vertical bars represents the value of the attribute (in this case the ip) for this node. Any text in parentheses will be evaluated with the current value of $1. If you do the math, the resulting ip for n2 will be 172.30.101.2 . If we want it to be 10.0.0.2 instead, then change the regular expression like this:

~~~~
    chdef -t group idataplex ip='|\D+(\d+).*$|10.0.0.($1+0)|'
~~~~


Note: you could also change this expression using:

~~~~
    tabedit hosts
~~~~


Now test that the expression is working correctly for n2:

~~~~
    mgt# lsdef n2 -i ip
    Object name: n2
        ip=10.0.0.2
~~~~


Any of the regular expressions can be changed in a similar way to suit your needs. For more details on the table regular expressions, see the [xCAT database object and table descriptions](http://xcat.sf.net/man5/xcatdb.5.html).

## Understanding the chain table

The **chain** mechanism is the xCAT genesis system. Genesis is a customized Linux system, booted on the node, to do the discovery and configuration.

The **chain** table is designed to store the tasks (For example: 'runcmd=bmcsetup', 'runimage=&lt;URL&gt;', 'osimage=&lt;image name&gt;', 'install', 'netboot', 'shell', 'standby' ...) which are planned to be run automatically during the discovery or configuration of a node. There are three related attributes **currstate**,**currchain** and **chain** in the chain table which are used to perform the **chain** mechanism.

Genesis when running on the node sends 'get_task/get_next_task' request to xcatd. xcatd copies the **chain** attribute to the **currchain** attribute. xcatd then pops each task from the **currchain** attribute and puts it into the **currstate** attribute. It continues this until all tasks in the **currchain** attribute are completed (removed). The **currstate** attribute will show the current task which is running.

### Task Type

xCAT supports following types of task which could be set in the chain:

~~~~

   runcmd=<cmd>
~~~~

Currently only the 'bmcsetup' command is officially supplied by xCAT to run to configure the bmc of the compute node. You can find the 'bmcsetup' in /opt/xcat/share/xcat/netboot/genesis/x86_64/fs/bin/. You also could create your command in this directory and adding it to be run by 'runcmd=&lt;you cmd&gt;'.

~~~~
    runcmd=bmcsetup
~~~~

~~~~
   runimage=<URL>
~~~~

URL is a string which can be run by 'wget' to download the image from the URL. The example of URL could be:

~~~~
    runimage=http://$MASTER/image.tgz
~~~~


The image.tgz should can be uncompressed by 'tar xvf image.tgz'. And image.tgz should include a file named 'runme.sh' which is a script to initiate the running of the image. Note: You could try to run 'wget http://$MASTER/image.tgz' manually to make sure the path has been set correctly.

~~~~

   osimage=<image name> or (install/netboot)
~~~~

This task is used to specify that the compute node should run the OS deployment with osimage=&lt;image name&gt;. The install and netboot are also supported, but osimage=xxx is recommended for xCAT which version higher than 2.8.

~~~~
    osimage=rhels6.3-x86_64-install-compute
~~~~


  * shell

Make the genesis gets into the shell for admin to log in and run command.

  * standby

Make the genesis gets into standby and waiting for the task from chain. If the compute node gets into this state, any new task set to chain.currstate will be run immediately.

### Run Task List During Discovery

If you want to run a list of tasks during the discovery, set the tasks in the chain table by using the chdef command to change the **chain** attribute, before powering on the nodes. For example:

~~~~
    chdef <node range> chain='runcmd=bmcsetup,osimage=<osimage name>'
~~~~


These tasks will be run after the discovery.

### Run Task List to Configure a Node

Run the 'nodeset' command to set the tasks for the compute node and 'rpower reset' the node to initiate the running of tasks.

~~~~
    nodeset $node runimage=http://$MASTER/image.tgz,osimage=rhels6.3-x86_64-install-compute
    rpower $node reset
~~~~


In this example, the runimage will be run first, and then the &lt;rhels6.3-x86_64-install-compute&gt; will be deployed to the node.

During nodeset your request is put into the **currstate** attribute. The **chain** attribute is not used. The task in the **currstate** attribute will be passed to genesis and executed. If additional tasks are defined in the **currchain** attribute, these tasks will be run after the tasks in the **currstate** attribute are run.

## Automatically Deploying Nodes After Discovery

If you want xCAT to install or diskless boot your nodes immediately after discovering and defining them, do this before kicking off the discovery process:

  * Define and configure your osimage object (copycds, pkglist, otherpkglist, genimage, packimage, etc)
  * Associate the osimage with your nodes:

~~~~
    chdef ipmi provmethod=<osimage>
~~~~


  * Add the deployment step to the chain attribute:

~~~~
    chdef ipmi chain='runcmd=bmcsetup,osimage=<osimage name>:reboot4deploy'
~~~~


Now initiate the discovery and deployment by powering on the nodes.

## **Manually setup the node attributes instead of using the templates or switch discovery**

If you just have a few nodes and do not want to use the templates to set up the xCAT tables, and do not want to configure your ethernet switches for SNMP access, then the following steps can be used to define your nodes and prepare them for bmcsetup. (For more information, see the [node object attribute descriptions](http://xcat.sourceforge.net/man7/node.7.html).)

  * Add the new nodes:

~~~~
    nodeadd n1-n20 groups=ipmi,idataplex,compute,all
~~~~


  * Set attributes that are common across all of the nodes:

~~~~
    chdef -t group ipmi mgt=ipmi netboot=xnba bmcusername=USERID bmcpassword=PASSW0RD
~~~~


  * For each node, set the node specific attributes (bmc, ip, mac). For example:

~~~~
    chdef n1 bmc=10.0.1.1 ip=10.0.2.1 mac="xx:xx:xx:xx:xx:xx"
      .
      .
      .
~~~~


  * Add the nodes to dhcp service

~~~~
    makedhcp idataplex
~~~~


  * Setup the current runcmd to be bmcsetup

~~~~
    nodeset idataplex runcmd=bmcsetup
~~~~


  * Then walk over and power on the node. This will set up each BMC with the IP address userid and password that were set in the database above.

## Updating Node Firmware

The process for updating node firmware during the node discovery phase, or at a later time, is:

  * Download the firmware files from the [IBM Fix Central](http://www-933.ibm.com/support/fixcentral/options?selectionBean.selectedTab=find) web site. For example: &lt;http://www-933.ibm.com/support/fixcentral/options?selection=Hardware%3bSystems%3bibm%2fsystemx%3bSystem+x+iDataPlex+dx360+M4+server&gt;
  * Download the [UpdateXpress System Pack Installer](http://www-947.ibm.com/support/entry/portal/docdisplay?brand=5000016&lndocid=SERV-XPRESS) ( ibm_utl_uxspi) and its [documentation](http://www-947.ibm.com/support/entry/portal/docdisplay?lndocid=MIGR-5085892).
  * Put into a tarball:
    * the firmware files downloaded
    * the executable from UpdateXpress that is able to update the firmware on your target machine
    * a runme.sh script that you create that runs the executable with appropriate flags

     For example:

~~~~~~
    # cd /install/firmware
    # ls
    ibm_fw_imm2_1aoo27b-1.10_anyos_noarch.uxz
    ibm_fw_imm2_1aoo27b-1.10_anyos_noarch.xml
    ibm_fw_uefi_tde111a-1.00_anyos_32-64.uxz
    ibm_fw_uefi_tde111a-1.00_anyos_32-64.xml
    runme.sh
    ibm_utl_uxspi_9.21_rhel6_32-64.bin
    # cat runme.sh
    ./ibm_utl_uxspi_9.21_rhel6_32-64.bin  up -L -u
    # chmod +x runme.sh ibm_utl_uxspi_9.21_rhel6_32-64.bin
    # tar -zcvf firmware-update.tgz .
~~~~~~

  * For this example, we assume you have a nodegroup called "ipmi" that contains the nodes you want to update.
  * **Option 1 - update during discovery:** If you want to update the firmware during the node discovery process, ensure you have already added a dynamic range to the networks table and run "makedhcp -n". Then update the chain table to do both bmcsetup and the firmware update:


~~~~
    chdef -t group ipmi chain="runcmd=bmcsetup,runimage=http://mgmtnode/install/firmware/firmware-update.tgz,shell"
~~~~


  * **Option2 - update after node deployment:** If you are updating the firmware at a later time (i.e. **not** during the node discovery process), tell nodeset that you want to do the firmware update, and then set currchain to drop the nodes into a shell when they are done:


~~~~
    nodeset ipmi runimage=http://mgmtnode/install/firmware/firmware-update.tgz
    chdef ipmi currchain=shell
~~~~


  * Then physically power on the nodes (in the discovery case), or if the BMCs are already configured, run: rpower ipmi boot
  * To monitor the progress, watch the currstate attribute in the chain table. When they all turn to "shell", then they are done:

~~~~
    watch -d 'nodels ipmi chain.currstate|xcoll'
~~~~


  * At this point, you can check the results of the updates by ssh'ing into nodes and looking at /var/log/IBM_Support. (Or you can use psh or xdsh to grep for specific messages on all of the nodes.)
  * When you are satisfied with the results, then nodeset the nodes to use whatever osimage you want, and then boot the nodes.

## Using ASU to Update CMOS, uEFI, or BIOS Settings on the Nodes

### Download ASU

If you need to update CMOS/uEFI/BIOS settings on your nodes, download ASU (Advanced Settings Utility) from the IBM Fix Central web site:

  * Go to https://www.ibm.com/support/entry/myportal/docdisplay?lndocid=TOOL-ASU
  * Scroll down and select the latest version of the linux 64 bit RPM
  * You will need an IBM customer ID
  * Get the ASU documentation from https://www.ibm.com/support/entry/myportal/docdisplay?lndocid=MIGR-5085890

### Determine CMOS Settings for Your Server Model

To see what CMOS settings are recommended, visit the [IBM Intelligent Cluster Best Recipe page](http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=Intelligent+Cluster&product=ibm/systemx/1410&release=All&platform=All&function=all) and click on the link for your server model and look for a file with "cmos-settings" in the file name.

Once you have the ASU RPM on your MN (management node), you have several **choices** of how to run it:

### Run ASU Out-of-Band

ASU can be run on the management node (MN) and told to connect to the IMM of a node. First install ASU on the MN:

~~~~
    rpm -i ibm_utl_asu_asut78c-9.21_linux_x86-64.rpm
~~~~


In xCAT 2.8 and 2.7.7 a new command called [pasu](http://xcat.sourceforge.net/man1/pasu.1.html) is available to run the asu utility from the MN in parallel to many nodes at once. (If you are running 2.7.5 or 2.7.6 you can [download pasu](http://svn.code.sf.net/p/xcat/code/xcat-core/trunk/xCAT-client/bin/pasu) and save it in /opt/xcat/bin on your MN.)

To display 1 ASU setting for a set of nodes:

~~~~
    pasu <noderang> show uEFI.RemoteConsoleRedirection
~~~~


To set 1 ASU setting:

~~~~
    pasu <noderange> set uEFI.RemoteConsoleRedirection Enable
~~~~


To check if the setting is the same on all nodes:

~~~~
    pasu compute show uEFI.RemoteConsoleRedirection | xcoll
~~~~


To check if all settings are the same:

~~~~
    pasu compute show all | xcoll
~~~~


If you want to show or set several settings in a single command, put the ASU commands in a file and use the batch option:

~~~~
    pasu -b <settingsfile> <noderange> | xcoll
~~~~


If you are **running a version of xCAT earlier than 2.7.5**, you can still run the ASU utility to one node at a time. To do this, first determine the IP address, username, and password of the IMM (BMC):

~~~~
    lsdef node1 -i bmc,bmcusername,bmcpasswd
    tabdump passwd | grep ipmi      # the default if username and password are not set for the node
~~~~


Run the ASU tool directly to one node:

~~~~
    cd /opt/ibm/toolscenter/asu
    ./asu64 show all --host <ip> --user <username> --password <pw>
    ./asu64 show uEFI.ProcessorHyperThreading --host <ip> --user <username> --password <pw>
    ./asu64 set uEFI.RemoteConsoleRedirection Enable --host <ip> --user <username> --password <pw>  # a common setting that needs to be set
~~~~


If you want to set a lot of settings, you can put them in a file and run:

~~~~
    ./asu64 batch <settingsfile> --host <ip> --user <username> --password <pw>
~~~~


### Manually Install ASU on the Nodes

Copy the RPM to the nodes:

~~~~
    xdcp ipmi ibm_utl_asu_asut78c-9.21_linux_x86-64.rpm /tmp
~~~~


Install the RPM:

~~~~
    xdsh ipmi rpm -i /tmp/ibm_utl_asu_asut78c-9.21_linux_x86-64.rpm
~~~~


Run asu64 with the ASU commands you want to run:

~~~~
    xdsh ipmi /opt/ibm/toolscenter/asu/asu64 show uEFI.ProcessorHyperThreading
~~~~


### Add ASU to Your Node Image

Add the ASU RPM to your node image following the instructions in [Install_Additional_Packages].

If this is a stateless node image, re-run [genimage](http://xcat.sourceforge.net/man1/genimage.1.html) and [packimage](http://xcat.sourceforge.net/man1/packimage.1.html) and reboot your nodes. (If you don't want to reboot your nodes right now, run [updatenode -S](http://xcat.sourceforge.net/man1/updatenode.1.html) to install ASU on the nodes temporarily.

If this is a stateful node image, run [updatenode -S](http://xcat.sourceforge.net/man1/updatenode.1.html) to install ASU on the nodes.

### Run ASU Via the Genesis Boot Kernel

If you want to set ASU settings while discovering the nodes:

  * Download the ASU tar file (instead of the RPM)
  * Create a runme.sh script that will execute the asu64 commands you want (see above for examples)
  * Add runme.sh to the tar file
  * Add a runimage entry that references this tar file to the chain attribute

See [Updating_Node_Firmware](XCAT_iDataPlex_Advanced_Setup/#updating-node-firmware) for an example of using a tar file in a runimage statement.




## Adding Drivers to the Genesis Boot Kernel

The xCAT genesis boot kernel/initrd has most of the necessary IBM drivers built into it. If you need to add a driver for another type of hardware, you can put the driver on the xCAT MN and rebuild genesis with using the [mknb](http://xcat.sourceforge.net/man8/mknb.8.html) command. Here is an example of adding the [Adaptec AACRAID driver](https://www.adaptec.com/en-us/speed/raid/aac/linux/aacraid_linux_rpms_v1_2_1-40300_tgz.htm) to genesis:

  * Download the tar file and extract the rpm:

~~~~
    tar -zxvf aacraid_linux_rpms_v1.2.1-40300.tgz
~~~~


  * Extract aacraid_prebuilt.tgz from the rpm:

~~~~
    rpm2cpio aacraid-1.2.1-40300.rpm | cpio -id '*aacraid_prebuilt.tgz'
~~~~


  * List the contents of that tar file and extract the file that matches your arch, distro, and kernel version:

~~~~
    tar -ztvf aacraid_prebuilt.tgz
    tar -zxvf aacraid_prebuilt.tgz aacraid-2.6.32-358.el6.x86_64-x86_64

~~~~

  * Use modinfo to verify it is a kernel module and rename it:

    modinfo aacraid-2.6.32-358.el6.x86_64-x86_64
    mv aacraid-2.6.32-358.el6.x86_64-x86_64 aacraid.ko


  * Make the appropriate sub-directory in the genesis file system and move the kernel module there:

~~~~
    mkdir -p /opt/xcat/share/xcat/netboot/genesis/x86_64/fs/lib/modules/2.6.32-431.el6.x86_64/kernel/drivers/scsi/aacraid
    mv aacraid.ko /opt/xcat/share/xcat/netboot/genesis/x86_64/fs/lib/modules/2.6.32-431.el6.x86_64/kernel/drivers/scsi/aacraid

~~~~

  * Rebuild the module dependency file in the genesis file system:

~~~~
    depmod -b /opt/xcat/share/xcat/netboot/genesis/x86_64/fs  2.6.32-431.el6.x86_64
~~~~


  * Rebuild genesis:

~~~~
    mknb x86_64
~~~~


  * Genesis is now ready to use for discovery. To use the new genesis for firmware updates or running other utilities on nodes, run nodeset for the nodes again.


Note: 
It's possible to see an error, "module signed with unknown key" either when running mknb or booting the newly rebuilt genesis kernel. If this happens, it is necessary to remove the signature from the kernel module:

~~~~
    objcopy -R .note.module.sig module.ko new_module.ko
~~~~

After this, replace the old module with the new one, rerun 'depmod' and 'mknb'. In above Adaptec AACRAID driver example, you can do the following:

~~~~
    cd /opt/xcat/share/xcat/netboot/genesis/x86_64/fs/lib/modules/2.6.32-431.el6.x86_64/kernel/drivers/scsi/aacraid
    objcopy -R .note.module.sig aacraid.ko new_ aacraid.ko
    mv new_ aacraid.ko aacraid.ko
~~~~


## **Configuring Secondary Adapters**

To configure secondary adapters, see [Configuring_Secondary_Adapters](Configuring_Secondary_Adapters).

## Build a Compressed Image

_**The following documentation is old and has not been tested in a long time.**_

**Note:** We have found that aufs is not supported in Redhat6, so the xCAT code and following process will not works on Redhat6 or any other OS that does not support aufs or aufs2.

### **Build aufs on Your Sample Node**

Do this on the same node you generated the image on. Note: if this is a node other than the management node, we assume you still have /install mounted from the MN, the genimage stuff in /root/netboot, etc..

~~~~
    yum install kernel-devel gcc squashfs-tools
~~~~


~~~~
    mkdir /tmp/aufs
    cd /tmp/aufs
    svn co http://xcat.svn.sf.net/svnroot/xcat/xcat-dep/trunk/aufs
~~~~


**If your node does not have internet acccess, do that elsewhere and copy**

~~~~
    tar jxvf aufs-2-6-2008.tar.bz2
    cd aufs
    mv include/linux/aufs_type.h fs/aufs/
    cd fs/aufs/
    patch -p1 <osimage_name>
    nodeset blade <osimage_name>
    rpower blade boot
~~~~


Note: If you have a need to unsquash the image:

~~~~
    cd /install/netboot/fedora8/x86_64/compute
    rm -f rootimg.sfs
    packimage <osimage_name>
~~~~


### **Check Memory Usage**

~~~~
    # ssh <node> "echo 3 > /proc/sys/vm/drop_caches;free -m;df -h"
    total used free shared buffers cached
    Mem: 3961 99 3861 0 0 61
    -/+ buffers/cache: 38 3922
    Swap: 0 0 0
    Filesystem Size Used Avail Use% Mounted on
    compute_ppc64 100M 220K 100M 1% /
    none 10M 0 10M 0% /tmp
    none 10M 0 10M 0% /var/tmp
    Max for / is 100M, but only 220K being used (down from 225M). But wheres the OS?
~~~~


Look at cached. 61M compress OS image. 3.5x smaller As files change in hidden OS they get copied to tmpfs (compute_ppc64) with a copy on write. To reclaim space reboot. The /tmp and /var/tmp is for MPI and other Torque and user related stuff. if 10M is too small you can fix it. To reclaim this space put in epilogue:

~~~~
    umount /tmp /var/tmp; mount -a
~~~~


## Network Boot Flows

**Note: this section is still under construction!**

In case you need to understand this to diagnose problems, this is a summary of what happens when xCAT network boots the different types of nodes.

### Network Installation of a x86_64 Stateful Node Using Kickstart

<!---
begin_xcat_table;
numcols=3;
colwidths=20,30,20;
-->

| Booting Node | <-- Network Transfer --> | Management Node
---------------|--------------------------|-----------------
| PXE ROM | DHCP request --> | DHCP server
| PXE ROM | <-- IP configuration | DHCP server
| PXE ROM | <-- TFTP server IP address | DHCP server
| PXE ROM | <-- bootloader file name | DHCP server
| PXE ROM | request for bootloader --> | TFTP server
| PXE ROM | <-- bootloader executable (xnba.kpxe or xnba.efi) | TFTP server
| bootloader (xnba.kpxe/xnba.efi) | DHCP request --> | DHCP server
| bootloader (xnba.kpxe/xnba.efi) | <-- bootloader config URL | DHCP server
| bootloader (xnba.kpxe/xnba.efi) | request bootloader configuration --> | HTTP server
| bootloader (xnba.kpxe/xnba.efi) | <-- bootloader configuration | HTTP server
| UEFI bootloader (xnba.efi) only | request elilo (elilo-x64.efi) --> | HTTP server
| UEFI bootloader (xnba.efi) only | <-- elilo (/tftpboot/xcat/elilo-x64.efi) | HTTP server
| UEFI bootloader (xnba.efi) only | request elilo configuration --> | HTTP server
| UEFI bootloader (xnba.efi) only | <-- configuration(/tftpboot/xcat/xnba/nodes/<node>.elilo) | HTTP server
| bootloader (xnba/elilo) | request for linux kernel --> | HTTP server
| bootloader (xnba/elilo) | <-- linux kernel | HTTP server
| bootloader (xnba/elilo) | request for initrd --> | HTTP server
| bootloader (xnba/elilo) | <-- initrd.img | HTTP server
| initrd | request kickstart file --> | HTTP server
| initrd | <-- kickstart file (/install/autoinst/<node>) | HTTP server
| initrd | request 2nd stage bootloader --> | DHCP server
| initrd | <-- 2nd stage bootloader (/install/<os>/x86_64/images/install.img) | HTTP server
| kickstart installer (install.img) | request installation pkgs --> | HTTP server
| kickstart installer (install.img) | <-- installation pkgs | HTTP server
| kickstart %post (post.xcat) | request postscripts --> | HTTP server
| kickstart %post (post.xcat) | <-- postscripts (/install/postscripts/*) | HTTP server
| kickstart %post (post.xcat) | execute the postscripts <--> | xCAT server
| xCAT postscript (for Power only) | set node to boot from local disk
| updateflag.awk | configure bootloader configuration to boot node from hd --> | xCAT server
| kickstart installer (install.img) | reboot node
| PXE | DHCP request --> | DHCP server
| PXE | <-- IP configuration | DHCP server
| PXE | <-- TFTP server IP address | DHCP server
| PXE | <-- bootfile name (xnba.kpxe) | DHCP server
| PXE | request for bootloader (xnba.kpxe) --> | TFTP server
| PXE | <-- bootloader executable (xnba.kpxe) | TFTP server
| bootloader xnba.kpxe | request bootloader configuration --> | TFTP server
| bootloader xnba.kpxe | <-- bootloader configuration (/tftpboot/xcat/xnba/nodes/<node>)(localboot) | TFTPserver
| boot from local disk
| /etc/init.d/xcatpostinit1 | execute /opt/xcat/xcatinstallpost
| /opt/xcat/xcatinstallpost | set "REBOOT=TRUE" in /opt/xcat/xcatinfo
| /opt/xcat/xcatinstallpost | execute mypostscript.post in /xcatpost
| mypostscript.post | execute postbootscripts in /xcatpost
| updateflag.awk | update node status to booted --> | xCAT server

<!---
end_xcat_table
-->

### Network Installation of a x86_64 Stateful Node using Autoyast

<!---
begin_xcat_table;
numcols=3;
colwidths=20,30,20;
-->

| Booting Node | Network Transfer | Management Node
---------------|------------------|-----------------
| PXE ROM | DHCP request --> | DHCP server
| PXE ROM | <-- IP configuration | DHCP server
| PXE ROM | <-- TFTP server IP address | DHCP server
| PXE ROM | <-- bootfile name | DHCP server
| PXE ROM | request for bootloader --> | TFTP server
| PXE ROM | <-- bootloader executable (xnba) | TFTP server
| bootloader (xnba.kpxe/xnba.efi) | DHCP request --> | DHCP server
| bootloader (xnba.kpxe/xnba.efi) | <-- bootloader config URL | DHCP server
| bootloader (xnba.kpxe/xnba.efi) | request bootloader configuration --> | HTTP server
| bootloader (xnba.kpxe/xnba.efi) | <-- bootloader configuration | HTTP server
| UEFI(xnba.efi) only: bootloader | request elilo (elilo-x64.efi) --> | HTTP server
| UEFI(xnba.efi) only: bootloader | <-- elilo (/tftpboot/xcat/elilo-x64.efi) | HTTP server
| UEFI(xnba.efi) only: bootloader | request elilo configuration --> | HTTP server
| UEFI(xnba.efi) only: bootloader | <-- configuration(/tftpboot/xcat/xnba/nodes/<node>.elilo) | HTTP server
| bootloader (xnba/elilo) | request for linux kernel --> | HTTP server
| bootloader (xnba/elilo) | <-- linux kernel | HTTP server
| bootloader (xnba/elilo) | request for initrd --> | HTTP server
| bootloader (xnba/elilo) | <-- initrd | HTTP server
| initrd | request node configuration file (autoinst) --> | HTTP server
| initrd | <-- configuration file | HTTP server
| initrd | request 2nd stage bootloader (install.img) --> | DHCP server
| initrd | <-- 2nd stage bootloader | HTTP server
| installer (install.img) | request installation pkgs --> | HTTP server
| installer | <-- installation pkgs | HTTP server
| installer | set node to boot from local disk |
| reboot (sles10 only) | boot from local disk directly |
| installer postscripts | request postscripts --> | xCAT server
| installer postscripts | <-- postscripts | xCAT server
| installer postscripts | execute the postscripts <--> | xCAT server
| reboot | boot from local disk directly |
| /etc/init.d/xcatpostinit1 | execute /opt/xcat/xcatinstallpost |
| /opt/xcat/xcatinstallpost | set "REBOOT=TRUE" in /opt/xcat/xcatinfo |
| /opt/xcat/xcatinstallpost | execute mypostscript.post in /xcatpost |
| mypostscript.post | execute postbootscripts in /xcatpost |
| updateflag.awk | update node status to booted --> | xCAT server

<!---
end_xcat_table
-->

### Network Boot of a x86_64 Stateless (RAMdisk) Node

<!---
begin_xcat_table;
numcols=3;
colwidths=20,30,20;
-->

| Booting Node | Network Transfer | Management Node
---------------|------------------|-----------------
| PXE ROM | DHCP request --> | DHCP server
| PXE ROM | <-- IP configuration | DHCP server
| PXE ROM | <-- TFTP server IP address | DHCP server
| PXE ROM | <-- bootfile name | DHCP server
| PXE ROM | request for bootloader --> | TFTP server
| PXE ROM | <-- bootloader executable (xnba.kpxe or xnba.efi) | TFTP server
| bootloader | request bootloader configuration --> | HTTP server
| bootloader | <-- bootloader configuration | HTTP server
| bootloader | request for linux kernel --> | HTTP server
| bootloader | <-- linux kernel | HTTP server
| bootloader | request for initial ramdisk --> | HTTP server
| bootloader | <-- initial ramdisk (initrd-stateless.gz) | HTTP server
| initrd | request for root image --> | HTTP server
| initrd | <-- root image (rootimg.gz) | HTTP server
| initrd | <-- switch to root file system |
| rootfs | boot up image |
| rootfs | xcatpostinit |
| xcatpostinit | xcatdsklspost |
| xcatdsklspost | request postscripts --> | HTTP server
| xcatdsklspost | <-- postscripts | HTTP server
| xcatdsklspost | request node postscript list --> | HTTP or xCAT server
| xcatdsklspost | <-- node postscript list | HTTP or xCAT server
| xcatdsklspost | execute the postscripts |
| xcatdsklspost | execute the post BOOT scripts |
| xcatdsklspost | update node status --> | xCAT server

<!---
end_xcat_table
-->

### Network Boot of a Statelite (NFS root) Node

<!---
begin_xcat_table;
numcols=3;
colwidths=20,30,20;
-->

| Booting Node | Network Transfer | Management Node
---------------|------------------|-----------------
| PXE ROM | DHCP request --> | DHCP server
| PXE ROM | <-- IP configuration | DHCP server
| PXE ROM | <-- TFTP server IP address | DHCP server
| PXE ROM | <-- bootfile name | DHCP server
| PXE ROM | request for bootloader --> | TFTP server
| PXE ROM | <-- bootloader executable | TFTP server
| bootloader | request bootloader configuration --> | HTTP server
| bootloader | <-- bootloader configuration | HTTP server
| bootloader | request for linux kernel -->| HTTP server
| bootloader | <-- linux kernel | HTTP server
| bootloader | request for initial ramdisk --> | HTTP server
| bootloader | <-- initial ramdisk | HTTP server
| initrd | <-- mount root file system | NFS server
| initrd | <-- mount persistent directories | NFS server
| initrd | <-- Get entries from litefile and litetree tables | xCAT server
| initrd | mount litetree directories --> | NFS server
| initrd |  configure lite files (do local bind mount or link) | NFS server
| initrd | <-- switch to root file system |
| installer postscripts | request postscripts --> | xCAT server
| installer postscripts | <-- postscripts | xCAT server
| installer postscripts | execute the postscripts <--> | xCAT server
| installer postscripts | execute the post BOOT scripts <--> | xCAT server
| | update node status --> | xCAT server

<!---
end_xcat_table
-->

### Network Deployment Diskful Windows Compute Node Using WinPE
NOTE: The deployment process could use proxydhcp or not. If using proxydhcp, ignore the 'NO Proxydhcp Only' part. Otherwise ignore the 'Proxydhcp Only' part.
NOTE: The compute node could boot in BIOS or UEFI mode. If booting in BIOS mode, ignore the 'UEFI Only' part. Otherwise ignore the 'BIOS Only' part.

<!---
begin_xcat_table;
numcols=3;
colwidths=20,30,20;
-->

| Booting Node | Network Transfer | Management Node
---------------|------------------|-----------------
| PXE ROM | DHCP request -> | DHCP server
| PXE ROM | <-- IP configuration | DHCP server
| PXE ROM | <-- TFTP server IP address | DHCP server
| PXE ROM (NO Proxydhcp Only) | <-- bootfile name (xNBA) | DHCP server
| PXE ROM (NO Proxydhcp Only) | request for bootloader --> | TFTP server
| PXE ROM (NO Proxydhcp Only) | <-- bootloader executable | TFTP server
| bootloader (NO Proxydhcp Only) | request bootloader configuration --> | HTTP server
| bootloader (NO Proxydhcp Only) | <-- bootloader configuration | HTTP server
| PXE ROM (Proxydhcp Only) | Proxydhcp configuration --> | Proxydhcp server
| PXE ROM (Proxydhcp Only) | <-- Proxydhcp configuration | Proxydhcp server
| bootloader (BIOS Only) | request for pxeboot.0 --> | HTTP server
| bootloader (BIOS Only) | <-- pxeboot.0 | HTTP server
| pxeboot.0 (BIOS Only) | request for bootmgr.exe --> | TFTP server
| pxeboot.0 (BIOS Only) | <-- bootmgr.exe | TFTP server
| bootmgr.exe (BIOS Only) | request for BCD --> | TFTP server
| bootmgr.exe (BIOS Only) | <-- BCD | TFTP server
| bootmgr.exe (BIOS Only) | request for WinPE--> | TFTP server
| bootmgr.exe (BIOS Only) | <-- WinPE| TFTP server
| bootloader (UEFI Only) | request for bootmgfw.efi --> | TFTP server
| bootloader (UEFI Only) | <-- bootmgfw.efi | TFTP server
| bootmgfw.efi (UEFI Only) | request for BCD --> | TFTP server
| bootmgfw.efi (UEFI Only) | <-- BCD | TFTP server
| bootmgfw.efi (UEFI Only) | request for WinPE--> | TFTP server
| bootmgfw.efi (UEFI Only) | <-- WinPE | TFTP server
| WinPE | Run startnet.cmd (Mount MN:/install to I:) |
| startnet.cmd | Get autoscript.cmd from I:&#92;autoinst |
| autoscript.cmd | Run fixupunattend.vbs to update unattend.xml (disk partition) |
| autoscript.cmd | Run Windows setup (deployment) from I:\<win ver>&#92;arch&#92;setup |
| autoscript.cmd | Get the postscripts and postbootscripts |
| WinPE | Configure nics (Through unattend.xml) |
| WinPE | Run postscripts (Through unattend.xml) |
| Reboot | |
| Boot from hard disk | |
| Installed Windows System | Run post boot scripts |

<!---
end_xcat_table
-->



## **Appendix A: Network Table Setup Example**

[[img src=Networks_setup.png]]

And the following table shows all network IP addresses of the cluster:




Network Table

<!---
begin_xcat_table;
numcols=3;
colwidths=20,30,20;
-->

| Machine name  | IP Address | Alias
----------------|------------|------
| managementnode.pub.site.net | 10.0.12.53 |  managementnode.site.net
| managementnode.priv.site.net | 92.168.1.10 |
| node01.pub.site.net | 10.0.12.61 |
| node02.pub.site.net | 10.0.12.62 |
| node01.infiniband.site.net | 10.0.6.236 |
| node02.infiniband.site.net | 10.0.6.237 |
| node01.10g.site.net |10.0.17.14 | node01.site.net
| node02.10g.site.net | 10.0.17.15 | node02.site.net
| node01.priv.site.net | 192.168.1.21 |
| node02.priv.site.net| 192.168.1.22 |

<!---
end_xcat_table
-->





All networks in the cluster must be defined in the networks table which can be modified with the command chtab,chdef or with the command tabedit .

The xCAT 2 installation ran the command makenetworks which created the following entry:

~~~~
    # tabdump networks
    #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,  -
    logservers,dynamicrange,nodehostname,comments,disable
    "10_0_12_0-255_255_255_0","192.168.1.0","255.255.255.0","eth1  -
    ",,,"192.168.1.10","10.0.12.10,10.0.17.10",,,,,,
    "192_168_1_0-255_255_255_0,"10.0.12.0","255.255.255.0","eth0  -
    ",,,"10.0.12.53","10.0.12.10,10.0.17.10",,,,,,
~~~~


. Update the private network of this table as follow:

~~~~
    # chdef -t network -o "pvtnet" net=192.168.1.0 mask=255.255.255.0 mgtifname=eth0\
    dhcpserver=192.168.1.10 tftpserver=192.168.1.10\
    nameservers=10.0.12.10,10.0.17.10\
    dynamicrange=192.168.1.21-192.168.1.22
~~~~

. Disable the entry for the public network:

~~~~
    # chtab net=10.0.12.0 networks.disable=1
    # tabdump networks
    #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,  -
    logservers,dynamicrange,nodehostname,comments,disable
    "10_0_12_0-255_255_255_0","10.0.12.0","255.255.255.0","eth1",,,\
    "10.0.12.53","10.0.12.10,10.0.17.10",,,,,,"1"
    "pvtnet","192.168.1.0","255.255.255.0","eth0",,\
    "192.168.1.10","192.168.1.10","10.0.12.10,10.0.17.10",,,"192.168.1.21-19
~~~~




## **Appendix B: Migrate your Management Node to a new Service Pack of Linux**

If you need to migrate your xCAT Management Node with a new SP level of Linux, for example rhels6.1 to rhels6.2 you should as a precautionary measure:

  * Backup database and save critical files to be used if needed to reference or restore using xcatsnap. Move the xcatsnap log and *gz file off the Management Node.
  * Backup images and custom data in /install and move off the Management Node.
  * service xcatd stop
  * service xcatd stop on any service nodes
  * Migrate to the new SP level of Linux.
  * service xcatd start

If you have any Service Nodes:

  * Migrate to the new SP level of linux and reinstall the servicenode with xCAT following normal procedures.
  * service xcatd start


The documentation

[Setting_Up_a_Linux_xCAT_Mgmt_Node#Appendix_D:_Upgrade_your_Management_Node_to_a_new_Service_Pack_of_Linux](Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-d-upgrade-your-management-node-to-a-new-service-pack-of-linux)
gives a sample procedure on how to update the management node or service nodes to a new service pack of Linux.

## **Appendix C: Install your Management Node to a new Release of Linux**

First backup critical xCAT data to another server so it will not be loss during OS install.

  * Back up the xcat database using xcatsnap, important config files and other system config files for reference and for restore later. Prune some of the larger tables:

~~~~
    * tabprune eventlog -a
    * tabprune auditlog -a
    * tabprune isnm_perf -a (Power 775 only)
    * tabprune isnm_perf_sum -a (Power 775 only)
    * Run xcatsnap ( will capture database, config files) and copy to another host. By default it will create in /tmp/xcatsnap two files, for example:
    * xcatsnap.hpcrhmn.10110922.log
    * xcatsnap.hpcrhmn.10110922.tar.gz
    * Back up from /install directory, all images, custom setup data that you want to save. and move to another server. xcatsnap will not backup images.

~~~~

After the OS install:

  * Proceed to to setup the xCAT MN as a new xCAT MN using the instructions in this document.

