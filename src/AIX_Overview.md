xCAT may be used to support cluster environments that use the AIX operating system. 

In an xCAT cluster the single point of control is the xCAT _management node_. In an AIX cluster the management node must be an AIX system and must be configured as an AIX NIM master. 

Before using xCAT on an AIX cluster you should become familiar with the AIX operating system and Network Installation Manager (NIM) tools. For more information about NIM, see the _IBM AIX Installation Guide and Reference_. (&lt;http://www-03.ibm.com/servers/aix/library/index.html&gt;) 

**This document assumes that you have already installed and configured your xCAT AIX management node by following the process described in the AIX overview document.** [XCAT_AIX_Cluster_Overview_and_Mgmt_Node]. 

For large scale cluster environments xCAT provides support for using additional installation servers. In an xCAT cluster these additional servers are referred to as _service nodes_. 

For an xCAT on AIX cluster there is a primary NIM master which is on the xCAT management node(MN). The service nodes(SN) are configured as additional NIM masters. All commands are run on the management node. The xCAT support automatically handles the NIM setup on the low level service nodes and the distribution of the NIM resources. All installation resources for the cluster are managed from the primary NIM master. The NIM resources are automatically replicated on the low level masters when they are needed. 

You can set up one or more service nodes in an xCAT cluster. The number you need will depend on many factors including the number of nodes in the cluster, the type of node deployment, the type of network etc. 

AIX service nodes must be diskfull (NIM standalone) systems. 

**This document contains a section on how to set up and use xCAT service nodes. If you do not need service nodes in your cluster then simply skip this section.**

xCAT uses AIX/NIM commands to support diskless and standalone NIM clients. For standalone clients you may choose either an "rte" or a "mksysb" type installation. 

For more information on using these installation methods please refer to the following documents. 

  * Installing AIX standalone nodes (using NIM rte method) [XCAT_AIX_RTE_Diskfull_Nodes] 
  * Cloning AIX nodes (install using AIX mksysb image) [XCAT_AIX_mksysb_Diskfull_Nodes] 
  * Installing AIX diskless nodes (using stateless,statelite,stateful methods) [XCAT_AIX_Diskless_Nodes] 
