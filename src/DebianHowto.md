<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [What Works](#what-works)
- [Known Issues](#known-issues)
- [ToDo's](#todos)
- [Ubuntu MN dependancies](#ubuntu-mn-dependancies)
  - [Universe Repository](#universe-repository)
- [Ubuntu MN Howto](#ubuntu-mn-howto)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**This doc is deprecated. See [Ubuntu_Quick_Start].**

See http://xcat.ocf.co.uk/devel 

SVN at http://svn.ocf.co.uk/xcat -- probably need a better viewer for this 

^^ Need to merge all this into one at some point ^^ 

https://sourceforge.net/tracker/?func=detail&amp;aid=3047018&amp;group_id=208749&amp;atid=1006948 

Instead of the createrepo as below for RPM based machines 
    
    createrepo .
    

we need to do the following to create a repo for debian/ubuntu 
    
    dpkg-scanpackages . /dev/null | gzip -9c &gt; Packages.gz
    


## What Works

  * statefull installs of 
    * ubuntu 9.10 
    * ubuntu 10.04 LTS 
    * ubuntu 10.04.1 LTS 
    * ubuntu 10.10 
  * copycds 
    * ubuntu 9.10 
    * ubuntu 10.04 LTS 
    * ubuntu 10.04.1 LTS 
    * ubuntu 10.10 
    * debian 5.0.6 

## Known Issues

  1. debootstrap in el5 will not work with lucid (10.04 and 10.04.1), but works on el6 
    * debootstrap works with 9.10 and 10.10 
  2. Syslog still doesn't work (Working on a FIX) 
  3. nbroot/nbkernel not done yet (FIXED by using alien) (need to create own) 
  4. yaboot-xcat can only be compiled on ppc therefore used alien 
  5. No stateless of statelite support yet, will come in the next devel release of the ubuntu PATCH set 
  6. Deb package issues 
    * some postinst/postrm scripts may not work as attended, please report any problems here 
  7. Installation of the deb packages doesn't start/configure xCAT correctly, although the relevant debs have the postinst scrip as the RPMS, prob need to change the deb that does the xcatconfig -i 
    1. rm -rf /etc/*.sqlite 
    2. xcatconfig -i 
    3. service xcatd start 

## ToDo's

  * Fix debs 
    * create debian folders for: and make proper debs instead of using alien 
      * nbroot 
      * nbkernel 
      * yaboot-xcat 
    * fix postinst/postrm issues if any reported 
    * Add proper copyrights/Licensing (DONE) 
    * Sign all packages (DONE) 
  * Fix postscripts 
    * otherpkgs (works OK with v0.1 i.e. xCAT 2.4.3) 
    * syslog 
  * Add support for stateless 
  * Add support for statelite 
  * test in VMs 
    * KVM 
    * virtual box 
    * xen 
    * vmware 
  * move repository to debian format such that I have dists and pools (better way of management) i.e. so that the following entries would work in the apt source files (DONE) 
    * deb http://xcat.ocf.co.uk/devel/debs maverick main universe xcat-core xcat-deps 

## Ubuntu MN dependancies

below are the dependancies that do not come from the main CD/DVD of the ubuntu/debian. So these are required from the universe repositories, I have added these as part of the xcat-deps dependancies. 

### Universe Repository

  * libnet-ssleay-perl 
  * libio-socket-ssl-perl 
  * libio-stty-perl 
  * libexpect-perl 
  * libossp-uuid-perl 
  * libcrypt-ssleay-perl 
  * libfcgi-perl 
  * libsoap-lite-perl 
  * libnet-libidn-perl 
  * fping 
  * ipmitool 

## Ubuntu MN Howto

  * Install node with ubuntu10.10 
  * Add the following into /etc/apt/sources.list.d/xcat-core.list 
    
    deb http://xcat.ocf.co.uk/devel/debs/xcat-core/. /
    

  * Add the following into /etc/apt/sources.list.d/xcat-dep.list 
    
    deb http://xcat.ocf.co.uk/devel/debs/xcat-deps/ubuntu10.10/x86_64/. /
    

  * Run apt-get update 
  * run apt-get install xcat 
  * You may run into trouble, if you do run the following commands 
    * . /etc/profile.d/xcat.sh 
    * xcatconfig -i -d 
    * apt-get -f install 
  * get the ubuntu patches from xCAT-ubuntu-0.2.pre.tgz 
    * Untar the file 
    * run ./install.sh 
    * This should patch the xCAT for use with Ubuntu/Debian 
  * Now you should be able deploy nodes statefull to all nodes. 
