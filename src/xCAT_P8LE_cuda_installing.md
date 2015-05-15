<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

    - [Overview](#overview)
    - [Install xCAT MN and discover p8le node](#install-xcat-mn-and-discover-p8le-node)
    - [Prepare cuda repo on xCAT Management Node](#prepare-cuda-repo-on-xcat-management-node)
      - [The online repo](#the-online-repo)
      - [The local package repo](#the-local-package-repo)
- [dpkg -x cuda-repo-ubuntu14xx-7-0-local_7.0-28_ppc64el.deb /install/cuda-repo/](#dpkg--x-cuda-repo-ubuntu14xx-7-0-local_70-28_ppc64eldeb-installcuda-repo)
- [scp -r <username>@<ubuntu_host>/<cuda_extract_dir> /install/cuda-repo/](#scp--r-username@ubuntu_hostcuda_extract_dir-installcuda-repo)
    - [Prepare osimage object for installing cuda](#prepare-osimage-object-for-installing-cuda)
      - [Prepare diskfull cudafull installation osimage object](#prepare-diskfull-cudafull-installation-osimage-object)
- [chdef -t osimage ubuntu14.04.2-ppc64el-install-cudafull -p pkgdir="http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main,http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /"](#chdef--t-osimage-ubuntu14042-ppc64el-install-cudafull--p-pkgdirhttpportsubuntucomubuntu-ports-trusty-mainhttpportsubuntucomubuntu-ports-trusty-updates-mainhttp103510installcuda-repovarcuda-repo-7-0-local-)
- [lsdef -t osimage ubuntu14.04.2-ppc64el-install-cudafull](#lsdef--t-osimage-ubuntu14042-ppc64el-install-cudafull)
      - [Prepare diskfull cudaruntime installation osimage object](#prepare-diskfull-cudaruntime-installation-osimage-object)
- [chdef -t osimage ubuntu14.04.2-ppc64el-install-cudaruntime -p pkgdir="http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main,http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /"](#chdef--t-osimage-ubuntu14042-ppc64el-install-cudaruntime--p-pkgdirhttpportsubuntucomubuntu-ports-trusty-mainhttpportsubuntucomubuntu-ports-trusty-updates-mainhttp103510installcuda-repovarcuda-repo-7-0-local-)
- [lsdef -t osimage ubuntu14.04.2-ppc64el-install-cudaruntime](#lsdef--t-osimage-ubuntu14042-ppc64el-install-cudaruntime)
      - [Prepare diskless cudafull installation osimage object](#prepare-diskless-cudafull-installation-osimage-object)
- [chdef -t osimage ubuntu14.04.2-ppc64el-netboot-cudafull -p pkgdir="http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main"](#chdef--t-osimage-ubuntu14042-ppc64el-netboot-cudafull--p-pkgdirhttpportsubuntucomubuntu-ports-trusty-mainhttpportsubuntucomubuntu-ports-trusty-updates-main)
- [chdef -t osimage ubuntu14.04.2-ppc64el-netboot-cudafull otherpkgdir="http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /"](#chdef--t-osimage-ubuntu14042-ppc64el-netboot-cudafull-otherpkgdirhttp103510installcuda-repovarcuda-repo-7-0-local-)
- [lsdef -t osimage ubuntu14.04.2-ppc64el-netboot-cudafull](#lsdef--t-osimage-ubuntu14042-ppc64el-netboot-cudafull)
      - [Prepare diskless cudaruntime installation osimage object](#prepare-diskless-cudaruntime-installation-osimage-object)
- [chdef -t osimage ubuntu14.04.2-ppc64el-netboot-cudaruntime -p pkgdir="http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main"](#chdef--t-osimage-ubuntu14042-ppc64el-netboot-cudaruntime--p-pkgdirhttpportsubuntucomubuntu-ports-trusty-mainhttpportsubuntucomubuntu-ports-trusty-updates-main)
- [chdef -t osimage ubuntu14.04.2-ppc64el-netboot-cudaruntime otherpkgdir="http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /"](#chdef--t-osimage-ubuntu14042-ppc64el-netboot-cudaruntime-otherpkgdirhttp103510installcuda-repovarcuda-repo-7-0-local-)
- [lsdef -t osimage ubuntu14.04.2-ppc64el-netboot-cudaruntime](#lsdef--t-osimage-ubuntu14042-ppc64el-netboot-cudaruntime)
    - [Install acpid for diskless installation(Optional, for generating stateless image only)](#install-acpid-for-diskless-installationoptional-for-generating-stateless-image-only)
- [apt-get  install -y acpid](#apt-get--install--y-acpid)
- [genimage <diskless_osimage_object_name>](#genimage-diskless_osimage_object_name)
- [packimage <diskless_osimage_object_name>](#packimage-diskless_osimage_object_name)
    - [Use addcudakey postscript to install GPGKEY for cuda packages](#use-addcudakey-postscript-to-install-gpgkey-for-cuda-packages)
- [chdef <node> -p postscripts=addcudakey](#chdef-node--p-postscriptsaddcudakey)
    - [Install NVML (optional, for nodes which need to compile cuda related applications)](#install-nvml-optional-for-nodes-which-need-to-compile-cuda-related-applications)
- [chmod +x  /install/postscripts/cuda_346.46_gdk_linux.run](#chmod-x--installpostscriptscuda_34646_gdk_linuxrun)
- [chdef <node> -p postbootscripts="cuda_346.46_gdk_linux.run --silent --installdir=<you_desired_dir>"](#chdef-node--p-postbootscriptscuda_34646_gdk_linuxrun---silent---installdiryou_desired_dir)
    - [Start OS provisioning and cuda installing](#start-os-provisioning-and-cuda-installing)
    - [Install cuda for normal diskfull node](#install-cuda-for-normal-diskfull-node)
    - [Verification of cuda installation](#verification-of-cuda-installation)
- [nvidia-smi -q](#nvidia-smi--q)
- [nvidia-smi -q](#nvidia-smi--q-1)
    - [GPU management and monitoring](#gpu-management-and-monitoring)
- [xdsh p8le-42l "nvidia-smi -i 0 --query-gpu=name,serial,uuid --format=csv,noheader"](#xdsh-p8le-42l-nvidia-smi--i-0---query-gpunameserialuuid---formatcsvnoheader)
    - [Appendix A: Installing CUDA example applications](#appendix-a-installing-cuda-example-applications)
- [apt-get install cuda-samples-7-0 -y](#apt-get-install-cuda-samples-7-0--y)
- [pwd](#pwd)
- [bin/ppc64le/linux/release/deviceQuery](#binppc64lelinuxreleasedevicequery)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


### Overview

  The cuda packages provided by nvidia include both the runtime libraries for computing and dev tools for programming and monitoring. In xCAT, we split the packages into 2 groups: the cudaruntime package set and the cudafull package set.
  Since the full package set is so large. xCAT suggests only installing the runtime libraries on your Compute Nodes (CNs), and the full cuda package set on your ubuntu Management Node or your monitor/development nodes.   

### Install xCAT MN and discover p8le node

  Follow the instructions in [ XCAT_P8LE_Hardware_Management ](https://sourceforge.net/p/xcat/wiki/XCAT_P8LE_Hardware_Management) to install your xCAT Management Node and do hardware discovery for p8le nodes. 

### Prepare cuda repo on xCAT Management Node

  Currently, there are 2 types of Ubuntu repos for installing cuda-7-0 on p8LE hardware:  The [online repo](http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/ppc64el/cuda-repo-ubuntu1404_7.0-28_ppc64el.deb) and  [local package repo](http://developer.download.nvidia.com/compute/cuda/7_0/Prod/local_installers/rpmdeb/cuda-repo-ubuntu1404-7-0-local_7.0-28_ppc64el.deb). 
  
#### The online repo
  The online repo will provide a sourcelist entry which includes the URL with the location of the cuda packages. The online repo can be used directly by Compute Nodes. The source.list entry will be similar to: 

~~~~
deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1410/ppc64el /
~~~~

#### The local package repo
A local package repo will contain all of the cuda packages.

  *[ubuntu MN]
  The admin can either simply install the local repo (need to copy the whole /var/cuda-repo-7-0-local/ to /install/cuda-repo/)or extract the cuda packages into the local repo with the following command:

~~~~
#dpkg -x cuda-repo-ubuntu14xx-7-0-local_7.0-28_ppc64el.deb /install/cuda-repo/
~~~~

  *[Rh or SLES]
  The admin will need to extract the cuda packages from the cuda repo deb file on an ubuntu host with the command above, and then copy the directories from the extracted directory back to your MN:

~~~~
#scp -r <username>@<ubuntu_host>/<cuda_extract_dir> /install/cuda-repo/
~~~~

The source.list entry for a local repo will be similar to:

~~~~
deb http://<MN_IP_ADDRESS>/install/cuda-repo/var/cuda-repo-7-0-local/ /
~~~~

### Prepare osimage object for installing cuda 

  After run "copycds", there will be 4 osimage object related to cuda installing, the admin can generate their own osimage object based on those definition or just modify them.

  * The diskfull cudafull installation osimage object
    ubuntu14.04.2-ppc64el-install-cudafull
  * The diskfull cudaruntime installation osimage object
    ubuntu14.04.2-ppc64el-install-cudaruntime
  * The diskless cudafull installation osimage object
    ubuntu14.04.2-ppc64el-netboot-cudafull  (osimage)
  * The diskless cudaruntime installation osimage object
    ubuntu14.04.2-ppc64el-netboot-cudaruntime  (osimage)

  The following repos will be used in the test environment:

  * "/install/ubuntu14.04.2/ppc64el": The OS image package directory
  * "http://ports.ubuntu.com/ubuntu-ports": The internet mirror, if there is local mirror available, it can be replaced
  * "http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /": The repo for cuda, you can replaced it with online cuda repo.

#### Prepare diskfull cudafull installation osimage object

The following command can be used to add internet mirror and cuda repo for the pkgdir attribute of the osimage object.

~~~~
# chdef -t osimage ubuntu14.04.2-ppc64el-install-cudafull -p pkgdir="http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main,http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /"
~~~~

The osimage object will be like this:

~~~~
# lsdef -t osimage ubuntu14.04.2-ppc64el-install-cudafull
Object name: ubuntu14.04.2-ppc64el-install-cudafull
    imagetype=linux
    osarch=ppc64el
    osname=Linux
    osvers=ubuntu14.04.2
    otherpkgdir=/install/post/otherpkgs/ubuntu14.04.2/ppc64el
    pkgdir=/install/ubuntu14.04.2/ppc64el,http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main,http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /
    pkglist=/opt/xcat/share/xcat/install/ubuntu/cudafull.ubuntu14.04.2.ppc64el.pkglist
    profile=cudafull
    provmethod=install
    template=/opt/xcat/share/xcat/install/ubuntu/cudafull.tmpl
~~~~

#### Prepare diskfull cudaruntime installation osimage object

The following command can be used to add internet mirror and cuda repo for the pkgdir attribute of the osimage object.

~~~~
# chdef -t osimage ubuntu14.04.2-ppc64el-install-cudaruntime -p pkgdir="http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main,http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /"
~~~~

The osimage object will be like this:

~~~~
# lsdef -t osimage ubuntu14.04.2-ppc64el-install-cudaruntime                          
Object name: ubuntu14.04.2-ppc64el-install-cudaruntime
    imagetype=linux
    osarch=ppc64el
    osname=Linux
    osvers=ubuntu14.04.2
    otherpkgdir=/install/post/otherpkgs/ubuntu14.04.2/ppc64el
    pkgdir=/install/ubuntu14.04.2/ppc64el,http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main,http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /
    pkglist=/opt/xcat/share/xcat/install/ubuntu/cudaruntime.ubuntu14.04.2.ppc64el.pkglist
    profile=cudaruntime
    provmethod=install
    template=/opt/xcat/share/xcat/install/ubuntu/cudaruntime.tmpl
~~~~

#### Prepare diskless cudafull installation osimage object

The following command can be used to add internet mirror for the pkgdir attribute of the osimage object.

~~~~
# chdef -t osimage ubuntu14.04.2-ppc64el-netboot-cudafull -p pkgdir="http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main"
~~~~

The following command can be used to modify the otherpkgdir attribute of the osimage object.

~~~~
# chdef -t osimage ubuntu14.04.2-ppc64el-netboot-cudafull otherpkgdir="http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /"
~~~~

The osimage object will be like this:
~~~~
# lsdef -t osimage ubuntu14.04.2-ppc64el-netboot-cudafull     
Object name: ubuntu14.04.2-ppc64el-netboot-cudafull
    imagetype=linux
    osarch=ppc64el
    osname=Linux
    osvers=ubuntu14.04.2
    otherpkgdir=http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /
    otherpkglist=/opt/xcat/share/xcat/netboot/ubuntu/cudafull.otherpkgs.pkglist
    pkgdir=/install/ubuntu14.04.2/ppc64el,http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main
    pkglist=/opt/xcat/share/xcat/netboot/ubuntu/cudafull.ubuntu14.04.2.ppc64el.pkglist
    profile=cudafull
    provmethod=netboot
    rootimgdir=/install/netboot/ubuntu14.04.2/ppc64el/cudafull
~~~~

#### Prepare diskless cudaruntime installation osimage object

The following command can be used to add internet mirror for the pkgdir attribute of the osimage object.

~~~~
# chdef -t osimage ubuntu14.04.2-ppc64el-netboot-cudaruntime -p pkgdir="http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main"
~~~~

The following command can be used to modify the otherpkgdir attribute of the osimage object.

~~~~
# chdef -t osimage ubuntu14.04.2-ppc64el-netboot-cudaruntime otherpkgdir="http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /"
~~~~

The osimage object will be like this:

~~~~
#lsdef -t osimage ubuntu14.04.2-ppc64el-netboot-cudaruntime
Object name: ubuntu14.04.2-ppc64el-netboot-cudaruntime
    imagetype=linux
    osarch=ppc64el
    osname=Linux
    osvers=ubuntu14.04.2
    otherpkgdir=http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /
    otherpkglist=/opt/xcat/share/xcat/netboot/ubuntu/cudaruntime.otherpkgs.pkglist
    permission=755
    pkgdir=/install/ubuntu14.04.2/ppc64el,http://ports.ubuntu.com/ubuntu-ports trusty main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main
    pkglist=/opt/xcat/share/xcat/netboot/ubuntu/cudaruntime.ubuntu14.04.2.ppc64el.pkglist
    profile=cudaruntime
    provmethod=netboot
    rootimgdir=/install/netboot/ubuntu14.04.2/ppc64el/cudaruntime
~~~~

### Install acpid for diskless installation(Optional, for generating stateless image only)

  To generate stateless image for a diskless installation, the acpid is needed to be installed on MN or  the host on which you generate stateless image.

~~~~
#apt-get  install -y acpid 
~~~~
  
  Then, use the following commands to generate stateless image and pack it.

~~~~
#genimage <diskless_osimage_object_name>
#packimage <diskless_osimage_object_name>
~~~~

### Use addcudakey postscript to install GPGKEY for cuda packages

  In order to access the cuda repo and authorize it, you will need to import the cuda GPGKEY into the apt key trust list. The following command can be used to add a postscript for a node that will install cuda:

~~~~
#chdef <node> -p postscripts=addcudakey
~~~~  

### Install NVML (optional, for nodes which need to compile cuda related applications)

  The NVIDIA Management Library (NVML) is a C-based programmatic interface for monitoring and managing various states within NVIDIA Tesla™ GPUs. It is intended to be a platform for building 3rd party applications.
  The NVML can be download from http://developer.download.nvidia.com/compute/cuda/7_0/Prod/local_installers/cuda_346.46_gdk_linux.run.
  After download NVML and put it under /install/postscripts on MN, the following steps can be used to have NVML installed after the node is installed and rebooted if needed.

~~~~
#chmod +x  /install/postscripts/cuda_346.46_gdk_linux.run
#chdef <node> -p postbootscripts="cuda_346.46_gdk_linux.run --silent --installdir=<you_desired_dir>"
~~~~

### Start OS provisioning and cuda installing

Follow the instructions in [provisioning ubuntu14xx for powerNV](https://sourceforge.net/p/xcat/wiki/XCAT_P8LE_Hardware_Management/#provisioning-ubuntu-14x-for-powernv) to perform OS provisioning for your p8le nodes. **note** that you should use the osimage object generated above to do the OS provisioning. 

### Install cuda for normal diskfull node 

**Note**, for note which is not installed by xCAT, you shall first connect it to a xCAT node, then use the step below to install cuda.

  * Add cuda required pkgs into osimage pkglist file
    
    ~~~~
    build-essential
    dkms
    zlib1g-dev
    cuda-runtime-7-0 (for cudaruntime installing)
    cuda (for cudafull installing)
    ~~~~

  * Add cuda related repo for your osimage

    ~~~~
    #chdef -t osimage <your_osimage_name> -p pkgdir="http://ports.ubuntu.com/ubuntu-ports trusty   main,http://ports.ubuntu.com/ubuntu-ports trusty-updates main,http://10.3.5.10/install/cuda-repo/var/cuda-repo-7-0-local /"
    ~~~~

  * Add postscripts for your node to install cuda GPGKEY and related pkgs

    ~~~~
    #chdef <nodename> -p postscripts=addcudakey,ospkgs
    ~~~~

  * If the NVML is needed, pls follow the "Install NVML" section to download the script and add it to postbootscript 

  * Start cuda installation

    ~~~~
    #updatenode <nodename> -P
    ~~~~

  * After cuda installation finished, you need to reboot your host to activate the NVIDIA driver.

### Verification of cuda installation 

The command below can be used to display GPU or Unit info on the node.
~~~~
# nvidia-smi -q
~~~~

The result on a test node were:
~~~~
# nvidia-smi -q
==============NVSMI LOG==============

Timestamp                           : Thu Apr  9 03:47:14 2015
Driver Version                      : 346.46

Attached GPUs                       : 1
GPU 0002:01:00.0
    Product Name                    : Tesla K40m
    Product Brand                   : Tesla
    Display Mode                    : Disabled
    Display Active                  : Disabled
    Persistence Mode                : Disabled
    Accounting Mode                 : Disabled
    Accounting Mode Buffer Size     : 128
    Driver Model
        Current                     : N/A
        Pending                     : N/A
    Serial Number                   : 0324114102927
    GPU UUID                        : GPU-8750df00-40e1-8a39-9fd8-9c29905fa127
    Minor Number                    : 0
    VBIOS Version                   : 80.80.24.00.06
    MultiGPU Board                  : No
    Board ID                        : 0x20100
    Inforom Version
        Image Version               : 2081.0202.01.04
        OEM Object                  : 1.1
        ECC Object                  : 3.0
        Power Management Object     : N/A
    GPU Operation Mode
        Current                     : N/A
        Pending                     : N/A
    PCI
        Bus                         : 0x01
        Device                      : 0x00
        Domain                      : 0x0002
        Device Id                   : 0x102310DE
        Bus Id                      : 0002:01:00.0
        Sub System Id               : 0x097E10DE
        GPU Link Info
            PCIe Generation
                Max                 : 3
                Current             : 3
            Link Width
                Max                 : 16x
                Current             : 16x
        Bridge Chip
            Type                    : N/A
            Firmware                : N/A
        Replays since reset         : 0
        Tx Throughput               : N/A
        Rx Throughput               : N/A
    Fan Speed                       : N/A
    Performance State               : P0
    Clocks Throttle Reasons
        Idle                        : Not Active
        Applications Clocks Setting : Active
        SW Power Cap                : Not Active
        HW Slowdown                 : Not Active
        Unknown                     : Not Active
    FB Memory Usage
        Total                       : 11519 MiB
        Used                        : 55 MiB
        Free                        : 11464 MiB
    BAR1 Memory Usage
        Total                       : 16384 MiB
        Used                        : 2 MiB
        Free                        : 16382 MiB
    Compute Mode                    : Default
    Utilization
        Gpu                         : 99 %
        Memory                      : 4 %
        Encoder                     : 0 %
        Decoder                     : 0 %
    Ecc Mode
        Current                     : Enabled
        Pending                     : Enabled
    ECC Errors
        Volatile
            Single Bit            
                Device Memory       : 0
                Register File       : 0
                L1 Cache            : 0
                L2 Cache            : 0
                Texture Memory      : 0
                Total               : 0
            Double Bit            
                Device Memory       : 0
                Register File       : 0
                L1 Cache            : 0
                L2 Cache            : 0
                Texture Memory      : 0
                Total               : 0
        Aggregate
            Single Bit            
                Device Memory       : 0
                Register File       : 0
                L1 Cache            : 0
                L2 Cache            : 0
                Texture Memory      : 0
                Total               : 0
            Double Bit            
                Device Memory       : 0
                Register File       : 0
                L1 Cache            : 0
                L2 Cache            : 0
                Texture Memory      : 0
                Total               : 0
    Retired Pages
        Single Bit ECC              : 0
        Double Bit ECC              : 0
        Pending                     : No
    Temperature
        GPU Current Temp            : 35 C
        GPU Shutdown Temp           : 95 C
        GPU Slowdown Temp           : 90 C
    Power Readings
        Power Management            : Supported
        Power Draw                  : 67.85 W
        Power Limit                 : 235.00 W
        Default Power Limit         : 235.00 W
        Enforced Power Limit        : 235.00 W
        Min Power Limit             : 150.00 W
        Max Power Limit             : 235.00 W
    Clocks
        Graphics                    : 745 MHz
        SM                          : 745 MHz
        Memory                      : 3004 MHz
    Applications Clocks
        Graphics                    : 745 MHz
        Memory                      : 3004 MHz
    Default Applications Clocks
        Graphics                    : 745 MHz
        Memory                      : 3004 MHz
    Max Clocks
        Graphics                    : 875 MHz
        SM                          : 875 MHz
        Memory                      : 3004 MHz
    Clock Policy
        Auto Boost                  : N/A
        Auto Boost Default          : N/A
    Processes                       : None
~~~~

### GPU management and monitoring

  The tool "nvidia-smi" provided by NVIDIA driver can be used to do GPU management and monitoring, but it can only be run on the host where GPU hardware, CUDA and NVIDIA driver is installed. The [xdsh](http://xcat.sourceforge.net/man1/xdsh.1.html) can be used to run "nvidia-smi" on GPU host remotely from xCAT management node.
  The using of xdsh will be like this:

~~~~
# xdsh p8le-42l "nvidia-smi -i 0 --query-gpu=name,serial,uuid --format=csv,noheader"
p8le-42l: Tesla K40m, 0324114102927, GPU-8750df00-40e1-8a39-9fd8-9c29905fa127
~~~~

  Some of the useful nvidia-smi command for monitoring and managing of GPU are as belows, for more information, pls read nvidia-smi manpage.

  * For monitoring: 
    * The number of NVIDIA GPUs in the system.
~~~~
nvidia-smi --query-gpu=count --format=csv,noheader
~~~~
    * The version of the installed NVIDIA display driver
~~~~
nvidia-smi -i 0 --query-gpu=driver_version --format=csv,noheader                       
~~~~
    * The BIOS of the GPU board
~~~~
nvidia-smi -i 0 --query-gpu=vbios_version --format=csv,noheader
~~~~
    * Product name, serial number and UUID of the GPU
~~~~
nvidia-smi -i 0 --query-gpu=name,serial,uuid --format=csv,noheader                     
~~~~    
	* Fan speed
~~~~
nvidia-smi -i 0 --query-gpu=fan.speed --format=csv,noheader
~~~~
    * The compute mode flag indicates whether individual or multiple compute applications may run on the GPU. Also known as exclusivity modes
~~~~
nvidia-smi -i 0 --query-gpu=compute_mode --format=csv,noheader  
~~~~
    * Percent of time over the past sample period during which one or more kernels was executing on the GPU
~~~~
nvidia-smi -i 0 --query-gpu=utilization.gpu --format=csv,noheader 
~~~~ 
    * Total errors detected across entire chip. Sum of device_memory, register_file, l1_cache, l2_cache and texture_memory
~~~~
nvidia-smi -i 0 --query-gpu=ecc.errors.corrected.aggregate.total --format=csv,noheader
~~~~    
    * Core GPU temperature, in degrees C
~~~~
nvidia-smi -i 0 --query-gpu=temperature.gpu --format=csv,noheader  
~~~~
    * The ECC mode that the GPU is currently operating under
~~~~
nvidia-smi -i 0 --query-gpu=ecc.mode.current --format=csv,noheader
~~~~
    * The power management status 
~~~~
nvidia-smi -i 0 --query-gpu=power.management --format=csv,noheader 
~~~~    
    * The last measured power draw for the entire board, in watts
~~~~
nvidia-smi -i 0 --query-gpu=power.draw --format=csv,noheader                           
~~~~    
    * The minimum and maximum value in watts that power limit can be set to.
~~~~
nvidia-smi -i 0 --query-gpu=power.min_limit,power.max_limit --format=csv
~~~~

  * For management:
    * Set persistence mode, When  persistence  mode  is enabled the NVIDIA driver remains loaded even when no active clients, DISABLED by default
~~~~
nvidia-smi -i 0 -pm 1
~~~~	
    * Disabled ECC support for GPU. Toggle ECC support, A flag that indicates whether ECC support is enabled,  need to use --query-gpu=ecc.mode.pending to check. Reboot required.                       
~~~~
nvidia-smi -i 0 -e 0
~~~~
    * Reset the ECC volatile/aggregate error counters for the target GPUs                     
~~~~
nvidia-smi -i 0 -p 0/1
~~~~
    * Set MODE for compute applications, query with --query-gpu=compute_mode 
~~~~
nvidia-smi -i 0 -c 0/1/2/3
~~~~
    * Trigger reset of the GPU.                    
~~~~
nvidia-smi -i 0 -r
~~~~
    * Enable or disable Accounting Mode,  statistics can be calculated for each compute process running on the GPU,  query with -query-gpu=accounting.mode                     
~~~~
nvidia-smi -i 0 -am 0/1 
~~~~
    * Specifies maximum power management limit in watts, query with --query-gpu=power.limit.                    
~~~~
nvidia-smi -i 0 -pl 200
~~~~

### Appendix A: Installing CUDA example applications

  The cuda-samples-7-0 pkgs include some CUDA examples which can help uses to know how to use cuda.
For a node which only cuda runtime libraries installed, the following command can be used to install cuda-samples package.

~~~~
#apt-get install cuda-samples-7-0 -y
~~~~

  After cuda-sample-7-0 has been installed, go to /usr/local/cuda-7.0/samples to build the examples. See this link https://developer.nvidia.com/ for more information. Or, you can simply run the make command under dir /usr/local/cuda-7.0/samples to build all the tools. 
  The following command can be used to build the deviceQuery tool in the cuda samples directory:

~~~~
# pwd
/usr/local/cuda-7.0/samples

*#make -C 1_Utilities/deviceQuery 
make: Entering directory `/usr/local/cuda-7.0/samples/1_Utilities/deviceQuery'
/usr/local/cuda-7.0/bin/nvcc -ccbin g++ -I../../common/inc  -m64    -gencode arch=compute_20,code=sm_20 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_52,code=compute_52 -o deviceQuery.o -c deviceQuery.cpp
/usr/local/cuda-7.0/bin/nvcc -ccbin g++   -m64      -gencode arch=compute_20,code=sm_20 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_52,code=compute_52 -o deviceQuery deviceQuery.o 
mkdir -p ../../bin/ppc64le/linux/release
cp deviceQuery ../../bin/ppc64le/linux/release
make: Leaving directory `/usr/local/cuda-7.0/samples/1_Utilities/deviceQuery'
~~~~

The verification results from this example on a test node were:

~~~~
# bin/ppc64le/linux/release/deviceQuery 
bin/ppc64le/linux/release/deviceQuery Starting...

 CUDA Device Query (Runtime API) version (CUDART static linking)

Detected 1 CUDA Capable device(s)

Device 0: "Tesla K40m"
  CUDA Driver Version / Runtime Version          7.0 / 7.0
  CUDA Capability Major/Minor version number:    3.5
  Total amount of global memory:                 11520 MBytes (12079136768 bytes)
  (15) Multiprocessors, (192) CUDA Cores/MP:     2880 CUDA Cores
  GPU Max Clock rate:                            745 MHz (0.75 GHz)
  Memory Clock rate:                             3004 Mhz
  Memory Bus Width:                              384-bit
  L2 Cache Size:                                 1572864 bytes
  Maximum Texture Dimension Size (x,y,z)         1D=(65536), 2D=(65536, 65536), 3D=(4096, 4096, 4096)
  Maximum Layered 1D Texture Size, (num) layers  1D=(16384), 2048 layers
  Maximum Layered 2D Texture Size, (num) layers  2D=(16384, 16384), 2048 layers
  Total amount of constant memory:               65536 bytes
  Total amount of shared memory per block:       49152 bytes
  Total number of registers available per block: 65536
  Warp size:                                     32
  Maximum number of threads per multiprocessor:  2048
  Maximum number of threads per block:           1024
  Max dimension size of a thread block (x,y,z): (1024, 1024, 64)
  Max dimension size of a grid size    (x,y,z): (2147483647, 65535, 65535)
  Maximum memory pitch:                          2147483647 bytes
  Texture alignment:                             512 bytes
  Concurrent copy and kernel execution:          Yes with 2 copy engine(s)
  Run time limit on kernels:                     No
  Integrated GPU sharing Host Memory:            No
  Support host page-locked memory mapping:       Yes
  Alignment requirement for Surfaces:            Yes
  Device has ECC support:                        Enabled
  Device supports Unified Addressing (UVA):      Yes
  Device PCI Domain ID / Bus ID / location ID:   2 / 1 / 0
  Compute Mode:
     < Default (multiple host threads can use ::cudaSetDevice() with device simultaneously) >

deviceQuery, CUDA Driver = CUDART, CUDA Driver Version = 7.0, CUDA Runtime Version = 7.0, NumDevs = 1, Device0 = Tesla K40m
Result = PASS
~~~~