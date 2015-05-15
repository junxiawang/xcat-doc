<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [USING HP BL BLADES WITH XCAT2](#using-hp-bl-blades-with-xcat2)
- [USING HP BLADES WITH XCAT2](#using-hp-blades-with-xcat2)
- [USING HP DL SERVERS WITH XCAT2](#using-hp-dl-servers-with-xcat2)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

  
Note: this document needs updating! Post to the xCAT mailing list if you want to help.

  
Follow the instructions in [XCAT_iDataPlex_Cluster_Quick_Start], but use the adaptations below. 

The 1350 templates referred to in the above document likely won't apply to this environment, although they could be adapted. Or you can define the attributes explicitly as described in 
[XCAT_iDataPlex_Advanced_Setup/#manually-setup-the-node-attributes-instead-of-using-the-templates-or-switch-discovery](XCAT_iDataPlex_Advanced_Setup/#manually-setup-the-node-attributes-instead-of-using-the-templates-or-switch-discovery).
 

## USING HP BL BLADES WITH XCAT2

  1. To add a BL server nodes to the database, for example node01 to node04, and create (or add them to) a group called "blservers": 
        
        nodeadd node[01-04] groups=all,compute,blservers

  2. Specify the management and netboot attributes at a group level: 
        
        chdef -t group blservers mgt=ipmi netboot=xnba

**Note**: For BL blades with iLO version 2, the attribute 'mgt' shall be specified as 'hpilo'. 

  3. Tell xCAT to use the user name "admin" with the password "admPass" to access the BL blades: 
        
        chtab key=ipmi passwd.username=admin passwd.password=admPass

  4. Configure IP address for each node: 
        
        for i in {1..4}; do chdef node0$i ip=10.0.0.$i; done
        makehosts node
        makedns node
        

  5. Specify the mac address of the installation NIC for each node manually: 
        
        chdef node01 mac=f0:92:1c:00:0b:48

  6. Start OS provisioning: 
        
        
        nodeset node01 osimage=rhels5.8-x86_64-install-compute
        rsetboot node01 net
        rpower node01 on
        

## USING HP BLADES WITH XCAT2

  1. To add an HP enclosure Onboard Administrator, say "hpoa1," and create (or add it to) a group called "hpoa" to the database: 
        
        nodeadd hpoa1 groups=hpoa
        chtab node=hpoa nodehm.mgt=hpblade

  2. To add 4 Blade nodes to the database, say hpbl001 through hpbl004, and create (or add them to) a group called "hpblades": 
        
        nodeadd hpbl001-hpbl004 groups=all,compute,hpblades

  3. Add the HP Blades to the hardware management table: 
        
        chtab node=hpblades nodehm.cons=hpblade nodehm.mgt=hpblade

  4. Tell xCAT to use the user name "admin" with the password "admPass" to access all members of the "hpoa" group 
        
        chtab mpa=hpoa mpa.username=admin mpa.password=admPass

  5. Set up the management processor tables, with Blades 1 and 2 in device bays 1 and 2, and Blades 3 and 4 in device bays 9 and 10 
        
        chtab node=hpbl001 mp.mpa=hpoa mp.id=1
        chtab node=hpbl002 mp.mpa=hpoa mp.id=2
        chtab node=hpbl003 mp.mpa=hpoa mp.id=9
        chtab node=hpbl004 mp.mpa=hpoa mp.id=10

  6. Set up the console server to add the blades 
        
        makeconservercf
        service conserver stop
        service conserver start

  7. Use "getmacs" to identify the new nodes: 
        
        getmacs hpbl001-hpbl004

## USING HP DL SERVERS WITH XCAT2

  1. To add 4 DL server nodes to the database, say node1 to node4, and create (or add them to) a group called "dlservers": 
        
        nodeadd node1-node4 groups=all,compute,dlservers

  2. Add the servers to the hardware management table: 
        
        chtab node=dlservers nodehm.cons=hpilo nodehm.mgt=hpilo

  3. Tell xCAT to use the user name "admin" with the password "admPass" to access all members of the "dlservers" group: 
        
        chtab mpa=dlservers mpa.username=admin mpa.password=admPass

  4. Set up the console server to add the blades 
        
        makeconservercf
        service conserver stop
        service conserver start

  5. Use "getmacs" to identify the new nodes: 
        
        getmacs node1-node4
