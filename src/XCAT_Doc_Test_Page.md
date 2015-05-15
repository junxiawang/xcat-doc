<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [First section](#first-section)
  - [Common xCAT Features](#common-xcat-features)
- [Second section](#second-section)
- [Fifth section](#fifth-section)
- [Linda Test Section](#linda-test-section)
- [Introduction](#introduction)
  - [Downloading and Installing DFM](#downloading-and-installing-dfm)
  - [Terminology](#terminology)
  - [Another Section](#another-section)
- [Discovering and Defining New Power 775 Hardware](#discovering-and-defining-new-power-775-hardware)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Note: this documentation is obsolete.   xCAT is now on MarkDown wiki, not mediawiki.





## First section

c1 
c2aaaa 
c3 

c4 
c5 
c6 

blah blah 

{{hidden |header=my title |content=my content }} 

blah blah 

{{hidden |header=Title for Collapsible Section |content= These are details that initially should be hidden, but can be shown if the reader is interested 

  * bullet 1 
  * bullet 2 

}} 

blah blah 

### Common xCAT Features

These features can be used in most xCAT environments. 

This is to test out some mediawiki features. 

This is a simple reference to a section in this doc.  See
[#fifth-section](#fifth-section)

This is a longer ref to the same:
[XCAT_Doc_Test_Page#fifth-section](XCAT_Doc_Test_Page#fifth-section)


## Second section

blah blah 

{{:XCAT Doc Test Transcluded Page}} 

## Fifth section

  1. one 
    
    first command
    second command

&lt;/ol&gt;

    1. two 
  1. one 

     indented text 
  2. two 
  1. one
        
        single line command

  2. two 
  1. one 
    * a 
    * b 
  2. two 

  

## Linda Test Section ##

see my Linda Test Page:  [Linda_Test_Page](Linda_Test_Page)

## Introduction

This cookbook provide 

### Downloading and Installing DFM

For most operations,the Power 775 is managed directly by xCAT, not using the HMC. This requires the new xCAT Direct FSP Management plugin (xCAT-dfm-*.ppc64.rpm), which is not part of the core xCAT open source, but is available as a free download from IBM. You must download this and install it on your xCAT management node (and possibly on your service nodes, depending on your configuration) before proceeding with this document. 

Download DFM and the pre-requisite hardware server from [Fix Central](http://www-933.ibm.com/support/fixcentral/) (need more specific instructions here when it GAs): 

  * xCAT-fsp RPM 
  * ISNM-hdwr_svr RPM (linux) 
  * isnm.hdwr_svr installp package (AIX) 

Once you have downloaded these packages, install the hardware server package, and then install DFM using: 

### Terminology

The following terms will be used in this document: 

**xCAT DFM**: Direct FSP Management is the name that we will use to describe the ability for xCAT software to communicate directly to the System p server's service processor without the use of the HMC for management. 

**Frame node**: A node with hwtype set to _frame_ represents a high end System P server 24 inch frame. 

**BPA node**: is node with a hwtype set to _bpa_ and it represents one port on one bpa (each BPA has two ports). For xCAT's purposes, the BPA is the service processor that controls the frame. The relationship between Frame node and BPA node from system admin's perspective is that the admin should always use the Frame node definition for the xCAT hardware control commands and xCAT will figure out which BPA nodes and their ip addresses to use for hardware service processor connections. 

**CEC node**: A node with attribute hwtype set to _cec_ which represents a System P CEC (i.e. one physical server). 

**FSP node**: FSP node is a node with the hwtype set to _fsp_ and represents one port on the FSP. In one CEC with redundant FSPs, there will be two FSPs and each FSP has two ports. There will be four FSP nodes defined by xCAT per server with redundant FSPs. Similar to the relationship between Frame node and BPA node, system admins will always use the CEC node for the hardware control commands. xCAT will automatically use the four FSP node definitions and their attributes for hardware connections. 

### Another Section

Blah, blah, blah, blah. 

## Discovering and Defining New Power 775 Hardware

When setting up a new cluster, you can use the xCAT commands [xcatsetup](http://xcat.sourceforge.net/man8/xcatsetup.8.html) and [lsslp](http://xcat.sourceforge.net/man1/lsslp.1.html) to specify the proper definition of all of the cluster hardware in the xCAT database, by automatically discovering and defining them. This is optional - you can define all of the hardware in the database by hand, but that can be confusing and error prone. 
