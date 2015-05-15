Create an account. This can be in the passwd table or in the active directory  
  
Active Directory required fields:  
clusterUser - a flag to indicate this is an active directory account  
userName - the user name  
userPass - the user password  
  
Passwd required fields:  
key - the key field to uniquely identify the account  
field - a passwd table field to update with a value  
  
Examples:  
https://myserver/xcatws/accounts?clusterUser&amp;userName=foo&amp;userPass=bar  
https://myserver/xcatws/accounts?key=system&amp;field=username=foo&amp;field=password=bar  

