[Howto_Warning](Howto_Warning)

For more details and complete information, see [XCAT_2_Security].

You can regenerate you xCAT credentials (-c) and ssh keys (-k) by running the following command on the Management Node(MN):  
xcatconfig -c   
xcatconfig -k   
If you regenerate your credentials and keys then you need to do the following steps. See man xcatconfig for more options and informations. 

If you have service nodes(SN): 

  * On the MN, run updatenode &lt;service nodes&gt; -k to all service nodes to re-exchange the ssh keys and credentials. 
  * On the service nodes, run xdsh &lt;compute nodes&gt; -K to each compute node to re-exchange the ssh keys. 

If you do not have service nodes 

  * On the MN, run xdsh &lt;compute nodes&gt; -K to all compute nodes to re-exchange the ssh keys. 

Whether or not you have service nodes: 

  * On the MN, Run the following commands to setup up new ssh keys on the management modules rspconfig mm snmpcfg=enable sshcfg=enable 

Setting back up Conserver:  
Run makeconservercf and stop and start ( not restart) conserver on the MN. If you have service nodes, Start and stop the xCAT daemon on the service node which will run makeconservercf and stop and start the conserver daemon. makeconservercf will rebuild the conserver configuration file and update it with the new credentials that were generated. 
