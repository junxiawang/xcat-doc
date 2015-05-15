Retrieve information about images.  
Without arguments, this returns a list all of the images' name:  
  
If data about a specific image is needed, the imagename can be used and if fewer fields are needed, they can be specified.  
optional parameters:  
field - a field to get info for. Any number of these can be used, the field name can be: profile, imagetype, provmethod, rootfstype, osname, osvers, osdistro, osarch, synclists, postscripts, postbootscripts  
  
Examples:  

    
    GET https://myserver/xcatws/images?userName=xxx&password=xxx

  


Get all images' name.  
  

    
    GET https://myserver/xcatws/images/rhel54?userName=xxx&password=xxx&field=imagetype&field=profile

  


Get image rhel54's attribute imagetype and profile value. 
