{{:Design Warning}} 

**1\. What are the problems we were seeing in scaling environment?**

We were seeing some rcons related problems when doing the scaling cluster setup and administration, we have to restart conserver from time to time. 

1) the conserver will start responding slow after the conserver have been running for a while(maybe several days, I am not so sure), when the conserver responds slow, it probably takes more than 5 or even 10 seconds to open the node console, caused the rnetboot and getmacs timeout, or occasionally the rcons can not open the consoles for the nodes at all. we have to restart the conserver to fix the problem. 

2) The conserver restart will take a very long time, about 5 minutes, to finish the initialization with 1K nodes, during the conserver initialization, the rcons will get "Connection refused" error. 

3) Even xCAT has set the "consoleondeman" attribute, but the conserver will fork a lot of child daemons to handle the consoles defined in /etc/conserver.cf, each conserver child daemon can handle only about 15 consoles, the conserver child daemons will probably be causing performance problems on the management nodes in scaling environment. Here is an example: 
    
    c906mgrs2:~ # cat /etc/conserver.cf | grep "console c906" | wc -l
    1204
    c906mgrs2:~ # ps -ef | grep "conserver -o -O1 -d" | wc -l
    78
    c906mgrs2:~ # 
    

We can see that with 1024 consoles defined in the /etc/conserver.cf, the conserver needs to fork 78-1=77 child daemons. 

  


**2\. How the problems are caused?** The current rcons/makeconservercf implementation does not support hierarchy very well, this should be the root cause of why the conserver overloaded the management node. 1) The current makeconservercf implementation will add all the nodes console definitions into /etc/conserver.cf on the management node, and the nodes console definitions will also be sent to the nodes' conserver-host. It means that all the nodes in the cluster will be in the /etc/conserver.cf on the management node. 

2) We can specify the conserver-host through rcons command line, but the rcons will use the xCAT management node as the default conserver host if the conserver-host is not specified, so the rcons command will always connect to the conserver on the management node by default. 

  


**3\. What changes I am planning to make?**

1) Add a new flag -c|--conserver to makeconservercf to only add the nodes into the /etc/conserver.cf on the node's conserver host. The default behaviour of makeconserver will not be changed if -c is not specified. The -c flag can not be used with -l flag. 

2) Change the rcons to read the node's conserver attribute and run "console -M &lt;conserver&gt; &lt;nodename&gt;" to connect to the conserver on the nodes' conserver host. The priority list of the possible -M values are: user specified parameters, noderes.conserver (don't you mean nodehm.conserver??), $XCATHOST, localhost. 

3) The conserver can be configured on the number of consoles each daemon can handle. The documentation will be updated to include the instructions. 

  


  
**4\. Future considerations.** For now, the conserver-host must be a servicenode because makeconsercf needs to use the xcatclient-&gt;xcatd communication to send the nodes console definitions to the conserver-host. It makes sense because the conserver-host is providing service to the nodes so it should be a "service"node. But tt will be easier for the users if we could eliminate the requirement that the conserver-host must be a service node, the users can simply install the conserver on designated servers and then the servers can act as the conserver-hosts, it provides flexibility and simplicity for the setup. But I think we do not need to do this in xCAT 2.4, and I am not even sure whether we need do this in the future. 

  


**5\. Alternative design** The rcons is NOT a command that goes through the xcatd, so the above design is not a completely hierarchy support from xCAT perspective, an alternative design is to change rcons to a program going through xcatd and the rcons request be sent to the conserver-host, but I guess there will be some issues, because rcons is a little bit different with the other commands, it need to read output from the conserver-host continuously. I do not see any performance advantages by using the xcatclient-&gt;xcatd communication instead of the console-&gt;conserver communication. And it will need structural changes for the rcons/makeconservercf logic. So I do not think we can or need to go with this alternative design. 
