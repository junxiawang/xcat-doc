<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Interface](#interface)
- [Inject the drivers to initrd](#inject-the-drivers-to-initrd)
- [Code Logic](#code-logic)
  - [To generate the initrd for diskfull against rh:](#to-generate-the-initrd-for-diskfull-against-rh)
  - [To generate the initrd for diskless against rh](#to-generate-the-initrd-for-diskless-against-rh)
  - [To generate the initrd for diskfull against the sles](#to-generate-the-initrd-for-diskfull-against-the-sles)
  - [To generate the initrd for diskless against the sles](#to-generate-the-initrd-for-diskless-against-the-sles)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Interface

For driver rpm support, the location of driver rpm only can be specified from the osimage object. A new column linuximage.driverupdatesrc will be added to store the location of driver rpm. It's a attribute of osimage object. 

The the value format of driverupdatesrc can be a comma seperated section of: dud:&lt;full path of driver update disk&gt; or rpm:&lt;full path of driver rpm package&gt;. If no tag, xCAT will consider it's the 'rpm' format. 

For example: 
    
    dud:/install/dud/dd.img,rpm:/install/rpm/d.rpm
    

The existed attribute 'netdrivers' (linuximage.netdrivers) will be used to specify the driver list that need to be loaded from the driver rpms. 

If no 'netdrivers' specified, all the drivers from the driver rpms will be injected to the initrd. 

For example: 
    
    megaraid_sas.ko,bnx2.ko
    

## Inject the drivers to initrd

Run the 'genimage' ang 'nodeset' against the osimage to trigger the action that inject the drivers from the driver rpm to the initrd. 
    
    [Diskless]
     genimage &lt;osimagename&gt;
    [Diskfull]
     nodeset &lt;noderange&gt; osimage=&lt;osimagename&gt;
    

Note: After injecting of the new drivers, the initrd will be different from the default one. Current initrd location '/tftpboot/xcat/&lt;os&gt;/&lt;arch&gt; cannot store the initrd that hacked one and original one. So I added a new level of directory base on 'profile' to store the new generated initrd. The initrd path for the pxe and yaboot also have been changed. 
    
    '/tftpboot/xcat/&lt;os&gt;/&lt;arch&gt;/&lt;profile&gt;'
    

## Code Logic

The pseudo-code in following described the logic that injecting the drivers from driver disk and driver rpm to the initrd. 

### To generate the initrd for diskfull against rh:
    
    In cases: 'dracut + drvier rpm', '!dracut + driver rpm' and '!dracut + driver disk'
     unpack the initrd
     If has driver rpm, Extract the drivers from driver rpm
     For dracut (rh6)
       If has driver rpm, copy the firmware,drivers and run the 'depmod'
     For rh5
       Unpack the modules.cgz for the orignial initrd
       If has driver disk:
         Unpack the driver disk and unpack the modules.cgz
         Copy firmware and drivers to initrd
         Generate the configure files: module-info, modules.dep ...
       If has driver rpm:
         Copy firmware and drivers to initrd
         generate the module-info.
           Add the entry to module-info if no entry for the driver was there
         generate the modules.dep	
           Use the 'depmod' command to generate the dep against all the drivers.
           Since the 'depmod' command needs the specific directory structure like '/lib/modules/&lt;kernelver&gt; to generate the modules.dep, I copied the drivers which extracted from the modules.cgz to a specific dirctory './lib/modules/&lt;kernelver&gt;', then run the 'depmod'. And since the modules.dep that used by the initrd has not the path and '.ko' postfix for each driver, then remove the path and '.ko' for the entries from the new generated moduels.dep. This logic works well from my testing.
       Pack te modules.cgz for initrd
     Pack the initrd
    
    
     In case: dracut + driver disk  ( I did not touch the code logic for this scenario)
       generate an image with the driver disk
       append the driver disk image to the original initrd
    

### To generate the initrd for diskless against rh
    
     If has driver disk: (no change)
       Unpack the driver disk and modules.cgz
       Copy the firmware and drivers from driver disk to the rootimage
     If has driver rpm:
       Extract drivers from rpm package
       Copy the firmware and drivers to the rootimage
     Make the dependency for the modules by 'depmod' command
    

### To generate the initrd for diskfull against the sles
    
     For the cases: arch=ppc or has driver rpm
       Unpack the initrd
       If has driver rpm
         Extract the drivers from driver rpms
         copy firmware and drivers to the initrd
         generate the dependency for driver modules
       If has driver disk
          mkpath /cus_driverdisk, and copy driver disk to /cus_driverdisk
       Pack the initrd
    
    
     For the case: arch=x86 and without driver rpm
       Generate an image with the driver disk
       Append the driver disk image to the original initrd
    

### To generate the initrd for diskless against the sles
    
     If has driver disk (not change)
       Unpack the driver disk
       Copy the drivers from the driver disk to the rootimage
     If has the driver rpm
       Extract the drivers from driver rpms
       copy firmware and drivers to the rootimage
     generate the dependency for driver modules
    
