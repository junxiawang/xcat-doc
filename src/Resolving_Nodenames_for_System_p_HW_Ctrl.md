{{:Design Warning}} 

After further discussion in Pok about this topic, we are proposing the following approach/policy: for all of the system p hw ctrl, the code should 1st try to resolve nodenames to IP addresses using the system's name resolution (i.e. /etc/hosts or DNS) and if that fails, then try the xcat hosts table. This should work for all of the cases below: 

  1. Using the HMC for hw ctrl and admin doesn't want the fsps/bpas cluttering /etc/hosts so they never run makehosts for those nodenames: in this case, the code will always have to fail on the system name resolution before looking in the hosts table. But this shouldn't be that big of a performance impact because the only xcat cmds that require this resolution are run infrequently: mkhwconn, rspconfig. The rest of the cmds (e.g. rpower) only have to pass the fsp's mtms to the hmc. (BTW, the hmcs have to be in the system name resolution in all cases.) 
  2. Using the HMC for hw ctrl and admin doesn't mind having the fsps/bpas in /etc/hosts: in this case, they run makehosts (and optionally makedns) and our code will always find the nodename there and won't ever end up looking in the hosts table. 
  3. Using fsp direct 

Our general policy should still be that the system name resolution is used by xcat to resolve nodenames, not the hosts table. But case #1 above is left as a concession to users because when the hmc is used for management, it mostly hides the fsps/bpas, so we shouldn't require that they be in /etc/hosts. 

BTW, a common function to first try system name res and then try the hosts table should be used and put in one of the PPC perl modules. (Maybe this already exists?) 

This discussion also led us to the next discussion of how to handle the case where some operations need to be handled thru direct attach and others (e.g. hw service event collection) still need to be handled by the hmc. We propose the following solution: nodehm.power or nodehm.mgt should still be set to "fsp". For each fsp row in the ppc table, ppc.hcp will be set to its own fsp nodename. Add a new attribute to the ppc table called "otherhcp". For each fsp, this attr will be filled in with the nodename of the hmc that is connected to this fsp. Here are some examples of how these attrs will be used: 

  * rpower of a compute node (lpar) will still work the same: see nodehm.power or mgt set to "fsp" and go to the ppc table and ppcdirect table to get the info about the fsp to connect to. 
  * rpower of an fsp (cec) will see nodehm.power set to "fsp" and go to the ppc table and ppcdirect table to get the info about the fsp to connect to to do the cec power on or off. 
  * mkhwconn -t of an fsp or bpa will see nodehm.power set to "fsp" and go to the ppc table. It will use ppc.hcp (set to the fsp itself) to give hw svr the associated IP address. And it will use ppc.otherhcp (set to the hmc nodename) to tell the hmc it should manage this fsp/bpa. 

Note, that the above is not used for the purpose of handling redundant hw ctrl points. For redundant fsps/bpas, ppc.hcp will still only contain the nodename of one fsp/bpa. If contacting that fails, the code will look in the vpd table for another entry with the same mtms, but different side attribute, and try that. This approach won't work for redundant hmcs (because the mtms's will be different), but we don't think we need to support that case. 
