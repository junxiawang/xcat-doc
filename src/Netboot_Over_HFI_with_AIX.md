This guide describes the initial iteration of the xCAT support for booting a node over an HFI network with AIX 71B. 

  1. Install xCAT and DB2 on AIX management node. 
    1. Install and configure an xCAT management node. See the following xCAT document for details: [XCAT_AIX_Cluster_Overview_and_Mgmt_Node] 
    2. DB2 supports remote access from service node to management node and HPC software. Configure DB2 on management node following document: [Setting_Up_DB2_as_the_xCAT_DB] 
    3. To setup the hardwares and create the hardware connections between management node and BPA/FSPs in PERCS without HMC, please contact IBM to get the latest hardware server, fsp-api builds and instructions, following document include hardware management and making hardware connections: [XCAT_System_p_Hardware_Management] 
    4. To use HPC software, you need to install additional xCAT package which is not installed by default. The package is distributed in xCAT-core tarball: 
            
            rpm -Uvh xCAT-IBMhpc*.rpm

  2. Download HFI packages 

    There are several seperate packages required for boot over HFI including NIM server/HFI device driver/xCAT scripts. Contact IBM to get the builds. In this example, we assume all the packages have been downloaded and extracted to /hfi folder on management node. 
Following are the required AIX packages: 
        
        
        bootpd
        cpio
        dd/README
        dd/devices.chrp.IBM.HFI
        dd/devices.common.IBM.hfi
        dd/if_hf
        dd/xCATaixHFIdd.bnd
        nim/bos.sysmgt
        scripts/confighfi
        scripts/confignim
        scripts/synclist

  3. Update the /etc/hosts file In the Power 775 system, the management node will only have Ethernet NIC. Service node will have local disks, Ethernet NIC and HFI network. The compute nodes will not have a local disk or an Ethernet NIC. Since there are no local disks, the nodes will run the OS in diskless mode, and since there are no Ethernet NICs, the HFI/ISR network will be used for client/server communications, including boot. 

    The examples in this guide assume the following IP addresses and hostnames: 
        
        
        10.0.0.208 c250mgrs03-pvt //management node
        10.7.2.5 c250f07c02ap05.ppd.pok.ibm.com c250f07c02ap05 //host name and IP of the ethernet network interface on service node.
        20.7.2.5 c250f07c02ap05-hf0.ppd.pok.ibm.com c250f07c02ap05-hf0 //service node
        21.7.2.5 c250f07c02ap05-hf1.ppd.pok.ibm.com c250f07c02ap05-hf1 //service node
        22.7.2.5 c250f07c02ap05-hf2.ppd.pok.ibm.com c250f07c02ap05-hf2 //service node
        23.7.2.5 c250f07c02ap05-hf3.ppd.pok.ibm.com c250f07c02ap05-hf3 //service node
        20.7.2.9 c250f07c02ap09-hf0.ppd.pok.ibm.com c250f07c02ap09-hf0 //compute node
        21.7.2.9 c250f07c02ap09-hf1.ppd.pok.ibm.com c250f07c02ap09-hf1 //compute node
        22.7.2.9 c250f07c02ap09-hf2.ppd.pok.ibm.com c250f07c02ap09-hf2 //compute node
        23.7.2.9 c250f07c02ap09-hf3.ppd.pok.ibm.com c250f07c02ap09-hf3 //compute node

    Make sure /etc/hosts on Management node contains hostnames for the ethernet interface and the HFI interface for the service node(s). 
  4. Define the service node and compute node 

    If there is no HMC configured to manage the Power 775 hardwares, you have to define the service nodes and compute nodes manually. If the hardwares are managed by HMC, you can use xCAT command "rscan" to generate the compute node definition. See [man page of rscan](http://xcat.sourceforge.net/man1/rscan.1.html) for more details. 

    This is an example of service node definition in a [mkdef stanza file](http://xcat.sourceforge.net/man5/xcatstanzafile.5.html): 
        
        c250f07c02ap05:
        objtype=node
        arch=ppc64
        cons=fsp
        groups=all,service //Specify service group indicate this is a service node.
        hcp=f07c02fsp1_a //FSP node definition that managed it.
        id=5
        installnic=en0
        ip=10.7.2.5
        mgt=fsp
        monserver=10.0.0.208
        nfsserver=10.0.0.208
        nodetype=lpar,osi
        os=AIX
        parent=f07c02fsp1_a //Set to Fsp that manage it.
        postbootscripts=servicenode
        pprofile=c250f07c02ap05
        primarynic=en0
        provmethod=1040A_SN
        setupconserver=0
        setupdhcp=1
        setupftp=1
        setupnfs=1
        setuptftp=1
        tftpserver=10.0.0.208
        xcatmaster=10.0.0.208

  
This is an example of the compute node's definition: 
        
        c250f07c02ap09-hf0:
        objtype=node
        arch=ppc64
        cons=fsp
        currchain=boot
        currstate=boot
        groups=lpar,all
        hcp=Server-9125-F2C-SNP7IH019-A
        id=9
        ip=10.4.32.224
        mgt=fsp
        nodetype=lpar,osi
        os=AIX
        parent=Server-9458-100-SNBPCF007-A
        pprofile=xcatnode9
        servicenode=c250f07c02ap05
        xcatmaster=c250f07c02ap05-hf0

You can put the definition into one stanza file and import it to xCAT with the mkdef xCAT command. 
        
        cat /percs/hfi/c250f07c02ap09-hf0.stanza | mkdef -z

  5. Install service node(s) and install HFI device drivers and NIM to service node(s). 
    1. Create NIM image for service node 
            
            mknimimage -s /percs/aiximages/aix/ 1040A_SN

where /install/aiximages/1040a/aix/ contains the AIX image. 

**Note:** If there are existing resource, you can specify the resource type and value as an option of mknimimage so mknimimage will not create same resource type. For example you have copied one lpp_source "1040A_SN_lpp_source" to /install/nim/lpp_source and created NIM lpp source "1040A_SN_lpp_source" then you can just use it to avoiding creating new lpp_source with command: 
            
            mknimimage -s /install/aiximages/1040a/aix/ 1040A_SN lpp_source=1040A_SN_lpp_source spot=1040A_SN -f

    2. Add required service node software Following steps add the HFI device driver, replace the NIM with new version, and replace the bootpd birnay for HFI support. Please aware that this software is to work with HFI support. There is still some other software needing to be installed on service node. Please check the "Add required service node software" in service node setup document for more packages: [Setting_Up_an_AIX_Hierarchical_Cluster#Add_required_service_node_software] 
    3. Update the HFI device driver to lpp source 
            
            inutoc /hfi/dd/
            nim -o update -a packages=all -a source=/hfi/dd/ 1040A_SN_lpp_source

    4. Define HFI device driver installp bundle 
            
            nim -o define -t installp_bundle -a server=master -a location=/hfi/dd/xCATaixHFIdd.bnd xCATaixHFIdd

    5. Assign HFI devices drivers isntallp bundle to service node image so they will be installed during service node installation. 
            
            chdef -t osimage -o 1040A_SN installp_bundle=xCATaixHFIdd,xCATaixSN71

Where installp_bundle should have been defined when installing required service node software. 

    6. Configure HFI interfaces with postscript 
            
            cp /hfi/scripts/confighfi /install/postscripts/
            cp /hfi/scripts/confignim /install/postscripts/
            chdef -t osimage -o 1040A_SN synclists=/hfi/scripts/synclist
            chdef c250f07c02ap05 postscripts=confighfi,confignim

    7. If you are using an existing NIM resource including HPC softwares, two steps needs to be done to automatically install and configure the HPC softwares 
      1. Create installp bundles which specified what are HPC softwares need to be installed: 
                
                mkdir -p /install/nim/installp_bundle
                cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_base.bnd /install/nim/installp_bundle
                nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/IBMhpc_base.bnd IBMhpc_base
                cp /opt/xcat/share/xcat/IBMhpc/IBMhpc_all.bnd /install/nim/installp_bundle
                nim -o define -t installp_bundle -a server=master -a location=/install/nim/installp_bundle/IBMhpc_all.bnd IBMhpc_all
                chdef -t osimage -o 1040A_SN installp_bundle="xCATaixHFIdd,xCATaixSN71,IBMhpc_base,IBMhpc_all"

      2. Assign the postscripts to service node to configure the HPC softwares automatically. 
                
                cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postbootscript /install/postscripts
                cp -p /opt/xcat/share/xcat/IBMhpc/IBMhpc.postscript /install/postscripts
                cp -p /opt/xcat/share/xcat/IBMhpc/gpfs/gpfs_updates /install/postscripts
                cp -p /opt/xcat/share/xcat/IBMhpc/compilers/compilers_license /install/postscripts
                cp -p /opt/xcat/share/xcat/IBMhpc/pe/pe_install /install/postscripts
                cp -p /opt/xcat/share/xcat/IBMhpc/essl/essl_install /install/postscripts
                cp -p /opt/xcat/share/xcat/IBMhpc/loadl/loadl_install /install/postscripts
                chdef c250f07c02ap05 postscripts=confighfi,confignim,IBMhpc.postbootscript

For more details and steps about HPC integration, please review following page: [Setting_up_all_IBM_HPC_products_in_a_Stateful_Cluster] 

    8. Then follow the service node setup document starting from "Section Define xCAT networks" to install service node. [Setting_Up_an_AIX_Hierarchical_Cluster] 
    9. Check if HFI interfaces are up after service node is setup. 
            
            xdsh c250f07c02ap05 ifconfig hf0

  6. Create a diskless image for the compute nodes. 
        
        mknimimage -V -f -r -t diskless -s /percs/aiximages/aix 1040A_CN

where /install/AIX71GOLD/ contains the AIX 710 GOLD source images. 

Same as diskfull images creation, if there are existing resource, you can specify the resource type and value as an option of mknimimage so mknimimage will not create same resource type. For example, you have copied one lpp_source 1040A_CN_lpp_source to /install/nim/lpp_source, then you can just use it to avoiding creating new lpp_source with command: 
        
        mknimimage -V -f -r -t diskless -s /install/AIX71GOLD/ 1040A_CNlpp_source=1040A_CN_lpp_source spot=1040A_CN 1040A_CN

  7. Update the spot 

    Note: Skip this step if you are using the existing image including HFP softwares since all the packages have been updated into the image 

    See the following doc for updating and adding required software 
Setting_Up_an_AIX_Hierarchical_Cluster#Install_the_cluster_nodes 
  8. Create an xCAT HFI network definition 

    Run a command similar to the following: 
        
        mkdef -t network -o hfinet net=20.0.0.0 mask=255.0.0.0 gateway=20.7.2.5

  9. Install HFI device driver into spot 

    (Skip this step if you are using the existing image including HFP softwares since all the packages have been updated) 

    Install the HFI device driver into the spot on the management node. 
        
        inutoc /hfi/dd/
        nim -o update -a packages=all -a source=/hfi/dd 1040A_CN_lpp_source

where: /percs/hfi/dd contains the HFI device driver installp packages. 
        
        chdef -t osimage -o 1040A_CN installp_bundle="xCATaixHFIdd,xCATaixCN71"

Where xCATaixCN71 should have been defined when add the additional softwares into spot. 
        
        mknimimage -u 1040A_CN

  10. synchronize /etc/hosts to SPOT to bring up all the HFI interfaces on compute nodes 
        
        chdef -t osimage -o 1040A_CN synclists=/hfi/scripts/synclist
        mknimimage -u 1040A_CN

  11. If you are using the existing NIM resource including HPC softwares, you need to assign the postscripts to computes node to configure the HPC softwares automatically.(Optional) 
        
        chdef c250f07c02ap09-hf0 postscripts=IBMhpc.postbootscript

  12. Initialize console for the compute node. 
        
        makeconservercf

  13. Add confighfi postscript to compute node to config HFI interfaces automatically. 
        
        cp /hfi/scripts/confighfi /install/postscripts/
        chdef c250f07c02ap09-hf0 postscripts=confighfi,IBMhpc.postbootscript

Note: remove the IBMhpc.postbootscript if you are not using a diskless image with HPC softwares. 

  14. Get the MAC address of the compute node 
        
        getmacs c250f07c02ap09-hf0 -D --hfi

  15. Initialize the AIX/NIM diskless nodes 
        
        mkdsklsnode -i 1040A_CN c250f07c02ap09-hf0 --hfi -f -V

  16. Open remote console 

    Open another window, login to the management node (ih1901) and run the following command to watch the installation from the console: 
        
        rcons c250f07c02ap09-hf0

  17. Boot the compute node 
        
        rnetboot c250f07c02ap09-hf0 --hfi
