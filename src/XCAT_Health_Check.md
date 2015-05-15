<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Interface](#interface)
  - [xCAT Files for the health check](#xcat-files-for-the-health-check)
  - [The definition of health check resource](#the-definition-of-health-check-resource)
  - [Syntax of xhealthcheck](#syntax-of-xhealthcheck)
  - [The General Interface for dohealthcheck](#the-general-interface-for-dohealthcheck)
  - [The interface for each healthcheck tool](#the-interface-for-each-healthcheck-tool)
- [Implementation](#implementation)
  - [Inside of xhealthcheck](#inside-of-xhealthcheck)
  - [Inside of dohealthcheck](#inside-of-dohealthcheck)
- [Check Scenarios](#check-scenarios)
- [More consideration](#more-consideration)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)



## Interface

### xCAT Files for the health check

  * /opt/xcat/bin/xhealthcheck 

The xCAT command to initiate the health check action 

  * /opt/xcat/sbin/dohealthcheck 

The script will be run on the target node (xCAT MN/SN or compute node) to parse the check request, call each check and generate the return message. 

  * /install/healthcheck/&lt;health check tools&gt;

The 'health check tool' is an OS executable file which can perform some specific checking. 

  * /install/healthcheck/hc.checksum 

A specific file to maintain the change of files in /install/healthcheck 

### The definition of health check resource

A **health check resource** is an unit which can be selected to check for end user. The name of 'health check resource' is composed of 'resource group' and 'sub resource name' by character '@'. e.g. I have a resource group named **tcpip** which is used to check any tcpip configuration, and this group includes several sub resources like 'dns', 'http', 'ib' ... Then the resource name will be tcpip@dns, tcpip@http, tcpip@ib. 

From the implementation perspective, the health check resources are offered by health check tool which is an executable OS file. In general, the 'health check resource group' is name of a 'health check tool'. .e.g A file named 'tcpip' will be added in /install/healthcheck/ and it offers the checking for sub resources like 'dns', 'http', 'ib'. 

### Syntax of xhealthcheck
    
        xhealthcheck -h | -v
        xhealthcheck -d 
             Display all the available check resources which have been installed in /install/healthcheck
        xhealthcheck {noderange} g1@r1 g1@r2 g2@r1 g3
             if just specifying a group name, all the resources in the group will be run.
        xhealthcheck {noderange} g1@r1=paramlist g3=paramlist
             The paramlist is a string which separated by ','
        xhealthcheck {noderange} -f check_src_file
             the check_src_file contains the list of check resources
        The {noderange} here is optional, that means you could ignore the {noderange} if you want to run the check on xCAT MN and SN.
    

### The General Interface for dohealthcheck

The json format will be used. This is also the interface that is used to offer functions for external UI. 

  * Input Interface: 
    
    [    
       {  # to make every check to be an element of array so that to control the running order of health check
             group1: {
                  globalparam: [p1, p2, ...],
                  resource1: {
                       param: [p1, p2, ...],
                  }
              },
        },
        {
             check2 ...
        },
    ]
    

  * Output Interface: 
    
    {
        group1:{
             resource1: {
                  errorcode: 1,
                  error: "errormessage",
                  returncode: "0 - OK, 1 - Warning, 2 - Error ...",
                  message: "return message",
             }
        },
    }
    

### The interface for each healthcheck tool

  * The tool can be any binary or scripts which can be run on an Operating System directly; (shell, python, peel, binary) 
  * The tool must have executable permission; 
  * The tool must be installed to /install/healthcheck directory before running the xhealthcheck command; 
  * The tool must check the level of Operating System which it is running on. If it cannot run on the OS, return the error message like following: 
    
    {errorcode: xx, error: &lt;Cannot run on the operating system.&gt;}
    

  * The interface of tool: 

    

  * Support the option -d 
    
    display all the check resources.
    

    

  * intput 
  * output 

## Implementation

### Inside of xhealthcheck

The inside code logic of xhealthcheck: 

  * 1\. Check the 'health check resource' have been installed in /install/healthcheck 

    

  * 1.1 If the 'health check resource' name is 'tcpip@dns', check the existence of '/install/healthcheck/tcpip' first. Then call '/install/healthcheck/tcpip -r' to see whether it can handle 'tcpip@dns' 

  * 2\. Check the /install/healthcheck/hcsrc.tar.gz is up to date, otherwise create it. Or recreate it when there's 'health check tool' changed (or new file added): 

    

  * 2.1 create it by tar all the files in /install/healthcheck except hc.checksum 
  * 2.2 regenerate the /install/healcheck/hc.checksum 
    
    Run 'ls -l /install/healthcheck' and sort the output to a string and put it in /install/healcheck/hc.checksum.  
    

    

  * 2.3 How to test whether there's file change in /install/healthcheck/? 

If the new generated 'check sum string' is not same with the /install/healthcheck/hc.checksum, that means there was file change. 

  * 3\. xdcp /install/healthcheck/hcsrc.tar.gz to all the target nodes at /tmp/xcat/. (This should be done by rsync so that we don't need to transmit it in every running of xhealthcheck) 
  * 4\. Run xdsh {noderange} -e /opt/xcat/sbin/dohealthcheck &lt;paramlist&gt;
    
    The &lt;paramlist&gt; is a json formated string. Refer to the input json format.
    The output format also needs follow the format in the output json format.
    

  * 5\. parse the jason format and display the result. 

Note: Consider the run of healthcheck from a Web GUI: 

Note: steps 2, 3, 4 are not necessary if you want to run check on xCAT MN/SN (miss the {noderange} when calling xhealthcheck) 

### Inside of dohealthcheck

  * 1\. Find the /tmp/xcat/hcsrc.tar.gz 
  * 2\. tar out the files from /tmp/xcat/hcsrc.tar.gz to /tmp/xcat/healthcheck/ 
  * 3\. Parse the health check parameters to get a run list 
    
    g1@r1 &lt;param&gt;
    g1@r2 &lt;param&gt;
    g2 &lt;param&gt;
    

  * 4\. Run each entry in the run list 
    
    use the group name like 'g1' to get the file name of 'healtch check tool'
    run it as g1 -r r1 -p &lt;param&gt;
    

  * 5\. Parse the output of each check resource and generate the json output, and send back to xcat mn 

## Check Scenarios

  * Local run: 
    
    Run on xCAT MN or SN
    

  * Compute node run: 
    
    Run directly on compute node.
    

  * Cross run: 
    
    The target node is n1, but n1 need access n2 to finish the check
    

  * Hierarchy run 
    
    Run on MN, but need run sub resource on compute node 
    

## More consideration

1\. Run resource on one node in parallel 
