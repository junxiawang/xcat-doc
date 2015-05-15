<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [External of osdistroupdate](#external-of-osdistroupdate)
  - [syntax](#syntax)
  - [Description](#description)
  - [Output of the osdistroupdate](#output-of-the-osdistroupdate)
    - [Create os distro update from network](#create-os-distro-update-from-network)
    - [Create os distro update from local](#create-os-distro-update-from-local)
    - [List the distro update on the management node](#list-the-distro-update-on-the-management-node)
    - [Delete the distro update](#delete-the-distro-update)
- [Internal of osdistroupdate](#internal-of-osdistroupdate)
  - [the osdistroupdate command](#the-osdistroupdate-command)
  - [the osdistroupdate.pm plugin](#the-osdistroupdatepm-plugin)
    - [preprocess_request() in the osdistroupdate.pm plugin](#preprocess_request-in-the-osdistroupdatepm-plugin)
    - [process_request() in the osdistroupdate.pm plugin](#process_request-in-the-osdistroupdatepm-plugin)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

This min-design is to provide the xCAT command interfaces which are for OS Distro Update. This osdistroupdate command is not exposed to end user, just for internal use. So there is no manpage, and only usage. The osdistroupdate command will provide creating/deleting/listing os distro update functions. This min-design is responsible for the the xCAT command interfaces and xCAT plugin. The xCAT plugin will invoke the function subroutines which Xu Xian implements. Wu Xian is responsible for the basic functions, such as download the os updates online and create the repodata on the mn. 


## External of osdistroupdate

### syntax
    
    osdistroupdate [-h|--help|-v|--version]
    osdistroupdate -l [&lt;osdistro-name&gt;]
    osdistroupdate -d &lt;osdistroupdate-name&gt;
    osdistroupdate -c &lt;osdistro-name&gt; [-p &lt;package directory&gt;]
    

### Description
    
     -h   Show the help message
     -v   Show the version.
     -l   List OS distro update with specified OS distro name, if no OS distro specified, all OS distro updates in system will be listed. The osdistro-name value will be &lt;osver&gt;-&lt;arh&gt;, such as rhels6.2-x86_64 .
     -d   Delete an OS distro update in system
     -c   Create an OS distro updates in system
     -p   Specify local directory which contains packages downloaded from distro official site. This option is used to create OS update from local.
    

### Output of the osdistroupdate

#### Create os distro update from network
    
    bash#osdistroupdate -c rhels6.2-x86_64
    Creating the distro update for rhels6.2-x86_64 from internet, please wait...
    Success! Please check the updates in /&lt;distro-name&gt;-&lt;arch&gt;-&lt;downloaded time&gt;-update/
    

#### Create os distro update from local
    
    bash#osdistroupdate -c rhels6.2-x86_64 -p /root/rhels6.2-x86_64-updates
    Creating the distro update for rhels6.2-x86_64 from the directory /root/rhels6.2-x86_64-updates, please wait...
    Success! Please check the updates in /&lt;distro-name&gt;-&lt;arch&gt;-&lt;downloaded time&gt;-update/
    

#### List the distro update on the management node
    
    bash#osdistroupdate -l 
    osdistroupdate name: rhels6.2-x86_64-update1
            osdistroname=rhels6.2-x86_64
            osupdatedir=/install/osdistroupdates/rhels6.2-x86_64-20120828-update/
            timestamp=2012.08.28 12:30:00
    

#### Delete the distro update
    
    bash#osdistroupdate -d rhels6.2-x86_64-update1
    Removing the distro update rhels6.2-x86_64-update1 for rhels5.5-x86_64, please wait...
    Success!
    

## Internal of osdistroupdate

### the osdistroupdate command

The internal commands in xCAT are put into /$install/xcat/sbin, such as fsp-api, lpar_netboot.expect, gatherfip . Considering the osdistroupdate is an internal command, and we will put the osdistroupdate command in /$install/xcat/sbin. osdistroupdate will be a link to ../bin/xcatclientnnr . This link will be created in the xCAT-client.spec file, such as: 

ln -sf ../bin/xcatclientnnr $RPM_BUILD_ROOT/%{prefix}/sbin/osdistroupdate 

### the osdistroupdate.pm plugin

The osdistroupdate.pm plugin will be in the /$install/xcat/lib/perl/xCAT_plugin directory. Almost all the functions will be implemented in the osdistroupdate.pm plugin. 

#### preprocess_request() in the osdistroupdate.pm plugin

In the preprocess_request() of the osdistroupdate.pm plugin, there is a parse_args() subroutine. And the parse_args() subroutine will parse the arguments of the osdistroupdate command. The result will be stored in the %opt hash. This hash will be set to $request-&gt;{opt}. 

#### process_request() in the osdistroupdate.pm plugin

The process_request() of the osdistroupdate.pm plugin is the main function. In the process_request(), the procedure is as following: 
    
    (1)get the option from the hash $request, such as  my $opt = $request-&gt;{opt};
    (2) If $opt-&gt;{l}== 1 , it will invoke the list_updates( $request, $callback)
        If $opt-&gt;{c} exists, it will invoke the create_updates(  $request, $callback)
        If $opt-&gt;{d} exists, it will invoke the delete_update( $request, $callback)
       Note: the $request is one basic hash variable in xCAT.  $callback is used to return the msg immediately.
    
    
       $opt = $request-&gt;{opt};
    

In the list_updates($request, $callback), the $opt will look like: 
    
      $opt = {
             'osdistroupdate_name' =&gt; undef,
             'l' =&gt; 1
           };
    

or 
    
      $opt = {
             'osdistroupdate_name' =&gt; 'rhels6.2',
             'l' =&gt; 1
           };
    

  


For create_updates($request, $callback), the $opt will look like: 
    
      $opt = {
             'c' =&gt; 'rhels6.2_x86_64'
           };
    

or 
    
      $opt = {
             'p' =&gt; '/root/test',
             'c' =&gt; 'rhels6.2_x86_64'
           };
    

  


For delete_updates($request, $callback), the $opt will look like: 
    
      $opt = {
             'd' =&gt; 'rhels6.2_x86_64'
           };
       
    

About the 3 subroutines(list_updates,create_updates and delete_update), the return value will be an array,such as [$rc, $data]. The first element of the array will be the return code of the subroutine: 1 and 0. 0 -- success, 1 -- failed. The second element will be the return content of the subroutine. 

For example, we will use the list_updates() as follows: 
    
      my $results = &list_updates($request, $callback);
      $rc = shift(@$results); //$rc will be 0 or 1.
      $data= $results;
      
    

For list_updates, if $rc = 1, the $data will be an array, and looks like [msg1, msg2, msg3,...]; 

if $rc = 0, the data will be an array, and looks like [h1, h2, h3...]. And h1,h2,h3 will look like: 
    
      h1= {
              'osupdatename' =&gt; 'rhels6.2-x86_64-update12125',
              'osdistroname' =&gt; 'rhels6.2-x86_64',
              'dirpath' =&gt; '/install/osdistroupdates/rhels6.2-x86_64-20120228-update12125/',
              'downloadtime' =&gt; '1330402626',
              'comments' =&gt; undef,
              'disable' =&gt; '0',
          }
    

For create_updates/delete_update, if $rc=0 or 1, the data will be an array, and looks like [msg1, msg2, msg3 ...]; 

  
The 3 subroutines will be implemented by PCM. 
