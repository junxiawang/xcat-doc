[Design_Warning](Design_Warning)


Today, nodeset can take an osimage name when it is called this way: 
   

~~~~ 
       nodeset <noderange> osimage=<imagename>
 
~~~~   

It will set the nodetype.provmethod to the <imagename> 

However, when **nodetype.provmethod** is already an image name, it is cumbersome to have to type the os image name again because the os image names are usually very long. 

With this new feature, the nodeset command take the following format: 
  
~~~~  
       nodeset <noderange> osimage
~~~~    

This way, the os image name will be taken from the **nodetype.provmethod** if it is set. And a single nodeset command can handle nodes with different os images. 

The FVT has to try this new feature as well as the existing functions of nodeset because the code change is in the critical path for most nodeset command. 
