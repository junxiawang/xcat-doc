<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

    - [Option 1: Installing Stateful Nodes Using ISOs or DVDs](#option-1-installing-stateful-nodes-using-isos-or-dvds)
      - [**Create the Distro Repository on the MN**](#create-the-distro-repository-on-the-mn)
      - [**Select or Create an osimage Definition**](#select-or-create-an-osimage-definition)
      - [**Install a New Kernel on the Nodes (Optional)**](#install-a-new-kernel-on-the-nodes-optional)
      - [**Customize the disk partitioning (Optional)**](#customize-the-disk-partitioning-optional)
        - [Partition definition file](#partition-definition-file)
          - [Create partition file](#create-partition-file)
- [Uncomment this PReP line for IBM Power servers](#uncomment-this-prep-line-for-ibm-power-servers)
- [part None --fstype "PPC PReP Boot" --size 8 --ondisk sda](#part-none---fstype-ppc-prep-boot---size-8---ondisk-sda)
- [Uncomment this efi line for x86_64 servers](#uncomment-this-efi-line-for-x86_64-servers)
- [part /boot/efi --size 50 --ondisk /dev/sda --fstype efi](#part-bootefi---size-50---ondisk-devsda---fstype-efi)
- [Uncomment this PReP line for IBM Power servers](#uncomment-this-prep-line-for-ibm-power-servers-1)
- [part None --fstype "PPC PReP Boot" --ondisk /dev/sda --size 8](#part-none---fstype-ppc-prep-boot---ondisk-devsda---size-8)
- [Uncomment this efi line for x86_64 servers](#uncomment-this-efi-line-for-x86_64-servers-1)
- [part /boot/efi --size 50 --ondisk /dev/sda --fstype efi](#part-bootefi---size-50---ondisk-devsda---fstype-efi-1)
          - [Associate partition file with osimage](#associate-partition-file-with-osimage)
        - [Partitioning definition script(for RedHat and Ubuntu)](#partitioning-definition-scriptfor-redhat-and-ubuntu)
          - [Create partition script](#create-partition-script)
          - [Associate partition script with osimage:](#associate-partition-script-with-osimage)
        - [Partitioning disk file(For Ubuntu only)](#partitioning-disk-filefor-ubuntu-only)
          - [Associate partition disk file with osimage:](#associate-partition-disk-file-with-osimage)
        - [Partitioning disk script(For Ubuntu only)](#partitioning-disk-scriptfor-ubuntu-only)
          - [Associate partition disk script with osimage:](#associate-partition-disk-script-with-osimage)
        - [Additional preseed configuration file and additional preseed configuration script (For Ubuntu only)](#additional-preseed-configuration-file-and-additional-preseed-configuration-script-for-ubuntu-only)
          - [Associate additional preseed configuration file or additional preseed configuration script with osimage:](#associate-additional-preseed-configuration-file-or-additional-preseed-configuration-script-with-osimage)
          - [Debug partition script](#debug-partition-script)
      - [** set the kernel options which will be persistent the installed system(Optional) **](#-set-the-kernel-options-which-will-be-persistent-the-installed-systemoptional-)
      - [**\[SLES\] set the netwait kernel parameter (Optional)**](#%5Csles%5C-set-the-netwait-kernel-parameter-optional)
      - [**Update the Distro at a Later Time**](#update-the-distro-at-a-later-time)
    - [Option 2: Installing Stateful Nodes Using Sysclone](#option-2-installing-stateful-nodes-using-sysclone)
      - [**Install or Configure the Golden Client**](#install-or-configure-the-golden-client)
      - [**Capture image from the Golden Client **](#capture-image-from-the-golden-client-)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

This section describes deploying stateful nodes.
There are two options to install your nodes as stateful (diskful) nodes: 

  1. Use ISOs or DVDs, follow the Option 1 , Installing Stateful Nodes using ISOs or DVDs below.
  2. Clone new nodes from a pre-installed/pre-configured node, follow the Option 2,Installing Stateful Nodes Using Sysclone below.





### Option 1: Installing Stateful Nodes Using ISOs or DVDs

This section describes the process for setting up xCAT to install nodes; that is how to install an OS on the disk of each node. 

#### **Create the Distro Repository on the MN**

The [copycds](http://xcat.sourceforge.net/man8/copycds.8.html) command copies the contents of the linux distro media to /install/&lt;os&gt;/&lt;arch&gt; so that it will be available to install nodes with or create diskless images. 

  * Obtain the Redhat or SLES ISOs or DVDs. 
  * If using an ISO, copy it to (or NFS mount it on) the management node, and then run: 
 
~~~~   
    copycds <path>/RHEL6.2-*-Server-x86_64-DVD1.iso
~~~~      

  * If using a DVD, put it in the DVD drive of the management node and run:
 
~~~~      
    copycds /dev/dvd       # or whatever the device name of your dvd drive is
~~~~      

Tip: if this is the same distro version as your management node, create a .repo file in /etc/yum.repos.d with content similar to: 

~~~~     
    [local-rhels6.2-x86_64]
    name=xCAT local rhels 6.2
    baseurl=file:/install/rhels6.2/x86_64
    enabled=1
    gpgcheck=0
~~~~      

This way, if you need some additional RPMs on your MN at a later, you can simply install them using yum. Or if you are installing other software on your MN that requires some additional RPMs from the disto, they will automatically be found and installed. 

#### **Select or Create an osimage Definition**

The copycds command also automatically creates several osimage defintions in the database that can be used for node deployment. To see them: 

~~~~  
    
    lsdef -t osimage          # see the list of osimages
    lsdef -t osimage <osimage-name>          # see the attributes of a particular osimage
~~~~      

From the list above, select the osimage for your distro, architecture, provisioning method (in this case install), and profile (compute, service, etc.). Although it is optional, we recommend you make a copy of the osimage, changing its name to a simpler name. For example: 

~~~~  
    
    lsdef -t osimage -z rhels6.2-x86_64-install-compute | sed 's/^[^ ]\+:/mycomputeimage:/' | mkdef -z
~~~~      

This displays the osimage "rhels6.2-x86_64-install-compute" in a format that can be used as input to mkdef, but on the way there it uses sed to modify the name of the object to "mycomputeimage". 

Initially, this osimage object points to templates, pkglists, etc. that are shipped by default with xCAT. And some attributes, for example otherpkglist and synclists, won't have any value at all because xCAT doesn't ship a default file for that. You can now change/fill in any [osimage attributes](http://xcat.sourceforge.net/man7/osimage.7.html) that you want. A general convention is that if you are modifying one of the default files that an osimage attribute points to, copy it into /install/custom and have your osimage point to it there. (If you modify the copy under /opt/xcat directly, it will be over-written the next time you upgrade xCAT.) 

But for now, we will use the default values in the osimage definition and continue on. (If you really want to see examples of modifying/creating the pkglist, template, otherpkgs pkglist, and sync file list, see the section [Using_Provmethod=osimagename]. Most of the examples there can be used for stateful nodes too.) 

#### **Install a New Kernel on the Nodes (Optional)**

Create a postscript file called (for example) updatekernel: 

~~~~  
    
    vi /install/postscripts/updatekernel
~~~~      

Add the following lines to the file: 

~~~~      
    #!/bin/bash
    rpm -Uivh data/kernel-*rpm
~~~~      

Change the permission on the file: 

~~~~      
    chmod 755 /install/postscripts/updatekernel
~~~~      

Make the new kernel RPM available to the postscript: 

~~~~      
    mkdir /install/postscripts/data
    cp <kernel> /install/postscripts/data
~~~~      

Add the postscript to your compute nodes: 

~~~~      
    chdef -p -t group compute postscripts=updatekernel
~~~~      

Now when you install your nodes (done in a step below), it will also update the kernel. 

Alternatively, you could install your nodes with the stock kernel, and update the nodes afterward using updatenode and the same postscript above, in this case, you need to reboot your nodes to make the new kernel be effective. 

#### **Customize the disk partitioning (Optional)**

By default, xCAT will install the operating system on the first disk and with default partitions layout in the node. However, you may choose to customize the disk partitioning during the install process and define a specific disk layout. You can do this in one of two ways: 

##### Partition definition file

You could create a customized osimage partition file, say /install/custom/my-partitions, that contains the disk partitioning definition, then associate the partition file with osimage, the nodeset command will insert the contents of this file directly into the generated autoinst configuration file that will be used by the OS installer. 

###### Create partition file

The partition file must follow the partitioning syntax of the installer(e.g. kickstart for RedHat, AutoYaST for SLES， Preseed for Ubuntu).

Here are examples of the partition file:

**RedHat Standard Partitions for IBM Power machines**

~~~~
# Uncomment this PReP line for IBM Power servers
#part None --fstype "PPC PReP Boot" --size 8 --ondisk sda
# Uncomment this efi line for x86_64 servers
#part /boot/efi --size 50 --ondisk /dev/sda --fstype efi
part /boot --size 256 --fstype ext4
part swap --recommended --ondisk sda
part / --size 1 --grow --fstype ext4 --ondisk sda
~~~~

** RedHat LVM Partitions**

~~~~
# Uncomment this PReP line for IBM Power servers
#part None --fstype "PPC PReP Boot" --ondisk /dev/sda --size 8
# Uncomment this efi line for x86_64 servers
#part /boot/efi --size 50 --ondisk /dev/sda --fstype efi
part /boot --size 256 --fstype ext4 --ondisk /dev/sda
part swap --recommended --ondisk /dev/sda
part pv.01 --size 1 --grow --ondisk /dev/sda
volgroup system pv.01
logvol / --vgname=system --name=root --size 1 --grow --fstype ext4
~~~~


** RedHat RAID 1 configuration **

See [Use_RAID1_In_xCAT_Cluster](Use_RAID1_In_xCAT_Cluster/#deploy-diskful-nodes-with-raid1-setup-on-redhat) for more details.



** x86_64 SLES Standard Partitions**

~~~~    
      <drive>
         <device>/dev/sda</device>
         <initialize config:type="boolean">true</initialize>
         <use>all</use>
         <partitions config:type="list">
           <partition>
             <create config:type="boolean">true</create>
             <filesystem config:type="symbol">swap</filesystem>
             <format config:type="boolean">true</format>
             <mount>swap</mount>
             <mountby config:type="symbol">path</mountby>
             <partition_nr config:type="integer">1</partition_nr>
             <partition_type>primary</partition_type>
             <size>32G</size>
           </partition>
           <partition>
             <create config:type="boolean">true</create>
             <filesystem config:type="symbol">ext3</filesystem>
             <format config:type="boolean">true</format>
             <mount>/</mount>
             <mountby config:type="symbol">path</mountby>
             <partition_nr config:type="integer">2</partition_nr>
             <partition_type>primary</partition_type>
             <size>64G</size>
           </partition>
         </partitions>
       </drive>
~~~~

** x86_64 SLES LVM Partitions**

~~~~
<drive>
  <device>/dev/sda</device>
  <initialize config:type="boolean">true</initialize>
  <partitions config:type="list">
    <partition>
      <create config:type="boolean">true</create>
      <crypt_fs config:type="boolean">false</crypt_fs>
      <filesystem config:type="symbol">ext3</filesystem>
      <format config:type="boolean">true</format>
      <loop_fs config:type="boolean">false</loop_fs>
      <mountby config:type="symbol">device</mountby>
      <partition_id config:type="integer">65</partition_id>
      <partition_nr config:type="integer">1</partition_nr>
      <pool config:type="boolean">false</pool>
      <raid_options/>
      <resize config:type="boolean">false</resize>
      <size>8M</size>
      <stripes config:type="integer">1</stripes>
      <stripesize config:type="integer">4</stripesize>
      <subvolumes config:type="list"/>
    </partition>
    <partition>
      <create config:type="boolean">true</create>
      <crypt_fs config:type="boolean">false</crypt_fs>
      <filesystem config:type="symbol">ext3</filesystem>
      <format config:type="boolean">true</format>
      <loop_fs config:type="boolean">false</loop_fs>
      <mount>/boot</mount>
      <mountby config:type="symbol">device</mountby>
      <partition_id config:type="integer">131</partition_id>
      <partition_nr config:type="integer">2</partition_nr>
      <pool config:type="boolean">false</pool>
      <raid_options/>
      <resize config:type="boolean">false</resize>
      <size>256M</size>
      <stripes config:type="integer">1</stripes>
      <stripesize config:type="integer">4</stripesize>
      <subvolumes config:type="list"/>
    </partition>
    <partition>
      <create config:type="boolean">true</create>
      <crypt_fs config:type="boolean">false</crypt_fs>
      <format config:type="boolean">false</format>
      <loop_fs config:type="boolean">false</loop_fs>
      <lvm_group>vg0</lvm_group>
      <mountby config:type="symbol">device</mountby>
      <partition_id config:type="integer">142</partition_id>
      <partition_nr config:type="integer">3</partition_nr>
      <pool config:type="boolean">false</pool>
      <raid_options/>
      <resize config:type="boolean">false</resize>
      <size>max</size>
      <stripes config:type="integer">1</stripes>
      <stripesize config:type="integer">4</stripesize>
      <subvolumes config:type="list"/>
    </partition>
  </partitions>
  <pesize></pesize>
  <type config:type="symbol">CT_DISK</type>
  <use>all</use>
</drive>
<drive>
  <device>/dev/vg0</device>
  <initialize config:type="boolean">true</initialize>
  <partitions config:type="list">
    <partition>
      <create config:type="boolean">true</create>
      <crypt_fs config:type="boolean">false</crypt_fs>
      <filesystem config:type="symbol">swap</filesystem>
      <format config:type="boolean">true</format>
      <loop_fs config:type="boolean">false</loop_fs>
      <lv_name>swap</lv_name>
      <mount>swap</mount>
      <mountby config:type="symbol">device</mountby>
      <partition_id config:type="integer">130</partition_id>
      <partition_nr config:type="integer">5</partition_nr>
      <pool config:type="boolean">false</pool>
      <raid_options/>
      <resize config:type="boolean">false</resize>
      <size>auto</size>
      <stripes config:type="integer">1</stripes>
      <stripesize config:type="integer">4</stripesize>
      <subvolumes config:type="list"/>
    </partition>
    <partition>
      <create config:type="boolean">true</create>
      <crypt_fs config:type="boolean">false</crypt_fs>
      <filesystem config:type="symbol">ext3</filesystem>
      <format config:type="boolean">true</format>
      <loop_fs config:type="boolean">false</loop_fs>
      <lv_name>root</lv_name>
      <mount>/</mount>
      <mountby config:type="symbol">device</mountby>
      <partition_id config:type="integer">131</partition_id>
      <partition_nr config:type="integer">1</partition_nr>
      <pool config:type="boolean">false</pool>
      <raid_options/>
      <resize config:type="boolean">false</resize>
      <size>max</size>
      <stripes config:type="integer">1</stripes>
      <stripesize config:type="integer">4</stripesize>
      <subvolumes config:type="list"/>
    </partition>
  </partitions>
  <pesize></pesize>
  <type config:type="symbol">CT_LVM</type>
  <use>all</use>
</drive>
~~~~    

** ppc64 SLES Standard Partitions**

~~~~
    <drive>
      <device>/dev/sda</device>
      <initialize config:type="boolean">true</initialize>
      <partitions config:type="list">
        <partition>
          <create config:type="boolean">true</create>
          <crypt_fs config:type="boolean">false</crypt_fs>
          <filesystem config:type="symbol">ext3</filesystem>
          <format config:type="boolean">false</format>
          <loop_fs config:type="boolean">false</loop_fs>
          <mountby config:type="symbol">device</mountby>
          <partition_id config:type="integer">65</partition_id>
          <partition_nr config:type="integer">1</partition_nr>
          <resize config:type="boolean">false</resize>
          <size>auto</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <crypt_fs config:type="boolean">false</crypt_fs>
          <filesystem config:type="symbol">swap</filesystem>
          <format config:type="boolean">true</format>
          <fstopt>defaults</fstopt>
          <loop_fs config:type="boolean">false</loop_fs>
          <mount>swap</mount>
          <mountby config:type="symbol">id</mountby>
          <partition_id config:type="integer">130</partition_id>
          <partition_nr config:type="integer">2</partition_nr>
          <resize config:type="boolean">false</resize>
          <size>auto</size>
        </partition>
        <partition>
          <create config:type="boolean">true</create>
          <crypt_fs config:type="boolean">false</crypt_fs>
          <filesystem config:type="symbol">ext3</filesystem>
          <format config:type="boolean">true</format>
          <fstopt>acl,user_xattr</fstopt>
          <loop_fs config:type="boolean">false</loop_fs>
          <mount>/</mount>
          <mountby config:type="symbol">id</mountby>
          <partition_id config:type="integer">131</partition_id>
          <partition_nr config:type="integer">3</partition_nr>
          <resize config:type="boolean">false</resize>
          <size>max</size>
        </partition>
      </partitions>
      <pesize></pesize>
      <type config:type="symbol">CT_DISK</type>
      <use>all</use>
    </drive>
~~~~

** SLES RAID 1 configuration **

See [Use_RAID1_In_xCAT_Cluster](Use_RAID1_In_xCAT_Cluster/#deploy-diskful-nodes-with-raid1-setup-on-sles) for more details.


** Ubuntu standard partition configuration on PPC64le **

~~~~

8 1 32 prep
        $primary{ }
        $bootable{ }
        method{ prep } .

256 256 512 ext3
        $primary{ }
        method{ format }
        format{ }
        use_filesystem{ }
        filesystem{ ext3 }
        mountpoint{ /boot } .

64 512 300% linux-swap
        method{ swap }
        format{ } .

512 1024 4096 ext3
        $primary{ }
        method{ format }
        format{ }
        use_filesystem{ }
        filesystem{ ext4 }
        mountpoint{ / } .

100 10000 1000000000 ext3
        method{ format }
        format{ }
        use_filesystem{ }
        filesystem{ ext4 }
        mountpoint{ /home } .

~~~~

** Ubuntu standard partition configuration on X86_64 **

~~~~

256 256 512 vfat
        $primary{ }
        method{ format }
        format{ }
        use_filesystem{ }
        filesystem{ vfat }
        mountpoint{ /boot/efi } .

256 256 512 ext3
        $primary{ }
        method{ format }
        format{ }
        use_filesystem{ }
        filesystem{ ext3 }
        mountpoint{ /boot } .

64 512 300% linux-swap
        method{ swap }
        format{ } .

512 1024 4096 ext3
        $primary{ }
        method{ format }
        format{ }
        use_filesystem{ }
        filesystem{ ext4 }
        mountpoint{ / } .

100 10000 1000000000 ext3
        method{ format }
        format{ }
        use_filesystem{ }
        filesystem{ ext4 }
        mountpoint{ /home } .

~~~~

If none of these examples could be used in your cluster, you could refer to the [Kickstart documentation](http://fedoraproject.org/wiki/Anaconda/Kickstart#part_or_partition) or [Autoyast documentation](https://doc.opensuse.org/projects/autoyast/configuration.html#CreateProfile.Partitioning) or [Preseed documentation](https://www.debian.org/releases/stable/i386/apbs04.html.en#preseed-partman) to write your own partitions layout. Meanwhile, RedHat and SuSE provides some tools that could help generate kickstart/autoyast templates, in which you could refer to the partition section for the partitions layout information:

* RedHat:
    * The file /root/anaconda-ks.cfg is a sample kickstart file created by RedHat installer during the installation process based on the options that you selected.
    * system-config-kickstart is a tool with graphical interface for creating kickstart files
  
* SLES
    * Use yast2 autoyast in GUI or CLI mode to customize the installation options and create autoyast file
    * Use yast2 clone_system to create autoyast configuration file /root/autoinst.xml to clone an existing system

* Ubuntu
    * For detailed information see the files partman-auto-recipe.txt and partman-auto-raid-recipe.txt included in the debian-installer package. Both files are also available from the debian-installer source repository. Note that the supported functionality may change between releases.

###### Associate partition file with osimage 

~~~~      

      chdef -t osimage <osimagename> partitionfile=/install/custom/my-partitions
      nodeset <nodename> osimage=<osimage>
~~~~      

For Redhat, when nodeset runs and generates the /install/autoinst file for a node, it will replace the #XCAT_PARTITION_START#...#XCAT_PARTITION_END# directives from your osimage template with the contents of your custom partitionfile. 

For Ubuntu, when nodeset runs and generates the /install/autoinst file for a node, it will generate a script to write the partition configuration to /tmp/partitionfile, this script will replace the #XCA_PARTMAN_RECIPE_SCRIPT# directive in /install/autoinst/<node>.pre. 

##### Partitioning definition script(for RedHat and Ubuntu)

Create a shell script that will be run on the node during the install process to dynamically create the disk partitioning definition. This script will be run during the OS installer %pre script on Redhat or preseed/early_command on Unbuntu execution and must write the correct partitioning definition into the file /tmp/partitionfile on the node. 


###### Create partition script

The purpose of the partition script is to create the /tmp/partionfile that will be inserted into the kickstart/autoyast/preseed template, the script could include complex logic like select which disk to install and even configure RAID, etc..

**Note**: the partition script feature is not thoroughly tested on SLES, there might be problems, use this feature on SLES at your own risk.

Here is an example of the partition script on Redhat and SLES, the partitioning script is /install/custom/my-partitions.sh:
 
~~~~     
instdisk="/dev/sda"

modprobe ext4 >& /dev/null
modprobe ext4dev >& /dev/null
if grep ext4dev /proc/filesystems > /dev/null; then
        FSTYPE=ext3
elif grep ext4 /proc/filesystems > /dev/null; then
        FSTYPE=ext4
else
        FSTYPE=ext3
fi
BOOTFSTYPE=ext3
EFIFSTYPE=vfat
if uname -r|grep ^3.*el7 > /dev/null; then
    FSTYPE=xfs
    BOOTFSTYPE=xfs
    EFIFSTYPE=efi
fi

if [ `uname -m` = "ppc64" ]; then
        echo 'part None --fstype "PPC PReP Boot" --ondisk '$instdisk' --size 8' >> /tmp/partitionfile
fi
if [ -d /sys/firmware/efi ]; then
    echo 'bootloader --driveorder='$instdisk >> /tmp/partitionfile
        echo 'part /boot/efi --size 50 --ondisk '$instdisk' --fstype $EFIFSTYPE' >> /tmp/partitionfile
else
    echo 'bootloader' >> /tmp/partitionfile
fi

echo "part /boot --size 512 --fstype $BOOTFSTYPE --ondisk $instdisk" >> /tmp/partitionfile
echo "part swap --recommended --ondisk $instdisk" >> /tmp/partitionfile
echo "part / --size 1 --grow --ondisk $instdisk --fstype $FSTYPE" >> /tmp/partitionfile
~~~~ 
     
The following is an example of the partition script on Ubuntu, the partitioning script is /install/custom/my-partitions.sh:

~~~~

if [ -d /sys/firmware/efi ]; then
    echo "ubuntu-efi ::" > /tmp/partitionfile
    echo "    512 512 1024 fat16" >> /tmp/partitionfile
    echo '    $iflabel{ gpt } $reusemethod{ } method{ efi } format{ }' >> /tmp/partitionfile
    echo "    ." >> /tmp/partitionfile
else
    echo "ubuntu-boot ::" > /tmp/partitionfile
    echo "100 50 100 ext3" >> /tmp/partitionfile
    echo '    $primary{ } $bootable{ } method{ format } format{ } use_filesystem{ } filesystem{ ext3 } mountpoint{ /boot }' >> /tmp/partitionfile
    echo "    ." >> /tmp/partitionfile
fi
echo "500 10000 1000000000 ext3" >> /tmp/partitionfile
echo "    method{ format } format{ } use_filesystem{ } filesystem{ ext3 } mountpoint{ / }" >> /tmp/partitionfile
echo "    ." >> /tmp/partitionfile
echo "2048 512 300% linux-swap" >> /tmp/partitionfile
echo "    method{ swap } format{ }" >> /tmp/partitionfile
echo "    ." >> /tmp/partitionfile

~~~~

###### Associate partition script with osimage: 

~~~~  
         chdef -t osimage <osimagename> partitionfile='s:/install/custom/my-partitions.sh'
         nodeset <nodename> osimage=<osimage>
~~~~  


Note: the 's:' preceding the filename tells nodeset that this is a script. 
For Redhat, when nodeset runs and generates the /install/autoinst file for a node, it will add the execution of the contents of this script to the %pre section of that file. The nodeset command will then replace the #XCAT_PARTITION_START#...#XCAT_PARTITION_END# directives from the osimage template file with "%include /tmp/partitionfile" to dynamically include the tmp definition file your script created. 
For Ubuntu, when nodeset runs and generates the /install/autoinst file for a node, it will replace the "#XCA_PARTMAN_RECIPE_SCRIPT#" directive and add the execution of the contents of this script to the /install/autoinst/<node>.pre, the /install/autoinst/<node>.pre script will be run in the preseed/early_command.
 
##### Partitioning disk file(For Ubuntu only)
The disk file contains the name of the disks to partition in traditional, non-devfs format and delimited with space “ ”, for example, 

~~~~
/dev/sda /dev/sdb 
~~~~

If not specified, the default value will be used.

###### Associate partition disk file with osimage: 

~~~~  
         chdef -t osimage <osimagename> -p partitionfile='d:/install/custom/partitiondisk'
         nodeset <nodename> osimage=<osimage>
~~~~  

Note: the 'd:' preceding the filename tells nodeset that this is a partition disk file. 
For Ubuntu, when nodeset runs and generates the /install/autoinst file for a node, it will generate a script to write the content of the partition disk file to /tmp/boot_disk, this context to run the script will replace the #XCA_PARTMAN_DISK_SCRIPT# directive in /install/autoinst/<node>.pre. 


##### Partitioning disk script(For Ubuntu only)
The disk script contains a script to generate a partitioning disk file named "/tmp/boot_disk". for example, 

~~~~
    rm /tmp/devs-with-boot 2>/dev/null || true; 
    for d in $(list-devices partition); do 
        mkdir -p /tmp/mymount; 
        rc=0; 
        mount $d /tmp/mymount || rc=$?; 
        if [[ $rc -eq 0 ]]; then 
            [[ -d /tmp/mymount/boot ]] && echo $d >>/tmp/devs-with-boot; 
            umount /tmp/mymount; 
        fi 
    done; 
    if [[ -e /tmp/devs-with-boot ]]; then 
        head -n1 /tmp/devs-with-boot | egrep  -o '\S+[^0-9]' > /tmp/boot_disk; 
        rm /tmp/devs-with-boot 2>/dev/null || true; 
    else 
        DEV=`ls /dev/disk/by-path/* -l | egrep -o '/dev.*[s|h|v]d[^0-9]$' | sort -t : -k 1 -k 2 -k 3 -k 4 -k 5 -k 6 -k 7 -k 8 -g | head -n1 | egrep -o '[s|h|v]d.*$'`; 
        if [[ "$DEV" == "" ]]; then DEV="sda"; fi; 
        echo "/dev/$DEV" > /tmp/boot_disk; 
    fi;  
~~~~

If not specified, the default value will be used.

###### Associate partition disk script with osimage: 

~~~~  
         chdef -t osimage <osimagename> -p partitionfile='s:d:/install/custom/partitiondiskscript'
         nodeset <nodename> osimage=<osimage>
~~~~  

Note: the 's:' prefix tells nodeset that is a script, the 's:d:' preceding the filename tells nodeset that this is a script to generate the partition disk file. 
For Ubuntu, when nodeset runs and generates the /install/autoinst file for a node, this context to run the script will replace the #XCA_PARTMAN_DISK_SCRIPT# directive in /install/autoinst/<node>.pre. 

##### Additional preseed configuration file and additional preseed configuration script (For Ubuntu only)

To support other specific partition methods such as RAID or LVM in Ubuntu, some additional preseed configuration entries should be specified, these entries can be specified in 2 ways:

    'c:<the absolute path of the additional preseed config file>', the additional preseed config file
     contains the additional preseed entries in "d-i ..." syntax. When "nodeset", the     
    #XCA_PARTMAN_ADDITIONAL_CFG# directive in /install/autoinst/<node> will be replaced with 
    content of the config file, an example:

~~~~

d-i partman-auto/method string raid
d-i partman-md/confirm boolean true

~~~~ 

    's:c:<the absolute path of the additional preseed config script>',  the additional preseed config
     script is a script to set the preseed values with "debconf-set". When "nodeset", the 
    #XCA_PARTMAN_ADDITIONAL_CONFIG_SCRIPT# directive in /install/autoinst/<node>.pre will be replaced 
    with the content of the script, an example: 

~~~~

debconf-set partman-auto/method string raid
debconf-set partman-md/confirm boolean true

~~~~ 

If not specified, the default value will be used.

###### Associate additional preseed configuration file or additional preseed configuration script with osimage: 

Associate additional preseed configuration file by:

~~~~  
         chdef -t osimage <osimagename> -p partitionfile='c:/install/custom/configfile'
         nodeset <nodename> osimage=<osimage>
~~~~  

Associate additional preseed configuration script by:

~~~~  
         chdef -t osimage <osimagename> -p partitionfile='s:c:/install/custom/configscript'
         nodeset <nodename> osimage=<osimage>
~~~~  




###### Debug partition script

If the partition script has any problem, the os installation will probably hang, to debug the partition script, you could enable the ssh access in the installer during installation, then login the node through ssh after the installer has started the sshd.
For Redhat, you could specify sshd in the kernel parameter and then kickstart will start the sshd when Anaconda starts, then you could login the node using ssh to debug the problem:

~~~~
chdef <nodename> addkcmdline="sshd"
nodeset <nodename> osimage=<osimage>
~~~~

For Ubuntu,  you could insert the following preseed entries to /install/autoinst/<node> to tell the debian installer to start the ssh server and wait for you to connect:

~~~~
d-i anna/choose_modules string network-console
d-i preseed/early_command string anna-install network-console

d-i network-console/password-disabled boolean false
d-i network-console/password           password cluster
d-i network-console/password-again     password cluster
~~~~
** Note: For the entry "d-i preseed/early_command string anna-install network-console",if there is already a "preseed/early_command"  entry in /install/autoinst/<node>,  the value "anna-install network-console" should be appended to the existed "preseed/early_command"  entry carefully, otherwise, the former will be overwritten. 

#### ** set the kernel options which will be persistent the installed system(Optional) **

The attributes “linuximage.addkcmdline” and “bootparams.addkcmdline” are the interfaces for the user to specify some additional kernel options to be passed to kernel/installer for node deployment. There are some scenarios that users want to specify some kernel options persistent after installation, that is, the specified kernel options will be effective(can be found in /proc/cmdline) among normal system reboots after installation.  

This can be finished by specifying the persistent kernel options with the prefix "R::", for example, to specify the redhat7 kernel option “net.ifnames=0” persistent:

~~~~

chdef -t osimage -o rhels7-ppc64-install-compute -p addkcmdline="R::net.ifnames=0"

~~~~

**Note**: The persistent kernel options with prefix "R::" won't be passed to the kernel/installer for node deployment.

#### **\[SLES\] set the netwait kernel parameter (Optional)**

If there are quite a few(e.g. 12) network adapters on the SLES compute nodes, the os provisioning progress might hang because that the kernel would timeout waiting for the network driver to initialize. The symptom is the compute node could not find os provisioning repository, the error message is "Please make sure your installation medium is available. Retry?".

To avoid this problem, you could specify the kernel parameter "netwait" to have the kernel wait the network adapters initialization. On a node with 12 network adapters, the netwait=60 did the trick.

~~~~
  chdef <nodename> -p addkcmdline="netwait=60"
~~~~

#### **Update the Distro at a Later Time**

After the initial install of the distro onto nodes, if you want to update the distro on the nodes (either with a few updates or a new SP) without reinstalling the nodes: 

  * create the new repo using copycds: 

~~~~  
    
    copycds <path>/RHEL6.3-*-Server-x86_64-DVD1.iso
~~~~      

     Or, for just a few updated rpms, you can copy the updated rpms from the distributor into a directory under /install and run createrepo in that directory. 

  * add the new repo to the pkgdir attribute of the osimage: 

~~~~      
    chdef -t osimage rhels6.2-x86_64-install-compute -p pkgdir=/install/rhels6.3/x86_64
    
~~~~ 
 
     Note: the above command will add a 2nd repo to the pkgdir attribute. This is only supported for xCAT 2.8.2 and above. For earlier versions of xCAT, omit the -p flag to replace the existing repo directory with the new one. 

  * run the ospkgs postscript to have yum update all rpms on the nodes 

~~~~      
    updatenode compute -P ospkgs
~~~~      

### Option 2: Installing Stateful Nodes Using Sysclone

This section describes how to install or configure a diskful node (we call it a golden-client), capture an osimage from this golden-client, then the osimage can be used to install/clone other nodes. See [Using_Clone_to_Deploy_Server](Using_Clone_to_Deploy_Server) for more information.

Note: this support is available in xCAT 2.8.2 and above. 

#### **Install or Configure the Golden Client**

If you want to use the **sysclone** provisioning method, you need a golden-client. In this way, you can customize and tweak the golden-client’s software and configuration according to your needs, and verify it’s proper operation. Once the image is captured and deployed, the new nodes will behave in the same way the golden-client does. 

To install a golden-client, follow the section [Installing_Stateful_Linux_Nodes#Option_1:_Installing_Stateful_Nodes_Using_ISOs_or_DVDs](Installing_Stateful_Linux_Nodes/#option-1-installing-stateful-nodes-using-isos-or-dvds). 

To install the systemimager rpms on the golden-client, do these steps on the mgmt node: 

  * Download the xcat-dep tarball which includes systemimager rpms. (You might already have the xcat-dep tarball on the mgmt node.) 

    Go to [xcat-dep](http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux) and get the latest xCAT dependency tarball. Copy the file to the management node and untar it in the appropriate sub-directory of /install/post/otherpkgs. For example: 

~~~~   
    (For RH/CentOS):    
    mkdir -p /install/post/otherpkgs/rhels6.3/x86_64/xcat
    cd /install/post/otherpkgs/rhels6.3/x86_64/xcat
    tar jxvf xcat-dep-*.tar.bz2
     
    

    (For SLES):  
    mkdir -p /install/post/otherpkgs/sles11.3/x86_64/xcat
    cd /install/post/otherpkgs/sles11.3/x86_64/xcat
    tar jxvf xcat-dep-*.tar.bz2
~~~~      

  * Add the sysclone otherpkglist file and otherpkgdir to osimage definition that is used for the golden client, and then use updatenode to install the rpms. For example: 

~~~~  
    (For RH/CentOS): 
    chdef -t osimage -o <osimage-name> otherpkglist=/opt/xcat/share/xcat/install/rh/sysclone.rhels6.x86_64.otherpkgs.pkglist
    chdef -t osimage -o <osimage-name> -p otherpkgdir=/install/post/otherpkgs/rhels6.3/x86_64
    updatenode <my-golden-cilent> -S
    

 
    (For SLES):  
    chdef -t osimage -o <osimage-name> otherpkglist=/opt/xcat/share/xcat/install/sles/sysclone.sles11.x86_64.otherpkgs.pkglist
    chdef -t osimage -o <osimage-name> -p otherpkgdir=/install/post/otherpkgs/sles11.3/x86_64
    updatenode <my-golden-cilent> -S
~~~~      

#### **Capture image from the Golden Client **

On the mgmt node, use [imgcapture](http://xcat.sourceforge.net/man1/imgcapture.1.html) to capture an osimage from the golden-client. 
 
~~~~     
    imgcapture <my-golden-client> -t sysclone -o <mycomputeimage>
~~~~      

Tip: when imgcapture is run, it pulls the osimage from the golden-client, and creates the image files system and a corresponding osimage definition on the xcat management node.

~~~~
 lsdef -t osimage <mycomputeimage> to check the osimage attributes. 
~~~~

