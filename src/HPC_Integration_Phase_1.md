<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Line Item:](#line-item)
- [xCAT Integration:](#xcat-integration)
  - [Bundle Files, Package Lists](#bundle-files-package-lists)
  - [Linux Exclude Lists](#linux-exclude-lists)
  - [Statelite litefile entries](#statelite-litefile-entries)
  - [Documentation](#documentation)
- [HPC Product Licenses:](#hpc-product-licenses)
- [Login nodes versus compute nodes:](#login-nodes-versus-compute-nodes)
- [Monitoring HPC products:](#monitoring-hpc-products)
- [Packaging for xCAT:](#packaging-for-xcat)
- [Specific product integration:](#specific-product-integration)
- [GPFS:](#gpfs)
  - [For storage nodes:](#for-storage-nodes)
  - [For compute nodes:](#for-compute-nodes)
  - [Existing GPFS support in xCAT:](#existing-gpfs-support-in-xcat)
- [LoadLeveler:](#loadleveler)
- [POE:](#poe)
- [MetaCluster (LL Checkpoint/Restart):](#metacluster-ll-checkpointrestart)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

**xCAT HPC Integration Mini-Design** Linda Mellor 2/16/2010 

  



## Line Item:
    
     	5U6	Phase 1 of HPC integration w/xCAT 
    

This design documents the changes required to xCAT to support the first phase of integration of with HPC software. 

The HPC software stack specifically addressed by this design: 

  * GPFS 
  * LoadLeveler 
  * MetaCluster Checkpoint/restart 
  * POE (Parallel Operating Environment) 
  * LAPI (Low-Level Application Programming Interface) 
  * PNSD (Protocol Network Services Daemon) 
  * ESSL/PESSL 
  * Parallel Debugger 
  * Compilers (vac, xlC, xlf) 
  * (RSCT – see xCAT Monitoring) 
  * (Infiniband – see xCAT IB support) 

  


## xCAT Integration:

### Bundle Files, Package Lists

Most of the HPC software products do not need any special xCAT integration. The software packages simply need to be installed on the compute nodes (full-disk) or in the compute node image (diskless). For AIX, bundle files will be provided to streamline this installation. For Linux, package lists will be provided. In some cases, a runtime daemon needs to be started for the product, but typically the software package will install a mechanism to automatically start the daemon when the node is booted (AIX: /etc/inittab, Linux: /etc/init.d). 

xCAT will provide sample bundle files and package lists for the latest versions of the software listed above. Note that that these are only sample files. It will be the admin's responsibility to verify that the lists are correct and match the software packages they are installing. Products often change their packaging and shipping current accurate lists with xCAT can be a challenge. 

Unless explicitly discussed in this design, assume that no additional xCAT integration is required for a product beyond the provided bundle files/package lists. 

### Linux Exclude Lists

Stateless Linux images need to be as small as possible to reduce the amount of memory used by the RAM-disk filesystem when the image is loaded on the node. XCAT will provide sample exclude lists that can be applied to compute node images to remove files that are typically not needed for HPC job execution. Again, it is the admin's responsibility to validate and adjust these lists for the software being installed. Note that developing minimal exclude lists is an ongoing effort as we understand the HPC applications and their needs in a diskless environment more. These exclude lists will continue to be updated in future xCAT releases as we continue our investigation. 

### Statelite litefile entries

The Linux statelite support requires that the litetable in the xCAT database identify all files in the image that are write-able, and those files which need to be made persistent across node reboots. It is each software product's responsibility to identify this list of files. xCAT will ship these sample filelists with this line item as the other software product developers provide them to us. These lists will continue to be updated in future xCAT releases as the lab continues its testing and investigation in this area. 

These filelists will be shipped as litefile.csv files that can be cut/pasted into a tabedit session of the litefile table in the xCAT database. We are currently considering implementing a "table merge" enhancement to our xCAT tabrestore function to make loading these lists into the litefile table easier. That work will be done outside of this line item. 

### Documentation

Implementation of this line item will include high-level documentation on the process of installing the HPC products with pointers to more detailed xCAT documents that describe the features xCAT provides to install and update software on nodes and in OS images. 

## HPC Product Licenses:

Most of the products above require explicit acceptance of a license agreement. 

When installing AIX lpps, the AIX install commands allow specifying automatic license acceptance, and all these HPC products use the AIX licensing feature to do this. 

For Linux rpms, each product handles its own license processing. Many products use a common Java-based mechanism, where Java libraries and an initial product rpm is installed, then a script is provided with that HPC rpm to run the Java license acceptance process and install the remaining rpms and configure the product. Once installed, the Java packages can be removed from the full-disk compute node or the diskless node image. 

xCAT will provide sample postscripts to run the product license acceptance and installation scripts for POE, LoadLeveler,ESSL/PESSL, and the compilers, and then remove the installed Java packages. For full-disk installs, the scripts will run on the nodes to install the product software after the node has been booted. For diskless nodes, the postscripts will be run at the time the image is generated. 

Note that GPFS does not require xCAT to provide any license acceptance for its Linux product. GPFS encapsulates license acceptance with an rpm extraction script that copies the rpms from the product media onto a local system. Since it is the admin's responsibility to gather all of the required HPC software, it is assumed that if the GPFS rpms are available on the xCAT management node for installing on the nodes, that all licenses have been properly accepted. 

  


## Login nodes versus compute nodes:

Admins often create special login nodes for users to create and submit their HPC parallel jobs from. These nodes typically contain additional software as full compilers, POE front-end, local tools, etc. On the other hand, compute nodes only require product runtime libraries and other software and database access to run the submitted jobs. This design does not address the special requirements of login nodes. 

  


## Monitoring HPC products:

xCAT 2.4 will provide monitoring support for application status (see Ling's work). Sample monitoring table entries will be included with this design to monitor application daemons and issue other queries to verify application health. For Linux, daemons will be monitored using nmap to verify port activity. Default application ports will be used, but can be modified by the admin. xCAT nmap support on AIX is planned for a future release (xCAT 2.5 or later). Therefore, for AIX and Linux, application status commands will be run to gather status for nodes and placed into the appstatus field of the nodelist table. 

  


## Packaging for xCAT:

For this design, a single xCAT-hpc rpm will be created for all of the new files implemented as part of this line item. Discussions will continue as to whether we may want individual rpms for each of the HPC products. If we decide to change in the future, we will still continue to keep xCAT-hpc as a “meta” rpm for all of the HPC product support. 

Installation of this rpm will be optional. It will not be automatically installed the the xCAT meta package. 

Design note: We are still discussing whether we will move existing xCAT support for some open source HPC products such as Torque, Moab, etc., into this new rpm, or if we will name this rpm xCAT-IBMhpc to consolidate only the HPC software distributed by our lab. 

  


## Specific product integration:

NOTE: For each of the items listed here, those that are done procedurally versus those that will be automated may change. For many of the more complex, one-time-only configuration steps for individual products, we will only document at a high-level what should be done, referring to the product documentation and any automation they choose to implement to improve their usability and ease their administrative processes. 

  


## GPFS:

Linux install of GPFS requires first building the GPFS open source portability layer for the correct OS distribution, kernel version, and hardware architecture (prebuilt binaries are NOT shipped with the product). Once built, the binaries need to be added to the image during the GPFS product installation. New for GPFS 3.3 (11/09 GA), GPFS provides tools for the build process which create an rpm that can be installed into the node image with the other GPFS software. 

Most work in designing, defining, and configuring a GPFS cluster will be done outside of xCAT following GPFS documented procedures as these are complex and involved tasks. Once configured, xCAT will help in maintaining the GPFS configuration across boots of stateless nodes. 

GPFS recommends that all the cluster nodes be up and running with the base OS and the GPFS packages installed before creating the GPFS cluster, defining storage nodes and filesystems, and adding compute nodes. 

  


### For storage nodes:

NOTE: No one has experimented with diskless storage nodes which is the current goal for PERCS. This will be an HPC Integration Phase 2 effort if additional support is required. At a minimum, all GPFS configuration files will either need to be included as part of the diskless image, or persistent non-GPFS storage will need to be available to maintain information between reboots. 

### For compute nodes:

  * One time: add the node to the GPFS configuration. xCAT can be used to easily create GPFS nodelist files from defined xCAT nodegroups. 
  * During image build/install/stateless boot, xCAT will ensure the node has correct and current GPFS configuration file (/var/mmfs/gen/mmsdrfs). Note: not needed for nodes with persistent /var/mmfs directory &lt;full disk, statelite&gt; – GPFS will put the correct file out there when the node is added to the cluster and will maintain any updates that are required. xCAT will be used to populate the image with the file when doing a reinstall or building a new image for the node so that if large numbers of nodes booting at once, they will not flood the GPFS config server for initial config files. 
  * Also, to improve GPFS startup performance when none of the compute nodes are serving GPFS filesystems (as will be true for PERCS), xCAT can be used to place a custom /var/mmfs/etc/nsddevices script (simply returns 0) in the image for each node. 
  * When adding nodes to the GPFS cluster, it is important to ensure communication across correct network to GPFS servers is active before creating the GPFS node. xCAT commands can be used to verify network access (ppping, xdsh ping, etc.). 
  * New with GPFS 3.3, GPFS only requires passwordless remote shell support from the “administrative” nodes to the compute nodes. Previous releases of GPFS require all nodes to have remote shell access to all other nodes. In either case, by default xCAT sets up root ssh access across all nodes in the xCAT cluster. No additional work is required. 

  


### Existing GPFS support in xCAT:

xCAT has provided Linux stateless support since xCAT 1. The support that is shipped in /opt/xcat/share/xcat/netboot/add-on/autogpfs does the following: 

  * the GPFS primary server is configured to run a small “autogpfsd” daemon that listens to requests from nodes. This can run in one of two modes “old” or “new”. Standard operation is to run in “old” mode which means that all the GPFS nodes have been defined and GPFS is running normally. “new” mode is used when first creating the cluster to add nodes to GPFS as they are brought online. 
  * diskless node images are configured to run an autogpfsc client script at node boot. The following happens in “old” mode: 
    * the node contacts the server 
    * the server checks if the node is in the GPFS config (does mmlscluster and checks for the node). If the node is not there, a msg is sent back that the node needs to be added. 
    * the server queries its local /etc/fstab and sends each GPFS entry to the node. The node checks its /etc/fstab and adds any entries not already there. 
    * the server queries its corresponding /dev/xxx for that entry and sends "major" and "minor" info back to the node. The node deletes that /dev/xxx and creates a new one with mknod 
    * the server sends a copy of its mmsdrfs file to the node which the node puts in its /var/mmfs/gen directory 
    * the node then runs mmstartup to start GPFS 

The following happens in “new” mode: 

  *     * the node contacts the server 
    * the server checks if the node is in the GPFS config (does mmlscluster and checks for the node). If the node is there, the daemon returns a msg that it is done. 
    * the server adds the node to the gpfs cluster (mmaddnode). 

Controls in the server daemon config file allow specifiying the max number of nodes it will process at one time to not flood GPFS. 

When we ran the scale cluster, we only needed to copy over the mmsdrfs file and did not need to do anything with /etc/fstab or /dev/xxx. I'm in the process of verifying if this work is still necessary. 

  


  


## LoadLeveler:

LL is currently developing support to use the xCAT database for its configuration information and to automatically add nodes to the LL cluster. Base support was delivered in LL 4.1 (11/09 GA) for AIX. Equivalent Linux support will be available with the 6/10 GA of LL. Also, available with LL in June will be additional enhancements to AIX and Linux to automatically build and distribute the /etc/LoadL.cfg file, and to use xCAT postscripts to automate all LL configuration for the node. The only responsibility xCAT will have in this environment is to provide the tools to install the LL product on the nodes and to apply software updates as required. LL can also operate with its previous non-database configuration where configuration files are available on each node in the cluster. Using the xCAT database to manage configuration information will be the recommended mode for xCAT clusters, and is the mode that is supported by this design. 

Note that if admins do choose to use the non-database configuration mode, some suggestions will be included in our documentation, basically following what we did for the PERCS scale cluster we administered last year: In order to ensure consistent LL configuration across the cluster, all LL configuration files were kept in GPFS and available to each node. Apparently, this is a common administration method for large scale clusters. Another option is to distribute LL config files across the cluster with the xCAT syncfiles support. 

  


## POE:

No xCAT integration is required. Customers typically use POE with LL to submit parallel jobs. POE can run without LL using a hostlist as input if desired. In this case, xCAT can be used to easily create hostlist files from xCAT nodegroups or node ranges. 

  


## MetaCluster (LL Checkpoint/Restart):

Internally, the AIX MetaCluster support creates WPARs as needed for its work. This requires that the WPAR be able to mount the AIX OS from its hosting node. For diskless AIX, since the OS is already NFS mounted to the hosting node (i.e. the xCAT compute node), changes will need to be made to the /etc/exports entries created by NIM on the xCAT MN or service nodes for each node to allow all MetaCluster virtual IPs to have mount access as well. A sample script will be provided to do this work. 
