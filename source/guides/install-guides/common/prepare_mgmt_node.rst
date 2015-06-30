Prepare the Management Node for xCAT Installation
=================================================

These steps prepare the Management Node or xCAT Installation

Install an OS on the Management Node
------------------------------------

**System Requirements:**

The hardware system requirements for your xCAT management node largely depends on the size of the cluster you plan to manage and the type of provisioning being used (diskful, diskless, system clones, etc).  The majority of system load comes during cluster provisioning time.

(Should have some real world use case numbers or examples here)

Install one of the supported operating system onto the management node.  

The xCAT software RPMs will automatically pull in base software rpms provided by the Operating System if they are not already installed onto the machine. 

Configure the Base OS Repository
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

xCAT uses Linux Package Management (yum, zypper, apt, etc) to install the RPM packages and resolve dependency packages provided by the base operating system.  

Follow this section to create the repository for the base operating system on the management node

#. Copy the dvd .iso file onto the management node: ::

     mkdir -p /tmp/iso
     scp <user>@<server>:/images/iso/rhels7.1/ppc64le/RHEL-LE-7.1-20150219.1-Server-ppc64le-dvd1.iso /tmp/iso
   
#. Mount the dvd iso to a directory on the management node.  Ex. ``/mnt/iso/rhels7.1`` ::

     # for RHEL servers
     mkdir -p /mnt/iso/rhels7.1
     mount -o loop /tmp/iso/RHEL-LE-7.1-20150219.1-Server-ppc64le-dvd1.iso /mnt/iso/rhels7.1

     # for SLES servers
     mkdir -p /mnt/iso/sles12
     mount -o loop /tmp/iso/SLE-12-Server-DVD-ppc64le-GM-DVD1.iso /mnt/iso/sles12

#. Create the local repository configuration file pointing to mounted iso image. ::

     # for RHEL servers
     vi /etc/yum/yum.repos.d/rhels71-base.repo

     # for SLES servers
     vi /etc/zypp/repos.d/sles12-base.repo



# Setting up OS Repository on Mgmt Node 

Disable system services
-----------------------
* Set up Network
* Configure Network Interface Cards (NICs)
* Install the Management Node OS
* Supported OS and Hardware
