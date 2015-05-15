For Linux: the operating system images definitions are already in the xCAT database, and the operating system image files are already in /install directory.

For AIX: If the HANIM is being used for keeping the NIM resources synchronized, then no manual steps are needed to create the NIM resources on the standby management node; otherwise, the operating system image files are in /install directory, but you will have to create the NIM resources manually. Here are some manual steps that can be referred to for re-creating the NIM resources:

For AIX:
If the nim master is not initialized, run command 

~~~~

nim_master_setup -a mk_resource=no -a device=<source directory> 
~~~~

to initialize the NIM master, where the <source directory> is the directory that contains the AIX installation image files.

Run the following command to list all the AIX operating system images.

~~~~ 
            lsdef -t osimage -l
~~~~

For each osimage:
 Create the lpp_source resource:

~~~~
        /usr/sbin/nim -Fo define -t lpp_source -a server=master -a location=/install
         /nim/lpp_source/<osimagename>_lpp_source <osimagename>_lpp_source
~~~~

 Create the spot resource:

~~~~
        /usr/lpp/bos.sysmgt/nim/methods/m_mkspot -o -a server=master -a
           location=/install/nim/spot/ -a source=no <osimage>
~~~~
 
 Check if the osimage has any of the following resources:

~~~~
         "installp_bundle", "script", "root", "tmp", "home",
         "shared_home", "dump" and "paging"
~~~~

If yes, use commands

~~~~

  /usr/sbin/nim -Fo define -t <type> -a server=master -a location=<location>
   <osimagename>_<type>

~~~~

to create all the necessary nim resources, where the <''location''> is the resource location returned by 

~~~~
       lsdef -t osimage -l 
~~~~

If the osimage has shared_root resource defined, the shared_root resource directory needs to be removed before recreating the shared_root resource, here is an example:

~~~~
    rm -rf /install/nim/shared_root/71Bshared_root/
    /usr/sbin/nim -Fo define -t shared_root -a server=master -a \
     location=/install/nim/shared_root/71Bshared_root -a spot=71Bcosi 71Bshared

~~~~

Note: If the NIM master was already up and running on the standby management node prior to failover, the NIM master hostname needs to be changed, you can use smit nim to perform the NIM master hostname change.

If you are seeing ssh problems when trying to ssh the compute nodes or any other nodes, the hostname in ssh keys under directory $HOME/.ssh needs to be updated.

** Run nimnodeset or mkdsklsnode

Before run nimnodeset or mkdsklsnode, make sure the entries in file /etc/exports match the exported NIM resources directories, otherwise, you will get exportfs error and nimnodeset/mkdsklsnode could not be finished successfully.

* Performing management operations
After finishing these steps, the standby management node is ready for managing the cluster, and you can run any xCAT commands to manage the cluster. For example, if the diskless nodes need to be rebooted, you can run

~~~~
  rpower <noderange> reset or rnetboot <noderange>
~~~~

to initialize the network boot.