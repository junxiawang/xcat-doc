<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [The previous support for imgexport/imgimport](#the-previous-support-for-imgexportimgimport)
- [New enhancements](#new-enhancements)
  - [**postscripts**](#postscripts)
  - [**profiles**](#profiles)
  - [**image def**](#image-def)
  - [**copy image to a new profile**](#copy-image-to-a-new-profile)
  - [**make destination optional for --extra flag for imgexport command**](#make-destination-optional-for---extra-flag-for-imgexport-command)
  - [**litefile table for statelite**](#litefile-table-for-statelite)
  - [**root image tree for statelite**](#root-image-tree-for-statelite)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## The previous support for imgexport/imgimport

Currently with imgexport command, we get the following files in the tar file (bundle) by default for stateless. 

  * initrd.gz 
  * kernel 
  * rootimg.gz 

And a **manifest.xml** file which looks like this: 
    
     &lt;xcatimage&gt;
        &lt;imagename&gt;sles11-ppc64-netboot-compute-rscttest&lt;/imagename&gt;
        &lt;kernel&gt;/install/netboot/sles11/ppc64/compute-rscttest/kernel&lt;/kernel&gt;
        &lt;osarch&gt;ppc64&lt;/osarch&gt;
        &lt;osvers&gt;sles11&lt;/osvers&gt;
        &lt;profile&gt;compute-rscttest&lt;/profile&gt;
        &lt;provmethod&gt;netboot&lt;/provmethod&gt;
        &lt;ramdisk&gt;/install/netboot/sles11/ppc64/compute-rscttest/initrd.gz&lt;/ramdisk&gt;
        &lt;rootimg&gt;/install/netboot/sles11/ppc64/compute-rscttest/rootimg.gz&lt;/rootimg&gt;
     &lt;/xcatimage&gt;
    

In addition, one can choose to add additional files by using the _\--extra &lt;file:dest_dir&gt;_ flag. For statefull case, the _.tmpl_ file is included in the bundle file. 

## New enhancements

The following enhancements will be added: 

### **postscripts**

Since the postscripts are not associated with the image, we can let user specify a node name in order to get the postscripts. 
    
         imgexport &lt;img_name&gt; [-p &lt;nodename&gt;]
    

The postscript names will be saved in the manifest.xml file. When import the image, user can specify a node name or a group name like this: 
    
        imgimport &lt;bundle_file_name&gt; [-p &lt;nodelist&gt;]
    

The postscripts will be entered into the postscripts table for the nodes specified. By postscripts, it means both _postscripts_ and _postbootscripts_ from the **postscripts** table. 

  


### **profiles**

We'll add the _.pkglist, .otherpkgs.pkglist, .postinstall .synclist and .exlist_ files in the bundle by default. This way, user can run **genimage** again on the new xCAT mn if they choose to. These files will be copied to the same directories as the source when **imgexport** runs. And they will be entered into the **osimage** and **linuximage** table. 

  


### **image def**

We also need to add more detailed imgage defs into the **manifest.xml** such as _primary nic, additonal nics, kernel versions_ etc. **imgexport** command will create a row for the new image on **osimage** and **linuximage** tables. 

  
The new **manifest.xml** file will look like this after the above 3 enhancements: 
    
     &lt;xcatimage&gt;
       &lt;exlist&gt;/install/custom/netboot/sles/test.exlist&lt;/exlist&gt;
       &lt;extra&gt;
         &lt;dest&gt;/install/postscripts&lt;/dest&gt;
         &lt;src&gt;/install/postscripts/test&lt;/src&gt;
       &lt;/extra&gt;
       &lt;extra&gt;
         &lt;dest&gt;/tmp&lt;/dest&gt;
         &lt;src&gt;/install/netboot/sles11/ppc64/test1/rootimg/etc/fstab&lt;/src&gt;
       &lt;/extra&gt;
       &lt;extra&gt;
         &lt;dest&gt;/tmp/test1&lt;/dest&gt;
         &lt;src&gt;/tmp/test1&lt;/src&gt;
       &lt;/extra&gt;
       &lt;imagename&gt;myimage&lt;/imagename&gt;
       &lt;imagetype&gt;linux&lt;/imagetype&gt;
       &lt;kernel&gt;/install/netboot/sles11/ppc64/test/kernel&lt;/kernel&gt;
       &lt;netdrivers&gt;e1000&lt;/netdrivers&gt;
       &lt;osarch&gt;ppc64&lt;/osarch&gt;
       &lt;osname&gt;Linux&lt;/osname&gt;
       &lt;osvers&gt;sles11&lt;/osvers&gt;
       &lt;otherpkgdir&gt;/install/post/otherpkgs/sles11/ppc64&lt;/otherpkgdir&gt;
       &lt;otherpkglist&gt;/install/custom/netboot/sles/test.otherpkgs.pkglist&lt;/otherpkglist&gt;
       &lt;pkgdir&gt;/install/sles11/ppc64&lt;/pkgdir&gt;
       &lt;pkglist&gt;/install/custom/netboot/sles/test.pkglist&lt;/pkglist&gt;
       &lt;postinstall&gt;/install/custom/netboot/sles/test.postinstall&lt;/postinstall&gt;
       &lt;profile&gt;test&lt;/profile&gt;
       &lt;provmethod&gt;netboot&lt;/provmethod&gt;
       &lt;ramdisk&gt;/install/netboot/sles11/ppc64/test/initrd.gz&lt;/ramdisk&gt;
       &lt;rootimg&gt;/install/netboot/sles11/ppc64/test/rootimg.gz&lt;/rootimg&gt;
       &lt;rootimgdir&gt;/install/netboot/sles11/ppc64/test&lt;/rootimgdir&gt;
       &lt;synclists&gt;/tmp/mysync.list&lt;/synclists&gt;
       &lt;postscripts&gt;syslog,remoteshell,syncfiles,mypostscript&lt;/postscripts&gt;
       &lt;postbootscripts&gt;otherpkgs,mypostscript2&lt;/postbootscripts&gt;
     &lt;/xcatimage&gt;
    

  


### **copy image to a new profile**

This function is needed for the user who wants to create a image with a different profile on the same xCAT mn. They want to modify the new image for some other purpose. In this case, **imgexport** will work the same, **imgimport** will support the following option: 
    
       imgimport &lt;bundle_file_name&gt; --profile &lt;new_profile_name&gt;
    

The ._pkglist, .otherpkgs.pkglist, .postinstall_ files will be copyed into _/install/custom/netboot/&lt;os&gt;_ with the new profile name. A new image def will be created on the **osimage** and **linuximage** table with details. User make modifications and run 
    
        genimage &lt;image_name&gt;    
    

to work on the new image. Question: do we have any files in the image that is profile related? 

  


### **make destination optional for --extra flag for imgexport command**
    
      imgexport  --extra s&lt;rc_file_name:dest_dir&gt;
    

The file specified will be saved in the bundle file by **imgexport** command. The the file will be copied to the _dest_dir_ by the **imgimport** command. If _dest_dir_ is omitted, the file will be copied to the same directory as the source. 

### **litefile table for statelite**

For statelite, the litefile table settings for the image will be saved in a file called litefile.csv in the tabdump format by imgexport command. If the 'imgage' column is ALL or empty, it will be replaced with the image name in the file. When imgimport command is called, it will update the litefile table on the destination mn with the contents from litefile.csv. 

### **root image tree for statelite**

For stateless, rootimg.gz is exported, however the files under /install/netboot/&lt;os&gt;/&lt;arch&gt;/&lt;profile&gt;/rootimg are not needed. The user can simply run nodeset command the deploy the node after importing the image without the files. This does not work for statelite. For statelite, since the root image directory is mounted on the nodes, we will have to export it. We'll compress all the files under /install/netboot/&lt;os&gt;/&lt;arch&gt;/&lt;profile&gt;/rootimg and stored them in a file called rootimgtree.gz. When importing, all the files will be extracted and be saved to /install/netboot/&lt;os&gt;/&lt;arch&gt;/&lt;profile&gt;/rootimg on the new mn. 
