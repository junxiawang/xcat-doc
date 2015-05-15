  
  
The root password can be encrypted using the following method:   
  
1) Create encrypted password  
$ perl -e 'print crypt("password","Xa") . "\n";'  
X238sbasdasdsajksjasd  
2) Edit password tab file  
$ vi passwd.tab  
rootpw X238sbasdasdsajksjasd  
3) Edit template file   
  
$ vi compute.tmpl  
rootpw --iscrypted #TABLE:passwd.tab:rootpw:1# 

This allows for the root password to be changed in the passwd.tab file, and remain encrypted.   
  
  
\- dtripp 1/07 

'''NOTE:'''  
This doesn't appear to work if you use an md5 crypt. For example, I have a cron job that copies the pw of a user on the xcat server into passwd.tab. I've updated compute.tmpl but when a node gets installed it seems to encrypt the password again and we are unable to get in as root.  
-gja 4/25 
