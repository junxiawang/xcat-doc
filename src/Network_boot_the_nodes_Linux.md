Network boot your nodes (for new node installations only - skip this step if you are adding HPC software to running nodes as described in the previous step):
** Run "nodeset <noderange> install" for all your nodes
** Run rnetboot to boot your nodes
** When the nodes are up, verify that all the HPC rpms are all correctly installed.

GPFS installation instructions advise having all your nodes running and installed with the GPFS rpms before creating your GPFS cluster.  However, with very large clusters, you may choose to only have your main GPFS infrastructure nodes up and running, create your cluster, and then add your compute nodes later.  If so, only install and boot those nodes that are critical to configuring your GPFS cluster and bringing your GPFS filesystems online.  You can network boot the compute nodes later and add them to your GPFS configuration using the mmaddnode command.