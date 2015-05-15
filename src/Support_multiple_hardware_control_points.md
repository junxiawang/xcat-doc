<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Support for multiple hardware control points](#support-for-multiple-hardware-control-points)
- [This feature can be used by several xCAT components and features:](#this-feature-can-be-used-by-several-xcat-components-and-features)
- [There are some restrictions in the support for multiple hardware control points:](#there-are-some-restrictions-in-the-support-for-multiple-hardware-control-points)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

#### Support for multiple hardware control points

The existing xCAT hardware control structure does not support more than one hardware control point for each node, the multiple hardware control points support is needed in some configuration scenarios, such as the HMC redundancy and FSP redundancy, and the Direct Attach is also requiring to try different methods(fsp-api, ASMI and HMC) before indicating that the operation failed. This mini design will describe how to support multiple hardware control points for each node. 

The main idea is to specify comma separated hardware control points with the node attribute ppc.hcp, then xCAT will try the hcps one by one until find a hardware control point that can succeed. If any of the hardware control point fails due to any reason, then sequentially try the next hcp specified in the hcp attribute. If all of the hcps failed, then tell the users why it fails on different hardware control points. When trying the hcps, the type of hcp can be determined by the hardware type of the hcp itself, the hcp has to be defined as a node in xCAT database anyway. Please notice that: if the hcp's type is fsp or bpa, it will run the command through fsp-api firstly; If it succeeds, the command will return; If it fails, the command will try the ASMI method secondly. 

#### This feature can be used by several xCAT components and features:

1\. fsp-api and HMC: the fsp-api does not support all necessary features for now, so we need HMC to perform some operations are not supported by fsp-api. 

2\. The fsp/bpa redundancy support that we plan to implement later this year can take advantage of this solution. 

3\. This can be treated as a new feature that xCAT can support multiple hardware control points for each node, system p does support two HMCs connected to the FSP/BPA, then xCAT can be used in this configuration scenario with this new feature. I believe this new general feature can be used in some other scenarios such as the blade management module redundancy. 

Question: Will performance be a problem if xCAT needs to try the hardware control points one by one? 

#### There are some restrictions in the support for multiple hardware control points:

1.Multiple hardware control points only support for system P machine. 

2.For rcons, the value of the node's cons attribute should be set to "multiple" 

3.specify comma separated hardware control points with the node attribute ppc.hcp. 

     NOTE: When running command with noderange, it's required that the hcps' types of the nodes in the noderange are in the same order. Four examples as the following are correct: 
    
      node     hcp 
     node1  fsp1,hmc1
     node2  fsp2,hmc2
     node3  fsp3
     node4  fsp4,hmc4
    

, 
    
     node      hcp 
     node1  hmc1,fsp1
     node2  hmc2,fsp2
     node3  hmc3
     node4  hmc4,fsp4
    

, 
    
      node     hcp 
     node1  fsp1,fsp12
     node2  fsp2,fsp22
     node3  fsp3
     node4  fsp4,fsp42
    

and 
    
     node      hcp 
     node1  hmc1,hmc12
     node2  hmc2,hmc22
     node3  hmc3
     node4  hmc4,hmc42
    

but the following two examples are wrong: 
    
     node      hcp 
     node1  fsp1,hmc1
     node2  hmc2,fsp2
     node3  hmc3
     node4  hmc4,fsp4
     
    

and 
    
     node     hcp
     node1  hmc1,fsp1
     node2  hmc2,fsp2
     node3  fsp3
     node4  hmc4,fsp4
     
    

4.For hierarchy environment, it's required that the service node for one node's hcps should be the same one. 
