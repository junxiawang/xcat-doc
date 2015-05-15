 This is a general guideline to support a new Linux distribution in xCAT.

An typical work flow of xCAT to support a newly released linux distribution is:

1.  setup a xCAT mgt server on RHEL7, make sure the following points, fix the problems if any:

    (1) successfully install all the xCAT core packages with xCAT dependency packages and OS shipped packages

    (2) successfully configure xCAT management node and start xCAT service 

2.  provision xCAT computer node with the RHEL7 iso, make sure the following points, fix the problems if any:

    (1) successfully copy in the RHEL7 iso with command  "copycds". for the Linux distributions belonging to or derived from the redhat-family,  such as centos, rh,fedora,sl, add the serial No in the .discinfo file in the iso, usually the 1st line, into the %distnames of perl-xCAT\data\discinfo.pm

   (2) successfully provision RHEL7 computer nodes with the diskful,statelite and stateless mode. in the past experience, "genimage" needs special attention.

3.  After the above 2 steps has been passed on the required platform(system P/X), transfer the test task to FVT  
Other Design Considerations

 

Other Design Considerations
•    Required reviewers: xCAT ALL
•    Required approvers: Li Guang Cheng
•    Database schema changes: N/A
•    Affect on other components: N/A
•    External interface changes, documentation, and usability issues: Yes
•    Packaging, installation, dependencies: N/A
•    Portability and platforms (HW/SW) supported: Tuleta, RHEL 7.
•    Performance and scaling considerations: N/A
•    Migration and coexistence: Yes
•    Serviceability: N/A
•    Security: N/A
•    NLS and accessibility: N/A
•    Invention protection: N/A