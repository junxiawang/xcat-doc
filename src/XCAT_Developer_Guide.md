<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [xCAT Architecture](#xcat-architecture)
- [Contributor and Maintainer Agreements](#contributor-and-maintainer-agreements)
  - [Contributors](#contributors)
  - [Maintainers](#maintainers)
- [Code Contribution Quick Checklist](#code-contribution-quick-checklist)
- [Developing xCAT Code](#developing-xcat-code)
  - [**Client/Server Model**](#clientserver-model)
    - [**Client code**](#client-code)
    - [**Server code (plugins)**](#server-code-plugins)
    - [**Debugging**](#debugging)
  - [**Hierarchy**](#hierarchy)
  - [**Calling Plugins from other Plugins**](#calling-plugins-from-other-plugins)
  - [**Remote Commands (ssh, rsh)**](#remote-commands-ssh-rsh)
  - [**Accessing the database from plugins**](#accessing-the-database-from-plugins)
  - [**Prompting for input from plugin**](#prompting-for-input-from-plugin)
- [Common Perl Libraries for xCAT code](#common-perl-libraries-for-xcat-code)
  - [**General Utilities**](#general-utilities)
- [Adding Tables and running sql commands on the xCAT Database](#adding-tables-and-running-sql-commands-on-the-xcat-database)
  - [runsqlcmd](#runsqlcmd)
  - [Changing Table definitions](#changing-table-definitions)
- [Man Pages](#man-pages)
- [Packaging new Code](#packaging-new-code)
- [Changes to xCAT *.spec files](#changes-to-xcat-spec-files)
- [Building and Releasing xCAT](#building-and-releasing-xcat)
  - [Building xCAT core](#building-xcat-core)
  - [Building xCAT deps](#building-xcat-deps)
  - [Releasing xCAT](#releasing-xcat)
  - [To Create a New GIT Branch](#to-create-a-new-git-branch)
  - [Using SVN ( no longer used by xCAT, replaced by GIT)](#using-svn--no-longer-used-by-xcat-replaced-by-git)
  - [Checkout a GIT tagged release](#checkout-a-git-tagged-release)
  - [Counting Lines of Code Added/Changed in a Release](#counting-lines-of-code-addedchanged-in-a-release)
- [Setting up your GIT development Environment](#setting-up-your-git-development-environment)
  - [Check your code into GIT](#check-your-code-into-git)
  - [Setting up GIT in Eclipse](#setting-up-git-in-eclipse)
  - [Eclipse Wiki Editor](#eclipse-wiki-editor)
  - [**Building xCAT rpms**](#building-xcat-rpms)
  - [Check Source Code in a Release level](#check-source-code-in-a-release-level)
    - [**Check for last revision number in a release level**](#check-for-last-revision-number-in-a-release-level)
    - [**Check out previous revision of a file**](#check-out-previous-revision-of-a-file)
    - [**Checkout a particular revision of a file**](#checkout-a-particular-revision-of-a-file)
    - [**Check for changed file with a revision number**](#check-for-changed-file-with-a-revision-number)
- [xCAT Testing Automation Tool](#xcat-testing-automation-tool)
- [Opening xCAT Defects](#opening-xcat-defects)
  - [PMRs](#pmrs)
- [Providing Patches for xCAT Bugs](#providing-patches-for-xcat-bugs)
- [Testing man pages](#testing-man-pages)
- [Editing xCAT SF home page](#editing-xcat-sf-home-page)
- [Log into SourceForge shell](#log-into-sourceforge-shell)
- [xCAT FRS area on sourceforge](#xcat-frs-area-on-sourceforge)
- [Scanning code for OSSC compliance](#scanning-code-for-ossc-compliance)
  - [Get the CSAR scan tool](#get-the-csar-scan-tool)
  - [Install and setup CSAR](#install-and-setup-csar)
  - [Analyze the results](#analyze-the-results)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


## Introduction

The Developer's Guide intends to give you enough information that you can start writing code for the xCAT project. It's intent is to be a starting point but by no means will provide all the information you need because each new function developed has it's own problems to solve.

Before starting to write code for xCAT, you should join the [xcat mailing list](http://xcat.org/mailman/listinfo/xcat-user) and post your intentions. First this will allow the xCAT architects to evaluate the function to see if it fits into the future plans of xCAT; and also to determine, if the function is already in plan and being developed by someone else.

You should also [create a SourceFourge account](http://sourceforge.net/account/registration/), and send your id to [xcat-user@lists.xcat.org](mailto:xcat-user@lists.xcat.org), requesting to be added to the xCAT sourceforge project.

You may also check the [Wish_List_for_xCAT_2](Wish_List_for_xCAT_2) and the list of [requested features](https://sourceforge.net/tracker/?group_id=208749&atid=1006948) and submit your request there.




## xCAT Architecture

The heart of the xCAT architecture is the xCAT daemon (xcatd) on the management node. This receives requests from the client, validates the requests, and then invokes the operation. Function developed for xCAT should be designed to operate in this environment.

You need to review and understand the [xCAT Architecture ](https://sourceforge.net/p/xcat/wiki/XCAT_2_Architecture/)before developing your commands.

## Contributor and Maintainer Agreements

xCAT 2 is licensed under the [Eclipse Public License](http://www.opensource.org/licenses/eclipse-1.0.php). All contributions to xCAT must be licensed to xCAT pursuant to the referenced [XCAT Contributor License Agreement](XCAT_Contributor_License_Agreement).

### Contributors

We welcome new developers willing to contribute to the xCAT code to make it better. In order to do that, you need to:

  * License your contribution(s) pursuant to the [XCAT Contributor License Agreement](XCAT_Contributor_License_Agreement).
  * Decide if you want to sign the contributor license agreement as an individual or as a coporate. The [XCAT Individual Contributor License Agreement](XCAT_Individual_Contributor_License_Agreement) allows the individual contributor to submit contributions to the xCAT community; the [xCAT Corporate Contributor License Agreement](XCAT_Corporate_Contributor_License_Agreement) allows an entity (the "Corporation") to submit contributions to the xCAT Community.
  * Print the [XCAT Individual Contributor License Agreement](https://sourceforge.net/p/xcat/wiki/XCAT_Developer_Guide/attachment/xCAT%20Individual%20Contributor%20License%20Agreement.pdf) or  [xCAT Corporate Contributor License Agreement](https://sourceforge.net/p/xcat/wiki/XCAT_Developer_Guide/attachment/xCAT%20Corporate%20Contributor%20License%20Agreement.pdf), fill it out and sign it, scan it in, and email it to xcat-legal@lists.sourceforge.net.
  * After submitting the signed license agreement, you can send your code and patches to the xCAT mailing list and request that they be integrated into the xCAT code stream.
  * If you are an experienced xCAT user and plan to contribute to the xCAT code regularly, you can request to become a Maintainer with GIT push access. See the [Maintainers](XCAT_Developer_Guide/#maintainers) section below.
  * Now read the rest of this Developer Guide before writing your code...

### Maintainers

If you are an experienced xCAT user and plan to contribute to the xCAT code regularly, you can request to become an xCAT Maintainer (which includes git push access) by posting to the xCAT mailing list.

If you are approved to become an xCAT maintainer, you must print the agreement [XCAT Maintainer License Agreement](https://sourceforge.net/p/xcat/wiki/XCAT_Developer_Guide/attachment/xCAT%20Project%20Maintainer%20Agreement.pdf), fill it out and sign it, scan it in, and email it to xcat-legal@lists.sourceforge.net .

The roles and responsibilities of the maintainers are:

  * set the direction for the xCAT project, including architectural and design decisions
  * commit code (new function or fixes) to the xCAT GIT repository (either their own code, or on behalf of another contributor - see below)
  * review requests for xCAT members to become maintainers (All such requests will be subject to a vote of current maintainers. Consensus of current maintainers is required for approval.)
  * review and help resolve technical concerns or problems regarding the project

All decisions by the maintainers are made by consensus.

When a maintainer pushes code to the xCAT GIT repository for another contributor (i.e. **not** your own code), they must:

  * Require that each code contributor sign the [XCAT Individual Contributor License Agreement](XCAT_Individual_Contributor_License_Agreement) or  [xCAT Corporate Contributor License Agreement](XCAT_Corporate_Contributor_License_Agreement) and email it to xcat-legal@lists.sourceforge.net .
  * Require that all code be contributed under the EPL.
  * Create a log entry with intellectual property information about the contribution &amp; contributor. Each log entry should contain the information below, and should be posted to xcat-legal@lists.sourceforge.net:

    Maintainer Name:  (the person who committed the code to the xCAT GIT repository)
    Maintainer Sourceforge Id:
    Contributor Name:  (the author of the code)
    Contributor's Organization or Employer (if the contribution was made on the organization's/employer's behalf):
    Contributor Sourceforge Id:
    GIT  Id of This Code PUSH:
    Date Code was Committed:
    Purpose/Description of New/Changed Code:
    Approximate Number of Lines of Code Added/Changed/Removed by This Commit:
    Additional Authors of the Contributed Code:
    License Used (if other than EPL, need approval from the xCAT Maintainers):
    Code Reviewed By (usually the maintainer who commits it):

## Code Contribution Quick Checklist

  * **Changes to common xCAT Perl library routines, and the Database Schema must be reviewed by the xCAT architects.** Examples are changes to any of the existing common Perl library routines in the /.../xcat-core/.../perl-xCAT/xCAT path.
  * **Addition of new xCAT plugins should be reviewed by the xCAT architects.** The new plugin should adhere to the coding guidelines for xCAT plugins using the common utilities provided by xCAT (e.g. xCAT::MsgUtils, etc). See xCATWorld.pm and other plugins for examples.
  * **Packaging and Documentation changes** should be requested via a SourceForge Tracker request.
  * **Comment your code.** A guideline of approximately 1 comment for every 10 lines of code is suggested. Huge block comments are not needed (not even wanted), just the useful info about what the code is doing, that is not immediately obvious from the code itself.
  * **Use good programming practices.** Shouldn't even have to include this one, but:
    * Use Perl, unless there is a specific reason not to
    * Use "use strict" in all files
    * Handle all error cases
    * See [Programming_Tips](Programming_Tips) for more info
  * **Consider all platforms and environments when making your code changes.** xCAT supports many environments, and most users only care about 1 or 2 of those environments. Thus, the tendency is for them to make code changes that work for their environment but may break other environments. Specifically, consider how your code change will function on AIX (if you are a linux xCAT user).
  * **Provide user documentation as part of the commit.** Check in updates to the man pages, cookbooks, etc. Whatever is needed for users to know how to use this feature. If this is a new command, create the man page using pod. See [Documentation_Organization](Documentation_Organization).
  * **Include a detailed comment in the commit command.** This helps the xCAT architects understand what has been checked in and is also used in the changelog of the next release.

## Developing xCAT Code

Code written for xCAT should be in Perl except under the condition that the code will run in environments where Perl may not be installed ( e.g compute nodes), or Perl is not appropriate for the function being developed. Non-use of Perl should be reviewed by the architecture committee. With the many OS's and architectures that xCAT must support, when a language like C or C++ is used, it causes additional packaging work. More rules for code development are listed at [contribution guidelines.](http://xcat.wiki.sourceforge.net/xCAT+2+Contribution+Guildelines)

Recommended good programming practices should be followed as outlined in our [Programming_Tips](Programming_Tips) page. 

### **Client/Server Model**

When developing commands, there will be two major parts to consider: Client code and Service code (plugin).  Review the [Client/Server](https://sourceforge.net/p/xcat/wiki/XCAT_2_Architecture/#clientserver) flow in the xCAT Architecture document.

We have provided a very simple example in the release:  **xCATWorld ** (client code) and **xCATWorld.pm** (plugin).




#### **Client code**

First, you need to develop the client front-end command. Many commands can directly use the two available client front-ends provided: xcatclient or xcatclientnnr. The command can either be a symbolic-link directly to xcatclient/xcatclientnnr, or, a thin wrapper that calls xCAT::Client::submit_request() .

The xcatclient client front end supports commands that require noderange and flags to the new function. The xcatclientnrr client front end supports commands that do not require a noderange. If your command has a more complex interface than is supported by these two routines, you can write your own client front-end. Go to the /opt/xcat/bin directory to see which commands are symbolic-links and which commands are their own clients.

#### **Server code (plugins)**

Next, you will develop your plugin that will support processing the requests from your client front-end. Review the [xcatd Plugins](https://sourceforge.net/p/xcat/wiki/XCAT_2_Architecture/#xcatd-plugins) flow in the xCAT Architecture to see how xcatd processes the plugins.  All xCAT plugins are installed in /opt/xcat/lib/perl/xCAT_plugin directory.

Each Plugin is divided into three major sections:

  1. handled_commands() - returns list of command(s) handled by this plugin. If commands are related we tend to put them in one plugin.
  2. preprocess_request() - Needed if your command supports hierarchy, that is the plugin will be run on a service node to process the compute node.
  3. process_request () - This is where the function of you command is placed.

Implementation note for handled_commands:

For many of the xCAT commands, the same command can be implemented in different plugins and the correct plugin is invoked based on a table value. For example, the rpower command is implemented in the hmc.pm for pSeries nodes, in the blade.pm for blades, and so on.  The correct plugin is invoked based on the value of nodehm:power and nodehm:mgt attributes for that node. This is coded in the plugin as follows:

~~~~
    sub handled_commands {
    return {
    findme => 'blade',
    getmacs => 'nodehm:getmac,mgt',
    rscan => 'nodehm:mgt',
    rpower => 'nodehm:power,mgt',
    getbladecons => 'blade',
    getrvidparms => 'nodehm:mgt',
    rvitals => 'nodehm:mgt',
    rinv => 'nodehm:mgt',
    rbeacon => 'nodehm:mgt',
    rspreset => 'nodehm:mgt',
    rspconfig => 'nodehm:mgt',
    rbootseq => 'nodehm:mgt',
    reventlog => 'nodehm:mgt',
    switchblade => 'nodehm:mgt',
    };
    }
~~~~


When the xCAT daemon loads all of the plugins, it builds an internal table of handled commands. When the same command is listed in more than one plugin, the value for the last plugin that is loaded is the one that the daemon will use. Therefore, ALL plugins must code the identical value for a table-driven command. For example, all plugins that implement the rpower command MUST code the handled_commands entry as

~~~~~
rpower => 'nodehm:power,mgt',
~~~~

If you are coding one of these database-driven commands, you should search all existing plugins for entries that match the command you are coding and use the same value.




#### **Debugging**

**XCATBYPASS MODE**

Debugging your new client/server command through the xcatd can be difficult, so a debug mode has been put in place that bypasses the daemon. This allows you to run the Perl debugger from the client invocation through the plugin.

If the **XCATBYPASS** environment variable is set ( to anything) , the connection to the server/daemon will be bypassed and the plugin will be called directly by Client.pm. If it is set to a directory, all Perl modules in that directory will be loaded in as plugins. This allows you to add or change new xCAT Perl module libraries for test without disrupting other users on the system. If it is set to any other value (e.g. "yes", "default", whatever string you want) the default plugin directory will be used.


**XML Tracing**

XCATXMLTRACE - If this environment variable is set, the XML structure for request and responses for all commands is printed out.

XCATWARNING - If this environment variable is set, a warning is printed when the XML in the structures appears invalid. 

### **Hierarchy**

Commands that are going to be run on the compute nodes, need to support hierarchy, because xCAT can be configured for hierarchy. This means the preprocess_request function in the plugin for the command must be provided. A simple example, is in the **xCATWorld.pm** plugin.




### **Calling Plugins from other Plugins**

If your xCAT client/server command needs to call another xCAT client/server command from your plugin ( e.g. xdsh), you are in the situation that your plugin must call the other commands plugin. You should not call the other xCAT command from the command line from your plugin.

There is a special interface defined in Utils.pm ( runxcmd) for doing this. If it does not support the returns you need from the command you can write your own. See the General Utilities provided by xCAT.

### **Remote Commands (ssh, rsh)**

We desire all the xCAT commands use the same remote shell method to the nodes. The default is **ssh** on both Linux and AIX. 

On AIX, remote shell is determined by the site table attribute "useSSHonAIX". If set to "yes", ssh will be used.  If set to "no", rsh will be used.  This attribute is needed on AIX because OpenSSH, historically, has not been the default remote shell method on AIX, and in older versions of the OS, was not shipped with AIX.

If you are developing commands that will use remote shell, you may want to discuss this with the xCAT architects. One way to always use the appropriate remote shell is to not call ssh or rsh ( scp/rcp) directly but to use xdsh and xdcp- api or plugin ( for hierarchy support) which will check the remote shell setup for xCAT and use the appropriate remote shell.

### **Accessing the database from plugins**

The xCAT command plugins should always access the database through the Table.pm routines. These routines are optimized for performance and scale and allow the routines to be immune to what database is currently being used.

### **Prompting for input from plugin**

Today, the plugins have no capability of prompting for, or accepting, input from the admin.  Any input from the admin must be accepted in the client front-end which usually means you must write your own client front-end and not use the two available common clients (xcatclient, xcatclientnnr). To handle the prompting from scripts, you should use the Perl Expect function. There are many samples of using Perl Expect in the current plugins and routines like mysqlsetup.

## Common Perl Libraries for xCAT code

### **General Utilities**

There are a many of xCAT Perl libraries available that contain utility functions that we have found useful to share across the xCAT code. Here are some of the more useful ones. You should always first look in the xCAT Perl library (/opt/xcat/lib/perl/xcat) to see if functions already exists before writing your own.




  * Utils.pm - Contains a large number of Utilities. Some of the more commonly used are the following:
  1.     1. isLinux
    2. isAIX
    3. isMN
    4. isServiceNode
    5. Version
    6. runcmd
    7. runxcmd
  * DbobjUtils.pm - A set of Utilities that handle xCAT data objects at a more abstract level. They are used by commands like lsdef which will access many database tables to return all the information for a node.
  * NodeRange.pm - Routines to figure out the list of node based on an input group or noderange.
  * MsgUtils.pm - Contains the messaging, logging interface for xCAT. All message should use these utilities. This ensure that the message do work in a client/server and hierarchical architecture. It also records messages to syslog appopriately for xCAT. You can see many examples in the existing code.
  * Table.pm - all the xCAT database access routines. These routines use a Perl DBI to access the database that xCAT is currently running. All accesses to the xCAT database should be through one of these routines. This ensures that your code will support all the databases supported by xCAT ( e.g. SQLite, MySQL, PostgreSQL, etc), and be unaware of what database we are using. If new routines are needed, the need should be submitted as a feature request. Changes to the existing routines must be done by the xCAT core development team to ensure existing code is not broken.
  * Client.pm - this routine is the primary interface from your command to the xcatd daemon. No changes should be made without careful review with the xCAT architects.
  * Schema.pm - Database Schema. Any change or addition requests to that Schema must be submitted to the xCAT architects. Currently in plan, is designing a way for individuals to extend the schema and not affect the basic schema everyone uses.

## Adding Tables and running sql commands on the xCAT Database

You can extend the xCAT database schema with your tables. XCAT will automatically add your tables on the restart of the xcatd daemon. On your installed system, open the file&nbsp;:

    /opt/xcat/lib/perl/xCAT_schema/samples/Sample.pm


and read the comments at the top. It explains how to add your tables. You must always include as the last two attributes (comments and disable). The disable attribute is required for the xCAT commands to work on the tables, even if you do not support disable.

**Note: make all tables and attributes lower case. No case sensitivity is supported.**

To read online select this link: [http://sourceforge.net/p/xcat/xcat-co.../Sample.pm](http://sourceforge.net/p/xcat/xcat-core/ci/master/tree/xCAT-server/lib/xcat/schema/samples/Sample.pm)


You can check to make sure your table syntax is correct, before starting the daemon, by:

~~~~
    export XCATBYPASS=y
    tabdump <yourtable>
~~~~


As of Release 2.5 or later, the following additional support has been added to XCAT.

A Customer may want to run sql scripts after the database tables are created for additional setup such as adding "views", "stored procedures", alter the table to add foreign keys, etc. xCAT provides a way for those sql script to be run against the current database using the new runsqlcmd. See man page.

Because the databases that xCAT support (SQLite, MySQL, PostgreSQL, DB2) are not consistent with the SQL and datatypes they support, we now support the Table Schema and SQL scripts to be created for a particular database.


The Table schema, and SQL scripts are added to the /opt/xcat/lib/perl/xCAT_schema directory by the Customer. xCAT will read all the *.pm files first and create the tables and then read all the *.sql files.

This is done each time xcatd is restarted. If you want the *.sql files to be run only once, then you can put the files in another directory and use the runsqlcmd to run them. See man page.

The following naming conventions will be followed for both the *.pm and *.sql files.

1\. &lt;name&gt;_&lt;database&gt;.pm for Table Schema

2\. &lt;name&gt;_&lt;database&gt;.sql for all SQL script (create stored procedure, views,alter table, etc) For runsqlcmd, see below.

where &lt;database&gt; is

"mysql" for MySQL (foo_mysql.pm)

"pgsql" for PostgreSQL (foo_pgsql.pm)

"db2" for db2 (foo_db2.pm)

"sqlite" for SQLite (foo_sqlite.pm)

do not put in the database, if the file will work for all databases. (foo.pm)

Files should be created owned by root with permission 0755.

Each time the xcatd daemon is started on the Management Node, it will read all the *.pm files for the database it is currently using and all the *.pm files that work for all databases and create the tables in the database. It will then run the runsqlcmd script to add database updates.

xCAT is providing a script runsqlcmd (/opt/xcat/sbin) that will read all the *.sql files for the database it is currently using and all the *.sql files that work for all the databases and run the sql scripts. This script can be run from an rpm post process, or on the command line.

The Customer *.pm and *.sql files should have no order dependency. If an order is needed, then you can use the &lt;name&gt; of the file to determine the order as it will appear in a listed directory. For example you could name them (CNM1.sql , CNM2.sql) then when the directory is listed CNM1.pm would get processed before CNM2. The Customer should code the *.sql files such that they can be run multiple times without error.

To have the database setup at the end of the Customers application install, the post processing of the rpm should reload xcatd.

On AIX: restartxcatd -r

On Linux: service xcatd reload

### runsqlcmd

runsqlcmd will by default run all *.sql files, appropriate for the database, from the /opt/xcat/lib/perl/xCAT_schema directory. The SQLite database is not supported. DB2, MySQL and PostgreSQL are supported on AIX and Linux. As an option, you can input the directory you want to use, or the list of filenames that you want to run. runsqlcmd will check that the filenames are appropriate for the database. Wild cards may be used for filenames, CNM* for example. The file names must follow the same naming convention as defined above, except SQLite is not supported.


More detail design information can be found at:

[Support_xcatd_running_user_defined_sql_scripts_on_start_and_foreign_keys](Support_xcatd_running_user_defined_sql_scripts_on_start_and_foreign_keys)



### Changing Table definitions

  * Attributes ( columns) can be added to tables at any time, but we please keep the last two attributes ( comments, disable) at the end so that we have some consistency in appearance in the tables when we use some of our commands like tabdump. Also, disable is a required attribute in every table, and comments should be there also.
  * Non-Key attributes can be deleted, but they will only not show up in the schema and will not be recognized by xCAT commands. The attribute is not actually deleted from the database.
  * Add key attribute- **You may not add a new key to a table that is a new attribute**. The only database that could handle the change is SQLite which allows null keys. MySQL, PostgreSQL and DB2 do not allow null keys. If you have an existing attribute that is not null, you can change that into a key. To add a new key that is a new attribute would cause any restores saved by the admin to fail from a previous version. The add key processing will also fail, since it tries to restore from a backup during the add key when the new key is an existing attribute.
  * Delete/rename a key - not allowed. If you want to do that we will have to drop the table definition and recreate the table. Right now that would be a manual task by the admin.
  * Tables that grow in row definition, such that they need a new tablespace for DB2; xCAT will take care of the move. New tables defined with many attributes must also indicate what tablespace in DB2 ti create the table.

## Man Pages

[Writing_Man_Pages](Writing_Man_Pages)

## Packaging new Code

In most cases it will be obvious where your client code will be checked into GIT ( the xCAT-client path) and the plugin code ( the xCAT-Server path) , but it would be good to review with the xCAT architects any new code that will be packaged with the xCAT code. For the most part, putting the code in the appropriate directory in GIT will automatically have it packaged with xCAT when it is built.




## Changes to xCAT *.spec files

All changes to the xCAT *.spec files should be done by the core xCAT team. Submit any change requests through a feature or directly to the team on the xCAT mailing list.




## Building and Releasing xCAT

### Building xCAT core

The core xCAT RPMs are built and uploaded to sourceforge using the buildcore.sh script, which is in the toplevel of the xCAT GIT repository. The comments at the beginning of [buildcore.sh](https://http://sourceforge.net/p/xcat/xcat-core/ci/master/tree/buildcore.sh) summarize the requirements that the build machine must have to be able to run the build, and they also describe all of the options that can be passed to the script. The xcat build machines for linux (RHEL/SLES), ubuntu, and aix have the following .bashrc/.kshrc aliases and functions defined to make it easier to run the correct buildcore.sh script:

  * buildxcat - builds the devel (trunk/git master) of xcat
  * buildxcat27 - builds the 2.7 branch of xcat
  * buildxcat26 - builds the 2.6 branch of xcat
  * buildxcat28 BUILDALL=1 - forces the build of all rpms in the 2.8 branch of xcat.

The following options can be used with the above aliases/functions, or when running buildcore.sh directly:

  * Building a snap version of the trunk or a branch - this is the default, don't use any options
  * Building a more stable version of the trunk - do this when you want a trunk build that won't be overlayed by a snap build, so we have time to fvt it and give it to system test: first do a snap build (see above), then build again with PROMOTE=1 . (This bullet is for the trunk only. For a branch, see the next bullet.)
  * Building a GA candidate build of a branch - build a snap build with BUILDALL=1, then build again, using options PROMOTE=1 and PREGA=1 . This will put the built tarball in https://sourceforge.net/projects/xcat/files/yum/ or https://sourceforge.net/projects/xcat/files/aix/ , which is not one of the locations that our download page points to, but also won't be overlayed by a branch snap build. This gives us a chance to test it before releasing it.
  * Releasing a GA candidate build of a branch - after the above step is done and tests out ok, then build again with just the PROMOTE=1 option.

  * When you run buildxcat, a special script db2man runs to create the database man page. http://xcat.sourceforge.net/man5/xcatdb.5.html.  All man pages on the web reflect the master branch and are built when you run buildxcat. 

### Building xCAT deps

The dependency packages are packaged together into the xcat-dep tarball and uploaded to sourceforge by the builddep.sh script. Note that this doesn't actually build each individual RPM (that must be done separately, by hand). It simply tars up the RPMS and uploads it to sourceforge. On the xcat build machines, there is an alias called **builddep** for your convenience.

On AIX, if you need to change the instoss (generated from builddep.sh) or instxcat (generated from buildcore.sh) scripts. You will first need to checkin the new builddep.sh or buildcore.sh script to the trunk and run a development build (buildxcat) to put the scripts on the build machine. Then you can run builddep and it will pick up the new instoss and/or instxcat script in the package.

### Releasing xCAT

Here's a checklist of what should be done for each new release of xCAT, for example a **major release** like 2.8 or a **dot release** like 2.8.4:

  * Promote the current build:
    * on the linux, ubuntu (2.8 or later), and aix build machines run: buildxcat28 PROMOTE=1
  * Make sure the [Release_Notes](Release_Notes) are up to date, and remove the note that this isn't released yet.
  * Edit the relevant wiki pages (Note: the [xcat web site](http://xcat.sourceforge.net/) pages are being phased out):
    * In [Download_xCAT](Download_xCAT):
      * In the first section (the stable release) update the links to the linux, ubuntu, and aix core tarballs to point to the new tarballs in the [File Manager](https://sourceforge.net/projects/xcat/files). (The new core tarballs are put there during a build promotion.) To get the proper URLs for your links, go to the [File Manager](https://sourceforge.net/projects/xcat/files/xcat/) and navigate to the proper tarballs and copy the link. While you are in the File Manager, when you find the appropriate linux core tarball, select the "i" icon, and set it as the default download for all
      * If this is a major release, change the release in the first 2 sections (Stable and Snapshot) in all of the urls to the new release #.
      * If this is a major release, change the links in the Development Builds section to point to the git master. (They were probably temporarily pointing to the new branch that was recently created for this release.)
    * In the [Main_Page](Main_Page) add an announcement in the News section for this release.
  * This must be edited and fixed when we release 2.9, first major git release.
    * If this is a major release, change the "stable" sym link in https://sourceforge.net/projects/xcat/files/yum/, https://sourceforge.net/projects/xcat/files/ubuntu/, and https://sourceforge.net/projects/xcat/files/aix/ to point to the 2.4 subdir. Easiest way to create the sym links is to ssh to SF:
    * ssh -t &lt;your-SF-id&gt;,xcat@shell.sf.net create # this takes a while to start
    * Once logged in, cd to /home/frs/project/x/xc/xcat/. The linux files are under the yum subdir, the ubuntu files are under the ubuntu subdir, and the aix files under the aix subdir.
  * Tag the release in GIT - for example, run from any machine that has git access:
    * git checkout 2.8
    * git tag -a 2.8.4 -m 'xCAT 2.8.4 release'
    * git push --tags
    * git ls-remote --tags ./. # list tags in remote repo
  * On the xCAT linux build machine, run builddoc (which will run getxcatdocs and upload the tarball to http://sourceforge.net/projects/xcat/files/doc ). 
    NOTE:  With the change to Sourceforge Allura wiki, getxcatdocs now requires pandoc and latex to be installed on the build machine.  See:  [Editing_and_Downloading_xCAT_Documentation/#converting-wiki-pages-to-html-and-pdfs](Editing_and_Downloading_xCAT_Documentation/#converting-wiki-pages-to-html-and-pdfs)
    If getxcatdocs fails during doc downloads, you can restart it with the -c or --continue flag:

~~~~
  /xcat2/build/xcat-core/src/xcat-core/xCAT-client/bin/getxcatdocs --continue --upload /xcat2/build/doc
~~~~

  * Create a pcm service branch (if necessary)
  * Post an email to the mailing list about the release
  * Update the Version file:
    * In the ../xcat-core/Version file, put in the next version number.
    * if dot release: change branch to next dot release, for example 2.8.5
    * if major release: change to next major version, for example 2.9.
    * commit this new Version file and push to git

### To Create a New GIT Branch

Using Git:

These instructions are untested: A new branch is usually created about a month before a release, so that only bug fixes will be committed to that branch from then on. To create a new branch (for example 2.8.5-pcm) from the 2.8.4 branch:

There are instructions in https://w3-connections.ibm.com/wikis/home?lang=en#!/wiki/xCAT/page/git%20Quick%20Reference%20for%20xCAT%20Team Quick Reference for xCAT Team to create a new branch in git on SF. See **"Create a new branch on sourceforge (most of you will not have to do this)."**

  * Need to create a new directory on the build machines(in this (pcmcase) only Linux)
    * mkdir -p /root/build/xcat-core/2.8.5-pcm
    * cd /root/build/xcat-core/src/xcat-core
    * git fetch origin
    * git checkout -b 2.8.5-pcm origin/2.8.5-pcm
    * create a buildxcat284pcm alias in ~/.bashrc
    * run buildxcat284pcm BUILDALL=1
  * If new xCAT release, for example 2.9 from 2.8.4, you would also need to update the AIX build machine.
    * mkdir -p /build/xcat-core/2.9
    * cd build/xcat-core/src/xcat-core
    * git fetch origin
    * git checkout -b 2.8.9 origin/2.8.4
    * create a buildxcat29 alias in ~/.kshrc
    * run buildxcat29 BUILDALL=1
  * In [Download_xCAT](Download_xCAT), change the links in the Development Builds section to point to the new branch, if needed (until GA)


###Using SVN ( no longer used by xCAT, replaced by GIT)

TODO: replace with GIT process

A new branch is usually created about a month before a release, so that only bug fixes will be committed to that branch from then on. To create a new branch (for example 2.7) from the trunk:

  * EDITOR=vi SVN copy https://svn.code.sf.net/p/xcat/code/xcat-core/trunk https://svn.code.sf.net/p/xcat/code/xcat-core/branches/2.7
    * when it brings up vi editing a tmp file, delete only the comment line, and save the file
  * (To get your own local repository of the new branch, in Eclipse in SVN Repository Exploring, right click on new branch and choose Checkout. Or from the CLI, from just above where you want the branch directory to land, run: svn co https://svn.code.sf.net/p/xcat/code/xcat-core/branches/2.7)
  * On linux, ubuntu, and aix build machines:
    * cd to top of build dir
    * mkdir -p 2.7/src/xcat-core
    * cd 2.7/src
    * svn co https://svn.code.sf.net/p/xcat/code/xcat-core/branches/2.7 xcat-core
    * cd to top of build dir and: cp devel/src/svnup-all 2.7/src
    * create buildxcat27 alias in ~/.bashrc or ~/.kshrc
    * cd to 2.7/src/xcat-core and: buildxcat27 BUILDALL=1
    * change Version in trunk to 2.8
    * cd to devel/src/xcat-core
    * svn up Version
    * buildxcat BUILDALL=1
  * In [Download_xCAT](Download_xCAT), change the links in the Development Builds section to point to the new branch (until GA).

### Checkout a GIT tagged release

~~~~
    git tag
     2.7.8
     2.8.3


    git show 2.8.3
     warning: refname '2.8.3' is ambiguous.
     tag 2.8.3
     Tagger: Bruce Potter <bp@us.ibm.com>
     Date:   Fri Nov 15 14:38:38 2013 -0500
     xCAT 2.8.3 release
     commit ccb66ff79365e38a818ae6e64b7dc1499bd8afb1
     Merge: cfb4a4c 92692d6
     Author: Jarrod Johnson <jbjohnso@us.ibm.com>
     Date:   Thu Nov 14 15:53:46 2013 -0500
       Merge branch '2.8' of ssh://git.code.sf.net/p/xcat/xcat-core into 2.8
~~~~

Now checkout the 2.8.3 tag and create a new 2.8.3 branch with the code:

~~~~
    git checkout -b 2.8.3 ccb66ff79365e38a818ae6e64b7dc1499bd8afb1
~~~~

### Counting Lines of Code Added/Changed in a Release

To get a **rough** count of the lines of code added or changed in a release:

TODO:  Put in information for GIT

For SVN ( no longer used):

  * cd to the top level of the trunk repository (on any machine)
  * Run: svn diff -r 7511:HEAD | egrep '^\\+' | wc -l # this will take a while
    * Where 7511 is the 1st revision number for this release. Get that number by running "svn log Version" and noting the revision number for when the version was changed to the one you are interested in.
  * Reduce the number by 10% or whatever you estimate is the number of comments and file names

## Setting up your GIT development Environment

Configure git on your machine:

~~~~
    git config --global user.name "Your Name Comes Here"
    git config --global user.email you@yourdomain.example.com
    git config --global alias.co checkout                 #set checkout's alias to co
    git config --global core.editor vim
    git config --list                                                       #list current git config
~~~~

Create a local git repo from sourceforge (only gets the master branch)

~~~~
    git clone ssh://<sf-userid>@git.code.sf.net/p/xcat/xcat-core xcat-core
~~~~

(replace &lt;sf-userid&gt; with your sourceforge userid)

Show all remote branches:

~~~~
     git branch -r
~~~~

To get the other branches, cd into local repo, then:

~~~~
    git fetch origin

    git checkout -b 2.8 origin/2.8

    git checkout -b master origin/master
~~~~


To remove a local branch.  Note you cannot be in that branch to remove it.

~~~~
    git branch -d 2.8.4
~~~~

Show all local branches (* indicates current one):

~~~~
    git branch
~~~~

Switch current branch:

~~~~
    git checkout 2.8

    git checkout master     # switch back to trunk
~~~~

Get latest code updates from sourceforge and merge them into your local repo:

~~~~
    git pull
~~~~

Show files you have changed locally:

~~~~
    git status
~~~~

Show the changes you have made to the files:

~~~~
    git diff
~~~~

See a history of changes:

~~~~
    git log
~~~~

If you want to discard one or more files that you've changed locally (but haven't committed yet):

~~~~
    git checkout -- <file> <file> ...
~~~~

Commit files you have created or changed into your local repo:

~~~~
    git commit -a

    git commit -a -m "your comments"
~~~~

Remove file:

~~~~
    git rm <file>
    git commit -a
~~~~

###Check your code into GIT
Push your committed changes from your local repo to sourceforge:

The correct order for checking code in, that will avoid the "rejected" msgs when you try to push is:

~~~~
        git pull in all branches you have in your local repo

        edit your files (or copy them from your test system) in 1 branch

        git commit -a    # in that same branch - this allows you to switch to other branches
~~~~

in the rest of the branches that you want this code change in:  either cherry-pick the change into each branch (see the bullet on cherry-pick below - this does the equivalent of both edit and commit), or manually edit the files and commit

git pull again in all branches you have in your local repo - in case there were changes by others while you were doing steps 2-4 above.  If there were changes, git pull will usually automatically merge them with your committed changes.  If there is a merge problem, git will let you know.

~~~~
        git push        # this will push changes in all branches
~~~~

If you only want to work with 1 branch right now, you can do the above process for just a single branch and then push for just that branch:  git push origin <branch>

If the remote files were changed by someone else while you were changing the files in the local repo, you will get a conflict error. Use the following commands to resolve this:

~~~~
        git fetch origin master

        git rebase origin/master
~~~~

Show the remote origin of a local repo:

    git remote show origin

Show  and checkout tagged releases

~~~~
    git tag      (lists tagged release)

    git show 2.8.3    (shows details including the git id of the tag)

     git checkout -b 2.8.3 ccb66ff79365e38a818ae6e64b7dc1499bd8afb1   ( this is the id that was from the git show 2.8.3)

~~~~

Create a new branch on sourceforge (most of you will not have to do this):

~~~~
    git checkout -b 2.8.2-pcm      # create the new branch in your local repo

    git push -u origin 2.8.2-pcm     # push the new branch to SF and have your local branch track it
~~~~

To merge a change from one branch to another, use git cherry picking: http://technosophos.com/content/git-cherry-picking-move-small-code-patches-across-branches

~~~~
    git commit -a -m 'commit message...'           # commit you changes in the 1st branch

    git log -1                # see what the commit id was of you last commit

    git checkout <branch2>            # switch to the other branch that should have the same change

    git cherry-pick <commit-id>         # commit the change in this branch

    git push                 # push your changes to sourceforge
~~~~

Show changed files based on commit number:

~~~~
    git show d5609b9ca85ef4f67015ea6aee2682e77e4ce3ce

    git diff-tree --no-commit-id --name-only -r d5609b9ca85ef4f67015ea6aee2682e77e4ce3ce

    git show --pretty="format:" --name-only d5609b9ca85ef4f67015ea6aee2682e77e4ce3ce
~~~~

Compare a file from 2 different branches:

~~~~
    git diff <branch1>:<file>  <branch2>:<file>

    git diff <branch1>  <branch2>  -- <file>
~~~~

Copy a file from another branch into the current branch:

~~~~
    git checkout <otherbranch> -- <file>
~~~~

Search the git commit history:

~~~~
    git log -S "keywords to search" ./path/to/file
~~~~

List lines of file with last changed userid, cd to directory containing the file:

~~~~
    git blame <filename>
~~~~

Show history of the file changes

~~~~
    git log -- <filename>
~~~~

Creating and applying patches in git

    http://ariejan.net/2009/10/26/how-to-create-and-apply-a-patch-with-git/

To delete all local changes (committed or not) done in your current local branch and get your local branch back to what is in the remote repo:

~~~~
    git clean -fd          # remove unstaged files that are not already files in git

    git checkout -- .    # (notice the dot at the end) overwrite local unstaged changes with the version of each file in the remote repo

    git reset --hard     # delete local commits and revert files back to the version in the remote repo
~~~~

Move a svn repo to git (you should never have to do this, but i'm putting here what i did to convert xcat-dep just for reference):

    (for the 1st 3 steps below, see https://github.com/nirvdrum/svn2git#readme)

    install pkgs:  git-svn ruby rubygems

    install svn2git using gems: sudo gem install svn2git

    make a dir for xcat-dep and cd into it

    clone from the svn SF repo:  svn2git http://svn.code.sf.net/p/xcat/code/xcat-dep --trunk trunk --nobranches --notags

    create an empty git repo for xcat-dep (using the SF web interface)

    configure the local repo to push to the SF git repo:  git remote add origin ssh://<yourSFid>@git.code.sf.net/p/xcat/xcat-dep

    configure the local repo to push the master branch to SF and start tracking that branch:  git push -u origin master


### Setting up GIT in Eclipse

Downloading Eclipse IDE Eclipse is an open source project that you can download from http://www.eclipse.org Choose Download Eclipse. Then select Download now: Eclipse SDK 3.2.2, download the zip file eclipse-SDK-3.2.2-win32.zip, and extract.

Installing GIT into Eclipse

Follow this tutorial: http://www.vogella.com/articles/EGit/article.html




### Eclipse Wiki Editor

There's also a Wiki editor plug-in for Eclipse (I'm not sure how useful it is). It can be installed using the same procedure outlined above. Enter http://www.stateofflow.com/UpdateSite for New Remote Site under Help Software Updates | Find and Install... | Search for new features to Install.

TODO: Is there something for GIT

&lt;s&gt;Tortoise Tortoise is not an Eclipse plug-in. After you install it, it integrates with Explorer and allows you to perform SVN operations (commit, update, merge, etc.) directly from Windows Explorer. The Tortoise homepage can be found at: http://tortoisesvn.tigris.org. You can download version 1.4.3 from http://tortoisesvn.net/downloads.&lt;/s&gt;

### **Building xCAT rpms**

TODO: Describe how to build rpms locally.

To get the latest level of the xCAT code and build the rpms on your machine:



### Check Source Code in a Release level


For GIT:  See Check your code into GIT.

Leave SVN info in, for reference for a while. Put in equivalent git info. TODO: Any changes for GIT other than the directory To see all the tagged releases&nbsp;: https://svn.code.sf.net/p/xcat/code/xcat-core/tags

#### **Check for last revision number in a release level**

TODO: What do we do for GIT

On a machine with SVN installed, to see the highest revision number in the release, this command will give you the last 5:

~~~~
    svn log -l 5 https://svn.code.sf.net/p/xcat/code/xcat-core/tags/release-2.7.7
~~~~

#### **Check out previous revision of a file**

ToDO: Add info for GIT

Note: SVN is no longer support by xCAT.  It now uses GIT.

For SVN: Sometimes you want to check out the previous revision of a file to compare or even to restore to that level. The following command will do this. You can then check in this level as you do normally. Go to the directory in your SVN workspace containing the file and run the following command:

~~~~
    svn update -r PREV Utils.pm
~~~~

#### **Checkout a particular revision of a file**

ToDO: Add Git info

Note: SVN is no longer support by xCAT.  It now uses GIT.

For SVN:

~~~~
    svn up -r &lt;revisionnumber> Utils.pm
~~~~

#### **Check for changed file with a revision number**

TODO: What do we do for GIT

Note: SVN is no longer support by xCAT.  It now uses GIT.

For SVN

To find out what files are changed, given a revision number. Go to your SVN workspace and run the following command.

~~~~
    svn diff -c <revision number>
~~~~

## xCAT Testing Automation Tool

xCAT provides a testing automation tool in the rpm xCAT-test. This is useful if you are making code modifications to xCAT and want test xCAT after changes. The xCAT-test RPM is included in the xcat-core tarball, but will not be installed by default. You must explicitly installed it on the management node. Below is a quick start for using the test framework. See the [xcattest man page](https://sourceforge.net/p/xcat/xcat-core/ci/master/tree/man1/xcattest.1.html) for complete details.

Quick start:

1\. Install xCAT-test:

    #rpm -ivh xCAT-test-2.7.5-snap201210082313.noarch.rpm
    # You can find man page
    man xcattest
    # You can have a first try:
    xcattest -c lsdef
    # You can find results in directory:/opt/xcat/share/xcat/tools/autotest/result


2\. Customize your own configuration file:

  * If there is a file called default.conf in /opt/xcat/share/xcat/tools/autotest, xcat-test will use that automatically. You can also use -f to use your own configuration file.
  * There are template configuration files in /opt/xcat/share/xcat/tools/autotest.
  * If you have definitions in the db for networks, CN nodes etc, it is not necessary to write all of them into default.conf.
  * If you want to run existing test cases that are in /opt/xcat/share/xcat/tools/autotest/testcase, you need to add MN, CN, and ISO like this (substituting your own values):

    \[System\]
    MN=p7hv16s32p05
    CN=ngpcmm01node09
    ISO=/iso/RHEL6.2-20111117.0-Server-ppc64-DVD1.iso


3\. Create your own test cases:

All the test cases shipped with xCAT are in /opt/xcat/share/xcat/tools/autotest/testcase. They are used for ppc64 redhat and aix; You can add your own specific test cases. (You can find more details in the [man page](http://xcat.sourceforge.net/man1/xcattest.1.html).

  * If you want to add test cases for a new command, for example lsdef, execute:

~~~~
    mkdir -p /opt/xcat/share/xcat/tools/autotest/testcase/lsdef
~~~~

  * Add new test case:

~~~~
    cd /opt/xcat/share/xcat/tools/autotest/testcase/lsdef
    vi cases0
~~~~

  * Add the following content for test case lsdef_test:

~~~~
    start:lsdef_test
    cmd:lsdef
    check:rc==0
    end
~~~~

  * execute all test cases for command lsdef:

~~~~
    xcattest -c lsdef
~~~~

  * execute test case lsdef_test

~~~~
    xcattest -t lsdef_test
~~~~

  * create your bundle file and add lsdef_test into it:

~~~~
    cd /opt/xcat/share/xcat/tools/autotest/bundle
    echo "lsdef_test" >> lsdef.bundle
~~~~

  * run all the test cases in the bundle list

~~~~
    xcattest -b lsdef.bundle
~~~~

## Opening xCAT Defects

xCAT bugs are opened in the Source Forge at https://sourceforge.net/p/xcat/bugs/. 

When you create an xCAT defect in SF, you need to fill in the following fields.

* Title
  Give a short description of the problem
* Assign to someone on the list,  if in doubt assign to Guang Cheng Li. Do not leave unassigned.
* Pick a component from the component field. For example updatenode.  We can add more if you thing we need more.
  Add additional component information in the label filed. Such as  sync files.
* Pick release level carefully, where do you want it fixed.  Next PTR ( such as 2.8.6) or can it wait until next major release  ( such as 2.9).
* In the field for adding details. put in level of xCAT (lsxcatd -a),  OS, and a detailed description of the problem. Any output is very useful.   Many times an lsdef of the node that is having problems, like installing is useful.  Document where it needs to be fix. Next PTF 2.8.6, PCM release 2.8.5-pcm, Next major release 2.9, Lenovo release 2.8.5.1.  
* Never put sensitive data in the defects.  No valid external ip addresses, passwords, etc.  These defect are world readable. 


### PMRs
When an xCAT PMR comes into service,  the service team is suppose to track a valid PMR with an xCAT SF defect.  If it is a PMR some special information is entered.

* The Component Field should be PMR.   
* The PMR # should be in the Title Field.
* The customer name should not be in the defect,  but you can put an alias for the customer.
* The first name of the service rep should be in the defect.
* As much content of the PMR description as appropriate should be in the defect. 
* The PMR defect can only be closed when the customer closes the PMR.
* Many times we like to mark these are private, only people with valid SF id's that can login can see.
* In any case never put customer sensitive data in the defect.  




## Providing Patches for xCAT Bugs

When we have a fix that we want to attach to a SF bug, instead of attaching the whole file, you should attach a patch file. A patch file is essentially a diff file which will fix the customers original file. There are 3 **advantages** of giving the customer a patch versus a full file replacement:

  * 2 patches to the same file (in 2 different SF bugs) can usually be applied to the customers file successfully, as long as the fixed lines don't overlap. (With full files, one file will wipe out the fix in the other file, depending on the order in which they get them.)
  * if 2 patches to the same file do overlap, the patch command will tell the user and not apply the patch. In this rare case, we will have to give the customer specific instructions of what to do, but at least it brings to their attention and ours that some speciall attention is needed.
  * the patch can include the full path of the patched file, so the customer doesn't have to worry about where the file should be placed.

To create the patch for one file:

  * if you are on a real mgmt node, cd to the dir that the file is in that needs fixing (usually somewhere under /opt/xcat). If you are not on a real MN, you need to pretend you are by moving the file to be patched to the real path (for example, /opt/xcat/lib/perl/xCAT_plugin).
  * copy the file to &lt;filename&gt;.new and fix the .new file
  * create the patch with:

~~~~
    diff -u /full-path-of-orig-file  /full-path-of-new-file  >short-file-name.patch
~~~~

  * an example of creating the patch for the hello world plugin:

~~~~
    diff -u /opt/xcat/lib/perl/xCAT_plugin/xCATWorld.pm /opt/xcat/lib/perl/xCAT_plugin/xCATWorld.pm.new >xCATWorld.pm.patch
~~~~

To add patches to for **additional** files into the same patch file, repeat the steps above, except use "&gt;&gt;" instead of "&gt;" to append the patch to the patch file.

To create a patch file for **many files** in the same directory:

  * get on a real MN or create the equivalent path
  * copy the directory to &lt;dir&gt;.new and files the files in &lt;dir&gt;.new
  * run:

~~~~
    diff -ruN <old-dir> <new-dir>
~~~~

The the instructions for the customer to **apply** the patch are:

  * save the file on the xcat MN and run:

~~~~
    patch -b -p0 <filename.patch
~~~~

     Note: this patch command works on both linux and in some cases AIX. More complex patches have been known to fail using patch on AIX. The team will only provide patches on AIX when they have been verified. In other cases files or emgr efixes will be provided.

Patch files can actually contain patches for multiple files, but i couldn't figure out how to create them with diff, unless all of the files are in the same directory, which is not always the case for us. If anyone knows how and want to share, feel free. Otherwise, you can just have a different patch file for each file that needs a fix for this bug.

Note: this patch process doesn't apply to real ifixes that are created by the service team using the emgr cmd on aix.

## Testing man pages

Put the below functions (podit and htmlit) in the .bashrc file on a linux machine that has a local git repo. To view the html file, it's easiest to scp it to your laptop.

To test the formatting of a pod file as a man page:

cd to the specific pod dir in git, e.g: cd xCAT-client/pods/man1
~~~~
podit nodels.1.pod

    function podit
    {
     mkdir -p ~/tmp/man
     pod2man $1 ~/tmp/man/${1/.pod/}
     #echo "rc=$?"
     cd ~/tmp/man/
     manit ${1/.pod/}
     cd - >/dev/null
    }

~~~~

To test the formatting of a pod file as an html page:

cd to the specific pod dir in git, e.g: cd xCAT-client/pods/man1

htmlit nodels.1.pod

use your browser to view ~/tmp/html/nodels.1.html

~~~~
    function htmlit
    {
     mkdir -p $HOME/tmp/html
     pod2html --infile=$1 --outfile=$HOME/tmp/html/${1/.pod/.html} --podroot=..  --podpath=man1:man3:man5:man8 --htmldir=$HOME/tmp/html --recurse
     #echo "rc=$?"
     rm -f pod2htmd.tmp pod2htmi.tmp
    }
~~~~

Needed by podit

~~~~
    function manit
    {
     num=${1/*./}
     mkdir -p ~/tmp/man/man$num
     ln -sf $PWD/$1 ~/tmp/man/man$num
     man -M ~/tmp/man ${1/.*/}
    }
~~~~

## Editing xCAT SF home page

     For editing http://xcat.sourceforge.net/, you basically have to edit the html by hand.  That can be done a couple different ways:


  * Log into their web servers using 'ssh -t &lt;sf-id&gt;,xcat@shell.sf.net create' and cd to the sym link call xcat-home, and then vi the html files.
  * If you have sftp://&lt;sf-id&gt;,xcat@web.sourceforge.net/home/groups/x/xc/xcat/htdocs .
    * copy the html files to your local machine
    * edit the html directly (WYSIWYG editors don't handle the css well)
    * copy the html files back to sourceforge


## Log into SourceForge shell

There are various times where it may be necessary to directly manipulate files in SourceForge (e.g. to edit the xCAT SF home page, to create symlinks for a new GA, to remove obsolete data, etc.).

Create a temporary shell:

    ssh -t <your-sf-id>,xcat@shell.sf.net create   

    This is an interactive shell created for user <your-sf-id>,xcat.
    Use the "timeleft" command to see how much time remains before shutdown.
    Use the "shutdown" command to destroy the shell before the time limit.
    For path information and login help, type "sf-help".

To get to the xCAT file directories:

   cd  /home/frs/project/xcat/

xCAT git repositories:
   cd /home/git/p/xcat



## xCAT FRS area on sourceforge

1. Brief introduction for the subdirectory under /Home
Home
|---Openstack: xCAT openstack demo tar ball which Jie hua has ever put there
|
|---aix: all xcat-core and xcat-dep files for each xcat release including GA release and development release for aix platform
|
|---doc: xcat documentation tar ball. This is updated when each xCAT release is GAed
|
|---kits: complete kits for chef, puppet and mpss for xeon phil support
|
|---Ubuntu: all xcat-core and xcat-dep files for each xcat release for ubuntu platform.
|
|---doc: xcat documentation tar ball. This is updated when each xCAT release is GAed
|
|---xcat: all released xcat core tar balls from xCAT 2.0 to xCAT 2.8.4. There is also where xCAT core download pages point to.
|
|---xcat-dep: all released xcat dep tar balls. There is also where xCAT dep download pages point to.
|
|---yum: all xcat-core and xcat-dep files for each xcat release including GA release and development release for linux platform


2. Introduction for yum subdirectory and take 2.8 subdirectory under yum as an example for the description.

|---yum
|    |
|    |---2.5: blank
|    |
|    |---2.6: xcat 2.6 lastest release tar ball and rpm packages. Now they are xcat 2.6.11 tar ball and xcat 2.6.11 rpm packages
|    |
|    |---2.7: xcat 2.7 lastest release tar ball and rpm packages. Now they are xcat 2.7.8 tar ball and xcat 2.7.8 rpm packages
|    |
|    |---2.8: xcat 2.8, 2.8.2-2.8.5 tar ball and latest xcat 2.8.x rpm packages.
|    |    |---core-rpms-snap.tar.bz2  : xcat 2.8.x development snapshot build tar ball.
|    |    |---xcat-core-2.8.2.tar.bz2 : xcat 2.8.2 promoted build tar ball.
|    |    |---xcat-core-2.8.3.tar.bz2 :  xcat 2.8.3 promoted build tar ball.
|    |    |---xcat-core-2.8.4.tar.bz2 : xcat 2.8.4 promoted build tar ball.
|    |    |---xcat-core-2.8.4.1,tar.bz2 : xcat 2.8.4.1 promoted build tar ball.
|    |    |---xcat-core-2.8.5.tar.bz2 : xcat 2.8.5 promoted build tar ball.
|    |    |
|    |    |---core-snap: subdirectory for current xcat 2.8.x development snapshot build rpm packages
|    |    |
|    |    |---xcat-core: subdirectory for latest xcat 2.8.x GA build rpm packages directory
|    |    |
|    |    |---core-snap-srpms: subdirectory for xcat 2.8.x development snapshot build rpm package with source code
|    |    |
|    |    |---fsm: subdirectory for current xcat 2.8.x development snapshot build rpm packages specific for fsm
|    |    |
|    |    |---pcm :
|    |    |    |---core-rpms-snap.tar.bz2 : xcat 2.8.x development snapshot build tar ball for pcm
|    |    |    |---xcat-core-2.8.1.tar.bz2 : xcat 2.8.1 tar ball for pcm
|    |    |    |---xcat-core-2.8.2.tar.bz2: xcat 2.8.2 tar ball for pcm
|    |    |    |---xcat-core-2.8.3.tar.bz2: xcat 2.8.3 tar ball for pcm
|    |    |    |---xcat-core-2.8.4.tar.bz2: xcat 2.8.4 tar ball for pcm
|    |    |    |---xcat-core-2.8.5.tar.bz2: xcat 2.8.5 tar ball for pcm
|    |    |    |---xcat-core-2.8.tar.bz2: xcat 2.8 tar ball for pcm
|    |    |    |---core-snap: subdirectory for current xcat 2.8.x development snapshot build rpm packages for pcm
|    |    |    |---xcat-core: subdirectory for latest xcat 2.8.x GA build rpm packages for pcm
|    |    |    |---core-snap-srpms:subdirectory for xcat 2.8.x development snapshot build rpm package with source code
|    |    |
|    |    |---zvm:subdirectory for current xcat 2.8.x development snapshot build rpm packages specific for zvm



## Scanning code for OSSC compliance

Periodically the xCAT code needs to be scanned to make sure all code is OSSC compliance with the CSAR tools located at:
[CSAR](https://w3-connections.ibm.com/wikis/home?lang=en_US#!/wiki/W7c33090f777f_4d05_bda9_b9d8b79b0c7c)

### Get the CSAR scan tool

I downloaded the abreviated scan package for linux  from 
https://w3-connections.ibm.com/files/app#/file/9a4b305b-00ae-48f7-9fae-76475c43ca79.

~~~~
   csar-3.0.2-rev-1403202008-abbreviated-unix.tar.gz
~~~~

I put it in /root/CSAR_HOME on my machine hpcrhm (redhat Linux6 power) and then proceeded to use the following setup.

### Install and setup CSAR

Open up the "User's Guide" and follow the Quick Start section.  

https://w3-connections.ibm.com/wikis/home?lang=en-us#!/wiki/W7c33090f777f_4d05_bda9_b9d8b79b0c7c/page/CSAR%20Users%20Guide

You will need Java SE6 at least, I downloaded the one from developerworks and installed it on the 
http://www.ibm.com/developerworks/java/jdk/

I wanted to run CSAR on the Redhat power node, which had the GIT repository installed.
To install and setup Java, I followed these instructions to install needed JAVA on the node.

http://www.cyberciti.biz/faq/linux-unix-set-java_home-path-variable/

Added this to ~/.bash_profile
~~~~
export JAVA_HOME=/opt/ibm/java-ppc64-60
export PATH=$PATH:/opt/ibm/java-ppc64-60/bin
export PATH
~~~~

This is a JAVA application, so on the node where CSAR is installed we need a VNC server.
Check 

~~~~
  root@hpcrhmn CSAR_HOME]# rpm -qa | grep -i vnc
  tigervnc-server-1.0.90-0.10.20100115svn3945.el6.ppc64
~~~~

On the node start the vnc server

~~~~
   root@hpcrhmn CSAR_HOME# vncserver :10 -geometry 1600x900

~~~~

On the node, make sure you have checked out the right level of xCAT in the git repository.  For example my repository is in /git/xcat-core, and is up-to-date  ( git pull).

~~~~
chdir /git/xcat-core
git checkout 2.8
~~~~


On your laptop, start tightvnc and put in the address of the linux node where you installed the tool.
Go to the /root/CSAR_HOME directory and run

~~~~
    csar.sh   ( in terminal)
~~~~

From the Menu: Pick *Scan Code*

Fill in the options:

For my example:

Project Home Directory: /git

Descriptive Scan Results file: <your file name>

Base Directory to scan: xcat-core

Note: The Scan is very fast ( < 12 seconds for full scan of a git branch). 

### Analyze the results

At the end of the scan it will prompt you to go into analyzing the results ( xml) file.  You can also save that as an htmml file and send out. 
