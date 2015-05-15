Review the following pkglist file and all of the files it includes: 

~~~~    
     /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.pkglist 
~~~~    

If you do not need to make any changes and are able to use the file as shipped, add an #INCLUDE ...# statement for this file to your custom pkglist: 

~~~~
    
      vi /install/custom/install/<ostype>/<profile>.pkglist
      Add the following line, substituting <osver> and <arch? with the correct values:
      #INCLUDE /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.pkglist#
~~~~    

    

For rhels6 ppc64, please edit the following file: 
 
~~~~   
      vi /install/custom/install/rh/compute.pkglist
      #INCLUDE:/opt/xcat/share/xcat/IBMhpc/compute.rhels6.ppc64.pkglist#
~~~~    

If you need to make changes to any of the files, you can copy the file to your custom directory
 
~~~~    
     cp /opt/xcat/share/xcat/IBMhpc/compute.<osver>.<arch>.pkglist \
    /install/custom/install/<ostype>/<profile>.pkglist
~~~~    

and modify it or you can copy the contents of the file into your
 &lt;profile&gt;.pkglist and edit as you wish instead of using the #INCLUDE: ...# entry. 

Note: This pkglist support is available with xCAT 2.5 and newer releases. 
If you are using an older release of xCAT, you will need to add the entries listed in
 these pkglist files to your Kickstart or AutoYaST install template file. 
