xCAT_P8LE_cuda_installing
=========================

Overview
--------

The cuda packages provided by nvidia include both the runtime libraries for computing and dev tools for programming and monitoring. In xCAT, we split the packages into 2 groups: the cudaruntime package set and the cudafull package set.
Since the full package set is so large. xCAT suggests only installing the runtime libraries on your Compute Nodes (CNs), and the full cuda package set on your ubuntu Management Node or your monitor/development nodes. 

Install xCAT MN and discover p8le node
--------------------------------------

Follow the instructions in ref:`ubuntu-os-support-label`. to install your xCAT Management Node and do hardware discovery for p8le nodes.

Prepare cuda repo on xCAT Management Node
-----------------------------------------

Currently, there are 2 types of Ubuntu repos for installing cuda-7-0 on p8LE hardware: The online repo and local package repo. 

The online repo
~~~~~~~~~~~~~~

The online repo will provide a sourcelist entry which includes the URL with the location of the cuda packages. The online repo can be used directly by Compute Nodes. The source.list entry will be similar to: ::
      deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1410/ppc64el /       

The local package repo
~~~~~~~~~~~~~~~~~~~~~~

A local package repo will contain all of the cuda packages.


