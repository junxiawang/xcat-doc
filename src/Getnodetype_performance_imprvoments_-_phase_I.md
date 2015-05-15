{{:Design Warning}} 

  
We think the following could be done and could gain a lot of performance improvement with minimal impact on the existing code. If I am missing something in the PPC code logic that will make this not work, please let me know. 

The DBobjUtils-&gt;getnodetype routine would have a new and optional input flag which would allow the calling routine to tell it what table to check first for it's nodetype. If the flag is not input, the logic will stay the same as today. The logic will be the following for both the array and single node processing: 

If the flag is not set 
    
      First read the nodetype table for the node or array of nodes to get the nodetype.
      If nodetype for the node is found save it
      if nodetype is another table (like PPC)
          read the  PPC table  for the  node's nodetype
          if found
             save it
         
     
    

If new flag is set to a table ( like PPC) 
    
     First read the PPC table for the node or array of nodes to get the nodetype
     If the node's nodetype is  found, save it
     If nodetype not found in the PPC table then
         read the nodetype table for the node's nodetype  ( or should we just return not found)
         If found, save it
         else If nodetype.nodetype points to a table (PPC)
            return nothing
         else If no nodetype
              return nothing
    

The plan would be to only modify the calling code to set this flag, if it can. This would mean we would not change a lot of calls to additionally read the nodetype parameter on the PPC table read. So for example, the following code would only be changed to add the new flag in PPCconn.pm 

  


my $node_parent_hash = $ppctab-&gt;getNodeAttribs( $node,[qw(parent)]); 
    
               #$nodetype    = $nodetype_hash-&gt;{nodetype};
               $nodetype = xCAT::DBobjUtils-&gt;getnodetype($node,"PPC");
    
