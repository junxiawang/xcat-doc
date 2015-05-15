Runs commands in parallel on nodes   
  
Parameters:  


  * devicetype = device type value&nbsp;: Specify a user-defined device type that references the location of relevant device configuration file. 
  * execute = filename&nbsp;: Indicates that command_list specifies a local script filename and arguments to be executed on the remote targets. 
  * environment = filename&nbsp;: Specifies that the environment file contains environment variable definitions to export to the target before executing the command list. 
  * fanout = value&nbsp;: Specifies a fanout value for the maximum number of concurrently executing remote shell processes. 
  * userid = id value&nbsp;: Specifies a remote user name to use for remote command execution. 
  * options = node options&nbsp;: Specifies options to pass to the remote shell command for node targets. 
  * remoteshell = node remote shell path&nbsp;: Specifies the path of the remote shell command used for remote command execution on node targets. 
  * syntax = csh|ksh&nbsp;: Specifies the shell syntax to be used on the remote target. 
  * timeout = timeout value&nbsp;: Specifies the time, in seconds, to wait for output from any currently executing remote targets. 
  * envlist = env list&nbsp;:Ignore xdsh environment variables. This option can take an argument which is a comma separated list of environment variable names that should NOT be ignored. 
  * sshsetup&nbsp;: Set up the SSH keys for the user running the command to the specified node list. 
  * rootimg = install img&nbsp;: For Linux, Specifies the path to the install image on the local node. For AIX, specifies the name of the osimage on the local node. 
  * command = cmd_list&nbsp;: command[; command]... where command is the command to run on the remote target. Quotation marks are required to ensure that all commands in the list are executed remotely, and that any special characters are interpreted correctly on the remote target. 

  
Flags:  


  * nolocale&nbsp;: Specifies to not export the locale definitions of the local host to the remote targets. 
  * monitor&nbsp;: Monitors remote shell execution by displaying status messages during execution on each target. 
  * showconfig&nbsp;: Displays the current environment settings for all DSH Utilities commands. 
  * silent&nbsp;: Specifies silent mode. 

  
For more parameter and flag introduction, refer [the man page of xdsh](http://xcat.sourceforge.net/man1/xdsh.1.html).  
  
Example:  

    
    PUT https://127.0.0.1/xcatws/nodes/b1-b3/dsh?userName=root&password=cluster

  


with data:  

    
    ["command=date"]

  


run command "date" on nodes b1-b4. 
