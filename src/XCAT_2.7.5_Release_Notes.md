<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## New Function and Changes in Behavior

  * Note in SVN the tag of the release was late. The last revision number for 2.7.5 is 14039. 
  * RHEV (RedHat Enterprise Virtualization) (RHEV-m, RHEV-h) support. Including the installing of RHEV-h and management the virtual machines through RHEV-m. 
  * Hardware discovery support for IBM Flex system x compute nodes 
  * Firmware assisted dump for Power 775 
  * RHEL 6.3 support 
  * Numerous enhancements to the xCAT support for AIX High Availability Service Nodes (HASN). 

## Key Bug fixes

  * Several xdcp synclist fixes. See defects 3002/3018/2956. https://sourceforge.net/p/xcat/bugs/3002/ and https://sourceforge.net/p/xcat/bugs/3018/ and https://sourceforge.net/p/xcat/bugs/2956/ 
  * For the rest of the bug fixes in 2.7.5, see the [list of 2.7.5 bugs fixed](https://sourceforge.net/p/xcat/bugs/search/?q=_milestone%3A2.7.5+%26%26+!status%3Awont-fix+%26%26+!status%3Aclosed+%26%26+!status%3Apending&_session_id=33b8c0b294971eb883aad9de6e4b19ccb515ee7f459c2cc763284ed895d7d8224e4d1ab60903bbb4). 

## Restrictions and Known Problems

  * On system x hardware you must use the latest xcat-dep tarball in https://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux/ . (Snap date 11/7/2012 or later.) Otherwise, you will encounter a bug in xCAT-genesis in which bmcsetup does not set up userids correctly on x3755 M3. 
  * A couple IPMI bugs exist in 2.7.5: 
    * In an initial install of 2.7.5 on new hardware, rvitals and rinv will not work. 
    * For cmds like rvitals for a lot of nodes would give errors like: node1: Error: 1 code on opening RMCP+ session 

     Both of the problems are fixed in the file IPMI.pm that is attached to [bug 3156](https://sourceforge.net/p/xcat/bugs/3156/). 

  * For xCAT 2.7.5 with Linux, you should use the [xcat-dep tarball from 6/12/2012](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux/xcat-dep-201206121608.tar.bz2/download). The is the xcat-dep tarball that has been tested with xCAT 2.7.5. (The most recent xcat-dep tarball should also work with xCAT 2.7.5, but it hasn't been tested yet.) 
  * For sles11.2 nfs-based statelite deployment on x86, initrd might fail to mount the rootimg and complain the messages below: 
    
    ...
    Setting up Statelite
    mount.nfs: Protocol not supported
    Couldn't mount dx360m3n04:/install/netboot/sles11.2/x86_64/compute on /sysroot
    Trying again in 1 seconds
    ...
    

    the work around can be found in bug [3038](https://sourceforge.net/p/xcat/bugs/3038/)

  * When running mkdsklsnode you may, in certain cases, see the following error: 
    
    Error: there is already one directory named "", but the entry in litefile table is set to one file, please check it
    Error: Could not complete the statelite setup.
    Error: Could not update the SPOT
    

If you see this error simply re-run the command. 

  * In an AIX HASN environment, if you have more than 8 service nodes, the mkdsklsnode command may create an /etc/exports file entry that is not supported by AIX. 

     The mkdsklsnode command updates the /etc/exports file on the service nodes with an entry that contains a list of replicas that are used by the the AIX NFSv4 support. Due to an NFS limitation the list of replicas may not exceed 8. If you have existing /etc/exports files that already contain the replication entry then it will not be modified and you DO NOT need to take any further actions. However, if you have removed the /etc/exports file or need to set up a new service node, you must manually check the /etc/xports file to make sure there are no more than 8 replicas listed. 

     The format of the file is as follows: 
    
    /install -vers=4,replicas=/install@20.10.12.1:/install@20.10.12.2:/install@20.10.12.3:/install@20.10.12.4:/install@20.10.12.5:/install@20.10.12.6,noauto,rw,root=*
    

     Simply remove one or more replicas from the list.( ex.&nbsp;:/install@20.10.12.6) 

  * For the rvitals command on system p with option "lcds", if there is any LPAR in the noderange which is defined in the xCAT DB, but doesn't exist on its CEC, the rvitals will not return correct info. You can get more info from bug [3133](https://sourceforge.net/p/xcat/bugs/3133/) and you also can get the e-fix to fix this issue from the attached in the bug [3133](https://sourceforge.net/p/xcat/bugs/3133/) page. 
