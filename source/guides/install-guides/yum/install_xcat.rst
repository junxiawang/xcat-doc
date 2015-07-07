Install xCAT
============

xCAT is installed by configuring the Software repository and using yum package manager.  The software repositoreies can be one of the following:

* Public Internet Repository (requires internet connectivity)
* Locally Configured Repository 

Configure xCAT Software Repository
----------------------------------

Public Internet Repository
~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO: Need to fill this out 

Locally Configured Repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

From the xCAT software download page: `<https://sourceforge.net/p/xcat/wiki/Download_xCAT/>`_, download ``xcat-core`` and ``xcat-dep``.

xcat-core
^^^^^^^^^

The xcat-core package is provided in one of the following options:

* **Latest Release (Stable) Builds**
  
    *This is the latest GA (Generally Availability) build that has been tested throughly*

* **Latest Snapshot Builds**
  
    *This is the latest snapshot of the GA version build that may contain bug fixes but has not yet been tested throughly*

* **Development Builds**

    *This is the snapshot builds of the new version of xCAT in development. This version has not been released yet, use as your own risk*


#. Download xcat-core, if downloading the latest devepment build: :: 

        cd /root
        mkdir -p ~/xcat
        cd ~/xcat/
        wget http://sourceforge.net/projects/xcat/files/yum/devel/core-rpms-snap.tar.bz2
  

#. Extract xcat-core: ::

        cd ~/xcat
        tar jxvf core-rpms-snap.tar.bz

#. Configure the local repository, by runnin the ``mklocalrepo.sh`` script: ::

        cd ~/xcat/xcat-core/
        ./mklocalrepo.sh 


xcat-dep
^^^^^^^^

xCAT's dependency package, ``xcat-dep``, is provided as a convenience for the user and contains dependency packages required by xCAT that are not provided by the operating system.

Unless you are downloading ``xcat-dep`` for a specific GA version of xCAT, you would normally select the package with the latest timestamp.


#. Download xcat-dep, if downloading xcat-dep from 6/11/2015, for Linux: :: 

        mkdir -p ~/xcat/
        cd ~/xcat
        wget http://sourceforge.net/projects/xcat/files/xcat-dep/2.x_Linux/xcat-dep-201506110324.tar.bz2

#. Extract xcat-dep: ::

        cd ~/xcat/
        tar jxvf xcat-dep-201506110324.tar.bz2

#. Configure the local repository by switching to the architecture and os of the system you are installing on , and running the ``mklocalrepo.sh`` script: ::

        cd ~/xcat/xcat-dep/
        # for redhat 6.5 on ppc64...
        cd rh6/ppc64
        ./mklocalrepo.sh 

Install xCAT
------------

Install xCAT with the following command: ::

        yum clean all (optional)
        yum install xCAT


**Note:** During the install, you will need to accept the *xCAT Security Key* to proceed: ::

        warning: rpmts_HdrFromFdno: Header V4 DSA/SHA1 Signature, key ID c6565bc9: NOKEY
        Retrieving key from file:///root/xcat/xcat-dep/rh6/ppc64/repodata/repomd.xml.key
        Importing GPG key 0xC6565BC9:
         Userid: "xCAT Security Key <xcat@cn.ibm.com>"
         From  : /root/xcat/xcat-dep/rh6/ppc64/repodata/repomd.xml.key
        Is this ok [y/N]:


Verify xCAT Installation
------------------------

Quick verificaiton can be done with the following steps:

#. Source the profile to add xCAT Commands to your path: ::

        source /etc/profile.d/xcat.sh

#. Check the xCAT Install version: ::

        lsxcatd -a 

#. Check to see the database is initialized by dumping the site table: ::

        tabdump site

   The output should similar to the following: ::

        #key,value,comments,disable
        "blademaxp","64",,
        "domain","pok.stglabs.ibm.com",,
        "fsptimeout","0",,
        "installdir","/install",,
        "ipmimaxp","64",,
        ...

