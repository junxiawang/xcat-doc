<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [The minidesign of supporting persistent kernel cmdline after diskful installation](#the-minidesign-of-supporting-persistent-kernel-cmdline-after-diskful-installation)
  - [Overview](#overview)
  - [The interface](#the-interface)
  - [The implementation](#the-implementation)
- [bootloader config](#bootloader-config)
- [--append <args>](#--append-args)
- [--useLilo](#--uselilo)
- [--md5pass <crypted MD5 password for GRUB>](#--md5pass-crypted-md5-password-for-grub)
- [Use the following option to add additional boot parameters for the](#use-the-following-option-to-add-additional-boot-parameters-for-the)
- [installed system (if supported by the bootloader installer).](#installed-system-if-supported-by-the-bootloader-installer)
- [Note: options passed to the installer will be added automatically.](#note-options-passed-to-the-installer-will-be-added-automatically)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

The minidesign of supporting persistent kernel cmdline after diskful installation
=================================================================================

Overview
--------

The xCAT table fields **linuximage.addkcmdline** and **bootparams.addkcmdline** are the interfaces for the user to specify some additional kernel options to be passed to kernel/initrd/installer during node provision. There are some scenarios that users want to keep some kernel options persistent after installation, that is, the specified kernel options is still effective(can be found in **/proc/cmdline**) among normal system reboots. 

The interface
-------------

To keep conciseness and consistentence, the persistent kernel options should still be specified in the existing table filelds **linuximage.addkcmdline** and **bootparams.addkcmdline**. Now the problem is how to tell the “persistent kernel options” out of the provision-time kernel options.
For the “persistent kernel options”, the options should be specified with a prefix token “R::”, for example, to specify the redhat7 kernel option **net.ifnames=0** persistent, **R::net.ifnames=0** should be specified in the **addkcmdline** attribute.

The implementation
------------------

The kernel cmdline is splited to be the **persistent kernel options** and **provision-time kernel options**. Only the **provision-time kernel options** are written to configuration file for node provision(under /tftpboot/). The **persistent kernel options** is exported as a environment variable in mypostscript. 

The persistent kernel options are appended to the bootloader configuration file in the installed system thru the kickstart/autoyast/preseed template file. The corresponding syntax to appending the kernel options are:

~~~~

Kickstart:

#
# bootloader config
# --append <args>
# --useLilo
# --md5pass <crypted MD5 password for GRUB>
#
bootloader --append="KERNEL OPTIONS "

~~~~


~~~~

Autoyast:
   <bootloader>
      <write_bootloader config:type="boolean">true</write_bootloader>
      <activate config:type="boolean">true</activate>
      <kernel_parameters>KERNEL OPTIONS</kernel_parameters>
      <lba_support config:type="boolean">false</lba_support>
      <linear config:type="boolean">false</linear>
      <location>mbr</location>
    </bootloader> 

~~~~


~~~~

Preseed:

# Use the following option to add additional boot parameters for the
# installed system (if supported by the bootloader installer).
# Note: options passed to the installer will be added automatically.
d-i debian-installer/add-kernel-opts KERNEL OPTIONS

~~~~