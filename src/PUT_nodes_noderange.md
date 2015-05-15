Change attributes for the nodes in the node range. 

Parameters: parameters are passed down through the command 

Example: 
    
    PUT https://127.0.0.1/xcatws/nodes/{noderange}?userName=xxx&password=xxx

with data: [ "group=all,compute", ..., "nodetype=lpar"] 
