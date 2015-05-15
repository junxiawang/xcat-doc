<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Interface==](#interface)
  - [Customize the mypostscript.tmpl (Optional)===](#customize-the-mypostscripttmpl-optional)
  - [Create post scripts and post boot scripts===](#create-post-scripts-and-post-boot-scripts)
  - [Copy all the scripts to /install/winpostscripts===](#copy-all-the-scripts-to-installwinpostscripts)
  - [Set the scripts to postscript and postbootscripts attributes for corresponding nodes or osimage===](#set-the-scripts-to-postscript-and-postbootscripts-attributes-for-corresponding-nodes-or-osimage)
  - [Enable the precreatemypostscripts===](#enable-the-precreatemypostscripts)
- [Implementation](#implementation)
  - [Copy postscripts needed stuffs to compute node](#copy-postscripts-needed-stuffs-to-compute-node)
  - [xcatwinpost.vbs and runpost.vbs](#xcatwinpostvbs-and-runpostvbs)
  - [Run the Post Boot Scripts](#run-the-post-boot-scripts)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 

##Overview

xCAT has supported the running of postscripts and postbootscripts for deployment of Linux node. This design is focus on how to support the running of postscripts and postbootscripts during deployment of Windows compute nodes.

The basic functionalities:
:*Support to run postscripts before the first reboot.
:*Support to run postbootscripts after the first reboot.
:*Support to pass arguments to postscripts and postbootscripts. The usage of how to pass arguments to postscripts and postbootscripts is same with Linux. e.g., postscripts="script1 p1 p2,script2,..."
:*Support to export environment variables for postscript and postbootscript to use in runtime. Windows node will share the same template with Linux node at: /opt/xcat/share/xcat/templates/mypostscript/mypostscript.tmpl
:*The default postscripts/postbootscripts which are set in the 'postscripts.xcatdefaults' will be ignored by Windows compute node.
:*The running order of postscripts is same with Linux that the postscripts which are set in osimage will be run first and then the ones in node definition.
:*No Service node and updatenode are considered.

##Interface==

###Customize the mypostscript.tmpl (Optional)===
The mypostscript.tmpl is a template which is used to create the mypostscript script which includes environment variables and postscripts to run in compute node. The default path of it is /opt/xcat/share/xcat/templates/mypostscript/mypostscript.tmpl. If you want to customize it, copy it to /install/postscripts/mypostscript.tmpl and customize it with the rules in [Postscripts_and_Prescripts].

###Create post scripts and post boot scripts===
The scripts can be any file which can be run in Windows OS.

Since Windows OS recognizes the file type by the postfix, all the postscripts which are created for Windows compute node should have correct postfix like .bat, .cmd, .vbs, .ps1

When running of postscripts, the running log will be written to c:\xcatpost\xcat.log. Admin can check the log at anytime for checking and debugging.

###Copy all the scripts to /install/winpostscripts===
On the xCAT management node, copy the postscripts/postbootscripts to /install/winpostscripts. If there are files which will be called by your scripts, also copy them to /install/winpostscripts
 cp <scripts> /install/winpostscripts

###Set the scripts to postscript and postbootscripts attributes for corresponding nodes or osimage===
Note: the scripts which are set by postscripts.xcatdefaults will be ignored.
 chdef <node> postscript="xx arg1 arg2,yy" postbootscripts="aa,bb arg1"
 chdef -t osoimage <osimage name> postscript=xx,yy postbootscripts=aa,bb

###Enable the precreatemypostscripts===
In the first pass support, the '''precreatemypostscripts''' must be enabled. That means for any changes in postscript/postscripts attributes or mypostscript.tmpl, the nodeset command must be run to refresh the mypostscript.
 chdef -t site clustersite precreatemypostscripts=1

4. Run the OS deployment
 nodeset <node> osimage=<osimage name>
 rpower


##Implementation
###Copy postscripts needed stuffs to compute node
In existed code logic, there is a install/autoinst/<node>.cmd file which is used to initiate the OS deployment. Following piece of code will be added in <node>.cmd to copy the files.
 If existed mypostscript.<node> in MN:/install/mypostscript
  copy MN:/install/mypostscript/mypostscript.<node> c:\xcatpost\
  oppy MN:/install/winpostscripts/* c:\xcatpost\
 Else 
  Do nothing
 End if

###xcatwinpost.vbs and runpost.vbs
Create a script named 'xcatwinpost.vbs' which will be used to initiate the postscript mechanism. Create a script named 'runpost.vbs' which will be used to run postscript and log debug messages.

Both of the scripts will be installed at /install/winpostscripts/ on xCAT MN and SN by xCAT rpm. Them will be copied to compute node by section: '''Copy postscripts needed stuffs to compute node'''

xcatwinpost.vbs will parse the mypostscript.<node> and generate the mypostscript.cmd for postscripts running and mypostbootscript.cmd for postbootscripts running.

===Inject xcatwinpost.vbs===
Inject the xcatwinpost.vbs in unattend.xml so that it can be called during node deployment by Windows setup program

Add a section like following in /install/autoinst/<node>.xml when run nodeset command:
 <RunSynchronous>
   <RunSynchronousCommand wcm:action="add">
      <Description>StartPointOfPostscripts</Description>
      <Order>50</Order>
      <Path>c:\xcatpost\winpostscripts\xcatwinpost.vbs</Path>
      <WillReboot>OnRequest</WillReboot>
   </RunSynchronousCommand>
 </RunSynchronous>

###Run the Post Boot Scripts
Use /install/autoinst/<node>.cmd to create a file named C:\Windows\Setup\Scripts\SetupComplete.cmd on Windows compute node. This is a Windows specific file which is called automatically at the first boot. 

Add the file 'mypostbootscript.cmd' which is created by 'xcatwinpost.vbs' into the C:\Windows\Setup\Scripts\SetupComplete.cmd to initiate the running of postbootscripts.



## Other Design Considerations 

* '''Required reviewers''':  
* '''Required approvers''':  Bruce Potter
* '''Database schema changes''':  N/A
* '''Affect on other components''':  N/A
* '''External interface changes, documentation, and usability issues''':  N/A
* '''Packaging, installation, dependencies''':  N/A
* '''Portability and platforms (HW/SW) supported''':  N/A
* '''Performance and scaling considerations''':  N/A
* '''Migration and coexistence''':  N/A
* '''Serviceability''':  N/A
* '''Security''':  N/A
* '''NLS and accessibility''':  N/A
* '''Invention protection''':  N/A