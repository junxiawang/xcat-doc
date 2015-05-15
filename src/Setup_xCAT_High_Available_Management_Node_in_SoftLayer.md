<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [vim:set syntax=pcmk](#vimset-syntaxpcmk)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

XCAT MN HA Configuration using Corosync/Pacemaker

In this example, we will be configuring a 2 xCAT MN  cluster using share-data NFS mount; We use SQLlite as DB;We use static IP to provision nodes, so we do not use dhcp service;There is no service node in this example.

1, Prepare hosts
The NFS SERVER IP is: c902f02x44  10.2.2.44
The NFS shares are /disk1/install,/etc/xcat,/root/.xcat,/root/.ssh/,/disk1/hpcpeadmin
First xCAT Management node is:   chefha  10.2.2.235 
Second xCAT Management node is:   cheftest    10.2.2.233
Virtual IP:  10.2.2.150  chefcnvip

2,Prepare NFS server
In NFS server 10.2.2.44, execute commands to export fs; If you want to use another non-root user to manage xCAT, such as hpcpeadmin, you should create a directory for /home/hpcpeadmin; 
[root@c902f02x44/]# service nfs start
[root@c902f02x44/]# mkdir ~/.xcat 
[root@c902f02x44/]#mkdir -p /etc/xcat
[root@c902f02x44/]#mkdir -p /disk1/install/
[root@c902f02x44/]#mkdir -p /disk1/hpcpeadmin
[root@c902f02x44/]# mkdir -p /disk1/install/xcat

[root@c902f02x44 /]# vi /etc/exports 
/disk1/install *(rw,no_root_squash,sync,no_subtree_check) 
/etc/xcat *(rw,no_root_squash,sync,no_subtree_check) 
/root/.xcat *(rw,no_root_squash,sync,no_subtree_check)
/root/.ssh *(rw,no_root_squash,sync,no_subtree_check)
/disk1/hpcpeadmin *(rw,no_root_squash,sync,no_subtree_check)
[root@c902f02x44 /]# exportfs -a

3,Install First xCAT MN chefha
1) configure IP alias in chefha
]#ifconfig eth0:0 10.2.2.250 netmask 255.0.0.0

2) add alias ip into /etc/resolv.conf 
]#vi /etc/resolv.conf
search pok.stglabs.ibm.com
nameserver 10.2.2.250

rsync /etc/resolv.conf to c902f02x44:/disk1/install/xcat/ 
]#rsync /etc/resolv.conf c902f02x44:/disk1/install/xcat/
add alias ip，cheftest,chefha into /etc/hosts
]#vi /etc/hosts
10.2.2.250 chefcnvip chefcnvip.pok.stglabs.ibm.com
10.2.2.233  cheftest cheftest.pok.stglabs.ibm.com
10.2.2.235  chefha chefha.pok.stglabs.ibm.com

rsync /etc/hosts to c902f02x44:/disk1/install/xcat/ 
]#rsync /etc/hosts c902f02x44:/disk1/install/xcat/

3)install first xcat MN chefha:

mount share nfs from 10.2.2.44:
[root@chefha /]# mkdir -p /install 
[root@chefha /]#mkdir -p /etc/xcat
[root@chefha /]#mkdir -p /home/hpcpeadmin
[root@chefha /]#mount 10.2.2.44:/disk1/install /install
[root@chefha /]# mount 10.2.2.44:/etc/xcat /etc/xcat
[root@chefha /]# mkdir -p /root/.xcat 
[root@chefha /]# mount 10.2.2.44:/root/.xcat /root/.xcat
[root@chefha ~]# mount 10.2.2.44:/root/.ssh /root/.ssh
[root@chefha ~]# mount 10.2.2.44:/disk1/hpcpeadmin /home/hpcpeadmin

create new user hpcpeadmin, change it password to hpcpeadminpw
[root@chefha /]# /install/postscripts/hpccloud.add_new_user hpcpeadmin hpcpeadminpw

change new user hpcpeadmin as sudoers:
[root@chefha /]# /install/postscripts/hpccloud.add_user_sudoer hpcpeadmin
[root@chefha /]# chown hpcpeadmin:hpcpeadmin /home/hpcpeadmin

check the result:
]#su - hpcpeadmin
$ sudo cat /etc/sudoers|grep hpcpeadmin
hpcpeadmin ALL=(ALL) NOPASSWD:ALL
$exit

download xcat-core tar ball and xcat-dep tar ball from sourceforge,and untar them:
[root@chefha /]# mkdir /install/xcat 
[root@chefha tmp]# mv xcat-core-2.8.4.tar.bz2 /install/xcat/ 
[root@chefha tmp]# mv xcat-dep-201404250449.tar.bz2 /install/xcat/
[root@chefha tmp]#cd /install/xcat 
[root@chefha xcat]#tar -jxvf xcat-core-2.8.4.tar.bz2
[root@chefha xcat]#tar -jxvf xcat-dep-201404250449.tar.bz2
[root@chefha xcat]#cd xcat-core
[root@chefha xcat-core]#./mklocalrepo.sh
[root@chefha xcat]-core#cd ../xcat-dep/rh6/x86_64/
[root@chefha x86_64]# ./mklocalrepo.sh 
[root@chefha x86_64]#yum clean metadata
[root@chefha x86_64]#yum install xCAT
[root@chefha x86_64]#source /etc/profile.d/xcat.sh

5) using vip in site table and networks table
[root@chefha ~]chdef -t site master=10.2.2.250 nameservers=10.2.2.250
[root@chefha ~]# chdef -t network 10_0_0_0-255_0_0_0 tftpserver=10.2.2.250
[root@chefha ~]#tabdump networks
]#netname,net,mask,mgtifname,gateway,dhcpserver,tftpserver,nameservers,ntpservers,logservers,dynamicrange,staticrange,staticrangeincrement,nodehostname,ddnsdomain,vlanid,domain,comments,disable
"10_0_0_0-255_0_0_0","10.0.0.0","255.0.0.0","eth0","10.2.0.221",,"10.2.2.250",,,,,,,,,,,,

6) add 2 nodes into policy table
]#tabedit policy
"1.2","chefha",,,,,,"trusted",,
"1.3","cheftest",,,,,,"trusted",,

7) backup xcatDB(optional)
 ]#dumpxCATdb -p <yourbackupdir>.

8) go to doc: https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/Wdaf5241f4aa1_4e22_a538_e47a7a1af08f/page/re-install%20xcat%20management%20nodes%20and%20hypervisors%20with%20software%20RAID-1
execute Part4;
Part4.Get node definition from softlayer through softlayer API

9)Stop the xcatd daemon and some related network services from starting on reboot
[root@chefha ~]# service xcatd stop 
Stopping xCATd [ OK ] 
[root@chefha ~]# chkconfig --level 345 xcatd off 
[root@chefha ~]# service conserver stop 
conserver not running, not stopping [PASSED] 
[root@chefha ~]# chkconfig --level 2345 conserver off 
[root@chefha ~]# service dhcpd stop 
[root@chefha ~]# chkconfig --level 2345 dhcpd off

Remove the Virtual Alias IP
[root@chefha ~]#ifconfig eth0:0 0.0.0.0 0.0.0.0

10)
Check and hange the policy table to allow the user to run commands:
]# chtab policy.priority=6 policy.name=hpcpeadmin policy.rule=allow
]# tabdump policy
/#priority,name,host,commands,noderange,parameters,time,rule,comments,disable
"1","root",,,,,,"allow",,
"1.2","chefha",,,,,,"trusted",,
"1.3","cheftest",,,,,,"trusted",,
"2",,,"getbmcconfig",,,,"allow",,
"2.1",,,"remoteimmsetup",,,,"allow",,
"2.3",,,"lsxcatd",,,,"allow",,
"3",,,"nextdestiny",,,,"allow",,
"4",,,"getdestiny",,,,"allow",,
"4.4",,,"getpostscript",,,,"allow",,
"4.5",,,"getcredentials",,,,"allow",,
"4.6",,,"syncfiles",,,,"allow",,
"4.7",,,"litefile",,,,"allow",,
"4.8",,,"litetree",,,,"allow",,
"6","hpcpeadmin",,,,,,"allow",,

11)
Make sure xCAT commands are in the user's path
]# su - hpcpeadmin
]$ echo $PATH | grep xcat
/opt/xcat/bin:/opt/xcat/sbin:/opt/xcat/share/xcat/tools:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/hpcpeadmin/bin
]$lsdef -t site -l

12) enable getslnodes can work under non-root user
$cd /home/hpcpeadmin
$ vi .slconfig
userid=IBM332186
apikey=b2288d64f0af51d70f456a36a72914a017878c23fac356b6f5dd23c1646b23c2
apidir=/usr/local/lib/softlayer-api-perl-client

running getslnodes to check results:
$getslnodes

13)Stop the xcatd daemon and some related network services from starting on reboot
[root@chefha ~]# service xcatd stop
Stopping xCATd [ OK ]
[root@chefha ~]# chkconfig --level 345 xcatd off
[root@chefha ~]# service conserver stop
conserver not running, not stopping [PASSED]
[root@chefha ~]# chkconfig --level 2345 conserver off
[root@chefha ~]# service dhcpd stop
[root@chefha ~]# chkconfig --level 2345 dhcpd off

Remove the Virtual Alias IP
[root@chefha ~]#ifconfig eth0:0 0.0.0.0 0.0.0.0

4, Install second xCAT MN node
The installation steps are the exactly same with part 3 Install fist xCAT MN node; Using the same VIP with part3

5, SSH Setup Across nodes chefha and cheftest

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
Verify chefha can ssh to cheftest using no password
rsync -ave ssh /etc/ssh/ cheftest:/etc/ssh/
rsync -ave ssh /root/.ssh/ cheftest:/root/.ssh/
Note: if they can ssh each other using password, it is enough;

6, Install corosync and pacemaker on both cheftest and chefha
1) download crmsh pssh python-pssh
~]#wget download.opensuse.org/repositories/network:/ha-clustering:/Stable/RedHat_RHEL-6/x86_64/crmsh-2.1-1.1.x86_64.rpm
~]#wget download.opensuse.org/repositories/network:/ha-clustering:/Stable/RedHat_RHEL-6/x86_64/pssh-2.3.1-4.2.x86_64.rpm
~]#wget download.opensuse.org/repositories/network:/ha-clustering:/Stable/RedHat_RHEL-6/x86_64/python-pssh-2.3.1-4.2.x86_64.rpm

~]#rpm -ivh python-pssh-2.3.1-4.2.x86_64.rpm
~]#rpm -ivh pssh-2.3.1-4.2.x86_64.rpm
~]#yum install redhat-rpm-config
~]#rpm -ivh crmsh-2.1-1.1.x86_64.rpm

2) install corosync and pacemaker from OS repositories
~]#cd /etc/yum.repos.d
~]#cat rhel-local.repo
[rhel-local]
name=HPCCloud configured local yum repository for rhels6.5/x86_64
baseurl=http://10.2.0.221/install/rhels6.5/x86_64
enabled=1
gpgcheck=0


[rhel-local1]
name=HPCCloud1 configured local yum repository for rhels6.5/x86_64
baseurl=http://10.2.0.221/install/rhels6.5/x86_64/HighAvailability
enabled=1
gpgcheck=0

3) Yum install and generate key
]#yum install -y corosync pacemaker 


Generate a Security Key -

First generate a security key for authentication for all nodes in the cluster-
On one of the systems in the corosync cluster enter -

]#corosync-keygen

It will look like the command is not doing anything. It is waiting for entropy data
to be written to /dev/random until it gets 1024 bits. You can speed that process
up by going to another console for the system and entering -

]#cd /tmp
]#wget http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.32.8.tar.bz2
]#tar xvfj linux-2.6.32.8.tar.bz2
]#find .
that should create enough i/o, needed for entropy.
Then you need to copy that file to all of your nodes and put it in /etc/corosync/
with user=root, group=root and mode 0400.

]#chmod 400 /etc/corosync/authkey
]#scp /etc/corosync/authkey vm2:/etc/corosync/

4) edit corosync.conf
]# cat /etc/corosync/corosync.conf
]# Please read the corosync.conf.5 manual page
compatibility: whitetank
totem {
        version: 2
        secauth: off
        threads: 0
        interface {
                member {
                      memberaddr: 10.2.2.233
                       }
                member {
                      memberaddr: 10.2.2.235
                       }
                ringnumber: 0
                bindnetaddr: 10.2.2.0
                mcastport: 5405
        }
        transport: udpu
}
logging {
        fileline: off
        to_stderr: no
        to_logfile: yes
        to_syslog: yes
        logfile: /var/log/cluster/corosync.log
        debug: off
        timestamp: on
        logger_subsys {
                subsys: AMF
                debug: off
        }
}
amf {
        mode: disabled
}

5) configure pacemaker

~]#vi /etc/corosync/service.d/pcmk
service {
name: pacemaker
ver: 1
}

6) synchronize 
chefha]# for f in /etc/corosync/corosync.conf /etc/corosync/service.d/pcmk; do scp $f cheftest:$f; done

7) start corosync and pacemaker in chefha and cheftest
]# /etc/init.d/corosync start
Starting Corosync Cluster Engine (corosync): [ OK ]
]# /etc/init.d/pacemaker start
Starting Pacemaker Cluster Manager[ OK ]

8) verify and let stonith false
]# crm_verify -L -V
   error: unpack_resources: Resource start-up disabled since no STONITH resources have been defined
   error: unpack_resources: Either configure some or disable STONITH with the stonith-enabled option
   error: unpack_resources: NOTE: Clusters with shared data need STONITH to ensure data integrity
Errors found during check: config not valid
]# crm configure property stonith-enabled=false


7, Customize corosync/pacemaker configuration for xCAT
Please be aware that you need to apply ALL the configuration at once. You cannot pick and choose which pieces to put in, and you cannot put some in now, and some later. Don't execute individual commands, but use crm configure edit instead. 

Check that both cheftest and chetha are standby state now:
[root@chefha ~]# crm status 
Last updated: Wed Aug 13 22:57:58 2014 
Last change: Wed Aug 13 22:40:31 2014 via cibadmin on chefha 
Stack: classic openais (with plugin) 
Current DC: cheftest - partition with quorum 
Version: 1.1.8-7.el6-394e906 
2 Nodes configured, 2 expected votes 
14 Resources configured. 
Node chefha: standby 
Node cheftest: standby

Using crm configure edit to add all configure at once:
[root@chefha ~]# crm configure edit

node chefha

node cheftest \

        attributes standby=on

primitive ETCXCATFS Filesystem \

        params device="10.2.2.44:/etc/xcat" fstype=nfs options=v3 directory="/etc/xcat" \

        op monitor interval=20 timeout=40

primitive HPCADMIN Filesystem \
        params device="10.2.2.44:/disk1/hpcpeadmin" fstype=nfs options=v3 directory="/home/hpcpeadmin" \
        op monitor interval=20 timeout=40

primitive ROOTSSHFS Filesystem \
        params device="10.2.2.44:/root/.ssh" fstype=nfs options=v3 directory="/root/.ssh" \
        op monitor interval=20 timeout=40

primitive INSTALLFS Filesystem \

        params device="10.2.2.44:/disk1/install" fstype=nfs options=v3 directory="/install" \

        op monitor interval=20 timeout=40

primitive NFS_xCAT lsb:nfs \

        op start interval=0 timeout=120s \

        op stop interval=0 timeout=120s \

        op monitor interval=41s

primitive NFSlock_xCAT lsb:nfslock \

        op start interval=0 timeout=120s \

        op stop interval=0 timeout=120s \

        op monitor interval=43s

primitive ROOTXCATFS Filesystem \

        params device="10.2.2.44:/root/.xcat" fstype=nfs options=v3 directory="/root/.xcat" \

        op monitor interval=20 timeout=40

primitive apache_xCAT apache \

        op start interval=0 timeout=600s \

        op stop interval=0 timeout=120s \

        op monitor interval=57s timeout=120s \

        params configfile="/etc/httpd/conf/httpd.conf" statusurl="http://localhost:80/icons/README.html" testregex="</html>" \

        meta target-role=Started

primitive dummy Dummy \

        op start interval=0 timeout=600s \

        op stop interval=0 timeout=120s \

        op monitor interval=57s timeout=120s \

        meta target-role=Started

primitive named lsb:named \

        op start interval=0 timeout=120s \

        op stop interval=0 timeout=120s \

        op monitor interval=37s

primitive xCAT lsb:xcatd \

        op start interval=0 timeout=120s \

        op stop interval=0 timeout=120s \

        op monitor interval=42s \

        meta target-role=Started

primitive xCAT_conserver lsb:conserver \

        op start interval=0 timeout=120s \

        op stop interval=0 timeout=120s \

        op monitor interval=53

primitive xCATmnVIP IPaddr2 \

        params ip=10.2.2.250 cidr_netmask=8 \

        op monitor interval=30s

group XCAT_GROUP INSTALLFS ETCXCATFS ROOTXCATFS HPCADMIN ROOTSSHFS \

        meta resource-stickiness=100 failure-timeout=60 migration-threshold=3 target-role=Started

clone clone_named named \

        meta clone-max=2 clone-node-max=1 notify=false

colocation colo1 inf: NFS_xCAT XCAT_GROUP

colocation colo2 inf: NFSlock_xCAT XCAT_GROUP

colocation colo4 inf: apache_xCAT XCAT_GROUP
colocation colo7 inf: xCAT_conserver XCAT_GROUP
colocation dummy_colocation inf: dummy xCAT

colocation xCAT_colocation inf: xCAT XCAT_GROUP
colocation xCAT_makedns_colocation inf: xCAT xCAT_makedns
order Most_aftergrp inf: XCAT_GROUP ( NFS_xCAT NFSlock_xCAT apache_xCAT xCAT_conserver )
order Most_afterip inf: xCATmnVIP ( apache_xCAT xCAT_conserver )
order clone_named_after_ip_xCAT inf: xCATmnVIP clone_named
order dummy_order0 inf: NFS_xCAT dummy
order dummy_order1 inf: xCAT dummy
order dummy_order2 inf: NFSlock_xCAT dummy
order dummy_order3 inf: clone_named dummy
order dummy_order4 inf: apache_xCAT dummy
order dummy_order7 inf: xCAT_conserver dummy
order dummy_order8 inf: xCAT_makedns dummy
order xcat_makedns inf: xCAT xCAT_makedns
property cib-bootstrap-options: \

        dc-version=1.1.8-7.el6-394e906 \

        cluster-infrastructure="classic openais (with plugin)" \

        expected-quorum-votes=2 \

        stonith-enabled=false \

        last-lrm-refresh=1406859140

#vim:set syntax=pcmk

8, Verify auto fail over;
1)
Now cheftest and chefha status are standby, let us online chefha
[root@cheftest ~]# crm node online chefha
[root@cheftest /]# crm status
Last updated: Mon Aug  4 23:16:44 2014
Last change: Mon Aug  4 23:13:09 2014 via crmd on cheftest
Stack: classic openais (with plugin)
Current DC: chefha - partition with quorum
Version: 1.1.8-7.el6-394e906
2 Nodes configured, 2 expected votes
12 Resources configured.
Node cheftest: standby
Online: [ chefha ]
 Resource Group: XCAT_GROUP
     xCATmnVIP  (ocf::heartbeat:IPaddr2):       Started chefha
     INSTALLFS  (ocf::heartbeat:Filesystem):    Started chefha
     ETCXCATFS  (ocf::heartbeat:Filesystem):    Started chefha
     ROOTXCATFS (ocf::heartbeat:Filesystem):    Started chefha
 NFS_xCAT       (lsb:nfs):      Started chefha
 NFSlock_xCAT   (lsb:nfslock):  Started chefha
 apache_xCAT    (ocf::heartbeat:apache):        Started chefha
xCAT   (lsb:xcatd):    Started chefha
xCAT_conserver (lsb:conserver):        Started chefha
dummy  (ocf::heartbeat:Dummy): Started chefha
 Clone Set: clone_named [named]
     Started: [ chefha ]
     Stopped: [ named:1 ]

2) xcat on cheftest is not working while it is running in chefha:
[root@cheftest /]# lsdef -t site -l
Unable to open socket connection to xcatd daemon on localhost:3001.
Verify that the xcatd daemon is running and that your SSL setup is correct.
Connection failure: IO::Socket::INET: connect: Connection refused at /opt/xcat/lib/perl/xCAT/Client.pm line 217.

[root@cheftest /]# ssh chefha "lsxcatd -v"
Version 2.8.4 (git commit 7306ca8abf1c6d8c68d3fc3addc901c1bcb6b7b3, built Mon Apr 21 20:48:59 EDT 2014)

3)let chefha standby and cheftest online, xcat will run on cheftest:
[root@cheftest /]# crm node online cheftest
[root@cheftest /]# crm node standby chefha 
[root@cheftest /]# crm status 
Last updated: Mon Aug 4 23:19:33 2014 
Last change: Mon Aug 4 23:19:40 2014 via crm_attribute on cheftest 
Stack: classic openais (with plugin) 
Current DC: chefha - partition with quorum 
Version: 1.1.8-7.el6-394e906 
2 Nodes configured, 2 expected votes 
12 Resources configured. 


Node chefha: standby 
Online: [ cheftest ] 

Resource Group: XCAT_GROUP 
xCATmnVIP (ocf::heartbeat:IPaddr2): Started cheftest 
INSTALLFS (ocf::heartbeat:Filesystem): Started cheftest 
ETCXCATFS (ocf::heartbeat:Filesystem): Started cheftest 
ROOTXCATFS (ocf::heartbeat:Filesystem): Started cheftest 
NFSlock_xCAT (lsb:nfslock): Started cheftest 
xCAT (lsb:xcatd): Started cheftest 
Clone Set: clone_named [named] 
Started: [ cheftest ] 
Stopped: [ named:1 ] 

[root@cheftest /]#lsxcatd -v
Version 2.8.4 (git commit 7306ca8abf1c6d8c68d3fc3addc901c1bcb6b7b3, built Mon Apr 21 20:48:59 EDT 2014)




