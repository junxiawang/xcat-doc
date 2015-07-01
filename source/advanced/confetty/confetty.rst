
Connecting to a remote server 
-----------------------------


In order to do remote sessions, keys must first be added to ``/etc/confluent``

* /etc/confluent/privkey.pem - private key 
* /etc/confluent/srvcert.pem - server cert

If you want to use the xCAT Keys, you can simple copy them into ``/etc/confluent`` ::

    cp /etc/xcat/cert/server-key.pem /etc/confluent/privkey.pem
    cp /etc/xcat/cert/server-cert.pem /etc/confluent/srvcert.pem 


Start confetty, specify the server IP address:  ::

    confetty -s 127.0.0.1



TODO: Add text for exporting user/pass into environment

 
