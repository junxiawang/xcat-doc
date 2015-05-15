<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT 2.0.1 Release Notes](#xcat-201-release-notes)
  - [Bug Fixes and Ehancements](#bug-fixes-and-ehancements)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# xCAT 2.0.1 Release Notes

## Bug Fixes and Ehancements

  * Fix problem where IPMI sessions were left open after rpower reset 
  * Fix problem where BMC error messages were being overwritten by generic error messages 
  * Add CentOS5.2 DVD media ids to anaconda plugin. 
  * Fix a problem where a missing noderes table would abort certain operations uncleanly 
  * Ignore multicast networks in DHCP and networks table. 
  * Backup /etc/hosts before makehosts 
  * ntp postscript fixes 
  * Fix for stateless initrd generation failures under certain circumstances. 
  * Fix System p linux mac table formatting 
  * LDAP postinstall script 
  * Fedora 9 stateless fixes (networking and serial console setup) 
  * Fix Bladecenter AMM eventlog retrieval to retrieve more than 32 items 
  * Fix for system resource consumption issue with a discovery plugin crash. 
  * Fix discovery of JS-22 systems with BPET42D and later firmware AMM revisions. 
  * Fix templates with some incorrectly formatted comments that could cause nodeset failures 
  * Fix stateless RHEL5 to allow image server to be specified by name as well as IP 
  * Fix a number of documentation issues 
  * Allow nodegroups in site.dhcpinterfaces as interface criteria 
  * iDataplex thermal profile manipulation support via rspconfig 
  * Fix stateless management to not eliminate an existing etc/shadow file 
  * Fix some SLES path issues in mknb and makedns. 
  * Fix init script for RHEL4 and SLES10 
  * Update xCAT discovery environment (QS22 discovery support) 
  * Init script fixes for various services and RHEL4 and SLES10 
  * atftp patches to implement unicast block rollover for large files (recent AMM firmware sizes through tftp). 
  * atftp patches to translate '\' to '/' and check for per-node BCD files (not used by xCAT today) 
  * Fix a character truncation issue in atftp PCRE support, unused by xCAT 
  * Added "-f" flag to getmacs (force LPAR shutdown) 
  * Removed "rspconfig build" - MPA specific 
  * Correct "rinv" usage for PPC 
  * Changed "deps" table to support multiple keys (node, cmd) 
  * Corrected ppchcp table "hcp" description 
  * Strip colons from mac address before sending - rnetboot (PPC specific). 
  * Call xCAT::Usage from getmacs instead of doing usage with PPCmac.pm module 
  * Updated getmacs usage (removed -c flag) 
  * Seperated mac address returned from getmacs with colons - Linux only (PPC specific). 
  * Remove -c (colon-seperated output) from lpar_netboot() function 
  * Fix problem not writing "first" mac in writemac() with -w specified (PPC specific). 
  * Added IO-Stty-02.tar.gz to perl-IO-Stty 
