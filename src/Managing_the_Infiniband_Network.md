<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [IB Interface Configuration](#ib-interface-configuration)
  - [Prepare IB drivers/libraries](#prepare-ib-driverslibraries)
  - [Configure IB interfaces during Node installation](#configure-ib-interfaces-during-node-installation)
- [xdsh support for QLogic IB Switch](#xdsh-support-for-qlogic-ib-switch)
  - [Create IB switch configuration file](#create-ib-switch-configuration-file)
  - [Set xCAT to use ssh on AIX](#set-xcat-to-use-ssh-on-aix)
  - [Define IB switch as a node](#define-ib-switch-as-a-node)
  - [Setup ssh connection](#setup-ssh-connection)
  - [Run the test commands](#run-the-test-commands)
- [Sample Scripts](#sample-scripts)
  - [**Annotatelog**](#annotatelog)
    - [**Log file**](#log-file)
  - [**syntax**](#syntax)
    - [Examples](#examples)
  - [**getGuids**](#getguids)
    - [**Syntax**](#syntax)
    - [Examples](#examples-1)
  - [configCEC](#configcec)
    - [**Syntax**](#syntax-1)
    - [Examples](#examples-2)
  - [**HealthCheck**](#healthcheck)
    - [Syntax](#syntax)
    - [Examples](#examples-3)
- [IB Monitoring](#ib-monitoring)
  - [Install RMC and xCAT-rmc packages on mn](#install-rmc-and-xcat-rmc-packages-on-mn)
  - [Install predefined conditions, sensors and responses](#install-predefined-conditions-sensors-and-responses)
  - [Enable remote logging](#enable-remote-logging)
  - [Start the monitoring](#start-the-monitoring)
- [Appendix](#appendix)
  - [The Mellanox QDR IB Driver/Library from rhels6.1 iso(currently, not used)](#the-mellanox-qdr-ib-driverlibrary-from-rhels61-isocurrently-not-used)
  - [The Mellanox QDR IB Driver/Library for sles11 sp1(currently, not used)](#the-mellanox-qdr-ib-driverlibrary-for-sles11-sp1currently-not-used)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

This document provides information and utilities to help you manage a **QLogic** IB network. If you have a Mellanox IB network, see [Managing_the_Mellanox_Infiniband_Network] instead.


## IB Interface Configuration

[IB_Interface_Configuration_ON_Management_node](IB_Interface_Configuration_ON_Management_node)

### Prepare IB drivers/libraries

For AIX, the IB drivers/libraries have been installed in the system.

This step is only needed for RHEL and SLES. For RHEL, the drivers/libraries are shipped in RHEL release CD/DVD. For SLES10, the drivers/libraries are shipped in SLES10 SP2 AS. For SLES11, the drivers/libraries are shipped in SLES11 release CD/DVD.

The required packages for RHEL and SLES have been listed in the appendix.

### Configure IB interfaces during Node installation

The default list of rpms to add to the diskful installation or diskless images is shipped in /opt/xcat/share/xcat/&lt;netboot|install&gt;/&lt;os&gt; directory. If you want to modify the current defaults for *.pkglist, copy the shipped default lists to the /install/custom/&lt;netboot|install&gt;/&lt;os&gt; directory, so your modifications will not be removed on the next xCAT rpm update. xCAT will first look in the custom directory for the files before going to the share directory.

For example, copy the /opt/xcat/share/xcat/netboot/rh/compute.pkglist to /install/custom/netboot/rh/compute.pkglist, and append IB required rpm names (without version number) to /install/custom/netboot/rh/compute.pkglist. The required packages for RHEL and SLES have been listed in the appendix.

After adding the IB package names into the *.pkglist file, continue to create the diskless image for diskless node installation.

[IB_Interface_Configuration_ON_MN_part2](IB_Interface_Configuration_ON_MN_part2)

## xdsh support for QLogic IB Switch

### Create IB switch configuration file

A new switch configuration file on management node is introduced to allow the xdsh command to setup ssh, that is transfer the ssh keys to the IB device. The device configuration file must be located in the following directory.

~~~~
     /var/opt/xcat/<DevicePath>/config
~~~~



The &lt;DevicePath&gt; is parsed by xdsh from the xdsh attribute value of the "--devicetype" flag or the environment variable "DEVICETYPE" which is input to the xdsh call. See man page for xdsh:


For example:

If the devicetype for Qlogic switch is "IBSwitch::Qlogic" then the device configuration file must be be found in the following directory:

~~~~
    mkdir -p /var/opt/xcat/IBSwitch/Qlogic
~~~~






**The following is an example the device configuration file for QLogic:**

In xCAT 2.7, a sample is shipped in /opt/xcat/share/xcat/ib/scripts/Qlogic/config.

Create the Qlogic switch device configuration file.

~~~~
    vi /var/opt/xcat/IBSwitch/Qlogic/config
~~~~


The file contains the following:

~~~~
    [main]
    ssh-setup-command=sshKey add
    [xdsh]
    pre-command=NULL
    post-command=showLastRetcode -brief
~~~~


Below is the explanation of the file attributes:

  * ssh-setup-command

Specify the ssh key appending command supported by device specified. If this entry is not provided, xCAT uses default ways for HMC and IVM-managed devices to write ssh keys of Management Nodes.




  * pre-command

Specify the pre-execution commands before remote command. For example, users might want to export some environment variables before executing real commands. If the value of this entry is assigned "NULL", it means no pre-execution commands are needed. For example, the Qlogic Switch does not support environment variables, the "pre-command" is assigned with "NULL" to disable environment variables usage.

If no entry is provided, the default behavior is to export the environment variables that are normally exported by xdsh when running remote commands.

  * post-command

Specify the built-in command provided by device specified to show the last command execution result. For example, the Qlogic Switch provides "showLastRetcode -brief" to display a numeric return code of last command execution. If the value of this entry is assigned "NULL", it means no post-command is used. If no entry is provided, the default behavior to run "echo $?" used to dump return code of last command execution.

### Set xCAT to use ssh on AIX

Make sure xCAT is setup to use ssh on AIX, it usually is by default.




~~~~
    chdef  -t site -o clustersite useSSHonAIX=yes
~~~~


### Define IB switch as a node

Define IB switch as a node, xdsh will only work with defined nodes in the xCAT database.

~~~~
    mkdef -t node -o ibswitch groups=all nodetype=switch
~~~~


### Setup ssh connection

You can use xdsh to configure ssh login to the IB device by running the following. Note you must use the correct userid for your device. After this configuration is complete, you will be able to login with ssh to the device without a password.




~~~~
    xdsh ibswitch -K -l admin --devicetype IBSwitch::Qlogic
    Enter the password for the userid on the node where the ssh keys will be updated.
    /usr/bin/ssh setup is complete.
    return code = 0
~~~~


See xdsh man page: http://xcat.sourceforge.net/man1/xdsh.1.html

### Run the test commands

After setup of IB switches ssh keys from the management node for the login, the admin can run the code using xdsh.

Interactive commands like List on IB switch are not supported by xdsh. An error message will print out, if user inputs an interactive command.

Below is an example of using xdsh to list the valid commands on the device.

~~~~
    /opt/xcat/bin/xdsh ibswitch-l admin --devicetype IBSwitch::Qlogic fwVersion
~~~~


Or:

~~~~
    export DEVICETYPE=IBSwitch::Qlogic && /opt/xcat/bin/xdsh ibswitch -l admin fwVersion
~~~~


## Sample Scripts

### **Annotatelog**

annotatelog is a sample script to parse the QLogic log entries in log files on the xCAT Management Node output by subnet manager, IB node, chassis, FRU(Field-Replaceable Unit) or a particular node. This script is supported on AIX and Linux management nodes.

#### **Log file**

/var/log/messages can be analyzed by annotatelog. But if you have setup RMC to monitor syslog/errorlog, then the log to analyze should be xCAT consolidated log from that monitoring in/var/log/xCAT/errorlog on the Management Node.

### **syntax**

~~~~
annotatelog -f log_file [-s start_time] [-e end_time]

     { [-i -g guid_file -l link_file] [-S] [-c] [-u]| [-A -g guid_file -l link_file]}
     {[-n node_list -g guid_file] [-E]}
     [-h]
~~~~


**-f log_file**

Specifies a log file fullpath name to analyze. It must be xCAT consolidated log from Qlogic HSM or ESM.

**-s start_time**

Specifies the start time for analysis, where the **start_time** variable has the format ddmmyyhh:mm:ss (day, month, year, hour, minute, and second). If it is not specified, annotatelog will parse the log file from the beginning.

**-e end_time**

Specifies the end time for analysis, where the **end_time** variable has the format ddmmyyhh:mm:ss (day, month, year, hour, minute, and second). If it is not specified, annotatelog will parse the log file to the end.

**-l link_file**

Specifies a link file fullpath name, which concatenates all '/var/opt/iba/analysis/baseline/fabric*links' files from all fabric management nodes.

**-g guid_file**

Specifies a guid file fullpath name, which has a list of GUIDs as obtained from the "getGuids" script.

**-E **

Annotate with node ERRLOG_ON and ERRLOG_OFF information. This can help determine if a disappearance was caused by a node disappearing. It is for AIX nodes only and should be used with -n or -i flag

**-S**

Sort the log entries by subnet manager only.

**-i**

Sort the log entries by IB node only.

**-c **

Sort the log entries by chassis only.

**-u **

Sort the log entries by FRU only.

**-A **

Output the combination of -i, -S, -c and -u. It should be used with -g and -l flags.

**-n node_list**

Specifies a comma-separated list of xCAT Managed Node host names, IP addresses to look up in log entries. It should be used with -g flag.

**-h**

Display usage information.

#### Examples

Sort the log entries by subnet manager only.

~~~~
    ./annotatelog -f /var/log/messages -S
~~~~



Sort the log entries by chassis only.

~~~~
    ./annotatelog -f /var/log/messages -c
~~~~


### **getGuids**

getGuids is a sample script to get GUIDs for Infiniband Galaxy HCAs (Host Channel Adapter) and their ports from xCAT Management Nodes. It needs to be run on the xCAT Management Node. It will use a xdsh call to all the xCAT Nodes to get the information about the IB devices. It uses the ibstat command on AIX system or ibv_devinfo command on Linux system to get the information about the IB devices.

#### **Syntax**

The syntax of the getGuids command will be:

~~~~
getGuids [-h] [-f output_file]
~~~~

**-f output_file**

Specifies a file full path name that is used to save the GUIDs output.

**-h **

Display usage information.

#### Examples

xcat05 is an AIX compute node defined in xCAT management node, run getGuid to get guid of xcat05

~~~~
    ./getGuids -f guid_file
~~~~


### configCEC

The configCECs script is written in ksh, and used to create a full system partition for each CECs Managed by the HMC. It will use ssh to login to the HMC with the hscroot userid in order to rename the CECs based on a certain pattern specified through command line and create full partition for all the CECs.

Only Power6 575 servers are supported with this script. If the users wants to do LPAR setup for other servers, they needs to modify this sample script manually.

To specify the name format to be used for the CEC/LPAR/Profile, this script uses the same logic that the 'date' command uses for specifying how to output the date. There are 4 field descriptors that the script will recognize:

    %F = the frame number of the frame that the CEC is in
    %N = the relative node number of the CEC in the frame
    %C = the cage number of the CEC in the frame
    %S = the serial number of the CEC



For example if you want the CEC name to be 'airbus_f&lt;frame#&gt;n&lt;node#&gt;_SN&lt;serial#&gt;', then the format to use would be 'airbus_f%Fn%N_SN%S'

The way the script finds the CECs on the HMC is to issue the 'lssyscfg -r frame' command to find all the frames and then issues the 'lssyscfg -r cage' command for each frame to list the contents of each cage position in a given frame. It then starts looking for CECs starting at cage 1 and going through to the last cage. The first CEC found in a frame is assumed to be node 1, the second node found is node 2 and so on. The script then will assign each CEC a frame number, a node number, a cage number and the Serial number of the CEC which can be used in naming the CEC/LPAR/Profile. If no frames/cages/CECs are found on this HMC, an error message will be displayed.

xCAT command rspconfig should be used to setup ssh remote shell from the xCAT Management Node to the HMCs so there will be without prompting for the hscroot password. Otherwise the user has to type in the password manually many times. If the user wants to use the frame number in the name of the CEC or LPAR then the frame number must be set on the frames through HMC Web GUI or HMC command line before issuing this script.

This script supports three resource allocate_types to create the full system partition. They are **always_all**, **always_list** and **conditional**. The default method is always_all.

  * always_all - indicates to always use the 'all resources' LPAR flag.
  * always_list - indicates to always explicitly list the devices in the LPAR.
  * conditional - indicates to use the 'all resources' LPAR flag if --exclude_hw is not found, otherwise use an explicit list for the hardware.

As default, this script will assign all the resources to the full system partition. If the allocate_type is always_list or conditional, then the user could use --exclude_hw flag to exclude those devices that can not be assigned or not supported by the operating system from assignment. The supported hardware names or 'device_id's to exclude are RIO and 10G, RIO indicates Galaxy 1 HCA used for RIO connection; 10G indicates 2-port 10G integrated adapter.

Actually, this script will not change the CECs/LPARs directly, but creates one or two scripts (Rename_cecs, Build_lpars) in /tmp directory on xCAT MN that will do the changes once the user executes them. The /tmp/Rename_cecs should be run first and then the /tmp/Build_lpars. The reason, we do it this way is to have the user see exactly what HMC commands would be executed and also have a better chance to fine tune the commands, if it is needed.

Warning: this script will configure all the CECs that managed by this hmc passed in. Check the contents in Build_lpars before running it. Remove the commands in Build_lpars that related to the CECs you dodn't want to do any change.

#### **Syntax**

~~~~

configCECs -H hmc_list [-c cec_format] [-l lpar_format] [-p profile_format]

     [--frame_pad_len len_number] [--node_pad_len len_number]

     [--cage_pad_len len_number]

     [--allocate_type always_all | always_list | conditional]

     [--exclude_hw ]

     [-h]



-H hmc_list

     Specifies a comma-separated list of HMC host names, IP addresses to configure CECs on.

-c cec_format

     Specifies the naming format for CEC, the default format is f%Fn%N_SN%S.

-l lpar_format

     Specifies the naming format for LPAR, the default format is f%Fn%N.

-p profile_format

     Specifies the naming format for profile, the default format is the same with lpar_format.

--frame_pad_len len_number

     Specifies the number of digits used for the frame numbers, it will be zero filled if needed.
     The default value is no padding.

--node_pad_len len_number

     Specifies the number of digits used for the node numbers, it will be zero filled if needed.
     The default value is no padding.

--cage_pad_len len_number

     Specifies the number of digits used for the cage numbers, it will be zero filled if needed.
     The default value is no padding.

--allocate_type

     Specifies the allocation method that is used to allocate resources to full system partition.
     The supported allocation methods are always_all, always_list and conditional.
     The default method is always_all. always_all indicates to always use the 'all resources'
     LPAR flag; always_list indicates to always explicitly list the devices in the LPAR; and
     conditional indicates to use the 'all resources' LPAR flag if not --exclude_hw is found,
     otherwise use an explicit list for the hardware.

--exclude_hw

     Specifies a comma-separated list of hardware names or 'device id's that do not need to
     assign. The supported hardware names are RIO and 10G, RIO indicates Galaxy 1 HCA
     used for RIO connection; 10G indicates 2-port 10G integrated adapter. It can only be used
     with --allocate_type is always_list or conditional.

-h Display usage information.
~~~~

#### Examples

If c98m6hmc01 manage one CEC, config the CEC with name Server_f1n1_SN0262672 as a single node f1n1:

~~~~
    ./configCECs -H c98m6hmc01 -c Server_f%Fn%N_SN%S
    /tmp/Build_lpars

~~~~

### **HealthCheck**

This script is used to check the system health for both AIX and Linux Managed Nodes on Power6 platforms. It will use xdsh to access the target nodes, and check the status for processor clock speed, IB interfaces, memory and large page configuration. If xdsh is unreachable, an error message will be given.

1\. Processor clock speed check

The script will use xdsh command to access the target nodes, and run "/usr/pmapi/tools/pmcycles -M" command on the AIX MNs or "cat /proc/cpuinfo" command on Linux MNs to list the actual processor clock speed in MHz. Compare this actual speed with the minimal value that user specified in command line with -p flag, if it is smaller than the minimal value, a warning message will be given out to indicate the unexpected low frequency.

2\. IB interface status check by llstatus

In LoadLeveler cluster environment, all the nodes are sharing the same cluster information. So we only need to xdsh to one of these nodes, and run LoadLeveler command "/usr/lpp/LoadL/full/bin/llstatus -a" on AIX or "/opt/ibmll/LoadL/full/bin/llstatus -a" on Linux nodes to list the IB interface status. If the status is not "READY", a warning message related to its nodename and IB port will be given out. This check process needs the "llstatus" command existed on the MNs, if it does not exist, an error message will be output.

3\. IB interface status check by lsrsrc

The script will use xdsh command to access the target nodes, and run "/usr/bin/lsrsrc IBM.NetworkInterface Name OpState" command on AIX or Linux MNs to list the IB interface status for each node. If the "OpState" value is not "1", a warning message related to its nodename and IB port will be given out.

4\. Memory check

The script will use xdsh command to access the target nodes, and run "/usr/bin/vmstat" command on AIX MNs or "cat /proc/meminfo" commands on Linux MNs to list the total memory information. If the total memory is smaller than the minimal value specified by the user in GB, a warning message will be given out with the node name and its real total memory account.

5\. Free large page check

The script will use xdsh command to access the target nodes, and run "/usr/bin/vmstat -l" command on AIX MNs or "cat /proc/meminfo" commands on Linux MNs to list the free large page information. If the free large page number is smaller than the minimal value specified by the user, a warning message will be given out with the node name and its real free large page number.

6\. Check HCA status

The script will use xdsh command to access the target nodes. For AIX nodes, we use command ibstat -v | egrep "IB PORT.*INFO|Port State:|Physical Port" to get the HCA status of Logical Port State, Physical Port State, Physical Port Physical State, Physical Port Speed and Physical Port Width. The expected values are "Logical Port State: Active", "Physical Port State: Active", "Physical Port Physical State: Link Up", "Physical Port Width: 4X". If the actual value is not the same as expected one, a warning message will be given out.

This is an example of the output of ibstat command:

~~~~
c890f11ec01:/ # ibstat -v | egrep "IB PORT.*INFO|Port State:|Physical Port"

    IB PORT 1 INFORMATION (iba0)
    Logical Port State: Active
    Physical Port State: Active
    Physical Port Physical State: Link Up
    Physical Port Speed: 2.5G
    Physical Port Width: 4X
    IB PORT 2 INFORMATION (iba0)
    Logical Port State: Active
    Physical Port State: Active
    Physical Port Physical State: Link Up
    Physical Port Speed: 2.5G
    Physical Port Width: 4X
~~~~


For Linux nodes, we use command ibv_devinfo -v | egrep "ehca|port:|state: |width:|speed:" to get the HCA status of port state, active_width, active_speed and phys_state. The expected values are "port state: PORT_ACTIVE", "active_width: 4X", "phys_state: LINK_UP". If the actual value is not the same as expected one, a warning message will be given out.

This is an example of the output of ibv_devinfo command:

~~~~
    c890f11ec05:~ # ibv_devinfo -v | egrep "ehca|port:|state:|width:|speed:"
    hca_id: ehca0
    port: 1
    state: PORT_ACTIVE (4)
    active_width: 4X (2)
    active_speed: 2.5 Gbps (1)
    phys_state: LINK_UP (5)
    port: 2
    state: PORT_ACTIVE (4)
    active_width: 4X (2)
    active_speed: 2.5 Gbps (1)
    phys_state: LINK_UP (5)
~~~~



But for "Physical Port Speed" on AIX nodes or "active_speed" on Linux nodes, since SDR and DDR adapters will use the different speeds, SDR is 2.5G and DDR is 5.0G, so the user needs to specify this "Speed" by flag "--speed", for example:

~~~~
    healthCheck -M -H --speed 2.5
~~~~


If "--speed" is not specified with "-H" flag, healthCheck script will list the actual value of "Physical Port Speed" gotten from ibstat command for each HCAs, so that it is easy for the user to use "grep" command to find the speed value he/she wants.

The output format is <node_name>:<interface_name>:<speed_value>, for example:

~~~~
     c890f11ec01.ppd.pok.ibm.com: ib0: Physical Port Speed: 2.5G
     c890f11ec01.ppd.pok.ibm.com: ib1: Physical Port Speed: 2.5G
     c890f11ec02.ppd.pok.ibm.com: ib0: Physical Port Speed: 5.0G
     c890f11ec02.ppd.pok.ibm.com: ib1: Physical Port Speed: 5.0G
~~~~


Since the output of ibstat or ibv_devinfo is identified by HCA name and port number, so we will use the mapping table below to map the HCA name and port number to its interface name. See the table below:




Mapping Table

<!---
begin_xcat_table;
numcols=7;
colwidths=20,20,20,20,20,20,20;
-->

|Interface Name | Adapter Name|Port Number
---------------|-------------|----------|
|ib0 |iba0/ehca0 | 1
|ib1 |iba0/ehca0 | 2
|ib2 | iba1/ehca1| 1
|ib3 | iba1/ehca1| 2
|... | .../... |    .

<!---
end_xcat_table
-->




For "Physical Port Width" on AIX nodes or "active_width" on Linux nodes, since it could be 4X or 12X, so the user needs to specify this "width" by flag "--width", for example:

~~~~
    healthCheck -M -H --width 4X
~~~~


If "--width" is not specified, healthCheck script will list the actual value of "Physical Port Width" gotten from ibstat command for each HCAs, so that it is easy for the user to use "grep" command to find the speed value he/she wants.

The output format is <node_name>:<interface_name>:<width_value>, for example:

~~~~
    c890f11ec01.ppd.pok.ibm.com: ib0: Physical Port Width: 4X
    c890f11ec01.ppd.pok.ibm.com: ib1: Physical Port Width: 4X
    c890f11ec02.ppd.pok.ibm.com: ib0: Physical Port Width: 4X
~~~~



For the ports that are not used by the target nodes, the user could use --ignore flag to exclude them from HCA
 status check. If the user does not specify these "unused port" with --ignore flag, healthCheck script will check all HCA check items for all interfaces, and return the warning message to for the failed ones.

**Note:The user could use grep piped into wc -l to get the total number of "unused port".**

#### Syntax

~~~~
healthCheck { [-n node_list] [-M]}

{[-p min_clock_speed] [-i method] [-m min_memory]

[-l min_freelp] [ -H [--speed speed --ignore interface_list --width width]]}

[ -h ]


-M Check status for all the Managed Nodes that are defined on this MN.

-n node_list

Specifies a comma-separated list of node host names, IP addresses for health check.

-p min_clock_speed

Specifies the minimal processor clock speed in MHz for processor monitor.

-i method

Specifies the method to do Infiniband interface status check, the supported

check methods are LL and RSCT.

-m min_memory

Specifies the minimal total memory in MB.

-l min_freelp

Specifies the minimal free large page number.

-H Check the status for HCAs.

\--speed speed

Specifies the physical port speed in G bps, it should be used with -H flag.

\--ignore interface_list

Specifies a comma-separated list of interface name to ignore from HCA status check,

such as ib0,ib1. It should be used with -H flag.

\--width width

Specifies the physical port width, such as 4X or 12X. It should be used with -H flag.

-h Display usage information.
~~~~

#### Examples

1). Check IB interface status of one node:

~~~~
./healthCheck -n xcat04 -i RSCT
~~~~

Output log is being written to "/var/log/xcat/healthCheck.log".

Checking health for AIX nodes: xcat04...


Checking IB interface status using command /usr/bin/lsrsrc for nodes: xcat04...

IB interfaces of all nodes are normal.

2). Check processor clock speed for one node:

~~~~
./healthCheck -n xcat04 -p 500
~~~~

Output log is being written to "/var/log/xcat/healthCheck.log".

Checking health for AIX nodes: xcat04...


Checking processor clock speed for nodes: xcat04...

The processor clock speed of all nodes is normal.

3). Check memory usage for one node:

~~~~
./healthCheck -n xcat04 -m 500
~~~~

Output log is being written to "/var/log/xcat/healthCheck.log".

Checking health for AIX nodes: xcat04...


Checking memory for nodes xcat04...

Memory size of all nodes are normal.

## IB Monitoring

xCAT has the capability to monitor, through IBM's Resource Monitoring and Control (RMC) subsystem, the errors or information in the syslog logged by IB switches and the subnet manager.

RMC is part of the IBM's Reliable Scalable Cluster Technology (RSCT) that provides a comprehensive clustering environment for AIXand Linux. The RMC subsystem and the core resource managers that ship with RSCT enable you to monitor various resources of your system and create automated responses to changing conditions of those resources. RMC also allows you to create your own conditions (monitors), responses (actions) and sensors (resources). rmcmon is xCAT's monitoring plug-in module for RMC. It's responsible for automatically setting up RMC monitoring domain for RMC and creates predefined conditions, responses and sensor on the management node, the service node and the nodes.

To monitor IB, RMC will leverage the remote syslog capability of the switches and subnet manager.

### Install RMC and xCAT-rmc packages on mn

Refer to [Monitoring_an_xCAT_Cluster], for how to setup RMC monitoring on management node. You do not have to install RMC on the compute node if you just want to monitor IB logs.




### Install predefined conditions, sensors and responses

~~~~
moncfg rmcmon
~~~~

This will get all predefined conditions, sensors and responses installed.

To verify, run command:

~~~~
lscondition
~~~~

One of the condition is called IBSwitchLog.

~~~~
lssensor
~~~~

One of the sensor is called IBSwitchLogSensor




### Enable remote logging

Configure the switches and the subnet manager to send all logs to the management node.




### Start the monitoring

startcondresp IBSwitchLog EmailRootAnyTime

With this condition-response association, any logs that's are level local6.info and above will be caught and sent to the root's mail box. This may generate a lot of mails for root.


You can customize the condition to filter out certain logs and send them to root. For example:

~~~~
chcondition -e String =? 'error'IBSwitchLog
~~~~

It will only send the logs that contain the word 'error' to the root.

To make it more efficient, you can customize the sensor instead. First run the following command to check the attributes of the sensor.

~~~~
lssensor IBSwitchLogSensor
~~~~

The output looks like this:

~~~~
Name = IBSwitchLogSensor
ActivePeerDomain =
Command = /opt/xcat/sbin/rmcmon/monaixsyslog -p local6.info
ConfigChanged = 0
ControlFlags = 0
Description =
ErrorExitValue = 1
ErrorMessage =
ExitValue = 0
Float32 =
Float64 =
Int32 =
Int64 =
MonitorStatus = 0
NodeNameList = {xcat20RRmn.cluster.net}
RefreshInterval = 0
SavedData =
SD =
String =
TimeCommandRun = Wed Dec 31 19:00:00 2008
Uint32 =
Uint64 =
UserName = root
~~~~

You can change the Command attribute to only process severity level 'warning' and above for IB logs. Since Command cannot be changed once the sensor is defined, you have to create a new sensor. For AIX, run the following command:

~~~~
mksensor -i 60 -e 1 -c 0 IBSwitchWarn
~~~~

"/opt/xcat/sbin/rmcmon/monaixsyslog -p local6.warn"

For Linux, replace the string monaixsyslog with monerrorlog.

Now change the condition to use this new sensor:

~~~~
chcondition -s Name='IBSwitchWarn' IBSwitchLog
~~~~




## Appendix

**Driver/Library**
Corresponding rpms in RHEL5.3

~~~~
openib
openib-*. el5.noarch.rpm

libib
32bit
libibcm-*.el5.ppc.rpm

libibcm-devel-*.el5.ppc.rpm
libibcm-static-*.el5.ppc.rpm
libibcommon-*.el5.ppc.rpm
libibcommon-devel-*.el5.ppc.rpm
libibcommon-static-*.el5.ppc.rpm
libibmad-*.el5.ppc.rpm
libibmad-devel-*.el5.ppc.rpm
libibmad-static-*.el5.ppc.rpm
libibumad-*.el5.ppc.rpm
libibumad-static-*.el5.ppc.rpm
libibumad-devel-*.el5.ppc.rpm
libibverbs-*.el5.ppc.rpm
libibverbs-devel-*.el5.ppc.rpm
libibverbs-static-*.el5.ppc.rpm
libibverbs-utils-*.el5.ppc.rpm

64bit
ibibcm-*.el5.ppc64.rpm
libibcm-devel-*.el5.ppc64.rpm
libibcm-static-*.el5.ppc64.rpm
libibcommon-*.el5.ppc64.rpm
libibcommon-devel-*.el5.ppc64.rpm
libibcommon-static-*.el5.ppc64.rpm
libibmad-*.el5.ppc64.rpm
libibmad-devel-*.el5.ppc64.rpm
libibmad-static-*.el5.ppc64.rpm
libibumad-*.el5.ppc64.rpm
libibumad-devel-*.el5.ppc64.rpm
libibumad-static-*.el5.ppc64.rpm
libibverbs-*.el5.ppc64.rpm
libibverbs-devel-*.el5.ppc64.rpm
libibverbs-static-*.el5.ppc64.rpm
libibverbs-utils(it is used to ship ibv* commands and depends on 32bit IB libraries) 64bit rpm is not available in RedHatEL5.3. Install 32bit IB libraries also if user needs both ibv* commands and the 64bit libraries.

Libehca

(for Galaxy1/Galaxy2 support)

32bit
libehca-*.el5.ppc.rpm
libehca-static-*.el5.ppc.rpm

64bit
libehca-*.el5.ppc64.rpm
libehca-static-*.el5.ppc64.rpm

libmthca

(for Mellanox

InfiniHost support)

32bit
libmthca-*.el5.ppc.rpm
libmthca-static-*.el5.ppc.rpm

64bit
libmthca-*.el5.ppc64.rpm
libmthca-static-*.el5.ppc64.rpm

libmlx4

(for Mellanox ConnectX support)

32bit
libmlx4-*.el5.ppc.rpm
libmlx4-static-*.el5.ppc.rpm

64bit
libmlx4-*.el5.ppc64.rpm
libmlx4-static-*.el5.ppc64.rpm

~~~~

RedHatEL5.3 only ships 32bit libibverbs-utils(it is used to ship ibv* commands) package in CDs/DVD,

which depends on 32bit IB libraries, so it will fail to be installed if only 64bit libraries exist on the system.

For the user who needs both these IB commands and the 64bit libraries, install both 32bit and 64bit

library packages.




**Driver/Library**
Corresponding rpms in RHEL5.4

~~~~
openib
openib-*. el5.noarch.rpm

libib
32bit
libibcm-*.el5.ppc.rpm
libibcm-devel-*.el5.ppc.rpm
libibcm-static-*.el5.ppc.rpm
libibcommon-*.el5.ppc.rpm
libibcommon-devel-*.el5.ppc.rpm
libibcommon-static-*.el5.ppc.rpm
libibmad-*.el5.ppc.rpm
libibmad-devel-*.el5.ppc.rpm
libibmad-static-*.el5.ppc.rpm
libibumad-*.el5.ppc.rpm
libibumad-static-*.el5.ppc.rpm
libibumad-devel-*.el5.ppc.rpm
libibverbs-*.el5.ppc.rpm
libibverbs-devel-*.el5.ppc.rpm
libibverbs-static-*.el5.ppc.rpm
libibverbs-utils-*.el5.ppc.rpm

64bit
libibcm-*.el5.ppc64.rpm
libibcm-devel-*.el5.ppc64.rpm
libibcm-static-*.el5.ppc64.rpm
libibcommon-*.el5.ppc64.rpm
libibcommon-devel-*.el5.ppc64.rpm
libibcommon-static-*.el5.ppc64.rpm
libibmad-*.el5.ppc64.rpm
libibmad-devel-*.el5.ppc64.rpm
libibmad-static-*.el5.ppc64.rpm
libibumad-*.el5.ppc64.rpm
libibumad-devel-*.el5.ppc64.rpm
libibumad-static-*.el5.ppc64.rpm
libibverbs-*.el5.ppc64.rpm
libibverbs-devel-*.el5.ppc64.rpm
libibverbs-static-*.el5.ppc64.rpm

libibverbs-utils(it is used to ship ibv* commands and depends on 32bit IB libraries) 64bit rpm is not available in RedHatEL5.4. Install 32bit IB libraries also if user needs both ibv* commands and the 64bit libraries.

Libehca

(for Galaxy1/Galaxy2 support)

32bit
libehca-*.el5.ppc.rpm
libehca-static-*.el5.ppc.rpm

64bit
libehca-*.el5.ppc64.rpm
libehca-static-*.el5.ppc64.rpm

libmthca

(for Mellanox

InfiniHost support)

32bit
libmthca-*.el5.ppc.rpm
libmthca-static-*.el5.ppc.rpm

64bit
libmthca-*.el5.ppc64.rpm

libmthca-static-*.el5.ppc64.rpm

libmlx4

(for Mellanox ConnectX support)

32bit
libmlx4-*.el5.ppc.rpm
libmlx4-static-*.el5.ppc.rpm

64bit
libmlx4-*.el5.ppc64.rpm
libmlx4-static-*.el5.ppc64.rpm

~~~~

RedHatEL5.4 only ships 32bit libibverbs-utils(it is used to ship ibv* commands) package in CDs/DVD,

which depends on 32bit IB libraries, so it will fail to be installed if only 64bit libraries exist on the system.

For the user who needs both these IB commands and the 64bit libraries, install both 32bit and 64bit

library packages.




**Platforms**
**Driver/Library**

RHEL6

~~~~
rdma.noarch

libibcm.ppc
libibcm.ppc64
libibverbs-utils.ppc64
libibverbs.ppc
libibverbs.ppc64
libibcommon.ppc
libibcommon.ppc64
libibmad.ppc
libibmad.ppc64
libibumad.ppc
libibumad.ppc64
libcxgb3.ppc
libcxgb3.ppc64
libehca.ppc
libehca.ppc64
libmlx4.ppc
libmlx4.ppc64
libmthca.ppc
libmthca.ppc64
librdmacm.ppc
librdmacm.ppc64
librdmacm-utils.ppc64
mvapich.ppc64
qperf.ppc64
rdma.noarch
rds-tools.ppc64
srptools.ppc64
opensm.ppc64
opensm-libs.ppc
opensm-libs.ppc64
**Platform**
**Driver/Library**

**SLES11**
ofed-*.ppc64.rpm
ofed-kmp-default-*.ppc64.rpm
ofed-kmp-ppc64-*.ppc64.rpm
opensm-*.ppc64.rpm
opensm-32bit-*.ppc64.rpm
libcxgb3-rdmav2-*.ppc64.rpm
libcxgb3-rdmav2-32bit-*.ppc64.rpm
libehca-rdmav2-*.ppc64.rpm
libehca-rdmav2-32bit-*.ppc64.rpm
libibcm-*.ppc64.rpm
libibcm-32bit-*.ppc64.rpm
libibcommon1-*.ppc64.rpm
libibcommon1-32bit-*.ppc64.rpm
libibmad1-*.ppc64.rpm
libibmad1-32bit-*.ppc64.rpm
libibumad1-*.ppc64.rpm
libibumad1-32bit-*.ppc64.rpm
libibverbs-*.ppc64.rpm
libibverbs-32bit-*.ppc64.rpm
libibverbs-devel-*.ppc64.rpm
libibverbs-devel-32bit-*.ppc64.rpm
libipathverbs-*.ppc64.rpm
libipathverbs-32bit-*.ppc64.rpm
libmlx4-rdmav2-*.ppc64.rpm
libmlx4-rdmav2-32bit-*.ppc64.rpm
libmthca-rdmav2-*.ppc64.rpm
libmthca-rdmav2-32bit-*.ppc64.rpm
librdmacm-*.ppc64.rpm
librdmacm-32bit-*.ppc64.rpm
libsdp-*.ppc64.rpm
libsdp-32bit-*.ppc64.rpm
mpi-selector-*.ppc64.rpm
mstflint-*.ppc64.rpm
glibc-devel-*.ppc64.rpm
glibc-devel-32bit-*.ppc64.rpm
linux-kernel-headers-*.noarch.rpm
kernel-default-*.ppc64.rpm
kernel-default-base-*.ppc64.rpm
~~~~

(Note: libibverbs-devel-*.ppc64.rpm and libibverbs-devel-32bit-*.ppc64.rpm are

in SLES 11 SDK ISO)

**SLES10**

~~~~

libcxgb3-64bit-*.ppc.rpm
libcxgb3-devel-*.ppc.rpm
libcxgb3-devel-64bit-*.ppc.rpm
libehca-*.ppc.rpm
libehca-64bit-*.ppc.rpm
libehca-devel-*.ppc.rpm
libehca-devel-64bit-*.ppc.rpm
libibcm-*.ppc.rpm
libibcm-64bit-*.ppc.rpm
libibcm-devel-*.ppc.rpm
libibcm-devel-64bit-*.ppc.rpm
libibcommon-*.ppc.rpm
libibcommon-64bit-*.ppc.rpm
libibcommon-devel-*.ppc.rpm
libibcommon-devel-64bit-*.ppc.rpm
libibmad-*.ppc.rpm
libibmad-64bit-*.ppc.rpm~~~~



### The Mellanox QDR IB Driver/Library from rhels6.1 iso(currently, not used)

~~~~

    opensm
    libibcm
    libibcommon
    libibmad
    libibumad
    libibverbs
    libibverbs-devel
    libibverbs-utils
    libcxgb3
    #libehca
    libmlx4
    libmthca
    mstflint
~~~~

### The Mellanox QDR IB Driver/Library for sles11 sp1(currently, not used)


~~~~
    ofed
    ofed-kmp-default
    opensm
    opensm-32bit
    libmlx4-rdmav2
    libmlx4-rdmav2-32bit
    libmthca-rdmav2
    libmthca-rdmav2-32bit
    libnes-rdmav2
    librdmacm
    librdmacm-32bit
    libamso-rdmav2
    libamso-rdmav2-32bit
    libcxgb3-rdmav2
    libcxgb3-rdmav2-32bit
    libibcm
    libibcm-32bit
    libibcommon
    libibcommon1
    libibcommon1-32bit
    libibmad
    libibmad1
    libibmad1-32bit
    libibumad
    libibumad1
    libibumad1-32bit
    libibverbs
    libibverbs-32bit
    libipathverbs
    libipathverbs-32bit
    libsdp
    libsdp-32bit
    mpi-selector
    mstflint
    glibc-devel
    glibc-devel-32bit
    linux-kernel-headers
    kernel-default
    kernel-default-base
    libcxgb3-rdmav2
    libcxgb3-rdmav2-32bit
    libibcm
    libibcm-32bit
~~~~

