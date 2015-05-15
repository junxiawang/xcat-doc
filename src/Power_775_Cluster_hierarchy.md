<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Setup of GPFS I/O Server nodes](#setup-of-gpfs-io-server-nodes)
- [Creation of Power 775 Octants in xCAT DB](#creation-of-power-775-octants-in-xcat-db)
- [Creation of System P LPARs using HMC](#creation-of-system-p-lpars-using-hmc)
  - [**Define the HMCs as xCAT nodes**](#define-the-hmcs-as-xcat-nodes)
  - [**Discover the LPARs managed by the HMCs**](#discover-the-lpars-managed-by-the-hmcs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


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
