{{:Design Warning}} 

This mini design is under construction at this time. I will attempt to complete this design very soon 

This line item is intented to meet a new requirement to allow the admin to specify that all post boot scripts for a disk full node are to be run on every node reboot. 

This is a rough outline of the changes that will be made. This design will be updated to contain more details about why each of the changes are needed and the impact of the change to meet the new requirement. 

  1. in post.xcat → save xcatdsklspost script to /opt/xcat - used to run pstbootscripts 
  2. in post.xcat → add a new flag REBOOT=TRUE to xcatinfo file - used to signal xcatpostinit1 to invoke to xcatdsklspost 
  3. in post.xcat → remove "chkconfig xcatpostinit1 off" - this is no longer needed as xcatpostinit1 will always run and invoke xcatdsklspost to determine if we should run postbootscripts 
  4. xcatpostinit1 file changes 
    1. if REBOOT=TRUE (from xcatinfo file) -&gt; call xcatdsklspost script with new mode 6 
  5. add a new mode 6 to xcatdsklspost script - this mode repesents the node booting - and checks to see if admin wants to run post boot scripts. that was last week... 
    1. remove post script files from mypostscript - the post scripts are not run on boot 
    2. if RUNBOOTSCRIPTS!='yes' - remove postbootscripts from mypostscript - only keep the postbootscript in mypostscript when RUNBOOTSCRIPTS is 'yes' 

  
This is a list of all post.* files: 

  1. post.debian 
  2. post.esx 
  3. post.rh 
  4. post.rh.common 
  5. post.rh.iscsi 
  6. post.rhel5.s390x 
  7. post.rhel6.s390x 
  8. post.sles 
  9. post.sles.common 
  10. post.sles.iscsi 
  11. post.sles10.s390x 
  12. post.sles11 
  13. post.sles11.iscsi 
  14. post.sles11.raid1 
  15. post.sles11.s390x 
  16. post.ubuntu 
  17. post.xcat 

  
This is a list of post.* files which are currently using post.xcat: 

  1. post.rh 
  2. post.rh.iscsi 
  3. post.sles 
  4. post.sles.iscsi 
  5. post.sles11 
  6. post.sles11.iscsi 
  7. post.sles11.raid1 

  
this is a list of the files which are not using post.xcat and would need to include the changes above for post.xcat: 

  1. post.debian 
  2. post.esx 
  3. post.rh.common 
  4. post.rhel5.s390x 
  5. post.rhel6.s390x 
  6. post.sles.common 
  7. post.sles10.s390x 
  8. post.sles11.s390x 
  9. post.ubuntu 
