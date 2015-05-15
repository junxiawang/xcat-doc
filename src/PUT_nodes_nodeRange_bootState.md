Change the boot state of the nodes.  
  
Parameters:  
boot - sets the boot state to boot. Has no value.  
install - sets the boot state to install. If a value is set for this parameter, it will be taken as the profile name  
netboot - sets the boot state to netboot. If a value is set for this parameter, it will be taken as the profile name  
statelite - sets the boot state to statelite. If a value is set for this parameter, it will be taken as the profile name  
bmcSetup - instructs the node to boot to the xCAT nbfs environment and proceed to configure BMC for basic remote access. This causes the IP, netmask, gateway, username, and password to be programmed according to the configuration table. Has no value.  
  
Example:  

    
    PUT https://127.0.0.1/xcatws/nodes/b1-b4/bootstat?userName=xxx&password=xxx

  
With data:  
["install"] / ["netboot"] /... 
