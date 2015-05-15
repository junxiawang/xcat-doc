Get the vitals information of the nodes  
  
Parameters:  
field - attribute to request. Any number of them can be used. If this parameter is not supplied, the API will get all attributes by default.   
Example:  

    
    GET https://127.0.0.1/xcatws/nodes/b1-b4/vitals?userName=xxx&password=xxx&field=lcds

  


  
For more field restriction detail, can refer [the man page of rvitals](http://xcat.sourceforge.net/man1/rvitals.1.html). 
