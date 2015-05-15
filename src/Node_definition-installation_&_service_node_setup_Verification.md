{{:Design Warning}} 

The verification for node (Include service node or compute node) definitioin and status after the installation/netboot is very important for user to know that the node is ready for installation or has been installed succeeded. This mini-design lists the items that should be checked before and after the installation for a node. The check activity should be implemented in a perl script and called by the nodecheck command. 

  
Verify the node definition before the install/netboot: 

  * dns: (the name resolution for the node, short name) 
  * dhcp: (has correct dhcpd.conf and correct section in the lease file) 
  * conserver: The node has a section in the /etc/conserver.cf 
  * The hcp is pingable 
  * Has correct bootloader file for the node (yaboot, pxelinux, xnba) 
  * The correct bootloader configuration file has been created 
  * Check the attributes: noderes.netboot, noderes.tftpserver,noderes.nfsserver,noderes.installnic,noderes.xcatmaster 
  * Diskfull 

    

  * autoyast/kickstart configuration file has been created 
  * copycds has been run for the specific os 
  * The kernel, initrd have been copied to correct location 

  * Diskless 

    

  * The specific osimage has been created 
  * The kernel and osimage has been copied to the correct location 

  * Statelite 

    

  * The specific osimage has been created 
  * The kernel and osimage has been copied to the correct location 
  * The statelite,litefile,litetree table 

  * passwd table has correct entries (omapi,xcat,system) 
  * The password in the ppchcp,ppcdirect,ipmi tables 
  * Display a configuration after the check 

    

  * Display: node name, node IP,mac address, os, profile, path of autoyast/kickstart configuration file, kernel parameters, 
  * List the postscripts, postbootscripts which will be run during the installation 
  * List the syncfile, pkglist, otherpkgs.pkglist which will be run for the node 

  * virtualization node ... 

Verify the node status after the install/netboot: 

  * dns: the node name of MN/SN can be resolved from the compute node 
  * Can ssh to the node without passwd from the MN/SN 
  * The node status is correct 
  * The files in the synclist have been synced to the node 
  * The pkgs in the otherpkgs.pkglist have been synced to the node 

Service node specific: 

  * The xCAT and dependency packages have been installed (xCATsn instead of xCAT) 
  * All the processes of xCAT have been started 
  * The database has been configured correctly. (/etc/xcat/cfgloc) 
  * The credentials have been gotten from MN. Should check the compatibility with the ones on MN. 
  * .ssh/ has correct configuration so that MN can ssh to SN without password 
  * The syslog has been redirected to the MN 
  * The service like tftp,nfs,http... have been started base on the definition of the service node. (servicenode table) 
  * The installation resource from the management node (/install mount from MN?) 
  * Has correct files in /install/postscripts 
