xCAT 2.0.3 changes: 

  * Fix bug where too many BMCs/Bladecenters being queried at once would fail 
  * Fix numerous instances of 'Unexpected Client disconnect' 
  * Alter template to preclude Xen kernel 
  * Fix [2017647] rpower report "Node not defined in 'nodetype' database" 
  * Fix rpower output to error on unsupported subcommands 
  * Correct bug where rpower reset on blade would always say 'on reset' regardless of previous state. 
  * Fixed output displaying IVM instead of FSP 
  * Fix bug where iSCSI would make increasingly small disks for a noderange 
  * fixed a problem that only returns the node status for one node for fping monitorng 
  * Fix problem where tabdump without arguments would fail 
  * Fix bug where makedhcp -a before mac table exists would result in an error 
  * Fix some *def cmd useability issues 
  * psh report exit code when client exits with non-zero 
  * update the 'rr' scheme scripts 
  * Error verbosity improvements on some commands and situations 
  * Fix rsyslog setup of Fedora 9. 
  * Fix typo in reventlog for IPMI 
  * Fix '|||' expressions in table not evaluating as expected. 
  * Fix problem with lsdef command listing removed def. 
  * Fix mkdef stanza file support 
  * Correct problem where service nodes would incorrectly interpret plugin redirections 
  * Fix problem where stateless stacking called out incorrect path to fstab 
  * Fix rspconfig to accomodate MM bay number variance. 
  * Fix rinv problem where some FRU data may cause rinv to crash 
