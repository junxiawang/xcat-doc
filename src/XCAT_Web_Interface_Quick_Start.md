<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [The requirements for the xCAT web interface](#the-requirements-for-the-xcat-web-interface)
  - [**Install the IBM HTTP Server (only for AIX)**](#install-the-ibm-http-server-only-for-aix)
  - [**Install the xCAT-web-dep rpm package (only for AIX)**](#install-the-xcat-web-dep-rpm-package-only-for-aix)
  - [**Install the php-related rpm package (only on Linux)**](#install-the-php-related-rpm-package-only-on-linux)
    - [**Install "php" on RHELS5.x**](#install-php-on-rhels5x)
    - [**Install "apache2-mod_php5", "php5-openssl" and "php5" on SLES11**](#install-apache2-mod_php5-php5-openssl-and-php5-on-sles11)
  - [**Install the xCAT-UI-deps rpm package**](#install-the-xcat-ui-deps-rpm-package)
  - [**Install the xCAT-UI rpm package**](#install-the-xcat-ui-rpm-package)
  - [**The default account for xCAT web interface**](#the-default-account-for-xcat-web-interface)
  - [**Enable "https" protocol for xCAT web interface**](#enable-https-protocol-for-xcat-web-interface)
    - [**Redhat**](#redhat)
    - [**SuSE**](#suse)
    - [**AIX**](#aix)
    - [**Make sure "https://" works for your browser**](#make-sure-https-works-for-your-browser)
  - [**Preferred Internet Browsers**](#preferred-internet-browsers)
- [Quick Manual](#quick-manual)
    - [**Nodes Page**](#nodes-page)
    - [**Configure Page**](#configure-page)
    - [**Provision Page**](#provision-page)
    - [**Monitor Page**](#monitor-page)
- [Adding non-root users](#adding-non-root-users)
- [The future](#the-future)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 

**Note: this function is no longer supported with 2.7 release of  xCAT or later**.

To use the xCAT zVM GUI, refer to the xCAT documentation page [XCAT_Documentation]  section on using
zVM in xCAT **xCAT Linux Cluster with zVM & zLinux**.


## The requirements for the xCAT web interface

The xCAT web interface requires the following packages installed on the management node (short as MN): 

  1. IBM HTTP Server (on AIX) 
  2. Apache2 HTTP Server (on Linux) 
  3. xCAT-web-dep (only on AIX) 
  4. apache2-mod_php5 and php5 (only on SUSE) 
  5. php (only on Redhat) 
  6. xCAT 
  7. xCAT-UI 

  
The information for downloading xCAT and xCAT-UI packages can be accessed from xCAT website: [http://xcat.sf.net](http://xcat.sf.net/). If you are using xCAT to manage your cluster, you should know how to get and install the xCAT and xCAT-UI packages. 

  
IBM HTTP Server V6.1 or higher is required, which can be downloaded from the "[IBM HTTP Server](http://www-01.ibm.com/software/webservers/httpservers/)" web site. IBM HTTP Server is based on [the Apache HTTP Server](http://httpd.apache.org/), developed by the Apache Software Foundation. There're many third-party modules written for Apache 2.0 that can be used for IBM HTTP Server. IBM HTTP Server is available for use free of charge but without IBM support. It's not packaged into the xCAT-web-dep rpm package because of the underlying legal issues. 

  
The AIX platform lacks of many packages for PHP support, so the package "xCAT-web-dep" is created to include all the possible packages for PHP support. Besides, the PHP rpm package is also included into the xCAT-web-dep package.

  
In order to support php, we also have to install several rpm packages on Linux. However, they are different on RHEL and SLES. On RHEL, "php" is used to support php; but on SLES, "apache2-mod_php5" and "php5" are used to support php.

  


### **Install the IBM HTTP Server (only for AIX)**

After the "IBM HTTP Server for AIX" (Version 6.1.0.0 is preferred) package is downloaded from the "[IBM HTTP Server](http://www-01.ibm.com/software/webservers/httpservers/)" web site, you can unzip it and get the directory named "IHS_6.1.0.0". Then, please follow the install guide in the directory "**IHS_6.1.0.0/IHS/docs**". The latest IHS version is 7.0, you might encounter an operating system detection error message when installing it on AIX 7.1. You should follow the [workaround](http://www-01.ibm.com/support/docview.wss?uid=swg21446119) to install IHS on AIX 7.1 

### **Install the xCAT-web-dep rpm package (only for AIX)**

From the web page "[Browse Files for xCAT on sourceforge.net](http://sourceforge.net/projects/xcat/files/)", you can find the xCAT-web-dep package under "**xcat-dep**" =&gt; "**2.x_AIX**". The current build is xcat-web-dep-2.3-200907141002.tar.gz. 

You can unzip this tar ball, and get the directory named "_xcat-web-dep_", which contains all the xCAT-UI dependencies. In the directory, you can find the README file, and several rpm packages to be installed. 

### **Install the php-related rpm package (only on Linux)**

The php-related rpm packages have different names on Redhat and SuSE. You have to handle these two distributions separately. 

#### **Install "php" on RHELS5.x**

Note: The following command should also work on Fedora.

~~~~ 
   
        yum install php
~~~~     

#### **Install "apache2-mod_php5", "php5-openssl" and "php5" on SLES11**

Note: The followding command should also work on SLES 10.x and OpenSuSE.
 
~~~~    
        zypper install apache2-mod_php5 php5 php5-openssl
~~~~     

use 

~~~~     
    rpm -ql apache2-mod_php5
~~~~ 

to find the mod_php5.so and php5.conf, add the following line into the head of php5.conf. 

~~~~     
        LoadModule php5_module  /usr/lib64/apache2/mod_php5.so
~~~~     

may be the path of mod_php5.so is different from the example. 

### **Install the xCAT-UI-deps rpm package**

The xCAT-UI-deps rpm package can be found on the website [sourceforge.net/projects/xcat/files/xcat-dep/2.x_AIX AIX-xcat-dep] or [Linux-xcat-dep](http://sourceforge.net/projects/xcat/files/yum/xcat-dep/), you can use the "rpm -ivh" command or use yum to install xCAT-UI-deps. 

~~~~     
        rpm -ivh xCAT-UI-deps*.rpm
        or
        yum install xCAT-UI-deps
~~~~     

### **Install the xCAT-UI rpm package**

The latest _xCAT-UI_ rpm package can be found on the website [AIX xCAT-UI](https://sourceforge.net/projects/xcat/files/aix/devel/core-snap/) or [Linux xCAT-UI](https://sourceforge.net/projects/xcat/files/yum/devel/core-snap/), you can use the "rpm -ivh" command or use yum to install xCAT-UI. 
 
~~~~    
        rpm -ivh xCAT-UI*.rpm
        or
        yum install xCAT-UI
~~~~     

Note: If the php-related rpm packages are not installed as chapter 1.3 describes, the installation of xCAT-UI will be failed. 

### **The default account for xCAT web interface**

During the installation of xCAT-UI rpm package, the encrypted password of the system "root" user has been put into the xCAT passwd database. You can use the following command to have a check: 

~~~~    
        tabdump passwd
~~~~     

You should see at least one line, which contains the account information for the web interface. On SLES, you can see that the account information locates in the 4th line, which starts with "xcat". 
 
~~~~    
    #key,username,password,comments,disable
    "system","root","cluster",,
    "omapi","xcat_key","MXBzOExuQUo0QlFrZWJtbVFWVzl4OEdYT0ExQTF1cFA=",,
    "xcat","root","$2a$10$FBaEMr4J5jZ6092.4B6bdutgezyo3lmN1UrYoxrYAIlRSvWl5HJya",,
~~~~     

### **Enable "https" protocol for xCAT web interface**

#### **Redhat**

The https protocol is enabled by default on RHEL, Fedora. You don't need to configure it manually. 

#### **SuSE**

There's one document "[Apache Howto SSL](http://en.opensuse.org/Apache_Howto_SSL)" on OpenSuSE's website, the same procedure works for SLES. 

  1. Make sure that apache starts with mod_ssl loaded.  
a2enmod ssl 
  2. Enable the SSL configuration for apache2  
a2enflag SSL 
  3. Create self signed keys  
/usr/bin/gensslcert 
  4. Create a virtual host  
cp /etc/apache2/vhosts.d/vhost-ssl.template /etc/apache2/vhosts.d/vhost-ssl.conf 
  5. Restart apache2 service  
/etc/init.d/apache2 restart 

#### **AIX**

There are two Technotes "[Guide to properly setting up SSL within the IBM HTTP Server](http://www-01.ibm.com/support/docview.wss?rs=177&uid=swg21179559#step2)" and "[Using the Key Management Utility](http://www-01.ibm.com/software/webservers/httpservers/doc/v1319/9atikeyu.htm)"on IBM HTTP Server website. 

  * Create the database. 
 
~~~~    
    java com.ibm.gsk.ikeyman.ikeycmd -keydb -create -db <filename>.kdb -pw <password>  -type cms -expire  <days> -stash
~~~~     

  * Create a self-signed certificate. 

~~~~     
    java com.ibm.gsk.ikeyman.ikeycmd -cert -create -db <dB_name>.kdb -pw <password> -size <1024 | 512> -dn<distinguished name> -label <label> -default_cert <yes or no>
~~~~     

  
Note: -label: Enter a descriptive comment used to identify the key and certificate in the database.

~~~~ 
-dn: Enter an X.500 distinguished name. This is input as a quoted string of the following format (Only CN, O, and C are required): CN=common_name, O=organization, OU=organization_unit, L=location, ST=state, province, C=country

Example: "CN=weblinux.raleigh.com,O=temp,OU=temp,L=RTP,ST=NC,C=US"
  * Configure the httpd.conf to create a virtual host. 
    
    Listen 443
    Keyfile "/usr/IBM/HTTPServer/temp/XXX.kdb"
    <VirtualHost  *:443>
    SSLEnable
    SSLClientAuth None
    SSLV2Timeout   100
    SSLV3Timeout   5000
    </VirtualHost>
    SSLDisable
~~~~     

  * Restart IBM HTTP Server 

~~~~     
    apachectl -k restart
~~~~     

#### **Make sure "https://" works for your browser**

Point your browser (Firefox, Chrome, or Safari) to https://&lt;ip&gt;/xcat , to see whether "https://" works or not. 

One more thing, because the SSL certificate is self-signed, you may meet the warning message in your 1st time to isit your HTTP server by "https://" protocol. The warning message shows "**The certificate for this website is invalid**", or "**The site's certificate is not-trusted**", or some other similar warnings, which depends on your web browser. 

For such a situation, please feel free to import the certificate into your browser, and the warning message won't show again. 

### **Preferred Internet Browsers**

Due to some compatibility issue, Internet Explorer is not permitted to access the xCAT web interface. Mozilla Firefox, Google Chrome and Apple Safari can be used to access the xCAT web interface. 

## Quick Manual

#### **Nodes Page**

  * All the groups are shown in a tree on the left side. Click the group name, 2 tabs will be shown on the right side. 
  * All nodes belongs to the selected group are shown in a table style in the nodes tab. You can review and modify all nodes' attributes on the pages. You can select the nodes and do operations like: power on/off, clone, delete and so on. 
  * All nodes belongs to the selected group are shown in graphical style in the graphical tab. You can select nodes and do operations, just like you what you do in the nodes tab. 

#### **Configure Page**

  * Tables tab: Show all xCAT tables' names and descriptions. Click the table name to open a new tab and modify the table. 
  * Update tab: Update all xCAT rpms installed on the MN node automatically. 
  * Discover tab: Cluster Setup Wizard. Prime the xCAT database for a new cluster by inputting naming conventions and hardware discovery on the web page step by step. (Only support system P by now) 

#### **Provision Page**

  * Provision tab: Install compute node in install/stateless/statelite style. 
  * Image tab: Copy cd and create stateless/statelite image with HPC stack software.(Only support Linux now) 

#### **Monitor Page**

  * Monitor tab: Configure the third party monitoring software such as Ganglia, RMC etc. The page allows you to start/stop the software and shows the monitor data in graphical style. 

## Adding non-root users

To add non-root users to be able to use the web interface, do the following. 

First setup the non-root user as an xCAT user following this documentation. This will allow them to also use the CLI interface. If planning to use xdsh/xdcp or commands that use xdsh/xdcp (e.g. updatenode) then also follow the procedure in this document for setting up xdsh/xdcp for the non-root user. [Granting_Users_xCAT_privileges] 

Next do the following: 

~~~~    
    tabch username=myuser passwd.key=xcat passwd.password=mypassword
    tabch priority=6.10 policy.name=myuser policy.rule=allow policy.comments="privilege:root"
~~~~   

If 6.10 is already used, pick another unused number. It does not matter which number. 

If you want to limit the commands the non-root user can run, for example only xdsh , then update the policy table commands attribute with the list of commands. Note you must always have authcheck in the list, if you put any commands in the list. 

~~~~    
    tabch priority=6.10 policy.commands="authcheck,xdsh"
~~~~    

## The future

TODO
