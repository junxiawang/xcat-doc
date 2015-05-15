[Howto_Warning](Howto_Warning)

To enable DHCP to work in environments where the network switches handle DHCP forwarding you need to mark the subnets in the network table with a tag indicating that they are "remote". The way that this is accomplished is by using the management interface name field in the subnet ("mgtifname") designating it as a "**!remote!**" interface. Here is an example of such a subnet definition: 
    
    #netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,nodehostname,comments,disable
    "rem1","192.168.0.0","255.255.255.0","!remote!",,,"192.168.0.197","9.0.9.1,9.0.8.1,192.168.0.1",,,,,,

* * *

After you get this entry in the networks table, you need to tell the site table which networks the management node is attached to. This is done by having the following value in the site table: 
    
    "dhcpinterface","!remote!",,

You may have as many "remote" subnets as are necessary. 
