check an AIX osimage created by xCAT.  
This API currently supported for AIX osimages only. Use this API to verify if the NIM lpp_source directories contain the correct software.  
optional parameters:  
clean&nbsp;: Remove any older versions of the rpms. Keep the version with the latest timestamp.  
For more introduction, refer [the man page of chkosimage](http://xcat.sourceforge.net/man1/chkosimage.1.html).  
  
Examples:  

    
    PUT https://myserver/xcatws/images/61img/check?userName=xxx&password=xxx

  


Check the XCAT osimage called "61img" to verify that the lpp_source directories contain all the software that is specified in the "installp_bundle" and "otherpkgs" attributes.  
  

    
    PUT https://myserver/xcatws/images/61img/check?userName=xxx&password=xxx

  
With data: 
    
    ["clean"]

  


Clean up the lpp_source directory for the osimage named "61img" by removing any older rpms with the same names but different versions. 
