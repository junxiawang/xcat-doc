Capture an image from one running diskful Linux node, prepares the rootimg directory, kernel and initial rmadisks for the liteimg/packimage command to generate the statelite/stateless rootimg.  
  
Paramters:  


  * nodename&nbsp;: specify the image source.  


  
optional parameters:  


  * profile = profilename&nbsp;: Assign profile as the profile of the image to be created. 
  * osimage = imgname&nbsp;: Assign the predefined osimage object. The attributes of osimage will be used to capture and prepare the root image. 
  * bootinterface = interface name&nbsp;: The network interface the diskless node will boot over. 
  * netdriver = driver name&nbsp;: The driver modules needed for the network interface, which is used by the generage image API to generate initial ramdisks. 

  
For more details, refer [the man page of imgcapture](http://xcat.sourceforge.net/man1/imgcapture.1.html).  
  
Exemple:  

    
    POST https://myserver/xcatws/images/capture?userName=xxx&password=xxx

  


With data:  

    
    ["nodename=node1", "profile=hpc", "bootinterface=eth0", "netdriver=e1000e"]

  


Capture and prepare the root image: its profile is hpc, and the network interface the diskless node will boot over is eth0, the driver modules for this network interface is e1000e. 
