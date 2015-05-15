Follow the instructions in the xCAT AIX documentation [XCAT_AIX_RTE_Diskfull_Nodes] to network boot your nodes:

** If the nodes are not already defined to NIM, run xcat2nim for all your nodes
** Run nimnodeset for your nodes
** Run rnetboot to boot your nodes
** When the nodes are up, verify that your HPC products are correctly installed.


'''NOTE'''  The ppe.pdb 5.2 lpp will fail during an AIX stateful install when it is installed from a bundle file.  The lpp postscript tries to start the scidv1 daemon using SRC, but the System Resource Controller is not active at the time the lpp is installed.  This is a known problem and will be fixed in the next release of ppe.pdb.  

As a workaround, after your nodes have been installed and rebooted, use xCAT to update the software on your nodes:

~~~~
      updatenode <noderange> -S  installp_flags="-agQXY"
~~~~

This will correctly install the failed packages since SRC should now be active on your nodes.


GPFS installation documentation advises having all your nodes running and installed with the GPFS lpps before creating your GPFS cluster.  However, with very large clusters, you may choose to only have your main GPFS infrastructure nodes up and running, create your cluster, and then add your compute nodes later.  If so, only install and boot those nodes that are critical to configuring your GPFS cluster and bringing your GPFS filesystems online.  You can network boot the compute nodes later and add them to your GPFS configuration using the mmaddnode command.