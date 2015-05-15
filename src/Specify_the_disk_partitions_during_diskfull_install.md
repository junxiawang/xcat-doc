<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [overview](#overview)
- [External Interface](#external-interface)
  - [use partition definition file](#use-partition-definition-file)
  - [use script to create partition definition](#use-script-to-create-partition-definition)
- [Internal implementation](#internal-implementation)
- [Limitation](#limitation)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)


## overview

xCAT use "nodeset &lt;noderange&gt; install" to create the install configure file(RHEL/CentOS/Fedora/SL/ESXI call kickstart file, SLES/SUSE/WINDOWS use xml file, Debian/Ubuntu call squeeze file) for each node. Command nodeset use *.tmpl file as a template and create each node's configure file. Currently the partition part in the *.tmpl file are hard code. There is a new requirement which from PCM is "Ability to specify the disk partitions that should be setup during diskfull install". 

## External Interface

### use partition definition file

1\. Write a file contains the partition definition. The definition format should be based on the OS type. 

for RHEL/CentOS/Fedora/SL/ESXI likes: 
    
     part swap --size 2048
     part / --size 1 --grow --fstype ext3
    

for SLES/SUSE likes: 
    
       <drive>
         <device>/dev/sda</device>
         <initialize config:type="boolean">true</initialize>
         <use>all</use>
       </drive>
    

for Windows likes: 
    
     <DiskConfiguration>
       <WillShowUI>OnError</WillShowUI>
       <Disk>
         <DiskID>0</DiskID>
         <WillWipeDisk>true</WillWipeDisk>
         <CreatePartitions>
           <CreatePartition>
             <Order>1</Order>
             <Type>Primary</Type>
             <Extend>true</Extend>
             </CreatePartition>
            </CreatePartitions>
       </Disk>
     </DiskConfiguration>
    

for Debian/Ubuntu likes: 
    
     d-i partman-auto/expert_recipe string               \
         boot-root ::                                    \
                 40 50 100 ext3                          \
                 $primary{ } $bootable{ }                \
                 method{ format } format{ }              \
                 use_filesystem{ } filesystem{ ext3 }    \
                 mountpoint{ /boot }                     \
    

2\. use "chdef -t osimage &lt;imagename&gt; partitionfile=&lt;definition file absolute path&gt;" to modify the osimage object. 

3\. run "nodeset &lt;noderange&gt; install". The install configure file will contains the partition definition in the specified file. 

### use script to create partition definition

1\. write a script file, which can create a partition definition, and save the definition into /tmp/partitionfile (this file name can not be changed). Like: 
    
     echo "part swap --size 1024" > /tmp/partitionfile
     echo "part / --size 1 --grow --fstype ext3" >> /tmp/partitionfile
    

2\. use "chdef -t osimage &lt;imagename&gt; partitionfile=s:&lt;script file absolute path&gt;" to modify the osimage object. 

3\. run "nodeset &lt;noderange&gt; install". The install configure file will contains the script which contained in %pre part and use "%include /tmp/partitionfile" to define the partition strategy. 

  


## Internal implementation

1\. Database change: add an attribute partitionfile into osimage object. Put the partitionfile attribute into the linuximage schema. The user can use the chdef command to set/change the partitionfile attribute for the image. 

2\. *.tmpl file change: find out the partition definition subset in all *.tmpl files, use special comment line embrace the subset. 

  * for non-xml format .tmpl file, use #XCAT_PARTITION_START# and #XCAT_PARTITION_END# to embrace the subset. 
  * for xml format .tmpl file, useandto embrace the subset. 

3\. template.pm&nbsp;: 

  * In mkinstall(): 
    
    a. get the osimage's partitionfile attribute.
    b. call subvars(), use the partitionfile attribute value as a parameter.
    

  * In subvars(); 
    
    a. if the partitionfile is not exist: do not do any operations (will use the default definition in our *.tmpl file).
    b. if the partitionfile is exist, 
     i. If the partitionfile is start with s:... , add the content in the partitionfile into %pre part in the kickstartfile, use %include /tmp/partitionfile to replace the subset witch embrace by comment line
     ii. else, If partitionfile is readable, use the content in the partition file to replace the subset witch embrace by comment line(will use the specified definition).
    

## Limitation

  * only the .tmpl files from xCAT-server package can work. 
  * use script to create partition definition only works on redhat and sles linux. other version linux is still under design. 

## Other Design Considerations

  * Required reviewers: Bruce Potter, Li Guang Cheng 
  * Required approvers: Bruce Potter 
  * Database schema changes: N/A 
  * Affect on other components: N/A 
  * External interface changes, documentation, and usability issues: add the document how to use this function 
  * Packaging, installation, dependencies: N/A 
  * Portability and platforms (HW/SW) supported: N/A 
  * Performance and scaling considerations: N/A 
  * Migration and coexistence: N/A 
  * Serviceability: N/A 
  * Security: N/A 
  * NLS and accessibility: N/A 
  * Invention protection: N/A 