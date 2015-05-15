<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Boot Targets and Customized Installation Methods](#boot-targets-and-customized-installation-methods)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)

## Boot Targets and Customized Installation Methods

Even though xCAT has almost every booting/netbooting/installing method under the sun ready for you to roll, some people just can't have enough. And need to do it "their own way". We fully understand this need and embrace it. Therefore, this howto is on how to set up customized methods of installations. For example, you may already have a nfsroot solution of your own and have the kernel &amp; the ramdisk ready to roll. You can easily integrate this into xCAT with the boottarget table. 

xCAT provides a table called boottarget (available in later releases of 2.1 and above). This table looks as follows: 
    
    [root@wopr xCAT]# tabdump boottarget
    #bprofile,kernel,initrd,kcmdline,comments,disable
    "foobooter","kernel-2.8.myownkernel","secretinitd.gz",,,
    "test2","kernel-2.8",,"arg1 vale to ipsom lorum=wer",,

There are 4 important fields:  
bprofile: This is the name that you give your set of kernel and parameters.  
kernel: This goes in the kernel field  
initrd: If you put this in you'll get the initrd=&lt;whateveryou put in the field&gt;  
kcmdline: Additional items to set to the command line. 

In order to assign nodes to this boottarget, you need to modify the nodetype table: 
    
    #node,os,arch,profile,nodetype,comments,disable
    "x3455001","boottarget","x86","test2",,,

Here you can see that my node x3455001 has set the os field to be boottarget. We have also set the profile to be test2. The nodetype.profile should match the boottarget.bprofile field. 

You can then run: 
    
    [root@wopr xCAT]# nodeset x3455001 netboot
    x3455001: netboot boottarget-x86-test2

Now, you'll see your /tftpboot/pxelinux.cfg/&lt;nodehex&gt; file shows: 
    
    #netboot boottarget-x86-test2
    DEFAULT xCAT
    LABEL xCAT
     KERNEL kernel2.8
     APPEND arg1 vale to ipsom lorum=wer

now reboot your node and you're on your way! 

Once you've done this - the next step that you might want to consider is setting up a notification trigger so that when you change a nodes' profile in the nodetype table or a parameter in an applicable boot target table entry that the appropriate pxelinux.cfg files are updated. To do this you simply: 
    
    #regnotif bootttmon.pm -o u

Then whenever you use the **chdef** command to change a node (or nodegroup) profile in the nodetype table or any of the fields in the boottarget table the pxelinux.cfg files will be updated as appropriate. **Note well:** Use of the **tabedit** command will not cause this notification handler to be invoked. A log file /var/log/bootttmon is generated with timestamped entries showing changed data and actions taken as a result of the changes. 
