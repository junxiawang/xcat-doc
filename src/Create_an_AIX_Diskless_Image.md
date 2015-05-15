  
In order to boot a diskless AIX node using xCAT and NIM you must create an xCAT osimage definition as well as several NIM resources. 

You can use the xCAT **mknimimage** command to automate this process. 

There are several NIM resources that must be created in order to deploy a diskless node. The main resource is the NIM SPOT (Shared Product Object Tree). An AIX diskless image is essentially a SPOT. It provides a **/usr** file system for diskless nodes and a root directory whose contents will be used for the initial diskless nodes root directory. It also provides network boot support. 

When you run the command you must provide a source for the installable images. This could be the AIX product media, a directory containing the AIX images, or the name of an existing NIM lpp_source resource. You must also provide a name for the osimage you wish to create. This name will be used for the NIM SPOT resource that is created as well as the name of the xCAT osimage definition. The naming convention for the other NIM resources that are created is the osimage name followed by the NIM resource type, (ex. " 61cosi_lpp_source"). 

**Stateful or stateless?**

You can choose to have your diskless nodes be either "stateful" or "stateless". If you want a "stateful" node you must use a NIM "root" resource. If you want a "stateless" node you must use a NIM "shared_root" resource. 

**A "stateful" diskless node** preserves its state in individual mounted root filesystems. When the node is shut down and rebooted, any information that was written to a root filesystem will be available 

**A "stateless " diskless node** uses a mounted root filesystem that is shared with other nodes. When it writes to its root directory the information is actually written to memory. If the node is shut down and rebooted any data that was written is lost. Any node-specific information must be re-established when the node is booted. 

The advantage of stateless nodes is that there is much less network traffic and fewer resources used which is especially important in a large cluster environment. 

For more information regarding the NIM "root" and "shared_root" resource refer to the NIM documentation. 

If you wish to set up stateless cluster nodes you must use the "-r" option when you run the **mknimimage** command. The default behavior would be to set up stateful nodes. 

For example, to create a stateless-diskless osimage called "61cosi" using the software contained in the /myimages directory you could issue the following command. 

~~~~
    
    mknimimage -r -t diskless -s /myimages 61cosi
~~~~    

(Note that this operation could take a while to complete!) 

**Caution:** Do not interrupt (kill) a NIM process while it is creating a SPOT resource. 

Starting with xCAT version 2.5 you can also use the "-D" option to specify that a dump resource should be created. See the section called "ISCSI dump support" in the following document for more information on the diskless ISCSI dump support.
[XCAT_AIX_Diskless_Nodes/#iscsi-dump-support](XCAT_AIX_Diskless_Nodes/#iscsi-dump-support)

**Note**: To populate the /myimages directory you could copy the software from the AIX product media using the AIX **gencopy** command. For example you could run "gencopy -U -X -d /dev/cd0 -t /myimages all". 
The **mknimimage** command will display a summary of what was created when it completes. For example: 
 
~~~~   
    Object name: 61cosi
    imagetype=NIM
    lpp_source=61cosi_lpp_source
    nimtype=diskless
    osname=AIX
    paging=61cosi_paging
    shared_root=61cosi_shared_root
    spot=61cosi
~~~~    

The NIM resources will be created in a subdirectory of /install/nim by default. You can use the "-l" option to specify a different location. 

You can also specify alternate or additional resources on the command line using the "attr=value" option, ("&lt;nim resource type&gt;=&lt;resource name&gt;"). For example, if you want to include a "resolv_conf" resource named "61cosi_resolv_conf" you could run the command as follows. 

~~~~    
    mknimimage -t diskless -s /dev/cd0 61cosi resolv_conf=61cosi_resolv_conf
~~~~    

**Any additional NIM resources specified on the command line must be previously created using NIM interfaces. **(Which means NIM must already have been configured previously. ) 

**Note**: Another alternative is to run **mknimimage** without the additional resources and then simply add them to the xCAT osimage definition later. You can add or change the osimage definition at any time. When you initialize and install the nodes xCAT will use whatever resources are specified in the osimage definition. 

The xCAT osimage definition can be listed using the **lsdef** command, modified using the **chdef** command and removed using the **rmnimimage** command. See the **man** pages for details. 

To get details for the NIM resource definitions use the AIX **lsnim** command. For example, if the name of your SPOT resource is "61cosi" then you could get the details by running: 

~~~~    
    lsnim -l 61cosi
~~~~    

To see the actual contents of a NIM resource use "nim -o showres &lt;resource name&gt;". For example, to get a list of the software installed in your SPOT you could run: 
 
~~~~   
    nim -o showres 61cosi
~~~~    
