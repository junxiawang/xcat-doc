<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Serial Console Settings](#serial-console-settings)
  - [IBM iDataPlex dx360](#ibm-idataplex-dx360)
  - [IBM iDataPlex dx360 M2](#ibm-idataplex-dx360-m2)
  - [KVM](#kvm)
  - [IBM BladeCenter HS21xM/LS22/HS22](#ibm-bladecenter-hs21xmls22hs22)
  - [IBM x3650](#ibm-x3650)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)


## Serial Console Settings

xCAT provides a way to monitor the output of devices on a serial port. Many hardware manufacturers have settings that are different across their hardware platforms. This list hopes to give information on how to set the nodehm table as well as how to set the BIOS settings on certain platforms. 

### IBM iDataPlex dx360

  * nodehm.mgt=ipmi 
  * nodehm.serialport=1 
  * nodehm.serialspeed=19200 
  * nodehm.serialflow="" 
  * noderes.netboot=pxe # xnba seems to fail on reboot on windows install. 

BIOS settings: 
    
    -Console Redirection
      Console Redirection      [Serial Port B]
      Flow Control      [RTS/CTS]
      Baud Rate        [19.2k]
      Terminal Type      [PC-ANSI]
      Legacy OS Redirection    [Enabled]
    

### IBM iDataPlex dx360 M2

  * nodehm.mgt=ipmi 
  * nodehm.serialport=0 
  * nodehm.serialspeed=115200 
  * nodehm.serialflow=hard 

### KVM

  * nodehm.mgt=kvm 
  * nodehm.serialport=0 
  * nodehm.serialspeed=115200 
  * nodehm.serialflow="" 

### IBM BladeCenter HS21xM/LS22/HS22

  * nodehm.mgt=blade 
  * nodehm.serialport=1 
  * nodehm.serialspeed=19200 
  * nodehm.serialflow=hard 

  


### IBM x3650

  * nodehm.mgt=ipmi 
  * nodehm.serialport=0 
  * nodehm.serialspeed=19200 
  * nodehm.serialflow=hard 
