Changes entries in the site table.  
  
Fields:  
key - required field  
value - required field  


  
Example:  

    
    PUT https://myserver/xcatws/site?userName=xxx&password=xxx&format=html

  
  
with data:  

    
    ["xcatdport=3001",...,"timezone=America/New_York"]

  


The "
    
    xcatdport

" is an user-defined attribute for the cluster. For all currently supported attributes, you can refer the output of "
    
    lsdef -h -t site

".
