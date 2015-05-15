<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xcatexport Input Args](#xcatexport-input-args)
- [xcatexport Function](#xcatexport-function)
- [xcatimport Input Args](#xcatimport-input-args)
- [xcatimport Function](#xcatimport-function)
- [Restrictions and Assumptions](#restrictions-and-assumptions)
- [Optional Behaviour or Uses](#optional-behaviour-or-uses)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)



The purpose of these new cmds is to be able to take a picture/snapshot of an xcat mgmt node (everything but the base distro) and put it on a usb stick (or dvd, or directory) and be able to restore it to another machine with a single cmd. One use for this is if manufacturing set up a customer cluster config (to configure and test all of the hw), then before breaking it down and sending to the customer, they could do xcatexport to a usb stick. Then at the customer site, they physically hook up the hw, install the distro on the mn, put the usb stick in and run xcatimport, and then deploy the nodes. (There have been some schemes in the past that people have tried that included the whole os in the snapshot, but this gets into legal problems i don't want to deal with.) This would also be useful for the many solutions that will be using xcat. And could even be useful if you just want to replace the hw of your mn. 


## xcatexport Input Args

  * the location of xcat rpms (including deps) that were used to install xcat on the MN. Need to handle the case in which the admin has placed them in an otherpkgs dir under /install. If the MN was installed directly from SF, then point to the specific URL that was used. 
  * Where to put the snapshot (usb drive, dir, etc.) 

## xcatexport Function

  * tar up: rpms, db, /install, /tftpboot, /etc/xcat, all the conf files (dhcp, dns, conserver, etc), keys/certs (what else) 
    * probably need to exclude the diskless image initrds, kernels, and rootimgs (for both size and legal reasons) 
  * is there anything else in /opt/xcat that users can modify/customize that needs to be save? 
  * dumpxCATdb 
  * on the usb stick, probably have 3 files: xcatimport cmd (stand alone), xcat rpm tarball, tarball of the dirs/files/db 

## xcatimport Input Args

  * It has been suggested that we add an arg specific putting to the config on a backup MN for HA (like skip the db). But i'm not sure we need to support this if MN pools will be our primary HA approach. 

## xcatimport Function

  * untar rpms, set up yum repos in /etc/yum.repos.d or in zypper, and install them (the user must have previously set up a yum repo for the distro rpms) 
  * untar other dirs 
  * run db setup script (needs to be made tolerant of cfgloc being there) 
  * restorexCATdb 
  * what make/mk cmds need to be run? If we capture the config files from the original MN, might not have to do this 
  * start daemons (are there any that don't get auto started during installation?) 

## Restrictions and Assumptions

  * export/import must be done on same distro level and arch 
  * the user has to get the xcat &amp; dep rpms. Either they should have originally installed from the downloaded tarballs, or they have to make sure they grab the same rpms they installed from the internet, or point to the correct SF URL. xcatimport must be run with the same version of xcat as xcatexport, altho a different snap build within the same version is probably ok. 
  * we won't tar up /opt/xcat, so patches are not supported and all modified files (templates, pkg lists, etc.) must be in /install/custom 

## Optional Behaviour or Uses

  * Integrate with PCM for their MN upgrade procedure 
  * Use to install the secondary MN in an HA environment? (Probably don't need this for MN pool.) 
  * Have a separate utility to automate changing hostnames &amp; ip addrs of nodes, that can be run after xcatimport. 

## Other Design Considerations

  * **Required reviewers**: 
  * **Required approvers**: Bruce Potter 
  * **Database schema changes**: N/A 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: N/A 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
