Change a VM.  
  
Currently uses generic parameters for most fields.  
  
Required Parameters:  
nodeRange - the nodes  
  
Optional Parameters:  
field - any number of these is allowed  
  
Example:  

    
    PUT https://myserver/xcatws/vms/n1-n4

  


  
with data:  
["min_mem=2048", "desired_mem=4096"] 
