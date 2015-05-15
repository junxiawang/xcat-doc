xCAT supports a variety of deployment mechanisms. A summary matrix that applies to xCAT 2.0 RC2: 

RHEL5/CentOS5 
Fedora 8 
Fedora 9 
SLES10 
RHEL4/CentOS4 

Disk Install 
kickstart 
kicksstart 
kickstart 
autoyast 
kickstart 

Stateful Diskless 
kickstart 
kickstart 
kickstart 
autoyast 
Not supported 

Stateless Diskless 
Implemented 
Implemented 
90% Implemented (some upstart-related tweaks needed) 
Implemented (squashfs/nfs not tested) 
Not yet implemented (Requires geninitrd modifications for RHEL4 era utilities) 

Note that currently imaging based solutions (systemimage/partimage) are not yet conveniently wrapped. 
