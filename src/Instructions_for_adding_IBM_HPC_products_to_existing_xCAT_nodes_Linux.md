If your nodes are already installed with the correct OS, and you are adding HPC software to the existing nodes, continue with these instructions and skip the next step to "Network boot the nodes".

The updatenode command will be used to add the HPC software and run the postscripts using the pkglist and  otherpkgs.pkglist files created above. Note that support was added to updatenode in xCAT 2.5 to install
packages listed in pkglist files (previously, only otherpkgs.pkglist entries were installed).  
If you are running an older version of xCAT, you may need to add the pkglist entries to your otherpkgs.pkglist file or install those packages in some other way on your existing nodes.

You will want updatenode to run zypper or yum to install all of the packages. 
 Make sure their repositories have access to the base OS rpms:


For SLES:

~~~~
   xdsh <noderange> zypper repos --details  | xcoll
~~~~

For RedHat:

~~~~
   xdsh <noderange> yum repolist -v  | xcoll
~~~~
If you installed these nodes with xCAT, you probably still have repositories set pointing to your distro  directories on the xCAT MN or SNs.  If there is no OS repository listed, add appropriate remote repositories using the zypper ar command or adding entries to /etc/yum/repos.d.

Also, for updatenode to use zypper or yum to install packages from your /install/post/otherpkgs directories, make sure you have run the createrepo command for each of your otherpkgs directories (see instructions in [Using Updatenode] .

Synchronize configuration files to your nodes (optional):

~~~~
   updatenode <noderange> -F
~~~~

Update the software on your nodes:

~~~~
   updatenode <noderange> -S
~~~~

Run postscripts and postbootscripts on your nodes:

~~~~
   updatenode <noderange> -P
~~~~