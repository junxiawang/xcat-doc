<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Background](#background)
- [Main thoughts](#main-thoughts)
- [External](#external)
- [Internal](#internal)
  - [**Code changes in linux os image template files**](#code-changes-in-linux-os-image-template-files)
  - [**Code changes in anaconda.pm/sles.pm/Template.pm**](#code-changes-in-anacondapmslespmtemplatepm)
  - [**Updates for the description of linuximage.pkgdir in the Schema.pm **](#updates-for-the-description-of-linuximagepkgdir-in-the-schemapm-)
- [support os](#support-os)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 


## Background

In xCAT 2.8, there is one item "support osimage.pkgdir with multiple paths in genimage and diskfull installation", and the min-design is the following link: 

[Support_osimage.pkgdir_with_multiple_paths_in_genimage_and_diskfull_installation] 

It supported the multiple paths in genimage successfully. 

For diskfull installation, we put the ospkgs into the postscripts. It was ok for rhels, but couldn't work for sles. Because the yast2 lock the zypper repository, and the zypper in ospkgs couldn't do anything. So for full installation, this solution will be obsoleted after xCAT 2.8. 

## Main thoughts

After some investigation, we propose that: put all the paths into the autoyast/kickstart file,and not change the main os repository in the yaboot/xnba file. During the installation, it will use all the repositories, and the updates will be installed. 

## External

The multiple paths of pkgdir will be separated by "," such as: 

pkgdir=/install/rhels6.2/ppc64,/install/updates 

Notes: 

(1)all the pkg dirs should be in the site.installdir directory 

(2)in the os base pkg dir, there are default repository data. And in the other pkg dir(s), the users should make sure there are repository data. If not, use "createrepo" command to create them. 

After running nodeset/makedhcp, and do the full installation. We can check that if the latest pkgs updates in the /install/updates, the latest pkgs updates will be installed. 

## Internal

The main work is focused on generating the repositories in the kickstart/autoyast file. After running nodeset, 

For rhels, the repositories in the kickstart file looks like: 
    
    repo --name=pkg0 --baseurl=http://1.1.1.2//install/rhels6.2/x86_64
    repo --name=pkg1 --baseurl=http://1.1.1.2//install/rhtest
    

For sles, we should add "signature-handling" tag, and add the "add-on" tag in autoyast file, such as: 
    
     &lt;general&gt;
    ...
         &lt;signature-handling&gt;
            &lt;accept_non_trusted_gpg_key config:type="boolean"&gt;true&lt;/accept_non_trusted_gpg_key&gt;
            &lt;accept_unknown_gpg_key config:type="boolean"&gt;true&lt;/accept_unknown_gpg_key&gt;
            &lt;accept_unsigned_file config:type="boolean"&gt;true&lt;/accept_unsigned_file&gt;
         &lt;/signature-handling&gt;
       &lt;/general&gt;
       &lt;add-on&gt;
          &lt;add_on_products config:type="list"&gt;
          &lt;listentry&gt;
              &lt;media_url&gt;http://1.1.1.4/install/test&lt;/media_url&gt;
              &lt;product&gt;SuSE-Linux-pkg1&lt;/product&gt;
              &lt;product_dir&gt;/&lt;/product_dir&gt;
              &lt;ask_on_error config:type="boolean"&gt;false&lt;/ask_on_error&gt;
              &lt;name&gt;SuSE-Linux-pkg1&lt;/name&gt;
            &lt;/listentry&gt;
          &lt;/add_on_products&gt;
       &lt;/add-on&gt;
    

So we need to modify the templates for installation, and the anaconda.pm/sles.pm/Template.pm. 

The subroutine subvars() of Template.pm will generate the kickstart/autoyast file according to the compute.&lt;osver&gt;.&lt;arch&gt;.tmpl or service.&lt;osver&gt;.&lt;arch&gt;.tmpl . 

### **Code changes in linux os image template files**

For rhels, in the /opt/xcat/share/xcat/install/rh/compute.&lt;osver&gt;.&lt;arch&gt;.tmpl or service.&lt;osver&gt;.&lt;arch&gt;.tmpl, there is one tag: 
    
    #INSTALL_SOURCES#
    

This tag will be used in the subvars() of Template.pm and generate the related repositories for rhels anaconda. 

For sles, the "signature-handling" tag will be added into the /opt/xcat/share/xcat/install/sles/compute.&lt;osver&gt;.&lt;arch&gt;.tmpl or service.&lt;osver&gt;.&lt;arch&gt;.tmpl, and there is “add-on” tag in the template: 
    
      &lt;add-on&gt;
          &lt;add_on_products config:type="list"&gt;
              #INSTALL_SOURCES#
          &lt;/add_on_products&gt;
       &lt;/add-on&gt;
    

The tag #INSTALL_SOURCES# will be used in the subvars() of Template.pm and generate the related repositories for sles autoyast. 

### **Code changes in anaconda.pm/sles.pm/Template.pm**

In anaconda.pm, the $pkgdir and $platform value should be passed into subvars() of Template.pm, and the changes are as follows: 
    
                $tmperr =
                 xCAT::Template-&gt;subvars(
                       $tmplfile,
                       "/$installroot/autoinst/" . $node,
                       $node,
                               $pkglistfile,
                       **  $pkgdir,**
                       **$platform,**
                       $partfile
                       );
    

  
In sles.pm , the $pkgdir and $os values should be passed into subvars() of Template.pm, and the changes are as follows: 

  

    
               $tmperr =
                 xCAT::Template-&gt;subvars(
                            $tmplfile,
                            "$installroot/autoinst/$node",
                            $node,
                            $pkglistfile,
                     **$tmppkgdir,**
                    **$os,**
                    $partfile
                            );
    

For sles, the os base path in the linuximage.pkgdir always be /install/&lt;slesvers&gt;/&lt;arch&gt;. But the autoyast uses the /install/&lt;slesvers&gt;/&lt;arch&gt;/1, so I apppend the "/1" to the os base path in linuximage.pkgdir, and set the value to $tmppkgdir. 

In subvars() of Template.pm, it will collect the repository information and use the info to replace the tag #INSTALL_SOURCES# in kickstart/autoyast template. 
    
     #support multiple paths of osimage in rh/sles diskfull installation
     my @pkgdirs;
     if ( defined($media_dir) ) {
         @pkgdirs = split(",", $media_dir);
         my $source;
         my $c = 0;
         foreach my $pkgdir(@pkgdirs) {
             if( $platform =~ /^(rh|SL)$/ ) {
                 $source .=  "repo --name=pkg$c --baseurl=http://#TABLE:noderes:\$NODE:nfsserver#/$pkgdir\n";
             } elsif ($platform =~ /^(sles|suse)/) {
                 my $http = "http://#TABLE:noderes:\$NODE:nfsserver#$pkgdir";
                 $source .=  "         &lt;listentry&gt;
              &lt;media_url&gt;$http&lt;/media_url&gt;
              &lt;product&gt;SuSE-Linux-pkg$c&lt;/product&gt;
              &lt;product_dir&gt;/&lt;/product_dir&gt;
              &lt;ask_on_error config:type=\"boolean\"&gt;false&lt;/ask_on_error&gt;
              &lt;name&gt;SuSE-Linux-pkg$c&lt;/name&gt;
            &lt;/listentry&gt;";
             }
             $c++;
         }
         $inc =~ s/#INSTALL_SOURCES#/$source/g;
     }
    

### **Updates for the description of linuximage.pkgdir in the Schema.pm **

I update the description of the linuximage.pkgdir in the Schema.pm. 
    
     linuximage  =&gt; {
     ...
        pkgdir =&gt; 'The name of the directory where the distro packages are stored. It could be set multiple paths.The multiple paths must be seperated by ",". 
     The first path in the value of osimage.pkgdir must be the OS base pkg dir path, such as pkgdir=/install/rhels6.2/x86_64,/install/updates . In the os base 
     pkg path, there are default repository data. And in the other pkg path(s), the users should make sure there are repository data. If not, use "createrepo"
     command to create them. ',
     ...
     }
    

You can run “tabdump linuximage -d” to get the description. 

## support os

I have verified the following scenarios: 

1\. use rhels6.2 mn to install rhels6.&lt;x&gt; cn/sn 

2\. use rhels6.2 mn to install sles11sp&lt;x&gt; cn 

3\. use sles11sp2 mn to install sles11sp&lt;x&gt; cn/sn, and sles10sp3 cn. 

4\. use sles11sp2 mn to install rhels6.&lt;x&gt; cn 

## Other Design Considerations
    
      *Required reviewers:  Bruce
      *Required approvers:  Bruce Potter
      *Affect on other components:  rhels/sles full installation
      *External interface changes, documentation, and usability issues: values of linuximage.pkgdir will be changed. This page.
      *Packaging, installation, dependencies:  N/A
      *Portability and platforms (HW/SW) supported:  N/A
      *Performance and scaling considerations:  N/A
      *Migration and coexistence:  N/A
      *Serviceability: N/A
      *Security:  N/A
      *NLS and accessibility:  N/A
      *Invention protection:  N/A
    
