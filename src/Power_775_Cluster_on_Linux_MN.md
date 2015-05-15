<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Obtain additional packages for HFI network](#obtain-additional-packages-for-hfi-network)
- [Additional configuration for Power 775](#additional-configuration-for-power-775)
- [Install LoadLeveler](#install-loadleveler)
  - [**Initialize the LoadLeveler database configuration**](#initialize-the-loadleveler-database-configuration)
- [**Install Teal**](#install-teal)
- [**Install ISNM**](#install-isnm)
  - [**Install ISNM prerequisite software**](#install-isnm-prerequisite-software)
- [Discover and define hardware components](#discover-and-define-hardware-components)
- [Install and Configure ISNM](#install-and-configure-isnm)
  - [**Check the hardware component and site definitions.**](#check-the-hardware-component-and-site-definitions)
  - [**Hardware server connections**](#hardware-server-connections)
  - [** Start CNMD and setup Master ISR ID&nbsp;:**](#-start-cnmd-and-setup-master-isr-id&nbsp)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

If not using Power 775 Clusters, skip this section. 

This section describes the additional setup required for the Power 775 support. This includes the setup of the cluster hardware components and the installation of TEAL, ISNM, and LoadLeveler on the xCAT management node. TEAL, ISNM and LoadLeveler have dependencies on each other so all three must be installed. 


### Obtain additional packages for HFI network

To work with HFI network in Power 775 clusters, the following RPMs and scripts must be obtained from IBM and put on the xCAT MN in the suggested directories. These packages and files should exist as part of the IBM LTC RH6 customized kernel: 
    
    /hfi/dd/kernel-2.6.32-*.ppc64.rpm
    /hfi/dd/kernel-headers-2.6.32-*.ppc64.rpm
    /hfi/dd/hfi_util-*.el6.ppc64.rpm
    /hfi/dd/hfi_ndai-*.el6.ppc64.rpm
    
    
    /hfi/dhcp/net-tools-*.el6.ppc64.rpm
    /hfi/dhcp/dhcp-*.el6.ppc64.rpm
    /hfi/dhcp/dhclient-*.el6.ppc64.rpm
    

### Additional configuration for Power 775

  * Increase /boot filesystem size for service nodes 

A customized kernel is required on service nodes to work with the HFI network. Since both the base and customized kernels will exist on the service nodes, the /boot filesystem will need be increased from the standard default when installing a service node. 

    Note, increasing /boot is a workaround for using the customized kernel. After this kernel is accepted by the Linux Kernel community, only one kernel will be required on the service node, and this step will no longer be needed. 

    Copy the service node Kickstart install template provided by xCAT to a custom location. For example: 
    
     cp /opt/xcat/share/xcat/install/rh/service.rhels6.ppc64.tmpl /install/custom/install/rh
    

Edit the copied file and change the line: 
    
     # From:
         part /boot --size 50 --fstype ext4&lt;/pre&gt;
     # To:
         part /boot --size 200 --fstype ext4&lt;/pre&gt;
    

### Install LoadLeveler

This section lists a quick summary of steps required to install LoadLeveler on your xCAT management node. For full instructions, please refer to the following documentation for setting up LL in an HPC cluster: [IBM_HPC_Stack_in_an_xCAT_Cluster] 

  * Create the loadl group and userid: 
    
      groupadd loadl
      useradd  -g loadl  -d /&lt;user_home&gt;/loadl loadl
    

  * Download the LoadLeveler packages to the xCAT management node and place in a directory such as: 
    
    /install/post/otherpkgs/rhels6/ppc64/loadl 
    

  * Make sure the following packages are installed on your management node: 

     compat-libstdc++-33.ppc64 
     libXmu.ppc64 
     libXtst.ppc64 
     libXp.ppc64 
     libXScrnSaver.ppc64 

  * Install the LoadLeveler license rpm: 
    
      cd /install/post/otherpkgs/rhels6/ppc64/loadl
      rpm -Uvh ./LoadL-full-license*.rpm
    

  * Accept the LoadLeveler license and install the product rpms: 
    
      /opt/ibmll/LoadL/sbin/install_ll -y -d .
    

Note: The LoadLeveler.scheduler fileset must be installed before installing teal-ll. 

#### **Initialize the LoadLeveler database configuration**

Copy and edit the sample files LoadL_config.l and LoadL_admin.l in /opt/ibmll/LoadL/full/samples with site-specific configuration, such as machine_groups or regions. 

Then initialize using these files and your cluster configuration file&nbsp;: 
    
    llconfig -i -t &lt;cluster_configuration_file&gt;
    

### **Install Teal**

Download the Teal prerequisite rpm packages and the Teal product rpms to your xCAT management. The Teal product does have prerequisites on the LoadL resource manager. Place the packages in a directory such as: 
    
    /install/post/otherpkgs/rhels6/ppc64/teal
    

The Teal prerequisites are: 
    
     gdbm-1.8.3-5
     readline-4.3-2
     python-2.6.2-2
     pyodbc-2.1.7-1   ***  this is in the latest xCAT deps package
    

Other than pyodbc, these rpms were most likely installed with your base RedHat installation. If these rpms are not installed, run a command similar to the following to install: 
    
     yum install gdbm.ppc64 readline.ppc64 python.ppc64 
    

The Teal rpms for the xCAT EMS are: 
    
    teal-base-1.1.0.0-1.ppc64.rpm -used with base Teal support 
    teal-ll-1.1.0.0-1.ppc64.rpm -used with LL teal 
    teal-sfp-1.1.0.0-1.ppc64.rpm -used with HMC Service focal point 
    teal-isnm-1.1.0.0-1.ppc64.rpm -used with isnm Teal
    teal-pnsd-1.1.0.0-1.ppc64.rpm -used with PE  pnsd teal 
    

There are other Teal rpms for GPFS that will be required on the Power 775 cluster. 
    
    teal-gpfs-1.1.0.0-1.ppc64.rpm
    teal-gpfs-sn-1.1.0.0-1.ppc64.rpm   
    

To install: 
    
     yum install pyodbc
     cd /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/teal
     rpm -Uvh ./teal*.rpm
    

Teal tables should only be viewed using xCAT database commands (e.g. tabedit, tabdump). Changes should be made using the following teal commands: 

tlchalert&nbsp;: close an alert that has been resolved. It will also close all duplicate alerts that have been reported. 
tlrmalert&nbsp;: remove select/all alerts that have been closed that are not associated with other alerts. 
tlrmevent&nbsp;: remove select/all events that are not associated with an alert that is still being saved in the alert log. 

Typically a user will do these steps to manage Teal alerts and maintain the Teal tables: 
    
    Resolve the active/open alerts and then close them with tlchalert
    tlrmalert --older-than &lt;timestamp&gt; to remove the alerts that are no longer required
    tlrmevent --older-than &lt;timestamp&gt; to remove the events that are no longer required
    

For more information on Teal please refer to the Teal documentation. (ptr) 

### **Install ISNM**

Download the ISNM packages to the xCAT MN and place them in a directory such as 
    
    /install/post/otherpkgs/&lt;os&gt;/ppc64/isnm
    

#### **Install ISNM prerequisite software**

  * Install RSCT 
    
     rpm –ivh rsct.core.utils-3.1.0.2-10266.ppc.rpm rsct.core-3.1.0.2-10266.ppc.rpm  src-1.3.1.1-10266.ppc.rpm
    

Obtain RSCT from: 
    
    https://www14.software.ibm.com/webapp/iwm/web/preLogin.do?lang=en_US&source=stg-rmc
    

  * Install unixODBC and pam (32 and 64 bit version) 

ISNM requires 32 bit rpms for the unixODBC and pam installed on xCAT MN. For RHEL 6 (ppc64): You will need to validate that both the pam-1.1.1-4.el6.ppc64 and the pam-1.1.1-4.el6.ppc rpm packages are installed on the xCAT MN. The RH6 yum package may install or update the 64 bit packages only. You manually need to install the 32 bit pam-1.1.1-4.el6.ppc rpm package. 

You then need to validate that both unixODBC-2.2.14-11.el6.ppc64 and unixODBC-2.2.14-11.el6.ppc rpms are installed on the xCAT. Make sure that unixODBC-2.2.14-11.el6.ppc64 rpm is installed first through yum, and then manually install the 32 bit unixODBC-2.2.14-11.el6.ppc rpm. Some files such as isql, odbc_config, and odbcinst, will be overwritten by the second rpm install. 

There is one hdwr_svr lib that is not in the package that must be manually placed in /usr/lib on the Managment Node. ( This will be fixed soon). Right now the lib is in the following backing tree: 
    
    /project/spreldenali/build/rdenali1107b/export/ppc64_redhat_6.0.0/usr/lib/libnetchmcx.so
    cp -p libnetchmcx.so /usr/lib
    

  


### Discover and define hardware components

The System P hardware components must be discovered, configured and defined in the xCAT database. If you haven't done so already, follow the steps in [XCAT_Power_775_Hardware_Management]. 

### Install and Configure ISNM

Install the ISNM package: 
    
    cd /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/isnm 
    rpm -Uvh ./isnm-cnm*.rpm
    

Note: you should have already install hardware server as part of xCAT's DFM. 
    
    **NOTE**
    There should be pointer to the ISNM documentation in the High Performance Clustering 
    using 9125-F2C  that describes   HFI-ISR network for Power 775  cluster.
    This would be a good place to describe how the HFI is being used with xCAT.
    We can provide a pointer where the admin should locate the HFI device drivers. 
    If you are only trying to communicate over hfi from one octant to another in the same CEC,
    the CNM daemon must be running on the EMS.  and the master ISR ID must be loaded to the CEC. 
    If you are communicating over the HFI from one CEC to another, the HFI cable links 
    (Dlinks and/or LR links) must be physically configured between the Power 775 CECs.  
    
    

#### **Check the hardware component and site definitions.**
    
    **NOTE:** Check for what????
    

The CNM HFI network requires that the Power 775 frame and cecs be physically installed and properly defined in the xCAT DataBase. This activity is defined in the xCAT Power 775 Hardware Management guide. The CNM HFI network requires the following data to be defined in the xCAT DB. 

Check that the correct Topology has been set in the site table. The topology definition is based on the the number of CECs and type of HFI network configured for your Power 775 cluster. 
    
     lsdef -t site -l | grep topology   (should be one of supported configs 8D, 32D, 128D)
       if there is no topology value found you can set the value with xCAT chdef  command
     chdef -t site  topology=32D
    

Check to make sure that the frame and the CECs node objects have the proper definitions. The frame must be connected to the EMS with DFM, and the frame number is assigned in the "id" attribute. The lsdef frame will list all the frame objects in your cluster, check that each frame has the frame number defined id=&lt;frame #&gt; . You should execute xCAT command "rspconfig" to set the frame number. 
    
     lsdef  frame   (check id attribute for each frame object&gt;
     rspconfig frame17 frame=17  (sets "id" to 17 for frame17 node, and will update frame number to 17 in BPA  
    

  
Check to make sure that the Power 775 CECs have the proper parent associations defined in the xCAT DB. 
    
     - lpars/octants should have the proper CEC node as the assigned parent attribute.
     - fsp node should have the proper CEC node as the assigned parent attribute
     - cec nodes should have the proper Frame node as the assigned parent attribute
     - bpa nodes should have the proper Frame node as the assigned parent attribute
     - frame nodes will have a building block number or will be empty 
    

Check to make sure that the cec node objects have the proper "supernode" attribute defined. The supernode will specify the HFI configuration being used by the cec. You should also make sure the cage id is properly defined where the "id" attribute matches the cage position for the CEC node. The CNM daemon and configuration commands will setup the Master ISR identifier for each cec. This will allow the HFI communications to work between the Power 775 cluster. 
    
     lsdef  cec  (check supernode and id attribute for each cec object)
     chdef  f17c01  supernode=0,0   (will set HFI supernode setting)    
    

  


#### **Hardware server connections**

The CNM hardware server daemon will be started as part of the Power 775 Hardware setup working with DFM. The hardware server daemon is used by both xCAT and CNM to track the hardware connections between the xCAT EMS and the Frame/BPA and CEC/FSPs. There are two different connections "tooltype" used with the hardware server daemon and the xCAT mkhwconn command. The tooltype "lpar' is used by the xCAT DFM support, and the tooltype "fnm" is used by the CNM support. 
    
    mkhwconn frame17 -T fnm   (will make the HW connection for the frame17  frame and cecs (drawers))
    

The hardware server daemon works with the /var/opt/isnm/hdwr_svr/data/HmcNetConfig file. The expectation is that HmcNetConfig file will get created as part of the first mkhwconn execution working with xCAT DFM . The CNM will add additional connections for the "fnm" HW connections. 

There are hardware server log files that are created and saved under /var/opt/isnm/hdwr_svr/log directory. If you have issues with hardware server daemon, you may want to check the recent "hdwr_svr.log.*" log files. If you need to take a hardware server daemon dump, you can execute "kill -USR1 &lt;hdwr_svr.pid&gt; (this will create the hdwr_svr dump file) 

  


#### ** Start CNMD and setup Master ISR ID&nbsp;:**

Once all the xCAT definitions are properly updated with CNM configuration data, It is time to start up the CNM daemon and load ounthe proper ISR data in the CECs. Make sure that all the CECs have been powered off prior to the initialization of the CNM daemon. This is necessary to setup the proper HFI configuration data in the Frame and CECs. You can execute the CNM command "chnwm" to activate or deactivate the CNM daemon for AIX EMS 
    
    /opt/isnm/cnm/bin/chnwm -d  (take down the CNM daemon)
    rpower cec  off             (power down all cecs)
    /opt/isnm/cnm/bin/chnwm -a   (activate the CNM daemon)
    

You can execute the Linux "service" command to activate or deactivite the CNM daemon for Linux EMS. 
    
    service cnmd stop     (take down the CNM daemon)
    rpower cec off        (power down all cecs)  
    service cnmd  start   (activate the CNM daemon) 
    

You can now load the HFI master ISR identifier on the Power 775 frame and cecs. This will be accomplished using the CNM command "chnwsvrconfig" . You will need to specify this command for each frame in you configuration. 
    
    /opt/isnm/cnm/bin/chnwsvrconfig  -f 17 -A   (will configure frame 17 and associated cecs withHFI data)
    

You can now verify that the CNM daemon and HFI configuration is working by executing the CNM command "nmcmd" to dump the drawer status information. This will list the current state of the drawers working with CNM. Please reference the HPC using the 9125-F2C guide for more detail about CNM commands, implementation, and debug. 
    
     /opt/isnm/cnm/bin/nmcmd -D -D 
     # nmcmd -D -D
     Frame 17  Cage 3 Supernode 0 Drawer 0 RUNTIME
     Frame 17  Cage 5 Supernode 0 Drawer 2 RUNTIME
     Frame 17  Cage 4 Supernode 0 Drawer 1 TERMINATE
    
