<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Required Reviewers](#required-reviewers)
  - [Required Approvers](#required-approvers)
- [Background](#background)
- [Design](#design)
  - [updatenode](#updatenode)
  - [xCAT::Postage::create_mypostscript_or_not](#xcatpostagecreate_mypostscript_or_not)
  - [nodeset](#nodeset)
  - [template.pm/postage.pm](#templatepmpostagepm)
  - [xcatdsklspost](#xcatdsklspost)
  - [getpostscript.pm](#getpostscriptpm)
  - [getpostscript.pm changes](#getpostscriptpm-changes)
  - [Other considerations](#other-considerations)
- [Alternate Design Considered](#alternate-design-considered)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)



### Required Reviewers

  * Ling Gao 
  * Jie Hua Jin 
  * Kerry Bosworth 

### Required Approvers

  * Bruce Potter 

## Background

In xCAT 2.8, site.precreatemypostscripts was added to enhance the performance. The logic is this: 

1\. when site.precreatemypostscripts=1, nodeset/updatenode creates mypostscritps and save it on the server as /tftpboot/mypostscripts/mypostscrtipt.$nodename. The Linux node uses "wget http" to download it and then run it. The AIX node, tftp. 

2\. when site.precreatemypostscripts=0,nodeset/updatenode does not create the file on the server. The node calls "getpostscritpts.awk version 2" to have it created on the server as /tftpboot/mypostscripts/mypostscrtipt.$nodename.tmp. The Linux node uses "wget http" to download it and then runs it. AIX uses tftp. 

With defect 3398 fix which is related to wget part in xcatdsklspost. In xcatdsklspost, before running wget, it has to figure out the $nodename as well as site.precreatemypostscripts so that it can get the correct mypostscrtipt file on the server. Here is the logic I have used: 

1) get the server name 

2) figure out the node name: (we consider the situation that the hostname is not the same as the node name) 

2.1)use "ip route get" to figure out which nic/ip on the node can get to the server. 

2.2)use "getent hosts &lt;ip&gt;" to figure out the possible node name. It may give you two names, a long name and a short name. 

2.3)If above fails, use "hostname -s" to get the short node name and use "hostname" to get the long node name. 

3) use "wget" with the short name to get mypostscritps.$shortname 

4) if failed, use "wget" with long name to get mypostscritps.$longname 

5) if failed, the assume site.precreatemypostscripts=0, run "getpostscripts.awk version 2" 

6) use "wget" with the short name to get mypostscritps.$shortname 

7) if failed, use "wget" with long name to get mypostscritps.$longname 

This logic helps the case when site.precreatemypostscripts=1, but make the performance worse when it is 0 which is used by most of customers. It has to go through 3 wgets and one getpostsctipts.awk to get the mypostscript file. In the old way, we only made one call (getpostsctipts.awk) to get it. It is because of this performance problem, we are coming up with a new design. 

## Design

The new design of generating and downloading the mypostscript files will be as follows. 

  * xdsh/xdcp will export an environment variable NODE on the ssh call which will contain the nodename as defined in the xCAT database. This will enable xcatdsklspost and xcataixpost to have a definitive way to know the node name. This nodename will be put in the /opt/xcat/xcatinfo file during updatenode execution by xcatdsklspost/xcataixpost. 
  * For install, a kernal parameter must be added to define the NODE parameter, which will be the node name as defined in the database. This nodename will be put in the /opt/xcat/xcatinfo file during install by xcatdsklspost. 

### updatenode

  * updatenode will no longer create the mypostscript.&lt;nodename&gt;.tmp file. It will create a mypostscript.&lt;nodename&gt; file as does nodeset in the /tftpboot/mypostscripts directory. 
    * If the site.precreatemypostscripts = 0, the /tftpboot/mypostscripts/my* files will be removed. Then updatenode will create the mypostscript* files for the noderange. They will be removed at the end of the updatenode execution. 
    * If site.precreatemypostscripts =1, it will create the mypostscripts files for the noderange, and remove at the end of the execution. This will require a new interface to **xCAT::Postage::create_mypostscript_or_not**. 

### xCAT::Postage::create_mypostscript_or_not

Understand that the call is from updatenode and will create the mypostscript.node files even if site.precreatemypostscripts=0. Two new flags input that are passed on to xCAT::Postage::makescript . $notmpfile and $nofiles are the new flags. If $notmpfile=1, then not files with the .tmp extension will be created. If $nofiles=1, then not mypostscript.&lt;nodename&gt; files will be created at all and the data will be returned in an array. nofiles is used by getpostscript.awk. notmpfiles is used by updatenote. 

### nodeset

  * nodeset will check 
    * if site.precreatemypostscripts=0, if true it will remove all the /tftpboot/mypostscripts/my* files. 
    * If site.precreatemyposcripts=1, then it will create the /tftpboot/mypostscript/my* files for the input noderange and not remove any of the other files. 

### template.pm/postage.pm

  * All code that does creation of the /tfptboot/mypostscript/my* files is moved out of Templage.pm and into Postage.pm. The one exception is sub enablesshbetweennodes in Template.pm because it is referenced in the mypostscript template file in 2.8 and 2.8.1 and would cause of migration problem, if someone had already modified it and put it in /install/postscripts. 
  * The code that does the creation of /tftpboot/mypostcript/my* files must honor hierarchy. If sharedtftp=1, then they can just be created locally. If sharedtftp=0 or not set, then they must be created on the service node /tftpboot/mypostscripts directory for the nodes in the noderange. 

### xcatdsklspost

xcatdsklspost will do the following: 

  * first call wget with the NODE name supplied from the kernel parm or the Env Variable to get the mypostscript.&lt;NODE&gt; file, if available. If the file is return, then it is used on the wget. 
  * On an updatenode call to xcatdsklspost,the mypostscripts file should be there since updatenode just created it. The NODE should be correct since this is on the xdsh call. I am planning to just stop with error, if wget does not succeed. It seems that continuing to try a getpostscript.awk call is not relevant on this path. 
    * It will update the /opt/xcat/xcatinfo file with NODE information. Should it update XCATSERVER information - No because of SN pools support. 
  * On a non-updatenode call to xcatdsklspost, if wget fails or the NODE information is not available to xcatdsklspost then 
    * it will look in xcatinfo file for the NODE information. If it exists, it will use the information from xcatinfo to call wget. 
    * If the wget fails for that NODE, it will try to determine the hostname with the current logic and try wget again. 
    * If that fails, then it will go the getpostscript.awk call where no nodename is required. 
      * First it contact xcatd to determine if the xcatd is ready using the new interface. 
      * If ready, it will use getpostscript.awk to download the mypostscript file. The version number is no longer needed. getpostscripts.awk calls getpostscripts, which can determine the correct file name to return. 
  * xcatdsklspost calling getpostscript.awk (version2 ) will no longer be used. The function in getpostscript.pm will still need to support the call, if an xcatdsklspost (2.8 and 2.8.1) has been built into the image for installs. 
  * xcatdsklspost will update the /opt/xcat/xcatinfo file with the nodename from the NODE env var or kernel parm, if supplied on the call. 

### getpostscript.pm

getpostscript.pm - Still support version2 but update the no version number path so that it can be the default for 2.8.1 and yet not break 2.7 and earlier code. 

**Template.pm and Postage.pm -** An attempt will be made, to make the AIX and Linux processing the same. We will therefore support precreatemypostscripts for both AIX and Linux. We will also add supporting long hostnames in the xCAT database. the mypostscripts.&lt;longhostname&gt; file will be generated for these long hostnames. 

**TBD: Work with Jarrod on nodename determination and "per node certificates".**

### getpostscript.pm changes

On the server, getpostscript reads the site.precreatemypostscripts setting and determine the name of the file to return. 

  * If precreatemypostscript = 1: it reads the existing file for the node, and return the content of the /tftpboot/mypostscripts/mypostscript.$nodename file. If the file does not exist, generate the file and return the content. 
  * If precreatemypostscript not 1 or not set: it generates the file and return the content of the file 

### Other considerations

  * FQDN hostnames 

In current xcatd code, we support long hostname in the database. We will need to add support for long hostnames in the xCAT database and in the postscripts interface. 

  


  * Performance 

After performance test, it was decide to go with wget first and use getpostscript.awk as a last choice. Need to check if there is room for performance improvements in getpostscript.pm, getpostscript.awk, Template.pm and Postage.pm. 

Should we change AIX to use wget and ship wget in the deps package. 

  


  * Migration 

Another item to consider is backward compatibility. For pre-release 2.8, if the user has old stateless/statelite image, that means the 2.7 or older /opt/xcat/xcatdsklspost is in the image and is used when the node reboot, (same is true for diskful case when site.runbootscripts=yes). Will it still work? The answer is yes, because getpostscripts.pm supports calls with no version and that is how it will be called with this new design. 

For release 2.8, if images are built with the xcatdsklspost from 2.8, then the version2 option will still be honored by getpostscripts. The logic will remain the same. 

updatenode is not a problem because it pushed the new xcatdsklspost down to the node. 

  * AIX and Linux 

This design will try and merge the logic of building the Linux and AIX mypostscript file. Currently Linux uses logic in Template.pm and AIX uses logic in Postage.pm. An attempt will be made to use the same code for both. In doing that we will can support precreatemypostscript on AIX. 

## Alternate Design Considered

Let xcatdsklspost know the setting of site.precreatemypostscripts before hand 

(Considered but will not be implemented) 

This is a chicken-and-egg problem. The setting is contained in mypostscript file. But we need it to get mypostscript file using that setting. The thought is to pass this value down to xcatdsklspost through a kernel parameter in the deployment case and as a parameter in the updatenode case. Let's make sure we cover everything: 

1.1) stateless and statelite deployment, use kernel parameter 

1.2) stateful deployment: both node name and site.precreatemypostscripts is known by the server, so only one call is needed to put in the kick start/autoyast configuration file. 

1.3) updatenode: pass it down as a parameter to xcatdsklspost 

1.4) running postbootscripts for diskfull node reboot when site.runbootscripts=yes: no way to know the current site.precreatemypostscripts setting. Have to try the mypostscrtipt.$nodename and then try mypostscrtipt.$nodename.tmp 

  


## Other Design Considerations

  * **Required reviewers**: Bruce, Lissa ,Ling , Guang Cheng, Jie hua 
  * **Required approvers**: Bruce Potter 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: N/A 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
