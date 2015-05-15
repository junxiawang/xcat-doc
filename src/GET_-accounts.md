List the accounts. If the clusterUser flag is set, it works with the cluster user list, otherwise the passwd table.  
  
Passwd Parameters:  
key - the account name. If this is set, at least one field must be as well. If not set, all of the accounts in the passwd table will be listed.  
field - a field to display in the output. Any number of these can be used.  
  
Cluster User Flags:  
clusterUser - indicates that the accounts in the cluster user list should be listed.  
  
Examples:  
https://myserver/xcatws/account?key=system&amp;field=username&amp;field=password  
https://myserver/xcatws/account?clusterUser 
