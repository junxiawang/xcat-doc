Include all of the HPC software in your xCAT management node. 

  * Install the optional xCAT-IBMhpc rpm on your xCAT management node. This rpm is available with xCAT 
and should already exist in your zypper or yum repository that you used to install xCAT 
on your managaement node. A new copy can be downloaded from: [the xCAT download web site](http://xcat.sourceforge.net/#download)

    To install the rpm in SLES: 

~~~~    
      zypper refresh
      zypper install xCAT-IBMhpc
~~~~     

    To install the rpm in Redhat: 

~~~~     
      yum install xCAT-IBMhpc
~~~~     

  * If you have a hierarchical cluster with service nodes, install the optional xCAT-IBMhpc rpm on all of your xCAT service nodes: 

    

  * Add xCAT-IBMhpc to your otherpkgs list: 
 
~~~~    
        vi /install/custom/install/<ostype>/<service-profile>.otherpkgs.pkglist
~~~~

   * If this is a new file, add the following to use the service profile shipped with xCAT:

~~~~
       #INCLUDE:/opt/xcat/share/xcat/install/<os>/service.<osver>.<arch>.otherpkgs.pkglist#
~~~~

   * Either way, add this line:

~~~~
        xcat/xcat-core/xCAT-IBMhpc
~~~~     

    

  * If your service nodes are already installed and running, update the software on your service nodes: 

~~~~     
      updatenode <service-noderange> -S
~~~~     

  * Copy all of your IBM HPC product software to the following locations: 

~~~~
    
       /install/post/otherpkgs/<osver>/<arch>/<product>
~~~~    

     where &lt;product&gt; is: 

~~~~
    gpfs 
    loadl 
    pe 
    essl 
    compilers 
    rsct 
~~~~

For rhels6 ppc64, the locations are: 

~~~~
    
      /install/post/otherpkgs/rhels6/ppc64/<product>
~~~~    

Note1: Several of the products require the System Resource Controller (src) rpm.
Please ensure this rpm is included with your other rpms in one of the above directories
before proceeding. 


Note2: For GPFS, only the base GPFS rpms can be placed in the above directories. 
If you have GPFS updates, copy them to the following location: 
   
~~~~ 
      /install/post/otherpkgs/gpfs_updates    
~~~~

Note3: Several products require special Java rpms to run their license acceptance scripts. 
The correct versions of these rpms are identified in the respective product documentation. 
Ensure the Java rpms are included in the corresponding product otherpkgs directory. 
