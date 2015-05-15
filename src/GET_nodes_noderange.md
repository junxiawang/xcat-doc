With no additional qualifiers, simply lists the nodes in the specified node range. The request can specify tables or table fields by placing them in 'field' parameters. 

This example:  

    
    GET https://127.0.0.1/xcatws/nodes/b1-b3?userName=xxx&password=xxx&field=mac&field=nodetype

will return all of the mac and nodetype fields for the nodes in b1-b3. 
