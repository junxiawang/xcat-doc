<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [The enhancement of xdcp command for File Syncing](#the-enhancement-of-xdcp-command-for-file-syncing)
  - [Sync files to the nodes:](#sync-files-to-the-nodes)
  - [sync files into images:](#sync-files-into-images)
  - [Hierarchy support for xdcp File Syncing:](#hierarchy-support-for-xdcp-file-syncing)
- [](#)
  - [Perform the File syncing periodically](#perform-the-file-syncing-periodically)
- [The enhancement of updatenode command:](#the-enhancement-of-updatenode-command)
  - [The syntax of updatenode command:](#the-syntax-of-updatenode-command)
  - [Add the include capability:](#add-the-include-capability)
- [Internal design of File Syncing function:](#internal-design-of-file-syncing-function)
  - [Installation process:](#installation-process)
    - [1\. Full install](#1%5C-full-install)
    - [2\. Diskless netboot](#2%5C-diskless-netboot)
  - [Updatenode -F:](#updatenode--f)
    - [What updatenode -F will do:](#what-updatenode--f-will-do)
    - [**For hierarchical scenario:**](#for-hierarchical-scenario)
    - [Updatenode -P will not run syncfiles/otherpkgs postscripts:](#updatenode--p-will-not-run-syncfilesotherpkgs-postscripts)
  - [Sync files to the image:](#sync-files-to-the-image)
    - [Linux:](#linux)
    - [AIX:](#aix)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)


# The enhancement of xdcp command for File Syncing

The basis of this capability is the new -F option on xdcp, which inputs a file that lists from/to pairs of files/dirs that should be sync'd to the noderange (or diskless image) that is passed into xdcp. The format of this file is: 
    
    /install/syncfiles/etc/services -&gt; /etc/services/
    /etc/groups /etc/passwd -&gt; /etc

Each line can have one or more "from" files or dirs, but must have only one "to" file or dir, after the "-&gt;". 

## Sync files to the nodes:
    
    xdcp compute -F /install/custom/install/sles11/compute.synclist

This will sync all the files listed in compute.synclist to the nodes in the compute group. By default, if the -F option is used, -r with /bin/rsync is assumed. For rsync with xdcp, we only support the ssh remote shell for rsync.  
xdcp will add the following rsync flags to the call to rsync unless the admin adds the -o flag to the call, where they can set their own rsync flags. The default rsync flags will be (-upogtz). 

## sync files into images:
    
    xdcp -i /install/netboot/sles11/ppc64/compute -F /install/custom/install/sles11/compute.synclist

## Hierarchy support for xdcp File Syncing:

For hierarchical support where nodes are being updated by servicenodes, the following happens.  
To sync files to the Service nodes for the range of compute nodes, run the following command. 
    
    xdcp compute  -F /tmp/compute.synclist

Where the compute.synclist file contains lines like this: 
    
    /etc/services -&gt; /etc/services

xdcp will sync the files to the default /var/xcat/syncfiles directory on the service nodes that service the compute node range.  
For the example, the /etc/passwd file from the Management Node will be put in /var/xcat/syncfiles/etc/passwd. xdcp will then sync the file from the /var/xcat/syncfiles/etc/passwd on the Service Nodes to the /etc/passwd directory on their compute nodes. The service node default sync directory , /var/xcat/syncfiles, can be changed by setting the site table, SNsyncfiles attribute. 

# 

## Perform the File syncing periodically

The options -F and -i on the xdcp cmd can be used manually by the admin, put into scripts, put on crontab, or used by FAM. This gives the user maximum control and flexibility.  
The updatenode -F also can be put into scripts, crontab and FAM. 

  


# The enhancement of updatenode command:

## The syntax of updatenode command:
    
    updatenode &lt;noderange&gt; [-F] [-S] [-P] [postscript,...]

The updatenode command can be used to update the nodes which listed in the noderange. The update features include sync files to the nodes, perform the software maintenance and re-run the postscripts for the nodes.  
By default, the updatenode command syncs files which defined in the synclist to the nodes, update the software packages of the nodes and re-run the postsrcipts which defined in the postscripts table for the nodes. 

If run updatenode command with only -F option, it syncs files which configured in the synclist configuration file to the nodes. For Linux nodes, the synclist will be worked out from /install/custom/&lt;inst_type&gt;/&lt;distro&gt;/&lt;profile&gt;.&lt;os&gt;.&lt;arch&gt;.synclist; For AIX nodes, the path of synclist will be configured as an attribute of the osimage object. (Norm will handle the AIX part)  
If run updatenode command with only -S option, it performs the Software Maintenance. For Linux nodes, the otherpkgs postscript will be re-run to handle the software maintenance; For AIX nodes, the NIM installp_bundle of the osimage object will be used to handle the software maintenance. (Norm will handle the AIX part)  
If run updatenode command with only -P option, it re-runs the postscripts which configured in the node object.  
If run updatenode command with '-P postscript,...', it re-runs the postscripts listed in the 'postscript,...'.  
Note: The postscript otherpkgs will not be run when specified the '-P' option, since it's the approach of software maintenance for Linux nodes. This will avoid the otherpkgs to be run twice. 

## Add the include capability:

Add the include capability into the otherpkgs.pkglist configuration file. (Will be done by Ling)  
Add the include capability into the synclist configuration file. (Will be done by Lissa) 

  


# Internal design of File Syncing function:

## Installation process:

### 1\. Full install

Add the xCAT postscript 'syncfiles' in the /install/postscripts/ to handle the file distribution function for the compute node. syncfiles will call the startsyncfiles.awk (for Linux) or startsyncfilesaix(for AIX) to initiate the xdcp operation from the Management Node or Service Node.  
The work flow should be following: 
    
     getpostscript.awk -&gt; syncfiles -&gt; startsyncfiles.awk/startsyncfilesaix -&gt; xcatd -&gt;
       syncfiles.pm -&gt; get the synclist file -&gt; xdcp $node -f synclist

### 2\. Diskless netboot

Since genimage already synced the files to the image directories, the syncfiles postscript will not run during the diskless netboot process (even if you specified the syncfiles postscript in the porstscripts attribute).  
In order to not run syncfiles during the diskless netboot, the getpostscript will set the $ENV{'NODESETSTATE'} to 'netboot' when working in the diskless netboot process, so syncfiles postscript will do nothing when $ENV{'NODESETSTATE'} equals ”netboot” (Linux) or “diskless” (AIX) 

## Updatenode -F:

### What updatenode -F will do:

**For Linux node:**  
updatenode finds the synclist file in following location, and calls 'xdcp -F synclist' to sync files to the node. 
    
        /install/custom/&lt;inst_type&gt;/&lt;distro&gt;/&lt;profile&gt;.&lt;os&gt;.&lt;arch&gt;.synclist
          &lt;inst_type&gt;: "install", "netboot"
          &lt;distro&gt;: "rh", "centos", "fedora", "sles"
          &lt;profile&gt;,&lt;os&gt; and &lt;arch&gt; are what you set for the node

**For AIX node:**  
updatenode finds synclist file which configured in the osimage.synclist, and calls 'xdcp -F synclist' to sync files to the node. 

**Implementation detail:**  
In updatenode.pm, use subroutine xCAT::Utils-&gt;getsynclistfile to get the synclist file for all the nodes, and classify the nodes by the synclist file, then send a request to the xdcp plugin to perform the 'xdcp $node -F synclist'. 

### **For hierarchical scenario:**

Since updatenode -F depends on the 'xdcp -F synclist', and 'xdcp -F synclist' has already handled the hierarchical scenario, updatenode -F does not need to take care of this. 

### Updatenode -P will not run syncfiles/otherpkgs postscripts:

Updatenode command will not initiate the syncfiles postscript even if you specify it in the postscript list. To make sure syncfiles is not executed, the following will happen. 

  * When the postscripts xcatdsklspost/xcataixpost called by the updatenode, a special flag UPDATENODE=1 will be set in the postscript running environment, and syncfiles postscript will not run when it finds UPDATENODE=1 has been set. 
  * In the xCAT::Postage-&gt;makescript, set the UPDATENODE=0 to the scripts as default, and then in the xcatdsklspost/xcataixpost set the UPDATENODE=1 when it's initiated by the updatenode command. 

updatenode command will not re-run the otherpkgs postscript even if you specify it in the postscript list. The otherpkgs will be removed from the postscript list when the re-run postscripts action initiated by the 'updatenode -P'. 

## Sync files to the image:

### Linux:

The packimage command automatically syncs the files to the root image if there is a synclist file in the defined location.  
Run xCAT::Utils-&gt;getsynclistfile to get the synclist file for the genimage base on the $os, $arch and $profile variables.  
Run following in the packimage command to sync files to the root image. 
    
        xdcp -i /install/netboot/sles11/ppc64/compute -F synclist

### AIX:

The mkdsklsnode command automatically syncs the files to the spot and root resource if there is a synclist file defined in the osimage.synclist  
Run xCAT::Utils-&gt;getsynclistfile to get the synclist file from the osimage.synclist.  
Run following command in the mkdsklsnode command to sync files to the nim image. 
    
        xdcp -i /install/nim/spot/61cosi/ -F synclist
