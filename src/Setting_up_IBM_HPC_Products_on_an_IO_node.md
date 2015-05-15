![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


The xCAT IBM HPC Integration function also provides instructions and sample files for setting up an I/O node in your xCAT cluster.

In an HPC cluster, I/O nodes play a different role from compute nodes. Typically, the I/O nodes are dedicated, over which the rest of the cluster stripes data transfers to achieve the required parallel I/O bandwidth. The underlying storage systems can be either direct-attached storage connected to cluster I/O nodes via FibreChannel or network-attached storage (NAS) accessed by I/O nodes over a storage network.

These instructions address how to set up IBM GPFS product on an I/O node. It assumes that you have already purchased your GPFS product, have the Linux rpms available, and are familiar with the 
http://publib.boulder.ibm.com/infocenter/clresctr/vxrx/topic/com.ibm.cluster.gpfs.doc/gpfsbooks.html GPFS documentation.

If you need other products installed on your I/O nodes, you can combine the installp bundle files or the pkglist files as needed.

These instructions are based on GPFS 3.4.5. If you are using a different version of GPFS product, you may need to make adjustments to the information provided here.

This support will use xCAT to do basic GPFS product installation and configuration into an I/O node. The support is provided as sample files only. Before using this support, you should review all files first and modify them to conform to your environment.

Since the I/O nodes install the same base HPC packages and the same GPFS product that are installed on compute nodes. So we can refer to the GPFS setup steps below:

* [Setting_up_GPFS_in_a_Statelite_or_Stateless_Cluster]
* [Setting_up_GPFS_in_a_Stateful_Cluster]