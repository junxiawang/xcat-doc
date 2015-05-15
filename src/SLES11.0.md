<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

  - [Step 1](#step-1)
  - [Step 2](#step-2)
  - [Step 3](#step-3)
  - [Step 4](#step-4)
  - [Step 5](#step-5)
- [Notes from SLES 10](#notes-from-sles-10)
  - [Stateless](#stateless)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)

**Note: Refer to [XCAT_iDataPlex_Cluster_Quick_Start] for a more up to date quick start guide.**


## Step 1

Install base OS, nothing special except: 

  * Turn off firewall unless you want to go through the hassle of configuring it. (Most of our sites are well protected already) 
  * Make a directory to install everything in 
    
    mkdir -p /install/packages/xcat

  * Copy the SLES 11 iso image to /install/packages - you may also need the SDK iso. 

## Step 2

  * Setup /etc/hosts 
  * Use YaST to add the SLES11 iso to your local repository. Zypper doesn't work for adding iso images. Use the iso image you copied to /install/packages. Run yast-&gt;software-&gt;software repositories. There, you can add the ISO(s). 
  * vi /etc/sysconfig/network/ifcfg-eth(0/1) the way you want 
    * TIP: To change the order of your ethernet interfaces change /etc/udev/30_persistant_names ... (or something like that, I'm doing this from memory... 

## Step 3

Add the xCAT and xCAT-dep repositories for SLES 
    
    zypper ar http://xcat.sf.net/yum/core-snap/xCAT-core.repo
    zypper ar http://xcat.sf.net/yum/xcat-dep/sles11/x86_64/xCAT-dep.repo

install xCAT 
    
    zypper install xCAT

## Step 4

Set up environment and services 
    
    . /etc/profile.d/xcat.sh
    tabdump site # just to check to make sure it works
    chkconfig –add nfsserver; service nfsserver restart
    chkconfig –add ntp; service ntp restart
    # correct this xCAT BUG
    cp /etc/httpd/conf.d/xcat.conf /etc/apache2/conf.d/
    chkconfig –add apache2; service apache2 restart
    chkconfig –add tftpd; service tftpd restart
    chkconfig -add named; service named start
    zypper install dhcp-server
    chkconfig -add dhcpd;

Edit the dhcp server config to use the appropritate interface: 
    
    vi /etc/sysconfig/dhcpd
    DHCPD_INTERFACE="eth1"

Starting dhcp won't work until makedhcp -n is run (after setting up tables) 

## Step 5

Setup tables as usual (see [here](Basic_Install_DHCP) for more info) 

Run copycds... no changes here, just make sure the nodetype OS is set to sles11. 

  


# Notes from SLES 10

## Stateless

If you are deploying a stateless image, genimage in /opt/xcat/share/xcat/netboot/sles does not work because zypper is buggy. (Its fixed in SP2) 

To install stateless you need to install YUM from the SDK DVD that comes with SLES10.1 as well as createrepo and all the dependencies. 

Once you have it do: 
    
    cd /install/sles10.1/x86_64
    createrepo .

Note: You need to do it in /install/sles10.1/x86_64 instead of /install/sles10.1/x86_64/1 otherwise it will ruin your YAST diskful installs.  
Once done you need to use genimage.yum to make this work. Copy the code below into /opt/xcat/share/xcat/netboot/sles/genimage.yum 

  


Note: You need to do it in /install/sles10.1/x86_64 instead of /install/sles10.1/x86_64/1 otherwise it will ruin your YAST diskful installs. 

Once done you need to use genimage.yum to make this work. Copy the code below into /opt/xcat/share/xcat/netboot/sles/genimage.yum 
    
    #!/usr/bin/env perl
    use Data::Dumper;
    use File::Basename;
    use File::Path;
    use File::Copy;
    use File::Find;
    use Getopt::Long;
    #use strict;
    Getopt::Long::Configure("bundling");
    Getopt::Long::Configure("pass_through");
    
    my $prinic; #TODO be flexible on node primary nic
    my $othernics; #TODO be flexible on node primary nic
    my $netdriver;
    my @yumdirs;
    my $arch = `uname -m`;
    chomp($arch);
    if ($arch =~ /i.86$/) {
    $arch = x86;
    }
    my %libhash;
    my @filestoadd;
    my $profile;
    my $osver;
    my $pathtofiles=dirname($0);
    my $name = basename($0);
    my $onlyinitrd=0;
    if ($name =~ /geninitrd/) {
    $onlyinitrd=1;
    }
    my $rootlimit;
    my $tmplimit;
    my $installroot = "/install";
    my $kernelver = ""; #`uname -r`;
    my $basekernelver; # = $kernelver;
    
    sub xdie {
    system("rm -rf /tmp/xcatinitrd.$$");
    die @_;
    }
    
    $SIG{INT} = $SIG{TERM} = sub { xdie "Interrupted" };
    GetOptions(
    'a=s' =&gt; \$arch,
    'p=s' =&gt; \$profile,
    'o=s' =&gt; \$osver,
    'n=s' =&gt; \$netdriver,
    'i=s' =&gt; \$prinic,
    'r=s' =&gt; \$othernics,
    'l=s' =&gt; \$rootlimit,
    't=s' =&gt; \$tmplimit,
    'k=s' =&gt; \$kernelver
    );
    #Default to the first kernel found in the install image if nothing specified explicitly.
    #A more accurate guess than whatever the image build server happens to be running
    #If specified, that takes precedence.
    #if image has one, that is used
    #if all else fails, resort to uname -r like this script did before
    my @KVERS= 
