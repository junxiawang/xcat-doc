{{:Design Warning}} 

Several enhancements are being made to the xcatsetup command and the cluster config for xCAT 2.6. See the [xcatsetup man page](http://xcat.sourceforge.net/man8/xcatsetup.8.html) for the current documentation of the command and the cluster config file. 

The enhancements being worked on are: 

  * Allow all ranges to start at something other than 1. E.g. your frame range could be frame[05-20]. Unit test all cases. (Yin Le) 
  * Allow chars after the number range. Combine the attach and non-attach code. Now the range formats supported are: (Yin Le) 
    * f[1-2]c[01-10]p[1-8]a 
    * f[1-2]c[01-10]p[1-8] 
    * f[1-2]c[01-10]a 
    * f[1-2]c[01-10] 
    * n[01-20]a 
    * n[01-20] 
    * n01a-n20a 
    * n01-n20 
  * Support the new attribute for which hmc monitors a frame (ppc.sfp) using the xcat-frames:num-frames-per-hmc setting (Yin Le) - done 
  * Support sevice node pools and the routes table to automatically set up routes between MN and CNs thru the SNs: (Bruce) 
    * set noderes.servicenode for all nodes to a comma separated list of the 2 service nodes in the BB - done 
    * set the servicenode.ipforwarding attribute to 1 for all servicenodes - done 
    * populate the routes table with routes through the 2 SNs in each BB, both ways (from MN to CN and from CN to MN) 
    * set the new node attribute noderes.routenames (being added by Ling) to the routes being put in the routes table for this node - done 
    * set the new attribute site.mnroutenames to all of the routes for the MN - done 
    * (Ling will be updating makeroutes and adding a postcript to support routes from the nodes back to the MN.) 
  * Support redundant fsps/bpas. (Yin Le) 
    * Change the bpa/fsa objects into frame/cec objects (done) 
    * Create bpa and fsp objects (with IP addresses as their nodenames) that are children of the frames and cecs 
    * Don't assign IP addresses to the frames/cecs 
    * Add additional variables in the config file for the ranges of all 4 bpas and fsps 
  * Make it easy to use xcatsetup to create a single range of objects (Bruce) 
    * Includes supporting a new setting xcat-cecs:num-cecs-per-frame which avoids having to specify the supernode-list. 
  * Support a new setting xcat-service-lan:dhcp-dynamic-range and use it to fill in the networks.dynamicrange attribute, which will cause makedhcp to populate the DHCP config with it. It will also fill in site.dhcpinterfaces. (Yin Le) 
  * Support a new range format d001c01, where d is a sequential numbering of the drawers (cecs) for the whole cluster, and c is a simple numbering (1-8) of the compute nodes within the drawer. (Yin Le) 
    * For now, only support this for the xcat-compute-nodes stanza. For the SNs and storage nodes, support a format like bb01sn1. 
  * Add an option for xcatsetup to not change/overwrite objects that are already defined in the db. This allows the user to slightly expand the ranges in the cluster config file (e.g. if they got new hw) and rerun xcatsetup w/o losing modifications they have already made to existing objects in the db. (Yin Le) 
    * For the regular expressions that are used, nothing has to be done, because they won't override specific node entries 
    * For all the code that generates hashes of specific node entries, the code should first query the list of existing nodes and put it in a hash so it can quickly look up if a node exists and if so not write the values into the new hash. 
  * Write a new command called nodepos which will give all possible position info for a command: (bruce) 
    * if nodepos table is filled out, show that 
    * if system p, follow parent for lpar and display name/location of cec and frame 
    * show hfi location info (supernode #, lpar id, octant #, cec mtms, etc.) 
    * support going backwards, e.g. if they specify a cage # and lpar id, show the cec hostname and lpar hostname 
  * Support reading the cluster config file from stdin (Yin Le) 
    * the xcatclientnnr already reads stdin, so in setup.pm if they don't pass in a filename in the arg list, try reading from $request-&gt;{stdin} before returning an error. 
    * BTW, while you are testing this, could you change the code in both xcatclient and xcatclientnnr that reads stdin to a more efficient method. Change it from: 
    
    if (-p STDIN) {
       my $data;
       while ( &lt;STDIN&gt; ) { $data.=$_; }
       $cmdref-&gt;{stdin}-&gt;[0]=$data;
    }

to: 
    
    if (-p STDIN) {
      my @data = &lt;STDIN&gt;;
      $cmdref-&gt;{stdin}-&gt;[0]=join(_,@data);_
    }
