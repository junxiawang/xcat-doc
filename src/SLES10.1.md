<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Step 1](#step-1)
- [Step 2](#step-2)
- [Step 3](#step-3)
- [Step 4](#step-4)
- [Step 5](#step-5)
- [Stateless](#stateless)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)

**Note: Refer to [XCAT_iDataPlex_Cluster_Quick_Start] for a more up to date quick start guide.**


## Step 1

Install base OS, nothing special except: 

  * Turn off firewall unless you want to go through the hassle of configuring it. (Most of our sites are well protected already) 
  * Make a directory called /install/packages to install everything 
  * Copy the SLES 10 SP1 iso image to /install/packages 

## Step 2

  * Setup /etc/hosts 
  * Use YaST to update your SLES10 SP1 repository. Zypper doesn't work in adding iso images. Use the iso image you copied in /install/packages 
  * vi /etc/sysconfig/network/ifcfg-eth&lt;mac address&gt; the way you want 
    * TIP: To change the order of your ethernet interfaces change /etc/udev/30_persistant_names ... (or something like that, I'm doing this from memory... 

## Step 3
    
    mkdir /install/packages/xcat
    cp &lt;wherever you downloaded xCAT to&gt;/xcat-*bz /install/packages/xcat

Untar 
    
    tar jxf xcat-core*bz; tar jxf xcat-dep*.bz

Use Zypper to set up your repository 
    
    zypper sa file:///install/packages/xcat/xcat-core
    zypper sa file:///install/packages/xcat/xcat-dep/sles10/x86_64

Install xCAT 
    
    zypper in xCAT

## Step 4

Set up environment and services 
    
    . /etc/profile.d/xcat.sh
    tabdump site # just to check to make sure it works
    chkconfig –add nfsserver; service nfsserver restart
    chkconfig –add ntp; service ntp restart
    # correct this xCAT BUG
    cp /etc/httpd/conf.d/xcat.sh /etc/apache2/conf.d/
    chkconfig –add apache2; service apache2 restart
    chkconfig –add tftpd; service tftpd restart

## Step 5

Setup tables as documented and copycds... no changes here, just make sure nodetype is set to sles10.1 as the OS. 

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
    my @KVERS= &lt;nodebootif&gt; -n &lt;nodenetdrivers&gt; [-r &lt;otherifaces&gt;] -o &lt;OSVER&gt; -p &lt;PROFILE&gt; -k &lt;KERNELVER&gt;'."\n";
    print "Examples:\n";
    print " genimage -i eth0 -n tg3 -o centos5.1 -p compute\n";
    print " genimage -i eth0 -r eth1,eth2 -n tg3,bnx2 -o centos5.1 -p compute\n";
    exit 1;
    }
    my @ndrivers;
    foreach (split /,/,$netdriver) {
    unless (/\.ko$/) {
    s/$/.ko/;
    }
    if (/^$/) {
    next;
    }
    push @ndrivers,$_;
    }
    unless (grep /af_packet/,@ndrivers) {
    unshift(@ndrivers,"af_packet.ko");
    }
    
    unless ($onlyinitrd) {
    my $srcdir = "$installroot/$osver/$arch/";
    find(\&isyumdir, &lt;EOMS;
    echo "You're dead.  rpower nodename reset to play again.
    
    * Did you packimage with -m cpio, -m squashfs, or -m nfs?
    * If using -m squashfs did you include aufs.ko with geninitrd?
    e.g.:  -n tg3,squashfs,aufs,loop
    * If using -m nfs did you export NFS and sync rootimg?  And
    did you include the aufs and nfs modules in the proper order:
    e.g.:  -n tg3,aufs,loop,sunrpc,lockd,nfs_acl,nfs
    
    "
    sleep 5
    EOMS
    print $inifile "  exit\n";
    print $inifile "fi\n";
    print $inifile "cd /\n";
    print $inifile "cp /var/lib/dhcpcd/* /sysroot/var/lib/dhcpcd/\n";
    print $inifile "cp /etc/resolv.conf /sysroot/etc/\n";
    print $inifile "cp /etc/HOSTNAME /sysroot/etc/\n";
    print $inifile "mknod /sysroot/dev/console c 5 1\n";
    print $inifile "exec /lib/mkinitrd/bin/run-init -c /dev/console /sysroot /sbin/init\n";
    close($inifile);
    open($inifile,"&gt;"."/tmp/xcatinitrd.$$/bin/netstart");
    print $inifile "#!/bin/bash\n";
    print $inifile "dhcpcd $prinic\n";
    print $inifile "echo -n 'search '&gt; /etc/resolv.conf\n";
    print $inifile "grep DOMAIN /var/lib/dhcpcd/*info|awk -F= '{print \$2}'|awk -F\\' '{print \$2}' &gt;&gt; /etc/resolv.conf\n";
    print $inifile "grep HOSTNAME /var/lib/dhcpcd/*info|awk -F= '{print \$2}'|awk -F\\' '{print \$2}' &gt;&gt; /etc/HOSTNAME\n";
    print $inifile "for names in `grep DNS /var/lib/dhcpcd/*info|awk -F= '{print \$2}'`; do\n";
    print $inifile '   echo nameserver $names &gt;&gt; /etc/resolv.conf'."\n";
    print $inifile "done\n";
    
    close($inifile);
    chmod(0755,"/tmp/xcatinitrd.$$/init");
    chmod(0755,"/tmp/xcatinitrd.$$/bin/netstart");
    @filestoadd=();
    foreach (@ndrivers) {
    if (-f "$pathtofiles/$_") {
    push @filestoadd,[$_,"lib/$_"];
    }
    }
    foreach ("usr/bin/grep","bin/cpio","bin/sleep","bin/mount","sbin/dhcpcd","bin/bash","sbin/insmod","bin/mkdir","bin/mknod","sbin/ip","bin/cat","usr/bin/awk","usr/bin/wget","bin/cp","usr/bin/cpio","usr/bin/zcat","lib/mkinitrd/bin/run-init") {
    getlibs($_);
    push @filestoadd,$_;
    }
    if ($arch =~ /x86_64/) {
    push @filestoadd,"lib64/libnss_dns.so.2";
    }
    else {
    push @filestoadd,"lib/libnss_dns.so.2";
    }
    push @filestoadd,keys %libhash;
    if($basekernelver ne $kernelver) {
    system("rm -rf $installroot/netboot/$osver/$arch/$profile/rootimg/lib/modules/$basekernelver");
    unless (-d "$installroot/netboot/$osver/$arch/$profile/rootimg/lib/modules/$kernelver") {
    if(-d "/lib/modules/$kernelver") {
    system("cd /lib/modules;cp -r $kernelver $installroot/netboot/$osver/$arch/$profile/rootimg/lib/modules/");
    }
    else {
    xdie("Cannot read /lib/modules/$kernelver");
    }
    }
    }
    find(\&isnetdriver, 

If you want to make a stateless install server go to the section on createing an install server somewhere in this wiki... I don't have the URL yet... will fix this later. 
