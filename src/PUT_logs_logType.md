Remove entries from or clear a log.  
  
reventlog required parameters:  
nodeRange - the nodes  
  
optional parameters for logs other than reventlog:  
If count, percent and lastRecord are all not set, it will clear the log entirely.  
count - the number of records to remove  
percent - the percentage of records to remove  
lastRecord - remove all of the records before this one  
  
flags for logs other than reventlog:  
showRemoved - return the records being removed  
  
Example:  
https://myserver/xcatws/logs/eventlog  
  
with data:  
  
{ 

     "count": 100, 
     "showRemoved" 

} 
