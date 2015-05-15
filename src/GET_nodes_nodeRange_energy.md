Get energy information for the nodes.  
  
Parameters:  
field - attribute to request. Any number of them can be used. If this parameter is not supplied, the API will get all attributes by default.  
  
Example:  
GET https://127.0.0.1/xcatws/nodes/b1/energy?userName=xxx&amp;password=xxx&amp;field=savingstatus&amp;field=cappingstatus&amp;field=CPUspeed 

For more noderange and field restriction detail, can refer [the man page of renergy](http://xcat.sourceforge.net/man1/renergy.1.html)
