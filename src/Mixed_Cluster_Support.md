![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

**Disclaimers:**

  * The mixed cluster support is not high on the priority list for xCAT's road map.  This may mean that  mixed cluster problems might not be able to get attention from the xCAT development team if you are not providing strong justification on why it is critical. 
  * Mixed cluster support is a big topic, we could not verify all the configuration scenarios, we are trying to document the scenarios that we have verified using this doc. 

**General rules:**

  * Diskful installation should work in most of the mixed cluster scenarios, but it is not possible for the development and testing team to verify all of the combinations. If you run into problem with the diskful installation in mixed cluster, feel free to let us know, either through posting on the mailing list or submitting xCAT bugs. 
  * Diskless provisioning is only supported between the distributions with same architecture and same major version. For example, x86_64 RHEL 6.2 and x86_64 RHEL 6.3. If the MN/SN does not have the same architecture or same major version with the CNs, a separate machine which has the same architecture and the same major version with the CNs is needed, the diskless images should be created on this separate machine, see [Building_a_Stateless_Image_of_a_Different_Architecture_or_OS] for more details. 
  * For DFM managed Power machine running in PowerVM mode, the Management Node can be Rh7.1 ppc64le, RH for x86_64, RH and sles for ppc64, and AIX. For more information about DFM management, pls see [xCAT_System_p_Hardware_Management_for_DFM_Managed_Systems].

**Docs for different configuration scenarios:**

  * [Mixed_Cluster_Support_Matrix] 
  * [Linux_AIX_mixed_cluster_configuration] 
  * [Mixed_Cluster_Support_for_SLES] 
