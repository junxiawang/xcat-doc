  * Initiate a network boot over HFI on Power 775 

Starting from xCAT 2.6 and working in Power 775 cluster, there are two ways to initialize a network boot to the compute nodes: one way is that using xCAT rbootseq command to setup the boot device as network adapter for the compute nodes, and after that, you can issue xCAT rpower command to power on or reset the compute node to boot from network, another way is to use xCAT rnetboot command directly. Comparing these two ways, rbootseq/rpower commands don't require the console support and operate in the console, so it has a better performance. It is recommended to use rbootseq/rpower to setup the boot device to network adapter and initialize the network boot in Power 775 cluster. 
    
    rbootseq computenodes hfi
    rpower computenodes boot
    
