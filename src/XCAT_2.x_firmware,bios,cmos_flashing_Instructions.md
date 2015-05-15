<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Intro](#intro)
- [xCAT and remote flashing history](#xcat-and-remote-flashing-history)
- [Remote Flashing](#remote-flashing)
  - [1\. Get Flash Code](#1%5C-get-flash-code)
  - [2\. Extract Files](#2%5C-extract-files)
  - [3\. Get Libraries](#3%5C-get-libraries)
  - [3.5 The Secret, or the theory of how this works](#35-the-secret-or-the-theory-of-how-this-works)
  - [4\. Create ls22.tgz and runme.sh](#4%5C-create-ls22tgz-and-runmesh)
  - [5\. Deploy image](#5%5C-deploy-image)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)

For an alternative method for flashing firmware, see also [Updating_Firmware_with_Bootable_Media_Creator]. 


## Intro

'Flashing' in the context of this HOWTO is the act of updating a BIOS or some firmware in a node on a cluster. For example, if the vendor supplies you a brand new machine but you then check their website and see that the BIOS is out of date (they post 1.40 but you have 1.38 on your machine) then you may need to update it. The reasons for this update are that there may some fix that may affect the performance of your cluster. In the x86 world this is unfortunately pretty routine. And with the advent of blades and other such systems merged into a machine its not just the BIOS that may need to be updated. On IBM machines you may need to update the BMC. On other vendors machines perhaps its the on board lights out board. Regardless, flashing needs to be done and the way most vendors have it set up does not take into account that a person may have thousands of machines to do this to. 

## xCAT and remote flashing history

xCAT has a history of using remote flashing to update machines. This has saved administrators countless hours in taking a CD to every machine and rebooting it and toggling though menus. In xCAT 1.3 a method was introduced that used the memdisk abilities of pxelinux to boot into a DOS mode and execute DOS images that IBM provided. This method was extremely difficult to set up, but once working was very reliable and worked very nicely. I once did 1500 nodes in less than an hour with it. (It could have been done faster but I was being cautious). The method was documented [here](http://xcat.org/doc/1.x/flash-HOWTO.html)

With xCAT 2, we have found that many vendors, including IBM, now support a Linux binary executable that can flash subsystems via the command line. There are also others that support setting the BIOS CMOS settings. This was a very welcomed event. As such, when xCAT 2 was written the remote flash (rflash) command seemed low on the priorities to move from 1.3 to 2.x. This is because the rflash method most used was a DOS image and I don't know of many others who used different images. So the state of xCAT 2.x today is that it does indeed support remote flashing with Linux images. However, to date the DOS based rflash does not exist. 

The rest of this article outlines how to do the Linux based remote flash with xCAT 2 

## Remote Flashing

Our example here is an LS22. This example is taken from the mailing list comment Egan made [here](http://www.xcat.org/pipermail/xcat-user/2008-November/007310.html)

### 1\. Get Flash Code

For My IBM LS22 this was an exercise in patience navigating ibm.com. The files I found were:  
ibm_fw_bios_l8e131a_linux_amd32.bin  
ibm_fw_bmc_l8bt14a_linux_i386.bin  
ibm_fw_mptsas_ls22-ls42-2.50_linux_32-64.bin 

I placed all of these files in /tmp/ls22 
    
    cd /tmp/ls22
    chmod 755 ibm*sh

  


### 2\. Extract Files
    
    mkdir bios bmc mptsas
    cd bios
    ../ibm_fw_bios_18e131a_linux_amd32.bin -x .
    cd ../bmc
    ../ibm_fw_bmc_18bt14a_linux_i386.bin -x .
    cd ../mptsas
    ../ibm_fw_mptsas_ls22-ls42-2.50_linux_32-64.bin -x .
    cd ..

The commands were from the various readmes. There were some issues I ran into at a few points:  
a. The files were corrupted so they didn't extract right, at which I found after some debugging that redownloading solved my problems.  
b. The -x option really only works on the current directory... at least that's how it was for me. So no doing: -x /tmp/foo/, only -x . 

### 3\. Get Libraries

Up to this point I've been doing everything on a RedHat 5.2 machine that was not an LS22. In order for the lflash64 commands to work that were just extracted above, you have to make sure you have libraries so they can execute. If you noticed Egan's email he showed you could run: 
    
    ldd lflash64

To show what files to copy. I did this and found that I needed to do the following: 
    
    cd /tmp/ls22
    mkdir lib
    cp /lib64/libc.so.6 .
    cp /lib64/libdl.so.2 .
    cp /lib64/libm.so.6 .
    cp /usr/lib64/libz.so.1 .
    cp /lib64/ld-linux-x86-64.so.2 .

After this I just copied the libraries to all subdirectories since they all needed it. (I'm sure you could make only one link somewhere but I was trying to get it done fast) 
    
    cp -a lib/* bios/
    cp -a lib/* bmc/
    cp -a lib/* mptsas/

Now we create the runme.sh script. 

### 3.5 The Secret, or the theory of how this works

It turns out that xCAT has an undocumented feature (well I guess its documented now that I'm writing about it) that you can use the nodeset command to wget a remote image and then it is hard coded to untar the image, extract it into /tmp/&lt;image nam&gt; and then run the runme.sh command. 

So for example:  
\- Create a directory called junk  
\- Put what ever you want in it, including a file called runme.sh  
\- tar up the file and call it junk.tgz  
\- put it on any web server that a node can get to.  
Then run: 
    
    nodeset &lt;node&gt; runimage=http://

Then reboot the node.  
If you do that then xCAT will untar junk.tgz on the node in the directory /tmp/junk.tgz/ and then run runme.sh 

### 4\. Create ls22.tgz and runme.sh

So, following what we know in 3.5, we now create the runme.sh. 
    
    cd /tmp/ls22

Create runme.sh, the contents look like this: 
    
    #!/bin/sh
    cd bios
    ./runme.sh
    cd ../bmc
    ./runme.sh
    cd ../mptsas
    ./runme.sh
    cd ../cmos
    ./runme.sh

Now create the runme for the different subsystems:  
**BIOS**
    
    cd bios
    cat runme.sh
    #!/bin/sh
    LD_LIBRARY_PATH=. ./ld-linux-x86-64.so.2 ./lflash64

MPTSAS and BMC: Do the exact same thing.  
**CMOS**  
This one you need the ASU tool for (as well as libpthread.so.0)  
runme.sh looks like this: 
    
    LD_LIBRARY_PATH=. ./ld-linux-x86-64.so.2 ./asu64 batch ls22-cmos.batch

ls22-cmos.batch is a file I created that looks like this: 
    
    loaddefault all
    set CMOS_SerialA "Auto-Configure"
    set CMOS_SerialB "Auto-Configure"
    set CMOS_RemoteConsoleEnable "Enabled"
    set CMOS_RemoteConsoleComPort "COM 2"
    set CMOS_RemoteConsoleEmulation "VT100/VT220"
    set CMOS_RemoteConsoleKybdEmul "VT100/VT220"
    set CMOS_RemoteConsoleBootEnable "Enabled"
    set CMOS_RemoteConsoleFlowCtrl "Hardware"
    set CMOS_ENET2_PXE_ENABLE "Disabled"
    set CMOS_ENET3_PXE_ENABLE "Disabled"
    set CMOS_ENET4_PXE_ENABLE "Disabled"
    set CMOS_PostBootFailRequired "Disabled"
    set CMOS_ROMControlSlot1 "Disabled"
    set CMOS_ROMControlSlot2 "Disabled"
    set CMOS_IOMMU_PLANAR_ENABLE "Enabled"

Ok, now that you're done you have a file structure that looks like this: 
    
    /tmp/ls22
    |-- bios
    |   |-- 0078000.FLS
    |   |-- CMOSDEF.BIN
    |   |-- CPUTHROT.BIN
    |   |-- ISCSIROM.BIN
    |   |-- PXEROM.BIN
    |   |-- ld-linux-x86-64.so.2
    |   |-- lflash
    |   |-- lflash64
    |   |-- libc.so.6
    |   |-- libdl.so.2
    |   |-- libm.so.6
    |   |-- libz.so.1
    |   |-- readme.lin
    |   |-- runFlash.sh
    |   `-- runme.sh
    |-- bmc
    |   |-- FULLFW.MOT
    |   |-- ld-linux-x86-64.so.2
    |   |-- lflash
    |   |-- lflash64
    |   |-- libc.so.6
    |   |-- libdl.so.2
    |   |-- libm.so.6
    |   |-- libz.so.1
    |   |-- readme.lin
    |   `-- runme.sh
    |-- cmos
    |   |-- asu64
    |   |-- ld-linux-x86-64.so.2
    |   |-- libc.so.6
    |   |-- libdl.so.2
    |   |-- libm.so.6
    |   |-- libpthread.so.0
    |   |-- librt.so.1
    |   |-- ls22-cmos.batch
    |   `-- runme.sh
    |-- mptsas
    |   |-- FULLFW.MOT
    |   |-- ld-linux-x86-64.so.2
    |   |-- lflash
    |   |-- lflash64
    |   |-- libc.so.6
    |   |-- libdl.so.2
    |   |-- libm.so.6
    |   |-- libz.so.1
    |   |-- readme.lin
    |   `-- runme.sh
    `-- runme.sh

### 5\. Deploy image

Now you just need to tar it up. In our example, we'll put it in /install/flash/ls22.tgz: 
    
    cd /tmp/ls22/
    tar czvf ../ls22.tgz .
    mv ../ls22.tgz /install/flash/

Now we're ready to install the node. In this case my node is called b001: 
    
    nodeset b001 runimage=http://192.168.15.1/install/flash/x3455.tgz
    rpower b001 boot

Now we'll test on this node and make sure everything worked. If it did, you'll see all the subsystems flash. 

Nice job! Now get some work done. 
