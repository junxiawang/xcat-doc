xCAT HAMN requires that the operating system version, xCAT version and database version all be identical on the two management nodes. 

The hardware type/model are not required to be the same on the two management nodes, but it is recommended to have similar hardware capability on the two management nodes to support the same operating system and have similar management capability. 

Since the management node needs to provide IP services through broadcast such as DHCP to the compute nodes, the primary management node and standby management node should be in the same subnet to ensure the network services will work correctly after failover. 

The HAMN setup can be performed at any time during the life of the cluster. This documentation assumes the HAMN setup is performed from the very beginning of the cluster setup. You can skip the corresponding steps in case part of the setup has already been done in your cluster. 

Twin-tailed disks are not required for this support since different methods are used to ensure the data synchronization between the primary management node and standby management node. However, if you have twin-tailed disks in your cluster, then the data synchronization will be easier. You can put the related directories and files listed in section **Setup Database Replication** and section **Files Synchronization** onto the twin-tailed disks, re-mount the twin-tailed disks to the standby management node during the failover, and the corresponding steps to keep the data synchronized can be skipped. 

  
The examples in this documentation are based on the following cluster environment: 

  
_Primary Management Node: aixmn1(9.114.47.103) running AIX 6.1L and DB2 9.7_

_Standby Management Node: aixmn2(9.114.47.104) running AIX 6.1L and DB2 9.7_

  
You need to substitute the hostnames and ip address with your own values when setting up your HAMN environment. 
