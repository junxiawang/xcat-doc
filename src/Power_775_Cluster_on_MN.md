<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Install LoadLeveler](#install-loadleveler)
- [**Install Teal**](#install-teal)
- [**Install ISNM**](#install-isnm)
- [Downloading and Installing DFM](#downloading-and-installing-dfm)
- [Discover and define hardware components](#discover-and-define-hardware-components)
- [Configure ISNM](#configure-isnm)
  - [**Check the hardware component and site definitions.**](#check-the-hardware-component-and-site-definitions)
  - [**Hardware server connections**](#hardware-server-connections)
  - [** Start CNMD and setup Master ISR ID&nbsp;:**](#-start-cnmd-and-setup-master-isr-id&nbsp)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

If not using Power 775 Clusters, skip this section. 

This section describes the additional setup required for the Power 775 support. This includes the setup of the cluster hardware components and the installation of TEAL, ISNM, and LoadLeveler on the xCAT management node. TEAL, ISNM and LoadLeveler have dependencies on each other so all three must be installed. 


### Install LoadLeveler

**Note**: The LoadLeveler.scheduler fileset must be installed before installing teal-ll. 

Refer to the following documentation for setting up LL in an HPC cluster: 

  * [Setting_up_LoadLeveler_in_a_Stateful_Cluster] 
  * [Setting_up_LoadLeveler_in_a_Statelite_or_Stateless_Cluster] 

### **Install Teal**

Download the Teal prerequisite rpm packages and the Teal installp file sets to your xCAT management. The packages should be available from Teal website: http://sourceforge.net/projects/pyteal/files/ 

Place the packages in a directory such as /install/post/otherpkgs/aix/ppc64/teal. 

The Teal prerequisite packages are: 
    
    gdbm-1.8.3-5.aix5.2.ppc.rpm   
    readline-4.3-2.aix5.1.ppc.rpm
    pyodbc-2.1.7-1.aix6.1.ppc.rpm   ***  this is in the latest xCAT deps packaging
    python-2.6.2-2.aix5.3.ppc.rpm
    

To install the rpms run a command similar to the following. 
    
    rpm -Uvh ./gdbm-1.8.3-5.aix5.2* readline-4.3-2.aix5.1* pyodbc-2.1.7-1.aix6.1*
    python-2.6.2-2.aix5.3
    

The Teal installp file sets are: 
    
    teal.base   -used with base Teal support   
    teal.isnm   -used with isnm Teal
    teal.ll     -used with LL teal 
    teal.pnsd   -used with PE  pnsd teal 
    teal.sfp    -used with HMC Service focal point 
    

There are other Teal packages for GPFS that will be required on the Power 775 cluster. GPFS is not required on the EMS, but will be required on GPFS I/O server nodes The teal.gpfs-sn package has dependencies for gpfs.base and libmmantras.so. 
    
    teal.gpfs     -used with base GPFS 
    teal.gpfs-sn  -used with GPFS server nodes   
    

To install: 
    
    cd /install/post/otherpkgs/aix/ppc64/teal
    inutoc .
    installp -aXgd . teal 
    

Teal installs their commands in the /opt/teal/bin directory and are used to track events and alerts in selected tables: For more information on Teal please refer to the Teal documentation. (Need to add pointer when available) 

Teal tables should viewed using tllsalert and tllsevent commands, or xCAT database commands (e.g. tabedit, tabdump). If there are changes to be made for Teal tables, they should be made only using the following teal commands: 
    
    tlchalert - this command will allow the user to close an alert that has been resolved. It will also close all duplicate
                alerts that have been reported as well
    tlrmalert - this will remove select/all alerts that have been closed that are not assocated with other alerts
    tlrmevent - this will remove select/all events not associated with an alert that is still being saved in the alert log
    

  
Typically a user will do these steps to manage Teal alerts and maintain the Teal tables: 
    
    Resolve the active/open alerts and then remove them with tlchalert
    /opt/teal/bin/tlrmalert --older-than &lt;timestamp&gt; to remove the alerts that are no longer required
    /opt/teal/bin/tlrmevent --older-than &lt;timestamp&gt; to remove the events that are no longer required
    

### **Install ISNM**

The following ISNM packages need to be downloaded and installed on the xCAT MN: 
    
    isnm.cnm      
    isnm.hdwr_svr
    

Download the ISNM packages to the xCAT MN, and place them in a directory such as 
    
    /install/post/otherpkgs/aix/ppc64/isnm
    

Install the hdwr_svr and ISNM installp packages. 
    
    cd /install/post/otherpkgs/aix/ppc64/isnm
    inutoc .
    installp -acXYFd . isnm.hdwr_svr
    installp -acXYFd . isnm.cnm
    

### Downloading and Installing DFM

For most operations, the Power 775 is managed directly by xCAT, not using the HMC. This requires the **new xCAT Direct FSP Management plugin** (xCAT-dfm-*.ppc64.rpm), which is not part of the core xCAT open source, but is available as a free download from IBM. You must download this and install it on your xCAT management node (and possibly on your service nodes, depending on your configuration) before proceeding with this document. 

Download DFM and the pre-requisite hardware server package from [Fix Central](http://www-933.ibm.com/support/fixcentral/) (need more specific instructions here when it GAs): 

Once you have downloaded these packages, then install DFM package on the xCAT MN: 
    
    installp -d . -agQXY isnm.hdwr_svr
    rpm –Uvh xCAT-dfm-2.6.0*.aix5.3.ppc.rpm
    

### Discover and define hardware components

The System P hardware components must be discovered, configured and defined in the xCAT database. 

Refer to the following doc [XCAT_Power_775_Hardware_Management] for general information on how to: 

  * connect the System P hardware Frames, CECs, and HMCs to the xCAT management node. 
  * setup DHCP for the hardeware service network. 
  * discover HMC, Frame/BPA, and CEC/FSP. 
  * setup the xCAT database with hardware node definitions. 
  * Apply firmware updates for System P Hardware 

Refer to the following doc [XCAT_Power_775_Hardware_Management] for implementation being used to support the Power 775 clusters. 

### Configure ISNM

#### **Check the hardware component and site definitions.**

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
    

Check to make sure that the cec node objects have the proper "supernode" attribute defined. The supernode will specify the HFI configuration being used by the cec. You should also make sure the cage id is properly defined where the "id" attribute matches the cage position for the cec node. The CNM daemon and configuration commands will setup the Master ISR identifier for each cec. This will allow the HFI communications to work between the Power 775 cluster. 
    
     lsdef  cec  (check supernode and id attribute for each cec object)
     chdef  f17c01  supernode=0,0   (will set HFI supernode setting)
    

#### **Hardware server connections**

The CNM hardware server daemon will be started as part of the Power 775 Hardware setup working with DFM. The hardware server daemon is used by both xCAT and CNM to track the hardware connections between the xCAT EMS and the Frame/BPA and CEC/FSPs. There are two different connections "tooltype" used with the hardware server daemon and the xCAT mkhwconn command. The tooltype "lpar' is used by the xCAT DFM support, and the tooltype "fnm" is used by the CNM support. 
    
    mkhwconn frame17 -t -T fnm   (will make the HW connection for the frame17 (frame) and cecs (drawers))
    mkhwconn cec -t -T fnm
    

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
    

You can now load the HFI master ISR identifier on the Power 775 frame and cecs. This will be accomplished using the CNM command "chnwsvrconfig" . The cecs in the frame should be in a powered off state prior to executing the chnwsvrconfig commands. You can specify the -A flag to enable all of the configured servers in the P775 cluster, or execute the -f (frame id) and -c (cage id) to configure the identifier one cec at a time. 
    
    /opt/isnm/cnm/bin/chnwsvrconfig   -A       (configures all associated cecs in cluster with HFI data)
    /opt/isnm/cnm/bin/chnwsvrconfig   -f 17 -c 3   (configures cec 1 in frame 17 with HFI data
    

You can now verify that the CNM daemon and HFI configuration is working by executing the CNM commands "lsnwloc" display frame-cage and supernode drawers information and "nmcmd" to dump the drawer status information. This will list the current state of the drawers working with CNM. Please reference the HPC using the 9125-F2C guide for more detail about CNM commands, implementation, and debug. 
    
    /opt/isnm/cnm/bin/lsnwloc
    FR0017-CG03-SN000-DR0 
    FR0017-CG04-SN000-DR1
    FR0017-CG05-SN000-DR2
    
    
    /opt/isnm/cnm/bin/nmcmd -D -D
    Frame 17  Cage 3 Supernode 0 Drawer 0 RUNTIME
    Frame 17  Cage 5 Supernode 0 Drawer 2 RUNTIME
    Frame 17  Cage 4 Supernode 0 Drawer 1 RUNTIME
    
