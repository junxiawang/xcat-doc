Delete an account.  
  
Active Directory required fields:  
clusterUser - flag indicating this is an Active Directory account  
userName - the user name of the account to be removed  
  
Passwd table required fields:  
key - the unique identifier for this account  
  
Examples:  
https://myserver/xcatws/accounts?clusterUser&amp;userName=foo  
https://myserver/xcatws/accounts?key=system  

