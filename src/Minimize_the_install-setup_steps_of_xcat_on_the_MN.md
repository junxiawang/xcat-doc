{{:Design Warning}} 

**Note: this design only applies for Linux environment.**

There are a bunch of manual steps to setup xCAT the management node, some of the manual steps could be automated to reduce the complexity of setting xCAT on the management node. The /opt/xcat/sbin/xcatconfig will run some configuration procedure on the management node after xCAT packages are installed. Additional steps will be added to xcatconfig to reduce the manual steps after xCAT are installed on the management node. 

**All the following steps should be done only for the new xCAT installation but not update.**

  
1\. Disable selinux on Redhat. If the user forgot to disable selinux, it will cause a lot of weird problems, the xcatconfig could check the selinux status and disable it if necessary. 

To check the selinux status, use the subroutine xCAT::Utils::isSElinux, to disable selinux: 
    
     echo 0 &gt; /selinux/enforce
     sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config
    

The "echo 0 &gt; /selinux/enforce" disables selinux until the system reboots, the "sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config" disables selinux after the system reboots. 

2\. Disable the firewall 

On Redhat: 
    
     service iptables stop
     chkconfig iptables off
    

On SLES: 
    
     service SuSEfirewall2_setup stop
     chkconfig SuSEfirewall2_setup off
    

To completely disable the firewall: 

On RedHat: 
    
     chkconfig iptables off
     service iptables stop
    

On SLES: 
    
     chkconfig SuSEfirewall2_setup off
     service SuSEfirewall2_setup stop
    

3\. Check if the network adapters are configure to use static ip address, if not, change the network adapters to use static ip address. The /install/postscripts/hardeths could be used to achieve this. 

4\. Check the MN host name resolution, if the MN hostname could not resolved, print a warning message and indicate what needs to be done after the xCAT is installed, for example: 
    
     Warning: Hostname resolution for &lt;mnnodename&gt; failed, setting the site.master to NORESOLUTION for now, 
     after the xCAT installation is finished, fix this hostname resolution problem, 
     change the site.master to the correct value and then resart xcatd.
    

5\. Setup ntp server on management node 

In /etc/ntp.conf 
    
     driftfile /var/lib/ntp/drift
     disable auth
     restrict 127.0.0.1
     server  127.127.1.0     # local clock
     fudge   127.127.1.0 stratum 10
    

Then restart ntpd: 
    
     service ntpd restart   # RedHat
     service ntp restart    # SLES
    

6\. Configure named and dhcpd to start on boot (Already done) 

7\. Setup the default timezone (Already done by os installation) 

In /etc/sysconfig/clock: 
    
     [RH] ZONE="US/Eastern"
    
    
     [SLES] TIMEZONE="America/New_York"
    
    
     ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime
    

8\. Setup PostgreSQL (Done) 

we are having a requirement that when xCAT installs, it comes up running postgresql, never setting up sqlite, a good way to do this would make it an option in xcatconfig, this option would be used in xcatconfig when run from xCAT.spec (xcatconfig -i). xcatconfig will call pgsqlsetup with the -N flag and XCATPGPW environment variable set to the admin password for pgsql, so there will be no prompting. This should be done before any database call is made out of xcatconfig and only for the initial install of xCAT. 

To drive xcatconfig to make the call to pgsqlsetup -i -N during install, we can use environment variable with yum command, if the user or PCM scripts exported the environment variable XCATPGPW when running yum command to install xCAT, then xcatconfig can call pgsqlsetup -i -N to setup postgresql. Here is an example: 
    
     XCATPGPW=cluster yum -y install xCAT
    

indicates that the xcatconfig should call pgsqlsetup -i -N to setup postgresql. 
