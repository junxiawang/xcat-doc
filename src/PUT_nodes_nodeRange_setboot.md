Set the next boot only of the nodes(only BMC-based servers).   
  


  * hd: Boot from the hard disk. 
  * net: Boot over the network, using a PXE or BOOTP broadcast. 
  * cd: Boot from the CD or DVD drive. 
  * def|default: Boot using the default set in BIOS. 

  
Example:  

    
    PUT https://127.0.0.1/xcatws/nodes/b1-b4/setboot?userName=xxx&password=xxx

  


With data:  

    
    ["net"]

  

