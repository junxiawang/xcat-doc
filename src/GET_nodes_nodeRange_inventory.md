Get the hardware inventory of the nodes.  
  
Parameters:  
field - attribute to request. Any number of them can be used. If this parameter is not supplied, the API will get all attributes by default. Example:  

    
     GET https://127.0.0.1/xcatws/nodes/b1-b4/inventory?userName=xxx&password=xxx?field=serial

For more field restriction detail, can refer [the man page of rinv](http://xcat.sourceforge.net/man1/rinv.1.html)
