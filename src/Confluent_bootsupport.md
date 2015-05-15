[Design_Warning](Design_Warning)

Confluent will expand role in PXE boot process. xCAT delegates to dhcpd which imposes some steep requirements on some networks and misses opportunity to acheive some things.

To that end, confluent will start listening on 4011 and either providing stub responses over 67 or having dhcpd send next-server on our behalf.

Another feature will be the construction and control of service processor directed boot.  This allows us to inject data in a more trustworthy manner, enabling end-to-end secure deployment.  This function will likely require configuring which interface to boot from.


More generally speaking, deprecate use of anything but iPXE base.  Stop sending iPXE as a step in forcing hard disk boot (either send a dedicated utility for that purpose or nothing at all).