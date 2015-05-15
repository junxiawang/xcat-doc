<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Background](#background)
- [NFS Redundancy Solutions](#nfs-redundancy-solutions)
- [HA-NFS in xCAT cluster](#ha-nfs-in-xcat-cluster)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

## Background

xCAT AIX stateless and Linux statelite compute nodes need to mount NFS directories from the service node, each service node can serve hundreds of compute nodes, if the NFS service on the service node or the service node itself runs into problem, all the compute nodes served by this service node will be taken down immediately, so we have to consider providing the redundant NFS service for the compute nodes. 

The reason we are focussing on NFS and not all of these other services on the service nodes, is because NFS is the only one that will take the nodes down immediately and force a reboot. For most of the other services, the admin will have a little while to run the utility to switch the nodes to another service node. For dhcp, the lease time can be made longer. For dns, they can replicate /etc/hosts if they want. This is also why we aren't putting a high priority on an automated fail over for the MN. Most customers just have another piece of hw standing by that they can bring up as an MN by hand if they need to. 

## NFS Redundancy Solutions

The ideal situation is to find out a reliable solution that the setup can be done through code easily, we tried a lot of ways, but we have not found out a perfect solution that can be fully automated, let's just describe the advantages and disadvantages of each possible way. 

1\. DRBD and heartbeat Using DRBD and heartbeat is the most common way to setup the NFS redundancy on Linux, there are a lot of web pages describe how to achieve this, you can see http://www.linux-ha.org/HaNFS, http://www.tutorialsconnect.com/2009/01/how-to-setup-a-redundant-nfs-server-with-drbd-and-heartbeat-in-centos-5/ for more details. But the DRBD and heartbeat can not support AIX, porting them to AIX will be time consuming or ven impossible. 

2\. GPFS CNFS GPFS CNFS is designed to providing reliable and high availability NFS service in cluster environment, we tried CNFS on Linux, it turned out that the CNFS work very well on providing NFS redundancy. But GPFS CNFS is not supported on AIX for now, and the GPFS team does not have any plan on supporting CNFS on AIX at least in 2010 releases. The GPFS CNFS will require at least three nodes in the cluster, we will have to add additional service nodes into the cluster if we plan to use CNFS providing NFS redundancy. Another concern for using CNFS is that the customer will need separate GPFS clusters for different building blocks, the GPFS CNFS is not designed to scale out at all. 

3\. NFSv4 on AIX and Linux The NFSv4 has a replication and migration feature that can provide high availability, but the NFSv4 is not supported very well on either Linux or AIX. Linux world is still doing some testing with NFSv4, AIX supports NFSv4 a little bit better, the diskful AIX can support NFSv4, and we tried the NFSv4 with diskful AIX, it works well. But the AIX diskless client does not support NFSv4, the current plan is that AIX diskless client will support NFSv4 in 61L/710 releases of AIX at 10/2010. The NFSv4 replication and migration only supports read-only exports, this should not be a problem for AIX diskless client, but for Linux statelite nodes, the nodes need to write data back to the NFS server, so the NFSv4 will have some problem with supporting Linux statelite nodes. 

4\. HANIM + HACMP High Availability NIM is an AIX feature that can provide HA feature for both NIM diskful installation and NIM diskless installation, the HANIM is quite easy to configure and is a very reliable way, but the biggest problem for HANIM is that the HANIM can not failover automatically, the user has to manually trigger the failover on one NIM master. AIX NIM from A to Z recommends the HANIM+HACMP to achieve the automatic NIM failover, but the HACMP is well known hard to configure, it is not possible for xCAT code to automate the HACMP configuration. 

5\. xCAT service node pool The current xCAT service node pool only provides workload balance, has not provided the high availability. 

  


## HA-NFS in xCAT cluster

We have two architectural structures for the HA-NFS in xCAT cluster: 

1\. Use the existing service nodes, each service node can act as the backup NFS server for the adjacent one or two service nodes. It requires a lot of HA-NFS domains, so the HA-NFS setup has to be automated if using this method. For all the HA-NFS tech we have investigated, the most promising one should be the NFSv4 for automatic setup. The HA-NFS setup can be done automatically when setting up the service nodes. 

2\. Use external HA-NFS domain, xCAT has the capability to point the compute nodes to mount NFS from specific NFS server. We can setup a separate HA-NFS domain such as GPFS CNFS cluster, then use the xCAT node attribute nfsserver to point the nodes to mount from the HA-NFS domain. This solution will need careful design for the external HA-NFS domain, for both the performance and the scalability, there may be thousands of nodes to mount from the HA-NFS domain at the same time. 
