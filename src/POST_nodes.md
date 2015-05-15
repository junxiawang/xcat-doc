Create nodes.  
For now, most of the arguments are taken in a very generic way.  
  
Parameters:  
parameters are passed down through the command  
  
Example:  

    
    POST https://127.0.0.1/xcatws/nodes/{noderange}?userName=xxx&password=xxx

  
with data:  
[ "group=all,compute", ..., "nodetype=lpar"] 
