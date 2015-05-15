<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Switch to the DB2 database](#switch-to-the-db2-database)
- [Cluster Hardware Setup and Discovery](#cluster-hardware-setup-and-discovery)
- [Firmware updates for System P Hardware](#firmware-updates-for-system-p-hardware)
- [Install and Configure LoadLeveler Resource manager on the Management Node](#install-and-configure-loadleveler-resource-manager-on-the-management-node)
  - [**Install LoadLeveler on your xCAT Management Node**](#install-loadleveler-on-your-xcat-management-node)
- [Implementation with TEAL on xCAT MN for Power 775 cluster](#implementation-with-teal-on-xcat-mn-for-power-775-cluster)
  - [**Install Teal on your xCAT Linux Management Node**](#install-teal-on-your-xcat-linux-management-node)
  - [**Install Teal on your xCAT AIX Management Node**](#install-teal-on-your-xcat-aix-management-node)
- [Implementation with ISNM and HFI for Power 775 Cluster](#implementation-with-isnm-and-hfi-for-power-775-cluster)
  - [**Check that your xCAT Tables are populated before installing ISNM**](#check-that-your-xcat-tables-are-populated-before-installing-isnm)
  - [**Install and configure ISNM on your Linux Management Node**](#install-and-configure-isnm-on-your-linux-management-node)
  - [**Install and configure ISNM on your AIX Management Node**](#install-and-configure-isnm-on-your-aix-management-node)
- [Setup of GPFS I/O Server nodes](#setup-of-gpfs-io-server-nodes)
- [Creation of Power 775 Octants in xCAT DB](#creation-of-power-775-octants-in-xcat-db)
- [Creation of System P LPARs using HMC](#creation-of-system-p-lpars-using-hmc)
  - [**Define the HMCs as xCAT nodes**](#define-the-hmcs-as-xcat-nodes)
  - [**Discover the LPARs managed by the HMCs**](#discover-the-lpars-managed-by-the-hmcs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

If not using Power 775 Clusters, skip this section. 

This section describes the additional setup required for the Power 775 support. This includes the installation of Teal, ISNM, and LoadL on the xCAT management node. 

     **NOTE**: 
     This information will probably be a pointer to some HPC integration documentation . 
     We also may want to provide an introduction about Power 775 Direct Management (DM) and energy management. 
     We could place information on where to locate the packages, how they are installed, and used with System P hardware. 

### Switch to the DB2 database

The xCAT Power 775 cluster support requires that you use the DB2 database. 

Follow the xCAT instructions on setting up the DB2 environment on the xCAT management node. [Setting_Up_DB2_as_the_xCAT_DB] 

### Cluster Hardware Setup and Discovery

This is a new section that provides a pointer to our System P Management Guide. It provides information on how to connect the System P hardware Frames, Cecs, and HMCs to the xCAT MN. It explains how to setup DHCP for the HW Service networks, the HW discovery for HMC, Frame/BPA, and CEC/FSP. and how to setup the xCAT data base with hardware node objects. [XCAT_System_p_Hardware_Management] 

### Firmware updates for System P Hardware

This should discuss how to locate the GFW images from the System P IBM web site. It can provide data about the xCAT rflash command and how it is used to update the GFW for Power 775 clusters using Direct Management interface from the xCAT MN. 

### Install and Configure LoadLeveler Resource manager on the Management Node

This should be pointer to the LoadL documentation being used to setup LoadL on the xCAT MN 

Copy the LoadLeveler packages from your distribution media onto the xCAT management node (MN). Suggested target location to put the packages on the xCAT MN: 
    
    /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/loadl
    

Note: LoadLeveler on Linux requires a special Java rpm to run its license acceptance script. The correct version of this rpm is identified in the LoadLeveler product documentation (at the time of this writing, the rpm was IBMJava2-142-ppc64-JRE-1.4.2-5.0.ppc64.rpm, but please verify with the LL documentation). Ensure the Java rpm is included in the loadl otherpkgs directory. 

Following the LoadLeveler Installation Guide, create the loadl group and userid: On Linux: 
    
      groupadd loadl
      useradd -g loadl loadl
    

On AIX: 
    
      mkgroup -a loadl
      mkuser pgrp=loadl groups=loadl home=/&lt;user_home&gt;/loadl loadl
    

#### **Install LoadLeveler on your xCAT Management Node**

You will need to install LoadLeveler resource manager on your xCAT management node working with Power 775 clusters. 

On Linux: 

Download the LoadLeveler rpms to the xCAT MN and place in a directory such as 
    
    /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/loadl 
    

Install the LoadLeveler Resource Manager and license rpm: 
    
    cd /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/loadl
    rpm -Uvh ./LoadL-resmgr-full*.rpm
    rpm -Uvh ./LoadL-full-license*.rpm 
    

Accept the LoadLeveler license and install the product rpms: 
    
     /opt/ibmll/LoadL/sbin/install_ll -y -d .
    

On AIX: Download the LoadLeveler packages to the xCAT MN and place in a directory such as 
    
    /install/post/otherpkgs/aix/ppc64/loadl 
    

Install the LoadLeveler Resource Manager: 
    
    cd /install/post/otherpkgs/aix/ppc64/loadl
    inutoc .
    installp -aXgYd . LoadL
      
    

  
Please reference the LoadLeveler Installation Guide, to provide more detail about LoadLeveler installation. 

This should be pointer to the LoadL documentation to configure LoadL on the xCAT cluster. 

### Implementation with TEAL on xCAT MN for Power 775 cluster

xCAT will provide only minimal instructions here for installing the TEAL product. You will need to refer to the TEAL product documentation for full installation and prerequisite details, and for configuration instructions to interface with other products to gather and process monitoring data. Note that the Teal product does have some prerequisites on the LoadL resource manager. 

For Power 775 clusters you need to install the Teal packages on your xCAT management node. 

#### **Install Teal on your xCAT Linux Management Node**

Download the Teal dependent rpm pyodbc-2.1.7-1.ppc64.rpm and teal rpm packages, and place them on your xCAT MN in a directory such as: 
    
    /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/teal
    

The current RH6 Linux Teal packages are: 
    
    teal-base-1.1.0.0-1.ppc64.rpm 
    teal-ll-1.1.0.0-1.ppc64.rpm    
    teal-sfp-1.1.0.0-1.ppc64.rpm
    teal-isnm-1.1.0.0-1.ppc64.rpm 
    teal-pnsd-1.1.0.0-1.ppc64.rpm  
    
    

To install: 
    
    cd /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/teal
    rpm -Uvh pyodbc-2.1.7-1.ppc64.rpm
    rpm -Uvh ./teal*.rpm
    

#### **Install Teal on your xCAT AIX Management Node**

Download the Teal dependent rpm packages, and the Teal installp packages on your xCAT MN. Place the packages in a directory such as /install/post/otherpkgs/aix/ppc64/teal. 

  
The Teal dep packages for AIX71B are: 
    
    gdbm-1.8.3-5.aix5.2.ppc.rpm   
    readline-4.3-2.aix5.1.ppc.rpm
    pyodbc-2.1.7-1.aix6.1.ppc.rpm   ***  this is being added to xCAT deps packaging
    python-2.6.2-2.aix5.3.ppc.rpm
    

To install: 
    
    rpm -Uvh ./gdbm-1.8.3-5.aix5.2* gdbm-1.8.3-5.aix5.2* pyodbc-2.1.7-1.aix6.1*
    python-2.6.2-2.aix5.3
    

The Teal installp packages with AIX are: 
    
    teal.base   -used with base Teal support   
    teal.isnm    -used with isnm Teal
    teal.ll           -used with LL teal 
    teal.pnsd   -used with PE  pnsd teal 
    teal.sfp       -used with HMC Service focal point 
    
    

To install: 
    
    cd /install/post/otherpkgs/aix/ppc64/teal
     inutoc .
    installp -aXgd . teal 
    

  
This should be pointer to Teal documentation on how to setup Teal for a System P cluster. 

  
If you are using TEAL with the GPFS connector feature, you will need to install the teal-gpfs-sn package, which is shipped with the TEAL product, onto one of your xCAT service nodes designated as your GPFS collector node. Follow the xCAT instructions for doing this included in setting up GPFS on your cluster: 

    

  * [Setting_up_GPFS_in_a_Stateful_Cluster] 
  * [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster] 

### Implementation with ISNM and HFI for Power 775 Cluster

This should be pointer to the ISNM documentation on how to work with HFI-ISR network for Power 775 cluster. This would be a good place to describe how the HFI is being used with xCAT. We can provide where the admin can locate the HFI device drivers, and what xCAT packages are being used with the HFI. 

If you are only trying to boot over hfi from one octant to another in the same cec (i.e. your mgmt node or service node is located in the cec), then you don't need ISNM/cnm. The time you need cnm is if you are trying to boot an octant in one cec from a MN/SN in another cec (i.e. cross-cec hfi traffic). 

#### **Check that your xCAT Tables are populated before installing ISNM**

ppcdirect -- contains user name and passwords to the hardware for xCAT to communicate with 
    
    # tabdump ppcdirect
    #hcp,username,password,comments,disable
    "f07c00bpca_a","admin","admin",,
    "f07c07fsp1_a","admin","abc123",,
    "f07c07fsp1_a","general","abc123",,
    "f07c07fsp1_a","HMC","abc123",,
    

nodelist -- nodes defined in the cluster 
    
    # tabdump nodelist
    #node,groups,status,statustime,appstatus,appstatustime,primarysn,hidden,comments,disable
    "f07c00bpca_a","bpa,all",,,,,,,,
    "f07c07fsp1_a","fsp,all",,,,,,,,
    

ppc - nodes with more information i.e. supernode/drawer 
    
    # tabdump ppc
    #node,hcp,id,pprofile,parent,nodetype,supernode,comments,disable
    "f07c00bpca_a","f07c00bpca_a","7",,,"bpa",,,
    "f07c07fsp1_a","f07c07fsp1_a","7",,"f07c00bpca_a","fsp","17,0",,
    

  


#### **Install and configure ISNM on your Linux Management Node**

You will need to install CNM ISNM packages on your xCAT MN working with Power 775 clusters. 

  
Download the ISNM rpms to the xCAT MN and place in a directory such as 
    
    /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/isnm
    

Note: ISNM requires 32 bit rpms for the unixODBC installed on xCAT MN. For RHEL 6 (ppc64): You will need to validate that both the pam-1.1.1-4.el6.ppc64 and the pam-1.1.1-4.el6.ppc rpm packages are installed on the xCAT MN. The RH6 yum package may install or update the 64 bit packages only. You manually need to install the 32 bit pam-1.1.1-4.el6.ppc rpm package. 

You then need to validate that both unixODBC-2.2.14-11.el6.ppc64 and unixODBC-2.2.14-11.el6.ppc rpms are installed on the xCAT. Make sure that unixODBC-2.2.14-11.el6.ppc64 rpm is installed first through yum, and then manually install the 32 bit unixODBC-2.2.14-11.el6.ppc rpm. Some files such as isql, odbc_config, and odbcinst, will be overwritten by the second rpm install. 

There is one hdwr_svr lib that is not in the package that must be manually placed in /usr/lib on the Managment Node. ( This will be fixed soon). Right now the lib is in the following backing tree: 
    
    /project/spreldenali/build/rdenali1107b/export/ppc64_redhat_6.0.0/usr/lib/libnetchmcx.so
    
    
    cp -p libnetchmcx.so /usr/lib
    

**Install the hardware server rpms:**
    
    cd /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/isnm
    rpm -Uvh ./ISNM-hdwr_svr*.rpm 
    

Have xCAT setup connection from hdwr_svr to drawers (populate HmcNetConfig). This will create /var/opt/isnm/hdwr_svr/data/HmcNetConfig and start hdwr_svr. 
    
    mkhwconn &lt;defined FSP name in nodelist table&gt; -T fnm
    

  


**Verify Hdwr_svr connection&nbsp;:**
    
    cd /var/opt/isnm/hdwr_svr/log
    # cat hdwr_svr.dump | grep -A 10 -i "FspConnectionRecord"
    FspConnectionRecord vport: 0x00000003
     hostname: '40.7.5.1'
     management_type: 1
     mtms: '9125-F2C*P7IH121'
     slot: A
     ipv4_address: '40.7.5.1'
     ip_connection: c 0x28070501 m 0x28070501
      0x28070501
      0x0
      client_number: 11
      connection_state: 0x0 - LINE_UP
    

**Install TEAL: CNMD requires it's libraries:**
    
    See
    [Setup_for_P7_IH_Cluster_on_xCAT/MN#Implementation_with_TEAL_on_xCAT_MN_for_P7_IH_cluster]
    

  


**Install CNMD rpms:**
    
    cd /install/post/otherpkgs/&lt;os&gt;/&lt;arch&gt;/isnm
    rpm -Uvh ./ISNM-cnm*.rpm
    
    

**Start CNMD:**
    
    /opt/isnm/cnm/bin/startCNMD &
    

  
**Verify CNMD -- list drawers and state**
    
    # nmcmd -D -D****
    Frame 7  Cage 7 Supernode 17 Drawer 0 RUNTIME
    

  

    
    # rpm -qa | grep ISNM
    ISNM-cnm-RHEL-PPC-1.0.0.0-1.ppc64
    ISNM-hdwr_svr-RHEL-PPC-1.0.0.0-1.ppc64
    

**To uninstall:**
    
    # rpm -e ISNM-hdwr_svr-RHEL-PPC-1.0.0.0-1.ppc64 ISNM-cnm-RHEL-PPC-1.0.0.0-1.ppc64
    # rpm -qa | grep ISNM
    #
    

#### **Install and configure ISNM on your AIX Management Node**

Download the ISNM packages to the xCAT MN and place them in a directory such as 
    
    /install/post/otherpkgs/aix/ppc64/isnm
    

The following packages will be installed: 
    
    isnm.cnm      
    isnm.hdwr_svr
    

Install the hdwr_svr package: 
    
    cd /install/post/otherpkgs/aix/ppc64/isnm
    .inutoc
    installp -acXYFd . isnm.hdwr_svr
    

Have xCAT setup connection from hdwr_svr to drawers (populate HmcNetConfig). This will create /var/opt/isnm/hdwr_svr/data/HmcNetConfig and start hdwr_svr. 
    
    mkhwconn &lt;defined FSP name in nodelist table&gt; -T fnm
    

  


**Verify Hdwr_svr connection&nbsp;:**
    
    cd /var/opt/isnm/hdwr_svr/log
    # cat hdwr_svr.dump | grep -A 10 -i "FspConnectionRecord"
    FspConnectionRecord vport: 0x00000003
     hostname: '40.7.5.1'
     management_type: 1
     mtms: '9125-F2C*P7IH121'
     slot: A
     ipv4_address: '40.7.5.1'
     ip_connection: c 0x28070501 m 0x28070501
      0x28070501
      0x0
      client_number: 11
      connection_state: 0x0 - LINE_UP
    

**Install TEAL: CNMD requires it's libraries:**
    
    See
    [Setup_for_P7_IH_Cluster_on_xCAT/MN#Implementation_with_TEAL_on_xCAT_MN_for_P7_IH_cluster]
    

**Install CNMD:**
    
    cd /install/post/otherpkgs/aix/ppc64/isnm
    installp -acXYFd . isnm.cnm
    

**Start CNMD:**
    
    /opt/isnm/cnm/bin/chnwm -a
    

**Verify CNMD -- list drawers and state**
    
    # nmcmd -D -D
    Frame 7  Cage 7 Supernode 17 Drawer 0 RUNTIME
    

### Setup of GPFS I/O Server nodes

This is pointer to the GPFS documentation to setup GPFS I/O servers on the Power 775 cluster. 

### Creation of Power 775 Octants in xCAT DB

This is a new section in xCAT 2.6 that describes the implementation to create the Power 775 Octants/LPARs used with a Power 775 cluster. It will describe the default Power 775 systems configuration, and will describe which Power 775 octants are designated as xCAT service nodes. This section should provide enough detail for the xCAT administrator to execute xCAT commands for the Power 775 CECs. We should try and provide the commands and should provide sample files that can be referenced. 

  
At this point we should have all the xCAT Service nodes and compute nodes should be defined in the xCAT DB. 

### Creation of System P LPARs using HMC

This section explains the xCAT implementation working with HMCs which has been supported with xCAT 2.4. These steps below implement where the HMC has created the LPARs. 

#### **Define the HMCs as xCAT nodes**

The xCAT hardware control support requires that the hardware control point for the nodes also be defined as a cluster node. 

The following example will create an xCAT node definition for an HMC with a host name of "_hmc01_". The _groups, nodetype, hwtype, mgt, username_, and _password_ attributes must be set. 
    
    _**mkdef -t node -o hmc01 groups="all" nodetype=ppc hwtype=hmc mgt=hmc username=hscroot password=abc123**_
    

#### **Discover the LPARs managed by the HMCs**

This step assumes that the partitions are already created using the standard HMC interfaces. 

Use the **rscan** command to gather the LPAR information. This command can be used to display the LPAR information in several formats and can also write the LPAR information directly to the xCAT database. In this example we will use the "-z" option to create a stanza file that contains the information gathered by **rscan** as well as some default values that could be used for the node definitions. 

To write the stanza format output of **rscan** to a file called "_mystanzafile"_ run the following command. 
    
    _**rscan -z hmc01 &gt; mystanzafile**_
    

The file will contain stanzas for all the LPARs that have been configured as well as some additional information that must also be defined in the xCAT database. It is not necessary to modify the non-LPAR stanzas in any way. 

This file can then be checked and modified as needed. For example you may need to add a different name for the node definition or add additional attributes and values. 

Since we are using service nodes there are several values that **must be set **for the node definitions. **You can set these values later, after the nodes have been defined, or you can modify the stanzas to include the values now. **(If you have many nodes it would be easier to do this later.) 
