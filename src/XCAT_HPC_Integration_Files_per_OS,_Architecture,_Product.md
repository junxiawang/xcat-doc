<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT 2.7.2](#xcat-272)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

# xCAT 2.7.2

Note: All HPC software is listed by its version number that xCAT 2.7.2 HPC Integration was tested with. Other versions may work with this support as well. 

_Developer notes: _

  * This table needs to be filled out for all products, architectures, OS. First entries should be for RH6.2 on ppc64 for System Test. 
  * Since it looks like this table may grow very large, another option would be to have separate tables for each OS/Arch. Then you could remove the first 2 columns to make it fit better on the screen. Or, the table separation could be at OS/Arch/node type. That would follow the HPC Documentation better for links. And, if tables are separate for OS/Arch/node type, you might want to create more columns to separate file types. Something like: 

    Files required for RH6.2 on PPC64 for Statelite or Stateless Nodes: 

    (all files are installed in /opt/xcat/share/xcat/IBMhpc) 

**HPC Product**
**pkglist Files**
otherpkgs Files 
postinstall scripts 
exclude lists 
postbootscripts 
**Notes**

  * Another change might be to  color highlight those files that are new/changed for this release to make it easier for users that are upgrading xCAT and their HPC software stack. 

__

  


**OS**
**Architecture**
**HPC Product**
**Node Type**
**Files**

in /opt/xcat/share/xcat/IBMhpc 

**Notes**

RH6.2 
ppc64 
All products: 

  * PE 1.2 
  * LL 5.1.0.7 
  * GPFS 3.5.0.2 
  * ESSL 5.1.0.2 
  * PESSL 4.1.0.0 
  * XL C/C++ V11.1.0.4 
  * XL Fortran V13.1.0.4 
compute 

     (stateless or statelite) 

    compute.rhels6.ppc64.pkglist 
    compute.rhels6.ppc64.otherpkgs.pkglist 
    compute.rhels6.ppc64.postinstall 
    _(optional)_ compute.rhels6.ppc64.exlist 

  * See notes for PE 1.2 below 
  * See notes for LL 5.1.0.3 below 
  * The UPC compiler is optional and only available for Power775. You will need to edit your otherpkgs.pkglist and postinstall script to include this compiler. See notes for Compilers below. 

compute 

     (statefull) 

    compute.rhels6.ppc64.pkglist 
    compute.rhels6.ppc64.otherpkgs.pkglist 

Copy the following files to /install/postscripts: 

    IBMhpc.postscript 
    IBMhpc.postbootscript 
    compilers/compilers_license 
    (optional) compilers/upc_license 
    essl/essl_install_pessl4100 
    gpfs/gpfs_updates 
    loadl/loadl_install-5103 
    pe/pe_install-1200 

  * See notes for PE 1.2 below 
  * See notes for LL 5.1.0.3 below 
  * You will need to edit 
  * You will need to edit IBMhpc.postbootscript to change the following calls: 

    

  * pe_install changes to pe_install-1200 
  * loadl_install changes to loadl_install-5103 
  * essl_install changes to essl_install_pessl4100 
  * add upc_license if using UPC compiler (Power775 only) 

min-compute 

    min-compute.rhels6.ppc64.pkglist 
    min-compute.rhels6.ppc64.otherpkgs.pkglist 
    min-compute.rhels6.ppc64.postinstall 
    min-compute.rhels6.ppc64.exlist 

PE 1.2 
compute 

    IBMhpc.rhels6.ppc64.pkglist 
    compilers/compilers.rhels6.pkglist 
    _(for IB)_ pe/pe-1200.rhels6.ppc64.pkglist 
    \- 
    compilers/compilers.otherpkgs.pkglist 
    _(optional)_ compilers/upc.otherpkgs.pkglist 
    pe/pe-1200.rhels6.ppc64.otherpkgs.pkglist 
    \- 
    IBMhpc.rhel.postinstall 
    compilers/compilers_license 
    _(optional)_ compilers/upc_license 
    pe/pe_install.1200 
    \- 
    _(optional)_ IBMhpc.rhels6.ppc64.exlist 
    _(optional)_ pe.exlist 
    \- 
    _(for checkpoint/restart)_ ckpt.sh 

  * See notes for Compilers below 
  * New with PE 1.2, the PE rpm install and license acceptance is now done using otherpkgs.pkglist instead of the pe_install postinstall script. 
  * The ckpt.sh script is only needed if you are using the checkpoint/restart function 
  * For BSR configuration, you will need to edit pe_install.1200 and remove comments 

  


Compilers: 

  * XL C/C++ V11.1 
  * XL Fortran V13.1 
  * XL UPC V12.0 
compute 

    IBMhpc.rhels6.ppc64.pkglist 
    compilers/compilers.rhels6.pkglist 
    compilers/compilers.otherpkgs.pkglist 
    _(optional)_ compilers/upc.otherpkgs.pkglist 
    IBMhpc.rhel.postinstall 
    compilers/compilers_license 
    _(optional)_ compilers/upc_license 

  * The UPC compiler is optional and only available for Power775 
  * The UPC compiler requires XL Mass v7.1, while XL C/C++ and XL Fortran both require XL Mass v6.1. If installing UPC, both versions of XL Mass will be installed. 
