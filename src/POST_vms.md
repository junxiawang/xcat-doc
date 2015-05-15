Create a VM from scratch or by cloning an existing VM.  
  
Required Parameters:  
nodeRange - The nodeRange  
  
Flags:  
verbose - Verbose output  
  
Cloning uses the following params:  
clone - Clone an existing VM  
target - The master to copy a single VM state to  
source - The master to base the clone on  
  
&lt;s&gt;Cloning required flags:  
clone - indicates the vms will be created by cloning  
  
Cloning optional flags:  
detached - Explicitly request that the noderange be untethered from any masters  
force - Force the cloning of a powered on VM&lt;/s&gt;  
  
Creating a VM uses the following params:  
cec - The CEC(FSP) name for the destination  
startId - The starting numeric id of the new partitions  
source - The partition name of the source  
profile - The file that contains the profiles for the source partitions  
  
Creation flags:  
full - Create a full system partition for each CEC  
  
Examples:  

    
    POST https://myserver/xcatws/vms/n1-n4

  


  
with data:  
  
["startId=5", "source=lpar4", "verbose"] 
