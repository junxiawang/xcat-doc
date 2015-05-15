Removes VMs.  
  
Required Parameters:  
nodeRange - the nodes  
  
Flags:  
verbose - return verbose output  
retain - retain the object definitions of the nodes  
service - remove the service partitions of the specified CECs  
  
Example:  
https://myserver/xcatws/vms/  
  
with data:  
  
{ 

     "nodeRange": "b1-b8", 
     "verbose", 
     "retain" 

} 
