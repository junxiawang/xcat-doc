<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Update /etc/hosts](#update-etchosts)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Update /etc/hosts 

All of the cluster nodes should be added to the /etc/hosts file on the xCAT management node.  You can either edit the /etc/hosts file by hand, or use [http://xcat.sourceforge.net/man8/makehosts.8.html makehosts]. 

If you edit the file by hand, it should look similar to:

~~~~

127.0.0.1  localhost localhost.localdomain
50.1.2.3  mgmtnode-public mgmtnode-public.cluster.com
10.0.0.100  mgmtnode mgmtnode.cluster.com
10.0.0.1  node1 node1.cluster.com
10.0.0.2  node2 node2.cluster.com
~~~~

On AIX systems the order of the short hostname and long hostname are typically reversed.

If your node names and IP addresses follow a regular pattern, you can easily populate /etc/hosts by putting a regular expression in the xCAT hosts table and then running '''makehosts'''.  To do this, you need to first create an initial definition of the nodes in the database, if you haven't done that already:

~~~~
mkdef node[01-80] groups=compute,all
~~~~

Next, put a regular expression in the hosts table.  The following example will associate IP address 10.0.0.1 with node1, 10.0.0.2 with node2, etc:

~~~~
chdef -t group -o compute ip='|node(\d+)|10.0.0.($1+0)|'
~~~~

Then run

~~~~
makehosts compute
~~~~

and the following entries will be added to /etc/hosts:

~~~~

10.0.0.1 node01 node01.cluster.com
10.0.0.2 node02 node02.cluster.com
10.0.0.3 node03 node03.cluster.com

~~~~


For an explanation of the regular expressions, see the [http://xcat.sourceforge.net/man5/xcatdb.5.html xCAT database man page].

Note that it is a convention of xCAT that for Linux systems the short hostname is the primary hostname for the node, and the long hostname is an alias. 

On AIX the order is typically reversed.  To have the long hostname be the primary hostname, you can use the -l option on the [http://xcat.sourceforge.net/man8/makehosts.8.html makehosts] command.