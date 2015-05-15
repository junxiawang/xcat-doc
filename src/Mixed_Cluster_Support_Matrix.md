<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Supported xCAT cross-distribution hardware control and OS installation environments](#supported-xcat-cross-distribution-hardware-control-and-os-installation-environments)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

##Supported xCAT cross-distribution hardware control and OS installation environments

Notes:

**a.** All the "yes" and "no" statements in the table are referring to hardware control and os provisioning, for the general purpose management like file sync and parallel commands, we do not see any obvious problem with any of the combination.

**b.** The "yes" means should work but may or may not have been verified by the xCAT development/testing team. 

**c.** For diskless node, need another node that has the same os version and arch with the compute nodes to create diskless image, see [Building_a_Stateless_Image_of_a_Different_Architecture_or_OS](Building_a_Stateless_Image_of_a_Different_Architecture_or_OS) for more details


<!---
begin_xcat_table;
numcols=7;
colwidths=20,20,20,20,20,20,20;
-->


| | RedHat ppc64 CN | SLES ppc64 CN | RedHat x86_64 CN | SLES x86_64 CN | Ubuntu x86_64 CN | RedHat ppc64le CN | SLES ppc64le CN | Ubuntu ppc64el CN | AIX CN
------------|--------------|------------|---------------|-------------|---------------|-----------|-----------|-----------|-----------
|RedHat ppc64 MN/SN | yes | yes | yes<sup>1</sup> | yes<sup>1</sup> | yes<sup>1</sup> | yes | yes | yes | no
|SLES ppc64 MN/SN | yes | yes | yes<sup>1</sup> | yes<sup>1</sup> | yes<sup>1</sup>| yes | yes | yes | no
|RedHat x86_64 MN/SN | yes<sup>4</sup> | yes<sup>4</sup> | yes | yes | yes | yes | yes | yes | no
|SLES x86_64 MN/SN | yes<sup>4</sup> | yes<sup>4</sup> | yes | yes | yes | yes | yes | yes | no
|Ubuntu x86_64 MN/SN | yes<sup>5</sup> | yes<sup>5</sup> | yes | yes | yes | yes | yes | yes | no
|RedHat ppc64le MN/SN | yes<sup>2<sup>| yes<sup>2<sup>| yes | yes | yes | yes | yes | yes | no
|SLES ppc64le MN/SN | no| no| yes | yes | yes | yes | yes | yes | no
|Ubuntu ppc64el MN/SN | yes<sup>3<sup>| yes<sup>3<sup>| yes | yes | yes | yes | yes | yes | no
|AIX MN/SN | no | no | no | no | no | no | no | no | yes

<!---
end_xcat_table
-->

Notes:

**1.** To manage x86_64 servers from ppc64/ppc64le nodes, will need to install the packages **xnba-undi** **elilo-xcat** and **syslinux-xcat** manually on the management node. And manually run command "cp /opt/xcat/share/xcat/netboot/syslinux/pxelinux.0 /tftpboot/"

**2.** If the compute nodes are DFM managed systems, will need xCAT 2.9.1 or high versions and the ppc64le DFM and ppc64le hardware server on the management node.

**3.** If the compute nodes are DFM managed systems, will need xCAT 2.10 or high versions and the ppc64le DFM and ppc64le hardware server on the management node.

**4.** If the compute nodes are DFM managed systems, will need the ppc64le DFM and ppc64le hardware server on the management node.

**5.** Does not support DFM managed compute nodes, hardware control does not work.
