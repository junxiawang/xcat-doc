<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Save important xCAT and system data](#save-important-xcat-and-system-data)
- [Stop all user services across the cluster](#stop-all-user-services-across-the-cluster)
  - [Stop monitoring (if it is on)](#stop-monitoring-if-it-is-on)
  - [you must stop all applications that are accessing the database on the Service Nodes and the EMS.](#you-must-stop-all-applications-that-are-accessing-the-database-on-the-service-nodes-and-the-ems)
  - [Shut down GPFS across the cluster](#shut-down-gpfs-across-the-cluster)
  - [Lockout user logins](#lockout-user-logins)
  - [Stop xcatd on the service nodes](#stop-xcatd-on-the-service-nodes)
  - [Power off all the service nodes, compute nodes and other nodes](#power-off-all-the-service-nodes-compute-nodes-and-other-nodes)
- [Upgrade DB2 (Optional)](#upgrade-db2-optional)
  - [Install DB2 Fix Pack on EMS](#install-db2-fix-pack-on-ems)
  - [Install DB2 Fix Pack on Service Node (no need)](#install-db2-fix-pack-on-service-node-no-need)
- [Upgrade OS on EMS (Optional)](#upgrade-os-on-ems-optional)
- [Upgrade xCAT on EMS](#upgrade-xcat-on-ems)
  - [start DB2](#start-db2)
  - [untar the xcat-core and xcat-deps tar balls](#untar-the-xcat-core-and-xcat-deps-tar-balls)
  - [add the repo files in yum repository if not done before](#add-the-repo-files-in-yum-repository-if-not-done-before)
  - [upgrade xCAT](#upgrade-xcat)
- [Upgrade the DFM and hardware server](#upgrade-the-dfm-and-hardware-server)
- [Upgrade firmware](#upgrade-firmware)
- [Upgrade HPC Software on the EMS](#upgrade-hpc-software-on-the-ems)
  - [Upgrade Loadleveler](#upgrade-loadleveler)
  - [Upgrade TEAL](#upgrade-teal)
  - [Upgrade ISNM](#upgrade-isnm)
- [Prepare EMS to support new installs](#prepare-ems-to-support-new-installs)
- [Reinstall service nodes](#reinstall-service-nodes)
- [Reboot nodes](#reboot-nodes)
- [Start the user services across the cluster](#start-the-user-services-across-the-cluster)
  - [Start LoadLeveler (LL), GPFS, allow user logins, etc.](#start-loadleveler-ll-gpfs-allow-user-logins-etc)
  - [Restart monitoring](#restart-monitoring)
- [Upgrade the backup EMS](#upgrade-the-backup-ems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

**!!! This documentation is still under construction&nbsp;!!!**

This documentation describes a process for upgrading the software and firmware on a Linux Power775 Cluster.


## Save important xCAT and system data

A good way to do this is run xcatsnap. It will save the DB2 database, system files like /etc/hosts, /install/postscripts, etc. You may want to prune your eventlog, and auditlog to keep the size of the database backup small.

~~~~
     tabprune -a auditlog
     tabprine -a eventlog
~~~~


Create a directory that can hold 50G or more for xcatsnap. Then run:

~~~~
       xcatsnap -d <directory>
~~~~


It will create a compressed tar file. Save this file to to different system for reference later. Also save the following files that xCAT uses:

~~~~
       /etc/ssh/sshd_config
       /etc/exports
       /etc/httpd/conf.d/xcat.conf
~~~~
     (any other files that need to be checked?)


Save any other data you think is important from both ems and service nodes.




## Stop all user services across the cluster

### Stop monitoring (if it is on)

For TEAL, find all the alerts that are active

~~~~
     tllsalert
~~~~


For each alert fix and close the alerts (for posterity)

~~~~
     tlchalert -i <rec_id> -s close
~~~~


Backup the database tables (could be large) - creates a tltab*.tar file /opt/teal/sbin/tltab -p /tmp -d

For xCAT, list the monitoring plug-ins

~~~~
        monls
~~~~


For each monitoring plug-ins that are "monitored" run:

~~~~
         monstop <plug-in-name>
         monstop <plug-in-name> -r
~~~~


### you must stop all applications that are accessing the database on the Service Nodes and the EMS.

For service nodes

~~~~
       xdsh <service_node_group> llctl stop

~~~~

For EMS:

~~~~
        service cnmd stop
         service teal stop
~~~~


### Shut down GPFS across the cluster

~~~~
       xdsh <node_groups> mmdelcallback <name>  #Prevent flood of msg's when shutting down GPFS
       xdsh <compute_group> mmshutdown
       xdsh <gpfs_group> mmshutdown
~~~~


Note: these GPFS commands will take a long time to finish. Please be patient and let it finish. Do not Ctrl-C out. Otherwise you may corrupt the database

### Lockout user logins

### Stop xcatd on the service nodes

~~~~
       xdsh <service_node_group> "service xcatd stop"
~~~~


### Power off all the service nodes, compute nodes and other nodes

~~~~
       rpower <service_node_group> off
       rpower <compute_node_group> off
       rpower <login_node_group> off
       rpower <gpfs_node_group> off

~~~~




## Upgrade DB2 (Optional)

The details are documented in this url, but the basic instruction are in the next steps.
[Setting_Up_DB2_as_the_xCAT_DB/#appendix-binstalling-db2-fix-packs](Setting_Up_DB2_as_the_xCAT_DB/#appendix-binstalling-db2-fix-packs).


At this point you must stop xCAT on the EMS. All the the database access applications on the EMS must the stopped, TEAL, ISNM,LL,xCAT. The others were done in previous steps.

~~~~
      service xcatd stop
~~~~


### Install DB2 Fix Pack on EMS

1\. Get DB2 fix pack Use the HPC DVD supplied to you for the HPC DB2 licensed product.

2\. Check disk space

To install a Fix Pack during the process there will be two copies of the DB2 code in /opt so additional space is required: To update DB2 server code on the Management Node in /opt -- at least 3.5 gigabytes of free space.

3\. Stopping the DB2 Server

You need to stop the DB2 database on the EMS. Now stop DB2 database:

~~~~
       su - xcatdb
       db2 force applications all; db2 terminate;
       db2stop or db2stop force

~~~~

4\. Install the DB2 fix pack on the EMS Details on installing fix packs to DB2 can be found here, but below are the basic instructions:
[Setting_Up_DB2_as_the_xCAT_DB/#appendix-binstalling-db2-fix-packs](Setting_Up_DB2_as_the_xCAT_DB/#appendix-binstalling-db2-fix-packs).


5\. Prepare the DB2 code directory for install on the Service Nodes.

~~~~
     lsdef -t site db2installloc  (get the location of the DB2 install code directory)
~~~~

     Remove all the old DB2 files under &lt;installloc&gt;
       Copy DB2 tarball with new DB2 fix pack under &lt;db2installloc&gt;, unzip  and untar it.


Change directory to the location of the FixPack code which you extracted.

~~~~
         cd  <db2installloc>/wser
      ./installFixPack -b /opt/ibm/db2/V9.7
~~~~


If get an error, read the error log. May suggest you use

~~~~
       ./installFixPack -b /opt/ibm/db2/V9.7 -f db2lib
~~~~


5\. Restart the database

~~~~
       su - xcatdb
       db2start
       exit
~~~~

    Restart xCAT and run the following command to verify if the DB2 upgrade is successful or not:

~~~~
       service xcatd start
       tabdump site
       lsxcatd -a
~~~~





Now stop xcat, we will be upgrading the EMS to Redhat 6.1.

~~~~
       service xcatd stop
~~~~


### Install DB2 Fix Pack on Service Node (no need)

Since the service node will be reinstalled, so this step will be skipped. The upgrade to operating system and DB2 and all the HPC software and xCAT will be done during the reinstall.

## Upgrade OS on EMS (Optional)

The detailed procedure on updating the operating system on EMS can be found at

[Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-d-upgrade-your-management-node-to-a-new-service-pack-of-linux](Setting_Up_a_Linux_xCAT_Mgmt_Node/#appendix-d-upgrade-your-management-node-to-a-new-service-pack-of-linux)




## Upgrade xCAT on EMS

### start DB2

~~~~
       su - xcatdb
       db2start
       exit
~~~~


### untar the xcat-core and xcat-deps tar balls

~~~~
       tar xjvf xcat-core*.tar
       tar xjvf xcat-deps*.tar
~~~~


### add the repo files in yum repository if not done before

Move back any repo files in the /etc/yum.repos.d directory that you might have renamed in the previous step when upgrading RedHat.

Make sure the following repo files are correct.

~~~~
     cat /etc/yum.repos.d/xcat-core
     [xcat-core-local]
     name=local copy of xCAT core
     baseurl=file:/install/post/otherpkgs/rhels6.1/ppc64/xcat/xcat-core
     enabled=1
     gpgcheck=0
~~~~


~~~~
     cat /etc/yum.repos.d/xcat-deps
     [xcat-dep-local]
     name=local copy of xCAT deps
     baseurl=file:/install/post/otherpkgs/rhels6.1/ppc64/xcat/xcat-dep
     enabled=1
     gpgcheck=0
~~~~


### upgrade xCAT

~~~~
      yum clean metadata
      yum check-update
      yum update '*xCAT*'
~~~~


Verify xcat is running correctly, run:

~~~~
      lsxcatd -a
~~~~


## Upgrade the DFM and hardware server

Download DFM and Hardware Server packages from the Fix Central or use the DVD supplied.

DFM: http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm~ClusterSoftware&amp;product=ibm/Other+software/IBM+direct+FSP+management+plug-in+for+xCAT&amp;release=All&amp;platform=All&amp;function=all

HW server: http://www-933.ibm.com/support/fixcentral/swg/selectFixes?parent=ibm~ClusterSoftware&amp;product=ibm/Other+software/IBM+High+Performance+Computing+(HPC)+Hardware+Server&amp;release=All&amp;platform=All&amp;function=all

~~~~
      rpm -Uvh xCAT-dfm-*.ppc64.rpm ISNM-hdwr_svr-*.ppc64.rpm
~~~~


## Upgrade firmware

Do the necessary firmware upgrade for the BPAs, FSPs and HMCs. Here is the detailed instruction.
[XCAT_Power_775_Hardware_Management/#updating-the-bpa-and-fsp-firmware-using-xcat-dfm](XCAT_Power_775_Hardware_Management/#updating-the-bpa-and-fsp-firmware-using-xcat-dfm).



## Upgrade HPC Software on the EMS

### Upgrade Loadleveler

If LL is installed on EMS, upgrade the LL rpms following normal procedure.

Reference LoadLeveler documentation: [Tivoli Workload Scheduler LoadLeveler library](http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.loadl.doc/llbooks.html)

### Upgrade TEAL

Upgrade the TEAL rpms and start teal following normal procedure.

For teal information: https://sourceforge.net/apps/mediawiki/pyteal/index.php?title=Main_Page   (TBD)

### Upgrade ISNM

Upgrade the ISNM rpms and start cnmd following normal procedure

Reference ISNM configuration from P775 Guide: http://www.ibm.com/developerworks/wikis/download/attachments/162267485/p775_planning_installation_guide.rev1.2.pdf?version=1

## Prepare EMS to support new installs

1\. Setup repository for new operating system(Optional)

~~~~
       copycds <iso file name>
~~~~


2\. Copy HPC rpms to a new directory, like /install/post/otherpkgs/rhels6.2/ppc64/, run createrepo for each HPC sub-directory.

3\. Obtain the latest HFI kernel and device driver rpms and copy them to the following directories

~~~~
      /install/kernels/kernel-2.6.32-131.0.15.el6.20120106b2.ppc64.rpm
      /install/kernels/kernel-headers-2.6.32-131.0.15.el6.20120106b2.ppc64.rpm
      /install/hfi/dd/hfi_util-2.19-0.el6.ppc64.rpm
      /install/hfi/dd/hfi_ndai-1.7.3-0.el6.ppc64.rpm
      /install/hfi/dd/net-tools-1.60-102.el6.ppc64.rpm
      /install/hfi/dhcp/dhclient-hfi-4.2.1-2.P1.el6_2.ppc64.rpm
      /install/hfi/dhcp/dhcp-common-hfi-4.2.1-2.P1.el6_2.ppc64.rpm
      /install/hfi/dhcp/dhcp-hfi-4.2.1-2.P1.el6_2.ppc64.rpm
~~~~


Then run:

~~~~
      createrepo /install/kernels
      createrepo /install/hfi/dd
      createrepo /install/hfi/dhcp
~~~~


4\. Copy the xCAT core rpms and deps rpms to /install/post/otherpkgs/rhels6.x/ppc64/, untar them.

5\. If not already done, prepare the DB2 code directory for install on the Service Nodes.(Optional)

~~~~
     lsdef -t site db2installloc  (get the location of the DB2 install code directory)
~~~~


Remove all the old PTF 4 DB2 files under &lt;db2installloc&gt;

Copy DB2 tarball with fix pack 5 under &lt;db2installloc&gt;, uncompress and untar it.

6\. Change the os attribute to new operating system for all the nodes (Optional)

~~~~
        chdef service,compute,gpfs,login os=rhels6.2
~~~~


7\. Change some attributes for all the images for the new operating system: (Optional)

~~~~
        chdef -t osimage -o <image_name> \
            osvers=rhels6.2  \
            otherpkgdir=/install/post/otherpkgs/rhels6.2/ppc64/   \
            rootimgdir=/install/netboot/rhels6.2/ppc64/<imgname>  \
            kernelver=.2.6.32-131.0.15.el6.20120106b2.ppc64.

~~~~

8\. Verify the os image definitions are set to use all the correct files, directories, pkglists, etc. Change any other attributes as needed:

~~~~
     lsdef -t osimage -o <image_name> -l
~~~~


9\. Modify the HPC installation scripts to work with the new HPC software

## Reinstall service nodes

1\. Before starting the service node installation, make sure the osimage for service nodes have been updated correctly.

~~~~
       nodeset <service_node_group> osimage=<image_name>
       rpower <service_node_group>  off
       rpower <service_node_group>  on
~~~~


2\. After the installation, make sure xcatd and DB2 are running properly.

~~~~
           xdsh <service_node_group> lsxcatd -a |xcoll
~~~~


3\. Install HFI kernel and device drivers

~~~~
       xdsh <service_node_group> rpm -ivh /install/kernels/kernel-2.6.32-*.ppc64.rpm
       xdsh <service_node_group> rpm -ivh /install/kernels/kernel-headers-2.6.32-*.ppc64.rpm --force
       xdsh <service_node_group> rpm -ivh /install/hfi/dd/hfi_util-*.el6.ppc64.rpm
       xdsh <service_node_group> rpm -ivh /install/hfi/dd/hfi_ndai-*.el6.ppc64.rpm
       xdsh <service_node_group> rpm -ivh /install/hfi/dd/net-tools-*.el6.ppc64.rpm --force
       xdsh <service_node_group> rpm -ivh /install/hfi/dhcp/dhcp-common-hfi-4.2.1-2.P1.el6_2.ppc64.rpm --force
       xdsh <service_node_group> rpm -ivh /install/hfi/dhcp/dhclient-hfi-4.2.1-2.P1.el6_2.ppc64.rpm --force
       xdsh <service_node_group> rpm -ivh /install/hfi/dhcp/dhcp-hfi-4.2.1-2.P1.el6_2.ppc64.rpm --force
       xdsh <service_node_group> /sbin/new-kernel-pkg --mkinitrd --depmod --install  2.6.32-131.0.15.el6.20120106b2.ppc64
       xdsh <service_node_group> /sbin/new-kernel-pkg --rpmposttrans  2.6.32-131.0.15.el6.20120106b2.ppc64
~~~~


4\. Change yaboot to boot from customized kernel on all service nodes.
[Setting_Up_a_Linux_Hierarchical_Cluster/#change-yaboot-to-boot-from-customized-kernel](Setting_Up_a_Linux_Hierarchical_Cluster/#change-yaboot-to-boot-from-customized-kernel).

5\. Reboot the service nodes:

~~~~
      xdsh <service_node_group> reboot
~~~~


6\. After the service nodes are all up, configure the HFI interfaces:

~~~~
      updatenode <service_node_group> -P confighfi
~~~~


7\. Create GPFS gplbin rpm

Login in to one service node, create GPFS gplbin rpm and copy it to the correct /install/post/otherpkgs/... directory.

## Reboot nodes

Needs to regenerate the images because the OS level changes and new HPC software changes. Make sure get the new kernel and HFI driver. The following are just normal processes.

~~~~
       genimage <image_name>
       liteimg  <image_name>
       nodeset <compute_node_group> osimage=<image_name>
       rbootseq <compute_node_group> hfi
       rpower  <compute_node_group> off
       rpower  <compute_node_group> on
~~~~


Do the same for GPFS servers and login nodes.

## Start the user services across the cluster

### Start LoadLeveler (LL), GPFS, allow user logins, etc.

~~~~
       xdsh <gpfs_group> mmstartup
       xdsh <compute_group> mmstartup
       xdsh <node_groups> mmaddcallback <name>
~~~~


Note: these GPFS commands will take a long time to finish. Please be patient and let it finish. Do not Ctrl-C out. Otherwise you may corrupt the database

### Restart monitoring

If monitor the serviceable events on HMC

~~~~
     moncfg rmcmon <hmc_group> -r
     moncfg rmcmon <hmc_group>
~~~~


If monitor the PNSD

~~~~
     moncfg rmcmon <service_node_group> -r
     moncfg rmcmon <service_node_group>
     moncfg rmcmon <compute_node_group> -r
     moncfg rmcmon <compute_node_group>

~~~~

If monitor the GPFS

~~~~
     moncfg rmcmon <service_node_group> -r
     moncfg rmcmon <service_node_group>
~~~~


Start up RMC monitoring

~~~~
     monstart rmcmon
     monstart rmcmon -r
~~~~


Start up the GPFS monitoring

~~~~
          tlgpfschnode -C <cluster> -N <service_node_group> -e
~~~~


Make sure that the condition/responses are setup and running

~~~~
     lscondresp | grep Active
     "TealAnyNodeEventNotify"  "TealNotifyEventLogged" "c250mgrs21-pvt" "Active"  <plug-in>
        moncfg <plug-in>  <service_node_group>
        moncfg <plug-in>  <service_node_group>  -r
        moncfg <plug-in>  <compute_node_group>
        moncfg <plug-in>  <compute_node_group>  -r
        monstart <plug-in>
        monstart <plug-in> -r
~~~~


## Upgrade the backup EMS

Your backup EMS must also be upgraded, including the operating system, DB2, xCAT and HPC software. After you have stabilized the Primary EMS and cluster, you should proceed to follow these steps to upgrade the backup EMS. The steps you will have to do are very similar to the steps that you just did on the Primary EMS.


