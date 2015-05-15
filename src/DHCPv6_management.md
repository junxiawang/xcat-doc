{{:Design Warning}} 

In DHCPv6, the identifier shifts from MAC address of the specific interface to a system wide DUID. Given the goal of trying to preserve current general behavior, xCAT will have to examine and modify supported install images to generate a consistent DUID that spans installations. Depending on mechanism, it may also be required that xCAT modify stateful installed image to re-source DUID from a secondary source on every boot prior to network bringup to avoid DUID cloning. Four options are possible: 

  * Use IPv4 to bootstrap and have xCAT hand down arbitrary DUIDs managed centrally 
  * Use DUID-LL to generate the same DUID regardless of time and refresh DUID contents on every boot (may be considered a violation of RFC3315 with regards to behavior on NIC change) 
  * Use DUID-EN to derive an identifier out of some enterprise number and the UUID. This may be workable for OS installs, but not likely to match netboot firmware. Note we'd have to not use the vendor number of the provider of the equipment, as that would be a violation of the RFC unless that vendor has signed off on it explicitly. 
  * Get a new DUID method adopted in the industry (preferred option, http://tools.ietf.org/html/draft-narten-dhc-duid-uuid-01 in progress) 
    * DUID-UUID an optimal solution, where the DUID contents is simply a well-known type number (i.e. 4) plus UUID 
    * UUID validity assurance required for replacement parts (cross-vendor implementation a challenge). 
      * If UUID invalid, fallback to DUID-LLT 
      * If DUID-LLT, boot discovery image, discovery image gets system discovered and on a system without existing UUID in xCAT, generate a new one, if replacement detected, restore old UUID 

For each existing platform, must pre-populate DUID prior to network bringup. 

For dhcp6c systems (RHEL5, SLES11, and similar vintage): 

  * Update /var/lib/dhcpv6/dhcp6c_duid 
    * Binary file, first two bytes DUID length followed by DUID in binary representation 
    * POWER/x86 Endian difference matters, bytes in file are host-order, not network-order 
    * xxd Can be used to create dhcp6c_duid 
    * RHEL5, little hope for provisioning time DUID type switch before it gets stage2, initrd too monolithic 
    * Unfortunately, it only works once. dhcp6c successfully reads and uses the DUID, but on exit corrupts the DUID by trancating it. 

For Windows Vista/2k8 and newer: 

  * Modify HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\Dhcpv6DUID 
    * Already checked into 2.5 using wmic to get the UUID 

For ISC DHCP 4+ clients (i.e. RHEL6, ESXi4.1): 

  * Modify dhclient6.leases to have a 'defualt-duid' setting amenable to our needs. For example, if a system had UUID c4b72aec-bdd3-42a3-8d47-76b79a8a9c95: 
    
    
    default-duid "\000\004\304\267*\354\275\323B\243\215Gv\267\232\212\234\225";
    

  * Rough perl code to convert hex UUID to this string format: 
    
    
    $uuid =~ s/-//g;
    $uuid =~ s/://g;
    $uuid =~ s/(..)/\1:/g;
    my @uuid = split /:/,$uuid;
    foreach (@uuid) {
    	$_ = hex($_);
    	if ($_ 

  * More useful shell code to extract and convert UUID that could be executed from the stock RHEL6 install initrd: 
    
    
    duid='default-duid "\000\004';
    for i in `sed -e s/-//g -e 's/\(..\)/\1 /g' /sys/devices/virtual/dmi/id/product_uuid`; do
    	num=`printf "%d" 0x$i`
    	octnum=`printf "\\%03o" 0x$i`
    	if [ $num -lt 127 -a $num -gt 31 ]; then
    		octnum=`printf $octnum`
    	fi
    	duid=$duid$octnum
    done
    duid=$duid'";'
    echo $duid &gt; &lt;leasefilehere&gt;
    

  * Extracting UUID: 
    * Linux systems use dmidecode 
    * Windows systems use wmic csproduct 
      * xCAT has an implementation checked into 2.5 (pending finalizing the DUID type number) 
    * ESXi uses vsish -e get /hardware/machineUUID 
      * xCAT has an implementation checked in for ESXi stateless 4.1 (pending finalizing the DUID type number) 
    * RHEL6 /sys/devices/virtual/dmi/id/product_uuid 
