![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


xCAT documents procedures and provides guidance for setting up a High Availability Management capability. If you are using this function, please follow all instructions in [Highly_Available_Management_Node]. 

When using the HA Management function in an IBM HPC cluster, you will need to take into account some additional considerations. 

  * In an HA MN environment, most of files and postscripts used by the HPC Integration procedure are located in the /install directory. You will need to ensure that any necessary files used in synclists are also copied to the standby management node. 
  * Verify that all custom files used for your HPC software installation and configuration are kept current on the standby management node. These include all application software packages, prescripts, postscripts, postinstall scripts, included package list files, exclude lists, and any other custom files you may have created. The easiest way to keep these synchronized is to keep them in your /install directory so they are automatically copied over by the base HA MN procedures you have put in place. Also, verify that all scripts and included files referenced by your custom files are available on standby management node. 
  * Verify that the xCAT-IBMhpc rpm is installed on your standby management node. This rpm contains all of the default sample HPC installation and configuration files and scripts used for setting up the IBM HPC software stack in your cluster. 
  * Ensure that all application files residing on the primary management node are available and kept current on the standby management node. If the data resides in a common filesystem such as a global NFS user home directory or in a GPFS filesystem, ensure these directories are mounted and available on the standby management node. If the data resides in local files on your primary management node, you will need to add them to your synclists that are periodically copied to your standby management node. 

     For example: 

     /etc/LoadL.cfg is one such file that must always be copied. Also, if you are NOT using the LoadLeveler database configuration option, the /etc/LoadL.cfg file may reference many other LoadLeveler configuration files. You will need to ensure that all of these configuration files are available and kept current on the standby management node. Depending on your cluster configuration, these files may reside in a common LoadLeveler administrator user home directory such as /u/loadl. If so, ensure that this directory is also mounted and available on the standby management node. 

  


  * During the failover process, start all application services that your primary xCAT management node had provided. The base failover process includes IP address takeover on the standby management node. So, in addition to the xCAT management network IP address changes, you may need to do IP address takeover for additional application networks that your management node is connected to. You may then need to manually start and verify application services. 

     For example, if your xCAT management is also your LoadLeveler central manager, you will need to issue an llctl start command to start the LL daemons. If you are also running with the LoadLeveler database configuration option, you may want to verify the LoadLeveler configuration 

~~~~

   llctl ckconfig <path/LoadL.config>, verifies that your LoadLeveler configuration data is available and correct. 
   llrconfig -d, checks the running database values (d means display) 
~~~~
