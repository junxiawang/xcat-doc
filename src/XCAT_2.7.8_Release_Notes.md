<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [New Function and Changes in Behavior](#new-function-and-changes-in-behavior)
- [Tested OS](#tested-os)
- [Restrictions and Known Problems](#restrictions-and-known-problems)
- [Key Bug fixes](#key-bug-fixes)
- [Restrictions and Known Problems](#restrictions-and-known-problems-1)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## New Function and Changes in Behavior

  * updatenode -k to hierarchical compute nodes has been disabled. Use xdsh -K to update ssh keys. See defect for details. [3652](https://sourceforge.net/p/xcat/bugs/3652/)
  * to support AIX 6.1.9 you need to install the latest AIX deps package. You need the a new level perl-Net_SSLeay.pm in the new deps package because the change to OpenSSL 1.0.1.501 in 6.1. Installing the new xcat-dep ( instoss) will upgrade the package. http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX/dep-aix-201403110451.tar.gz/download 

## Tested OS

AIX: 7.3.1.0 and 7.3.1.1) ( 71L and 71L sp1) and AIX 6.1.9.1 

LInux: Rhel5,6 SLES 10,11 

## Restrictions and Known Problems

  * NFS based statelite cannot configure bond0 in confighfi postscript. [3939](https://sourceforge.net/p/xcat/bugs/3939/)

## Key Bug fixes

  * rinstall did not support provmethod=osimagename. This support has been added. [3644](https://sourceforge.net/p/xcat/bugs/3644/)
  * rnetboot hang, P5 AIX 6.1 [3533](https://sourceforge.net/p/xcat/bugs/3533/)
  * litefile error with mkdsklsnode -r [3183](https://sourceforge.net/p/xcat/bugs/3183/)
  * confighfi postscript errors for hfi bonding [3179](https://sourceforge.net/p/xcat/bugs/3179/)
  * mkhwconn -s fails for Firebird from Redhat MN [3583](https://sourceforge.net/p/xcat/bugs/3583/)
  * lsslp unicast on Power Linux [3947](http://sourceforge.net/p/xcat/bugs/3947/)

## Restrictions and Known Problems

  * lsslp unicast doesn't support AIX. 
