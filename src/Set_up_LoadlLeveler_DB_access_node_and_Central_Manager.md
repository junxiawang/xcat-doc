<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Set up LoadLeveler Central Manager](#set-up-loadleveler-central-manager)
  - [Install LoadLeveler on xCAT management node (optional)](#install-loadleveler-on-xcat-management-node-optional)
  - [Install LoadLeveler on xCAT service nodes](#install-loadleveler-on-xcat-service-nodes)
  - [Configure LoadLeveler Central Manager](#configure-loadleveler-central-manager)
- [Use LoadLeveler Database Configuration Option (Optional)](#use-loadleveler-database-configuration-option-optional)
  - [Set up MySQL as LoadLeveler Database](#set-up-mysql-as-loadleveler-database)
    - [**Set up LoadLeveler DB access on xCAT management node**](#set-up-loadleveler-db-access-on-xcat-management-node)
    - [**Set up LoadLeveler DB access on xCAT service nodes**](#set-up-loadleveler-db-access-on-xcat-service-nodes)
  - [Set up DB2 as LoadLeveler Database](#set-up-db2-as-loadleveler-database)
    - [**Set up LoadLeveler DB access on xCAT management node**](#set-up-loadleveler-db-access-on-xcat-management-node-1)
    - [**Set up LoadLeveler DB access on xCAT service nodes**](#set-up-loadleveler-db-access-on-xcat-service-nodes-1)
  - [Configure LoadLeveler DB access nodes](#configure-loadleveler-db-access-nodes)
- [Initialize and Configure LoadLeveler](#initialize-and-configure-loadleveler)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Set up LoadLeveler Central Manager

The role of the central manager is to examine the job.s requirements and find one or more machines in the LoadLeveler cluster that will run the job. Once it finds the machine(s), it notifies the scheduling machine. To Set up LoadLeveler Central Manager, install LoadLeveler on the node to act as LoadLeveler Central Manager. When setting up LoadLeveler in an xCAT non-hierarchical cluster, it is recommended to set up xCAT management node as the LoadLeveler Central Manager. When setting up LoadLeveler in an xCAT hierarchical cluster, it is recommended to set up one of your xCAT service nodes as the LoadLeveler Central Manager. If you have a different LoadLeveler Central Manager configuration, please see LoadLeveler documentation for more information.

### Install LoadLeveler on xCAT management node (optional)

To use the LoadLeveler database configuration option with the xCAT database, you will need to install LoadLeveler on your xCAT management node. You may also choose to configure your management node or service nodes as your LL central manager and resource manager. Following the LoadLeveler Installation Guide for details, install LoadLeveler on your xCAT management node. These are the high-level steps:

  * On Linux:



  * Make sure the following packages are installed on your management node:

~~~~
     compat-libstdc++-33.ppc64
     libXmu.ppc64
     libXtst.ppc64
     libXp.ppc64
     libXScrnSaver.ppc64
~~~~



  * Install the LoadLeveler license rpm:

~~~~
      cd /install/post/otherpkgs/<os>/<arch>/loadl
      IBM_LOADL_LICENSE_ACCEPT=yes rpm -Uvh ./LoadL-full-license*.rpm
~~~~




  * Install the product rpms:

~~~~
      rpm -Uvh ./LoadL-scheduler-full*.rpm ./LoadL-resmgr-full*.rpm
~~~~


  * On AIX:

~~~~
      cd /install/post/otherpkgs/aix/ppc64/loadl
      inutoc .
      installp -Y -X -d . all
      installp -X -B -d . all
~~~~


### Install LoadLeveler on xCAT service nodes

You may choose to install LoadLeveler on your xCAT service node and configure it as your LL central manager or resource manager. Follow [Setting_up_LoadLeveler_in_a_Stateful_Cluster/#linux](Setting_up_LoadLeveler_in_a_Stateful_Cluster/#linux) to install LoadLeveler on your xCAT Linux service node. Follow [Setting_up_LoadLeveler_in_a_Stateful_Cluster/#AIX](Setting_up_LoadLeveler_in_a_Stateful_Cluster/#AIX) to install LoadLeveler on your xCAT AIX service node.

    Note: Installing LoadLeveler on xCAT service nodes follows the same process as Installing LoadLeveler on compute nodes, only with the differences below:

  * Make sure the following packages are installed on your service nodes:


~~~~

   Python
   PyODBC
~~~~

  * For AIX, xCAT ships /opt/xcat/share/xcat/IBMhpc/loadl/loadl.bnd by default as the sample bundle file to install LoadLeveler on compute nodes. While to install LoadLeveler on the service nodes, you need to make your own copy, rename and edit it.

For example:

~~~~
           cp /opt/xcat/share/xcat/IBMhpc/loadl/loadl.bnd /install/nim/installp_bundle/loadl-sn.bnd
~~~~

Make sure the LoadL.scheduler packages exist in /install/post/otherpkgs/aix/ppc64/loadl directory
Add a new line in /install/nim/installp_bundle/loadl-sn.bnd

~~~~
          I:LoadL.scheduler
~~~~

~~~~
          nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/loadl-sn.bnd loadl-sn
          chdef -t osimage -o <image_name> -p installp_bundle="IBMhpc_base,loadl-sn"
~~~~

Make your own copy for /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install, rename and edit it.

~~~~
          cp -p /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install /install/postscripts/loadl_install-sn

~~~~

Modify /install/postscripts/loadl_install-sn, and change the "aix_loadl_bin" as:

~~~~
          aix_loadl_bin=/usr/lpp/LoadL/full/bin
~~~~




  * For Linux, make sure you have put LoadL-scheduler rpms in the same directory as LoadL-resmgr rpms in /install/post/otherpkgs/<os>/<arch>/loadl.
Make your own copy for /opt/xcat/share/xcat/IBMhpc/loadl/loadl-5103.otherpkgs.pkglist, rename and edit it to add LoadL-scheduler-full*.rpm which should be installed on service node.

For example:

~~~~
          cp -p /opt/xcat/share/xcat/IBMhpc/loadl/loadl-5103.otherpkgs.pkglist /opt/xcat/share/xcat/IBMhpc/loadl/loadl-5103-sn.otherpkgs.pkglist
~~~~

* Modify /opt/xcat/share/xcat/IBMhpc/loadl/loadl-5103-sn.otherpkgs.pkglist, and change the lines from:

~~~~
            #ENV:IBM_LOADL_LICENSE_ACCEPT=yes#
            loadl/LoadL-full-license*
            #loadl/LoadL-scheduler-full*
            loadl/LoadL-resmgr-full*

~~~~
To:

~~~~
            #ENV:IBM_LOADL_LICENSE_ACCEPT=yes#
            loadl/LoadL-full-license*
            loadl/LoadL-scheduler-full*
            loadl/LoadL-resmgr-full*

~~~~


Note: by default, it is assuming to install Loadl 5.1.0.3 or upper. If you wish to install Loadl 5.1.0.2 or below, then make your own copy for /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install, rename and edit it.

     For example:

~~~~
          cp -p /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install /install/postscripts/loadl_install-sn
~~~~

Modify /install/postscripts/loadl_install-sn, and change the three lines as:

~~~~
          #linux_loadl_license_script="/opt/ibmll/LoadL/sbin/install_ll -c resmgr"
          linux_loadl_license_script="/opt/ibmll/LoadL/sbin/install_ll"
          linux_loadl_bin=/opt/ibmll/LoadL/full/bin
~~~~


### Configure LoadLeveler Central Manager

After your xCAT management node and service nodes are installed with the LoadLeveler resmgr and scheduler packages, you can start to configure the xCAT management node or an xCAT service node as the LoadLeveler Central Manager and Resource Manager.

Generally, any LoadLeveler node can be specified as the LoadLeveler Central Manager and Resource Manager given that it has the LoadLeveler resmgr and scheduler packages installed, has remote access to the database when using the database configuration option, and has network connectivity to all of the nodes that will be part of your LoadLeveler cluster. For an xCAT HPC cluster without hierarchy, it is recommended that you set up your xCAT management node as the LoadLeveler Central Manager. For an xCAT HPC hierarchical cluster, it is recommended that you set up one of your xCAT service nodes as the LoadLeveler Central Manager. If you are setting up a service node as your central manager in an xCAT hierarchical cluster, you may need to also set up network routing so that the xCAT management node can communicate to the service node using the interface defined as the central manager. This may not be the same interface that the xCAT management node uses to communicate to the service node if they are on different networks. Follow the instructions in [Setup_IP_routes_between_the_MN_and_the_CNs].

To specify LoadLeveler Central Manager, you can either use llinit command if you are using file-based configuration:

~~~~
    llinit -cm <central manager host>
~~~~


OR edit LoadL_config configuration file:

~~~~
    CENTRAL_MANAGER_LIST = <list of central manager and alt central managers>
~~~~


OR if planning to use database configuration edit the ll-config stanza in the cluster configuration file:

~~~~
    CENTRAL_MANAGER_LIST = <list of central manager and alt central managers>
~~~~


OR if you have already set up and are running the LoadLeveler database configuration option (see instructions below), change the attribute directly in the database:

~~~~
     llconfig -c CENTRAL_MANAGER_LIST=<central manager host>
~~~~


Unless otherwise specified, LoadLeveler will use the central manager as the resource manager.

## Use LoadLeveler Database Configuration Option (Optional)

LoadLeveler provides the option to use configuration data from files or from a database. When setting up LoadLeveler in an xCAT HPC cluster, it is recommended that you use the database configuration option. This will use the xCAT MySQL or DB2 database. **The DB2 database is required for Power 775 clusters.** The hints and tips provided here will allow you to use xCAT to help set up default LoadLeveler database support. However, be sure that you have read through all of the LoadLeveler documentation for this support and understand what needs to be done to set it up. You will need to make modifications to the processes outlined here to take advantage of advanced LoadLeveler features and to set this up correctly for your environment.

All LoadLeveler nodes that will access the database must have access to the database server, and have ODBC installed and configured correctly. When setting up LoadLeveler in an xCAT non-hierarchical cluster, it is recommended that you set up your xCAT management node as the LoadLeveler DB access node. When setting up LoadLeveler in an xCAT hierarchical cluster, it is recommended that you set up your xCAT service nodes as the LoadLeveler DB access nodes. The LoadLeveler DB access nodes will serve all of its xCAT compute nodes as LoadLeveler "remotely configured nodes". The xCAT service nodes already have database access granted.

### Set up MySQL as LoadLeveler Database

If you are running xCAT with the MySQL database, you will need to set up LoadLeveler to use this same database. Note that MySQL is not supported on Power 775 clusters. You must use DB2.

If you do not already have xCAT running with MySQL, follow the instructions in 
 [Setting_Up_MySQL_as_the_xCAT_DB] to convert your xCAT database to MySQL on xCAT management node. After that, follow the instructions below to set up ODBC for LoadLeveler DB access.

#### **Set up LoadLeveler DB access on xCAT management node**

After your xCAT cluster is running with MySQL, to add LoadLeveler DB access on your xCAT management node, and configure the MySQL database for use with LoadLeveler, follow the instructions in [Setting_Up_MySQL_as_the_xCAT_DB/#add-odbc-support](Setting_Up_MySQL_as_the_xCAT_DB/#add-odbc-support) to set up ODBC support. We only list the basic steps here that are fully documented in the XCAT doc:

  * Install unixODBC and MySQL Connector/ODBC 5.1 (available from the xCAT MySQL tarball on AIX):

Note: As of Oct 2010, the AIX deps package will automatically install the perl-DBD-MySQL , and unixODBC-* when installed on the Management or Service Nodes. On Redhat/Fedora and on SLES, MySQL comes as part of the OS. You may find these already installed.

~~~~
     cd <your xCAT-mysql rpm directory>
     rpm -Uvh unixODBC-*
     rpm -Uvh mysql-connector-odbc-*
~~~~


  * Use xCAT to set up base ODBC support:

With xCAT 2.6 and newer, run the command

~~~~
     mysqlsetup -o -L
~~~~


This will set up /etc/odbcinst.ini, /etc/odbc.ini, and .odbc.ini in the root home directory and set the MySQL log-bin-trust-function-creators variable to on.

With xCAT 2.5 and older, run the command

~~~~
     mysqlsetup -o
~~~~


and manually set the MySQL log-bin-trust-function-creators variable to ON using the MySQL interactive command:

~~~~
     mysql -u root -p
     <enter password when prompted>
     SET GLOBAL log_bin_trust_function_creators=1;
~~~~


  * You must provide an .odbc.ini file in the home directory of each LoadLeveler administrator to ensure database access. Copy the .odbc.ini file created above to /u/loadl:

~~~~
      # On Linux:
      cp /root/.odbc.ini /<user_home>/loadl
      chown loadl:loadl /<user_home>/loadl/.odbc.ini

~~~~

~~~~
      # On AIX:
      cp /.odbc.ini /<user_home>/loadl
      chown loadl:loadl /<user_home>/loadl/.odbc.ini
~~~~


You can verify this access:

~~~~
      su - loadl
      # On Linux:
      /usr/bin/isql -v xcatdb
      # On AIX:
      /usr/local/bin/isql -v xcatdb
~~~~


#### **Set up LoadLeveler DB access on xCAT service nodes**

After your xCAT cluster is running with MySQL, to configure LoadLeveler DB access on xCAT service nodes, and configure the MySQL database for use with LoadLeveler, follow the instructions in [Setting_Up_MySQL_as_the_xCAT_DB/#add-odbc-support](Setting_Up_MySQL_as_the_xCAT_DB/#add-odbc-support) - section "**Setup the ODBC on the Service Node**" to set up ODBC support. The basic steps are:

Note: As of Oct 2010, the AIX deps package will automatically install the perl-DBD-MySQL , and unixODBC-* when installed on the Management or Service Nodes. On Redhat/Fedora and on SLES, MySQL comes as part of the OS. With xCAT 2.6, the sample service package lists shipped with xCAT contain the ODBC rpms. You may find these already installed.

To include the rpms and ODBC files in the service node image, first add the rpms to the service node package list:

On Linux, add the rpms to the otherpkgs.pkglist file:

~~~~
     vi /install/custom/install/<ostype>/<service-profile>.otherpkgs.pkglist
     # add the following entries:
     unixODBC
     mysql-connector-odbc
~~~~




On AIX, add the rpms to the bundle file (assuming this bundle file is already defined to NIM and included in your xCAT osimage definition):

~~~~
     vi /install/nim/installp_bundle/xCATaixSN<version>.bnd
     # add the following entries:
     I:X11.base.lib
     R:mysql-connector-odbc-*
~~~~




For AIX61, the bundle file is /install/nim/installp_bundle/xCATaixSN61.bnd; For AIX71, the bundle file is /install/nim/installp_bundle/xCATaixSN71.bnd
With xCAT 2.6, xCAT provides an odbcsetup postbootscript. Add this to the list of postscripts run on your servicenode to create the required ODBC files:

~~~~
      chdef service -p postbootscripts=odbcsetup
~~~~


With xCAT 2.5 and older, you will need to add the ODBC files to the synclist for your service node image:

~~~~
      vi /install/custom/install/<ostype>/<service-profile>.synclist
      #add the following entries:
      /etc/odbcinst.ini /etc/odbc.ini -> /etc/
      # On Linux:
      /root/.odbc.ini -> /root/
      # On AIX:
      /.odbc.ini -> /
~~~~


and if you don't already have a synclist defined for your image:

~~~~
      chdef -t osimage -o <service node image> -p synclists=/install/custom/install/<ostype>/<service-profile>.synclist
~~~~


If your service nodes are actively running, push out the changes now:

For xCAT 2.6 and newer:

~~~~
      updatenode -P odbcsetup
~~~~




For xCAT 2.5 and older:

~~~~
      updatenode service -S
      updatenode service -F
~~~~






(These need to be run as two separate commands since the files need to get pushed out AFTER the packages are installed).

### Set up DB2 as LoadLeveler Database

If you are running xCAT with the DB2 database, you will need to set up LoadLeveler to use this same database. If you do not already have xCAT running with DB2, follow the instructions in [Setting_Up_DB2_as_the_xCAT_DB] to convert your xCAT database to DB2 on xCAT management node. After that, follow the instruction below to set up ODBC for LoadLeveler DB access.

#### **Set up LoadLeveler DB access on xCAT management node**

After your xCAT cluster is running with DB2, to configure LoadLeveler DB access on xCAT management node, and configure the DB2 database for use with LoadLeveler, follow the instructions in [Setting_Up_DB2_as_the_xCAT_DB/#adding-odbc-support](Setting_Up_DB2_as_the_xCAT_DB/#adding-odbc-support) - section "**Setup the ODBC on the Management Node**" to set up ODBC support.

#### **Set up LoadLeveler DB access on xCAT service nodes**

After your xCAT cluster is running with DB2, to configure LoadLeveler DB access on xCAT service nodes, and configure the DB2 database for use with LoadLeveler, follow the instructions in [Setting_Up_DB2_as_the_xCAT_DB/#adding-odbc-support](Setting_Up_DB2_as_the_xCAT_DB/#adding-odbc-support) - section "**Setup ODBC on the Service Nodes**" to set up ODBC support. Also read the section on automatic setup of DB2 on the Service Nodes during install: [Setting_Up_DB2_as_the_xCAT_DB/#setting-up-the-db2-client-on-the-service-nodes](Setting_Up_DB2_as_the_xCAT_DB/#setting-up-the-db2-client-on-the-service-nodes).

### Configure LoadLeveler DB access nodes

After your xCAT cluster is running with the MySQL or DB2 database, and your xCAT management node or service nodes are set up with ODBC support for LoadLeveler DB access following the instruction above, you can start to configure the xCAT management node or xCAT service nodes as the LoadLeveler DB access nodes.

Generally, all LoadLeveler nodes that have access to the database can be specified as LoadLeveler DB access nodes. While in an xCAT HPC cluster, it is recommended that you set up your xCAT management node as the LoadLeveler DB access node in an xCAT non-hierarchical cluster, and set up your xCAT service nodes as the LoadLeveler DB access nodes in an xCAT hierarchical cluster. If you have a different LoadLeveler DB access node configuration, please see LoadLeveler documentation for more information.

Modify /etc/LoadL.cfg master configuration file on the xCAT management node or xCAT service nodes to add a line:

~~~~
    LoadLDB = xcatdb
~~~~


## Initialize and Configure LoadLeveler

Follow the LoadLeveler instructions to perform the necessary steps to initialize and configure your cluster using the database configuration option. This includes things like properly editting your /etc/LoadL.cfg master configuration file, and determining your LoadLeveler configuration information, and running the llconfig -i command to initialize the database.

Note: By default, the xCAT HPC Integration support will only install the LoadLeveler resmgr rpm on the compute nodes in your cluster. Both the LoadLeveler resmgr and scheduler rpms are installed on your xCAT management node or your xCAT service nodes, so when you run llinit on your xCAT management node or your xCAT service nodes, it will configure the default LoadL_admin and LoadL_config files to reference these. You will need to modify the BIN and NEGOTIATOR values in the LoadL_config file to correctly work for all the compute nodes in your cluster. If you are running with the LoadLeveler database configuration option,use the llconfig -c command to change these values:
On Linux:

~~~~
      BIN    = /opt/ibmll/LoadL/resmgr/full/bin/
      NEGOTIATOR=/opt/ibmll/LoadL/scheduler/full/bin/LoadL_negotiator
~~~~


On AIX:

~~~~
      BIN    = /usr/lpp/LoadL/resmgr/full/bin/
      NEGOTIATOR=/usr/lpp/LoadL/scheduler/full/bin/LoadL_negotiator
~~~~


After you have made any needed updates, initialize the LoadLeveler database configuration:

~~~~
    llconfig -i -t <your cluster config file> -f <LoadL_config file you have edited>
~~~~


Note: After llconfig -i is executed on the xCAT management node to initialize the LL database, it creates /install/postscripts/llserver.sh and /install/postscripts/llcompute.sh postscripts and the /install/postscripts/LoadL directory with files used by these scripts. You can use these postscripts via the xCAT postscript process to configure the selected nodes as the LoadLeveler database server nodes or compute nodes when running LoadLeveler with the database option. Please see the descriptions in llserver.sh and llcompute.sh for details.

To configure the LoadLeveler database server nodes, specify the llserver.sh as xCAT postbootscripts. For example:


To run during service node installs:

~~~~
     chdef <loadl db servers> -p postbootscripts=llserver.sh
~~~~

To run immediately on a service node that is already installed:

~~~~
     updatenode <loadl db servers> -P llserver.sh
~~~~


To configure the LoadLeveler compute nodes, specify the llcompute.sh as xCAT postbootscripts. For example:

To run during compute node installs or diskless boot:

~~~~
     chdef <loadl compute nodes> -p postbootscripts=llcompute.sh

~~~~

To run immediately on a compute node that is already installed:

~~~~
     updatenode <loadl compute nodes> -P llcompute.sh

~~~~




Note: When using service nodes make sure the postscripts and the LoadL subdirectory are copied to the /install/postscripts directories on each service node before the updatenode command is issued.
For example:

~~~~
         xdcp service -v -R /install/postscripts/* /install/postscripts
~~~~



