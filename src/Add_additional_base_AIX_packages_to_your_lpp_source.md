Some of the HPC products require additional AIX packages that may not be part of your default AIX lpp_source. Review the following file to verify all the AIX packages needed by the HPC products are included in your lpp_source (instructions are provided below for copying and editing this file if you choose to use a different list of packages): 

~~~~    
      /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd
~~~~
    

To list the contents of your lpp_source, you can use: 
 
~~~~   
      nim -o showres <lpp_source_name>
~~~~    

And to add additional packages to your lpp_source, you can use the nim update command similar to above specifying your AIX distribution media and the AIX packages you need. 
