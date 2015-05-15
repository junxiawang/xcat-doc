Retrieve attributes from the specified table.  
  
optional parameter(only select a row): 

  * col = column name: The select condition column name. This parameter should used with parameter value and attribute. 
  * value = value&nbsp;: the select condition value. This parameter should used with parameter col and attribute. 
  * attribute = attr name&nbsp;: the attribute which want to get. This parameter should used with parameter col and value. 

  
Excemple:  

    
    GET https://myserver/xcatws/tables/ppc?userName=xxx&password=xxx

  


Dump all content in ppc table.  
  

    
    GET https://myserver/xcatws/tables/ppc?userName=xxx&password=xxx&col=nodetype&value=lpar&attribute=parent&attribute=hcp

  


Display the first row satify the condition "nodetype=lpar", only return attribute "parent" and "hcp". 
