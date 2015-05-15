<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [What Should User Know](#what-should-user-know)
  - [Full Install](#full-install)
  - [Statelite/Stateless Install](#statelitestateless-install)
- [What Should Developer Know](#what-should-developer-know)
  - [Full Install Implementation](#full-install-implementation)
  - [Statelite/Stateless Install Implementation](#statelitestateless-install-implementation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Overview

As there's the requirement to install packages in SDK DVD during SLES11 DVD install, we decided to support this feature. 
    
    * Distribution Target:  SLES11 SP1
    * Function:             Enable user with packages in SDK DVD for full/statelite/stateless install
    * Known defect:         N/A
    * Known Limitations:    Only SDK DVD1 supported, since SDK DVD2 contains only source rpms.
    

## What Should User Know

### Full Install

Two extra steps if you want use this feature. 
    
    1. Run "copycds" with SDK DVD's iso. (e.g. copycds /iso/SLE-11-SP1-SDK-DVD-ppc64-GM-DVD1.iso)
    2. Prepare a autoyast config file under /install/custom/...,it should originate from compute.sdk.sles11.tmpl, 
       make sure it contains node &lt;add-on&gt;.
    

_**Note:** Do make sure the SDK DVD's version matches the installtion DVD, if you use a SLES11 installation DVD with a SLES11 SP1 SDK DVD, YaST won't install._

### Statelite/Stateless Install

The only thing you need to do is to run "copycds" command with SDK DVD's iso. 

## What Should Developer Know

### Full Install Implementation

A specific node &lt;add-on&gt; is contained in compute.sdk.sles11.tmpl, which will be the autoyast configuration file if we've done copycds with the SDK DVD. When we do nodeset this template will be revised, set location of SDK DVD location for subnode &lt;media_url&gt;, and been copied to /install/autoinst. By this we let autoyast know the repository position of the SDK DVD. (the SDK DVD itself is a well generated repository). A sample of the &lt;add-on&gt; node in generated autoyast file is: 
    
     &lt;add-on&gt;
       &lt;add_on_products config:type="list"&gt;
         &lt;listentry&gt;
           &lt;media_url&gt;http://192.168.0.245/install/sles11.1/ppc64/sdk1&lt;/media_url&gt;
           &lt;product&gt;SuSE-Linux-SDK&lt;/product&gt;
           &lt;product_dir&gt;/&lt;/product_dir&gt;
           &lt;ask_on_error config:type="boolean"&gt;false&lt;/ask_on_error&gt;
           &lt;name&gt;SuSE-Linux-SDK&lt;/name&gt;
         &lt;/listentry&gt;
       &lt;/add_on_products&gt;
     &lt;/add-on&gt;
    

You can find autoyast config document here: [[AutoYaST document](http://www.suse.com/~ug/autoyast_doc/index.html)] 

_**Note:** It won't work if you just throw arbitrary packages into SDK DVD's repository, this kind of repository is signed using a gpg key to make sure it won't be revised. You can follow this to create your additional repository, see section 2.4 and 2.6:_ [[AutoYaST FAQ](http://www.suse.de/~ug/AutoYaST_FAQ.html)]__

### Statelite/Stateless Install Implementation

When we generate root image using genimage, firstly repository of installation DVD been added to zypper, then zypper install packages to the directory of root image. So all we have to do is to add the location of SDK DVD to zypper (zypper ar ...) before package installation. This is quite straightforward. If you haven't copied the SDK DVD at that time, zypper will simply ignore that. 
