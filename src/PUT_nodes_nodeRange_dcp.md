Concurrently copies files to or from remote target nodes.  
  
Parameters:  


  * fanout = fanout value&nbsp;: Specifies a fanout value for the maximum number of concurrently executing remote shell processes. 
  * rootimg = img path&nbsp;: Specifies the path to the install image on the local Linux node. 
  * options = node options&nbsp;: Specifies options to pass to the remote shell command for node targets. The options must be specified within double quotation marks ("") to distinguish them from xdsh options. 
  * rsyncfile = sync configure file&nbsp;: Specifies the path to the file that will be used to build the rsync command. 
  * remotecopy = command path&nbsp;: Specifies the full path of the remote copy command used for remote command execution on node targets. 
  * timeout = timeout value&nbsp;: Specifies the time, in seconds, to wait for output from any currently executing remote targets. 
  * source = source file path 
  * target = target file path 

  
Flags:  


  * preserve&nbsp;: Preserves the source file characteristics as implemented by the configured remote copy command. 
  * pull&nbsp;: Pulls (copies) the files from the targets and places them in the target_path directory on the local host. 
  * showconfig&nbsp;: Displays the current environment settings for all DSH Utilities commands. 
  * recursive: Recursively copies files from a local directory to the remote targets 

  
For more parameter and flag introduction, refer [the man page of xdcp](http://xcat.sourceforge.net/man1/xdcp.1.html)  
  
Example:  

    
    PUT https://127.0.0.1/xcatws/nodes/b1-b3/dcp?userName=root&password=cluster

  


with data:  

    
    ["remotecopy =/usr/bin/rsync", "options=\"-t\"", "source=/localnode/smallfile /tmp/bigfile", "target=/tmp"]

  


copy /localnode/smallfile and /tmp/bigfile to /tmp on node1 using rsync and input -t flag to rsync. 
