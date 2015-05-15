<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Token Resources](#token-resources)
  - [](#)
  - [](#-1)
  - [\[URI:/tokens\] - The authentication token resource.](#%5Curitokens%5C---the-authentication-token-resource)
    - [POST - Create a token.](#post---create-a-token)
  - [](#-2)
- [Node Resources](#node-resources)
  - [](#-3)
  - [](#-4)
  - [\[URI:/nodes\] - The node list resource.](#%5Curinodes%5C---the-node-list-resource)
    - [GET - Get all the nodes in xCAT.](#get---get-all-the-nodes-in-xcat)
  - [](#-5)
  - [\[URI:/nodes/{noderange}\] - The node resource](#%5Curinodesnoderange%5C---the-node-resource)
    - [GET - Get all the attibutes for the node {noderange}.](#get---get-all-the-attibutes-for-the-node-noderange)
  - [](#-6)
    - [PUT - Change the attibutes for the node {noderange}.](#put---change-the-attibutes-for-the-node-noderange)
  - [](#-7)
    - [POST - Create the node {noderange}.](#post---create-the-node-noderange)
  - [](#-8)
    - [DELETE - Remove the node {noderange}.](#delete---remove-the-node-noderange)
  - [](#-9)
  - [\[URI:/nodes/{noderange}/attrs/{attr1,attr2,attr3 ...}\] - The attributes resource for the node {noderange}](#%5Curinodesnoderangeattrsattr1attr2attr3-%5C---the-attributes-resource-for-the-node-noderange)
    - [GET - Get the specific attributes for the node {noderange}.](#get---get-the-specific-attributes-for-the-node-noderange)
  - [](#-10)
  - [\[URI:/nodes/{noderange}/host\] - The mapping of ip and hostname for the node {noderange}](#%5Curinodesnoderangehost%5C---the-mapping-of-ip-and-hostname-for-the-node-noderange)
    - [POST - Create the mapping of ip and hostname record for the node {noderange}.](#post---create-the-mapping-of-ip-and-hostname-record-for-the-node-noderange)
  - [](#-11)
  - [\[URI:/nodes/{noderange}/dns\] - The dns record resource for the node {noderange}](#%5Curinodesnoderangedns%5C---the-dns-record-resource-for-the-node-noderange)
    - [POST - Create the dns record for the node {noderange}.](#post---create-the-dns-record-for-the-node-noderange)
  - [](#-12)
    - [DELETE - Remove the dns record for the node {noderange}.](#delete---remove-the-dns-record-for-the-node-noderange)
  - [](#-13)
  - [\[URI:/nodes/{noderange}/dhcp\] - The dhcp record resource for the node {noderange}](#%5Curinodesnoderangedhcp%5C---the-dhcp-record-resource-for-the-node-noderange)
    - [POST - Create the dhcp record for the node {noderange}.](#post---create-the-dhcp-record-for-the-node-noderange)
  - [](#-14)
    - [DELETE - Remove the dhcp record for the node {noderange}.](#delete---remove-the-dhcp-record-for-the-node-noderange)
  - [](#-15)
  - [\[URI:/nodes/{noderange}/nodestat}\] - The attributes resource for the node {noderange}](#%5Curinodesnoderangenodestat%5C---the-attributes-resource-for-the-node-noderange)
    - [GET - Get the running status for the node {noderange}.](#get---get-the-running-status-for-the-node-noderange)
  - [](#-16)
  - [\[URI:/nodes/{noderange}/subnodes\] - The sub-nodes resources for the node {noderange}](#%5Curinodesnoderangesubnodes%5C---the-sub-nodes-resources-for-the-node-noderange)
    - [GET - Return the Children nodes for the node {noderange}.](#get---return-the-children-nodes-for-the-node-noderange)
  - [](#-17)
  - [\[URI:/nodes/{noderange}/power\] - The power resource for the node {noderange}](#%5Curinodesnoderangepower%5C---the-power-resource-for-the-node-noderange)
    - [GET - Get the power status for the node {noderange}.](#get---get-the-power-status-for-the-node-noderange)
  - [](#-18)
    - [PUT - Change power status for the node {noderange}.](#put---change-power-status-for-the-node-noderange)
  - [](#-19)
  - [\[URI:/nodes/{noderange}/energy\] - The energy resource for the node {noderange}](#%5Curinodesnoderangeenergy%5C---the-energy-resource-for-the-node-noderange)
    - [GET - Get all the energy status for the node {noderange}.](#get---get-all-the-energy-status-for-the-node-noderange)
  - [](#-20)
    - [PUT - Change energy attributes for the node {noderange}.](#put---change-energy-attributes-for-the-node-noderange)
  - [](#-21)
  - [\[URI:/nodes/{noderange}/energy/{cappingmaxmin,cappingstatus,cappingvalue ...}\] - The specific energy attributes resource for the node {noderange}](#%5Curinodesnoderangeenergycappingmaxmincappingstatuscappingvalue-%5C---the-specific-energy-attributes-resource-for-the-node-noderange)
    - [GET - Get the specific energy attributes cappingmaxmin,cappingstatus,cappingvalue ... for the node {noderange}.](#get---get-the-specific-energy-attributes-cappingmaxmincappingstatuscappingvalue--for-the-node-noderange)
  - [](#-22)
  - [\[URI:/nodes/{noderange}/sp/{community|ip|netmask|...}\] - The attribute resource of service processor for the node {noderange}](#%5Curinodesnoderangespcommunity%7Cip%7Cnetmask%7C%5C---the-attribute-resource-of-service-processor-for-the-node-noderange)
    - [GET - Get the specific attributes for service processor resource.](#get---get-the-specific-attributes-for-service-processor-resource)
  - [](#-23)
    - [PUT - Change the specific attributes for the service processor resource.](#put---change-the-specific-attributes-for-the-service-processor-resource)
  - [](#-24)
  - [\[URI:/nodes/{noderange}/nextboot\] - The temporary bootorder resource in next boot for the node {noderange}](#%5Curinodesnoderangenextboot%5C---the-temporary-bootorder-resource-in-next-boot-for-the-node-noderange)
    - [GET - Get the next bootorder.](#get---get-the-next-bootorder)
  - [](#-25)
    - [PUT - Change the next boot order.](#put---change-the-next-boot-order)
  - [](#-26)
  - [\[URI:/nodes/{noderange}/bootstate\] - The boot state resource for node {noderange}.](#%5Curinodesnoderangebootstate%5C---the-boot-state-resource-for-node-noderange)
    - [GET - Get boot state.](#get---get-boot-state)
  - [](#-27)
    - [PUT - Set the boot state.](#put---set-the-boot-state)
  - [](#-28)
  - [\[URI:/nodes/{noderange}/vitals\] - The vitals resources for the node {noderange}](#%5Curinodesnoderangevitals%5C---the-vitals-resources-for-the-node-noderange)
    - [GET - Get all the vitals attibutes.](#get---get-all-the-vitals-attibutes)
  - [](#-29)
  - [\[URI:/nodes/{noderange}/vitals/{temp|voltage|wattage|fanspeed|power|leds...}\] - The specific vital attributes for the node {noderange}](#%5Curinodesnoderangevitalstemp%7Cvoltage%7Cwattage%7Cfanspeed%7Cpower%7Cleds%5C---the-specific-vital-attributes-for-the-node-noderange)
    - [GET - Get the specific vitals attibutes.](#get---get-the-specific-vitals-attibutes)
  - [](#-30)
  - [\[URI:/nodes/{noderange}/inventory\] - The inventory attributes for the node {noderange}](#%5Curinodesnoderangeinventory%5C---the-inventory-attributes-for-the-node-noderange)
    - [GET - Get all the inventory attibutes.](#get---get-all-the-inventory-attibutes)
  - [](#-31)
  - [\[URI:/nodes/{noderange}/inventory/{pci|model...}\] - The specific inventory attributes for the node {noderange}](#%5Curinodesnoderangeinventorypci%7Cmodel%5C---the-specific-inventory-attributes-for-the-node-noderange)
    - [GET - Get the specific inventory attibutes.](#get---get-the-specific-inventory-attibutes)
  - [](#-32)
  - [\[URI:/nodes/{noderange}/eventlog\] - The eventlog resource for the node {noderange}](#%5Curinodesnoderangeeventlog%5C---the-eventlog-resource-for-the-node-noderange)
    - [GET - Get all the eventlog for the node {noderange}.](#get---get-all-the-eventlog-for-the-node-noderange)
  - [](#-33)
    - [DELETE - Clean up the event log for the node {noderange}.](#delete---clean-up-the-event-log-for-the-node-noderange)
  - [](#-34)
  - [\[URI:/nodes/{noderange}/beacon\] - The beacon resource for the node {noderange}](#%5Curinodesnoderangebeacon%5C---the-beacon-resource-for-the-node-noderange)
    - [PUT - Change the beacon status for the node {noderange}.](#put---change-the-beacon-status-for-the-node-noderange)
  - [](#-35)
  - [\[URI:/nodes/{noderange}/updating\] - The updating resource for the node {noderange}](#%5Curinodesnoderangeupdating%5C---the-updating-resource-for-the-node-noderange)
    - [POST - Update the node with file syncing, software maintenance and rerun postscripts.](#post---update-the-node-with-file-syncing-software-maintenance-and-rerun-postscripts)
  - [](#-36)
  - [\[URI:/nodes/{noderange}/filesyncing\] - The filesyncing resource for the node {noderange}](#%5Curinodesnoderangefilesyncing%5C---the-filesyncing-resource-for-the-node-noderange)
    - [POST - Sync files for the node {noderange}.](#post---sync-files-for-the-node-noderange)
  - [](#-37)
  - [\[URI:/nodes/{noderange}/sw\] - The software maintenance for the node {noderange}](#%5Curinodesnoderangesw%5C---the-software-maintenance-for-the-node-noderange)
    - [POST - Perform the software maintenance process for the node {noderange}.](#post---perform-the-software-maintenance-process-for-the-node-noderange)
  - [](#-38)
  - [\[URI:/nodes/{noderange}/postscript\] - The postscript resource for the node {noderange}](#%5Curinodesnoderangepostscript%5C---the-postscript-resource-for-the-node-noderange)
    - [POST - Run the postscripts for the node {noderange}.](#post---run-the-postscripts-for-the-node-noderange)
  - [](#-39)
  - [\[URI:/nodes/{noderange}/nodeshell\] - The nodeshell resource for the node {noderange}](#%5Curinodesnoderangenodeshell%5C---the-nodeshell-resource-for-the-node-noderange)
    - [POST - Run the command in the shell of the node {noderange}.](#post---run-the-command-in-the-shell-of-the-node-noderange)
  - [](#-40)
  - [\[URI:/nodes/{noderange}/nodecopy\] - The nodecopy resource for the node {noderange}](#%5Curinodesnoderangenodecopy%5C---the-nodecopy-resource-for-the-node-noderange)
    - [POST - Copy files to the node {noderange}.](#post---copy-files-to-the-node-noderange)
  - [](#-41)
  - [\[URI:/nodes/{noderange}/vm\] - The virtualization node {noderange}.](#%5Curinodesnoderangevm%5C---the-virtualization-node-noderange)
    - [PUT - Change the configuration for the virtual machine {noderange}.](#put---change-the-configuration-for-the-virtual-machine-noderange)
  - [](#-42)
  - [](#-43)
  - [](#-44)
    - [POST - Create the vm node {noderange}.](#post---create-the-vm-node-noderange)
  - [](#-45)
    - [DELETE - Remove the vm node {noderange}.](#delete---remove-the-vm-node-noderange)
  - [](#-46)
  - [\[URI:/nodes/{noderange}/vmclone\] - The clone resource for the virtual node {noderange}.](#%5Curinodesnoderangevmclone%5C---the-clone-resource-for-the-virtual-node-noderange)
    - [POST - Create a clone master from node {noderange}. Or clone the node {noderange} from a clone master.](#post---create-a-clone-master-from-node-noderange-or-clone-the-node-noderange-from-a-clone-master)
  - [](#-47)
  - [](#-48)
  - [\[URI:/nodes/{noderange}/vmmigrate\] - The virtualization resource for migration.](#%5Curinodesnoderangevmmigrate%5C---the-virtualization-resource-for-migration)
    - [POST - Migrate a node to targe node.](#post---migrate-a-node-to-targe-node)
  - [](#-49)
- [Osimage resources](#osimage-resources)
  - [](#-50)
  - [](#-51)
  - [\[URI:/osimages\] - The osimage resource.](#%5Curiosimages%5C---the-osimage-resource)
    - [GET - Get all the osimage in xCAT.](#get---get-all-the-osimage-in-xcat)
  - [](#-52)
    - [POST - Create the osimage resources base on the parameters specified in the Data body.](#post---create-the-osimage-resources-base-on-the-parameters-specified-in-the-data-body)
  - [](#-53)
  - [](#-54)
  - [\[URI:/osimages/{imgname}\] - The osimage resource](#%5Curiosimagesimgname%5C---the-osimage-resource)
    - [GET - Get all the attibutes for the osimage {imgname}.](#get---get-all-the-attibutes-for-the-osimage-imgname)
  - [](#-55)
    - [PUT - Change the attibutes for the osimage {imgname}.](#put---change-the-attibutes-for-the-osimage-imgname)
  - [](#-56)
    - [POST - Create the osimage {imgname}.](#post---create-the-osimage-imgname)
  - [](#-57)
    - [DELETE - Remove the osimage {imgname}.](#delete---remove-the-osimage-imgname)
  - [](#-58)
  - [\[URI:/osimages/{imgname}/attrs/attr1,attr2,attr3 ...\] - The attributes resource for the osimage {imgname}](#%5Curiosimagesimgnameattrsattr1attr2attr3-%5C---the-attributes-resource-for-the-osimage-imgname)
    - [GET - Get the specific attributes for the osimage {imgname}.](#get---get-the-specific-attributes-for-the-osimage-imgname)
  - [](#-59)
  - [\[URI:/osimages/{imgname}/instance\] - The instance for the osimage {imgname}](#%5Curiosimagesimgnameinstance%5C---the-instance-for-the-osimage-imgname)
    - [POST - Operate the instance of the osimage {imgname}.](#post---operate-the-instance-of-the-osimage-imgname)
  - [](#-60)
  - [](#-61)
  - [](#-62)
    - [DELETE - Delete the stateless or statelite image instance for the osimage {imgname} from the file system](#delete---delete-the-stateless-or-statelite-image-instance-for-the-osimage-imgname-from-the-file-system)
  - [](#-63)
- [Network Resources](#network-resources)
  - [](#-64)
  - [](#-65)
  - [\[URI:/networks\] - The network list resource.](#%5Curinetworks%5C---the-network-list-resource)
    - [GET - Get all the networks in xCAT.](#get---get-all-the-networks-in-xcat)
  - [](#-66)
    - [POST - Create the networks resources base on the network configuration on xCAT MN.](#post---create-the-networks-resources-base-on-the-network-configuration-on-xcat-mn)
  - [](#-67)
  - [\[URI:/networks/{netname}\] - The network resource](#%5Curinetworksnetname%5C---the-network-resource)
    - [GET - Get all the attibutes for the network {netname}.](#get---get-all-the-attibutes-for-the-network-netname)
  - [](#-68)
    - [PUT - Change the attibutes for the network {netname}.](#put---change-the-attibutes-for-the-network-netname)
  - [](#-69)
    - [POST - Create the network {netname}. DataBody: {attr1:v1,att2:v2...}.](#post---create-the-network-netname-databody-attr1v1att2v2)
  - [](#-70)
    - [DELETE - Remove the network {netname}.](#delete---remove-the-network-netname)
  - [](#-71)
  - [\[URI:/networks/{netname}/attrs/attr1,attr2,...\] - The attributes resource for the network {netname}](#%5Curinetworksnetnameattrsattr1attr2%5C---the-attributes-resource-for-the-network-netname)
    - [GET - Get the specific attributes for the network {netname}.](#get---get-the-specific-attributes-for-the-network-netname)
  - [](#-72)
- [Policy Resources](#policy-resources)
  - [](#-73)
  - [](#-74)
  - [\[URI:/policy\] - The policy resource.](#%5Curipolicy%5C---the-policy-resource)
    - [GET - Get all the policies in xCAT.](#get---get-all-the-policies-in-xcat)
  - [](#-75)
  - [\[URI:/policy/{policy_priority}\] - The policy resource](#%5Curipolicypolicy_priority%5C---the-policy-resource)
    - [GET - Get all the attibutes for a policy {policy_priority}.](#get---get-all-the-attibutes-for-a-policy-policy_priority)
  - [](#-76)
    - [PUT - Change the attibutes for the policy {policy_priority}.](#put---change-the-attibutes-for-the-policy-policy_priority)
  - [](#-77)
    - [POST - Create the policy {policyname}. DataBody: {attr1:v1,att2:v2...}.](#post---create-the-policy-policyname-databody-attr1v1att2v2)
  - [](#-78)
    - [DELETE - Remove the policy {policy_priority}.](#delete---remove-the-policy-policy_priority)
  - [](#-79)
  - [\[URI:/policy/{policyname}/attrs/{attr1,attr2,attr3,...}\] - The attributes resource for the policy {policy_priority}](#%5Curipolicypolicynameattrsattr1attr2attr3%5C---the-attributes-resource-for-the-policy-policy_priority)
    - [GET - Get the specific attributes for the policy {policy_priority}.](#get---get-the-specific-attributes-for-the-policy-policy_priority)
  - [](#-80)
- [Group Resources](#group-resources)
  - [](#-81)
  - [](#-82)
  - [\[URI:/groups\] - The group list resource.](#%5Curigroups%5C---the-group-list-resource)
    - [GET - Get all the groups in xCAT.](#get---get-all-the-groups-in-xcat)
  - [](#-83)
  - [\[URI:/groups/{groupname}\] - The group resource](#%5Curigroupsgroupname%5C---the-group-resource)
    - [GET - Get all the attibutes for the group {groupname}.](#get---get-all-the-attibutes-for-the-group-groupname)
  - [](#-84)
    - [PUT - Change the attibutes for the group {groupname}.](#put---change-the-attibutes-for-the-group-groupname)
  - [](#-85)
  - [\[URI:/groups/{groupname}/attrs/{attr1,attr2,attr3 ...}\] - The attributes resource for the group {groupname}](#%5Curigroupsgroupnameattrsattr1attr2attr3-%5C---the-attributes-resource-for-the-group-groupname)
    - [GET - Get the specific attributes for the group {groupname}.](#get---get-the-specific-attributes-for-the-group-groupname)
  - [](#-86)
- [Global Configuration Resources](#global-configuration-resources)
  - [](#-87)
  - [](#-88)
  - [\[URI:/globalconf\] - The global configuration resource.](#%5Curiglobalconf%5C---the-global-configuration-resource)
    - [GET - Get all the xCAT global configuration.](#get---get-all-the-xcat-global-configuration)
  - [](#-89)
  - [\[URI:/globalconf/attrs/{attr1,attr2 ...}\] - The specific global configuration resource.](#%5Curiglobalconfattrsattr1attr2-%5C---the-specific-global-configuration-resource)
    - [GET - Get the specific configuration in global.](#get---get-the-specific-configuration-in-global)
  - [](#-90)
    - [PUT - Change the global attributes.](#put---change-the-global-attributes)
  - [](#-91)
    - [DELETE - Remove the site attributes.](#delete---remove-the-site-attributes)
  - [](#-92)
- [Service Resources](#service-resources)
  - [](#-93)
  - [](#-94)
  - [\[URI:/services/dns\] - The dns service resource.](#%5Curiservicesdns%5C---the-dns-service-resource)
    - [POST - Initialize the dns service.](#post---initialize-the-dns-service)
  - [](#-95)
  - [\[URI:/services/dhcp\] - The dhcp service resource.](#%5Curiservicesdhcp%5C---the-dhcp-service-resource)
    - [POST - Create the dhcpd.conf for all the networks which are defined in the xCAT Management Node.](#post---create-the-dhcpdconf-for-all-the-networks-which-are-defined-in-the-xcat-management-node)
  - [](#-96)
  - [\[URI:/services/host\] - The hostname resource.](#%5Curiserviceshost%5C---the-hostname-resource)
    - [POST - Create the ip/hostname records for all the nodes to /etc/hosts.](#post---create-the-iphostname-records-for-all-the-nodes-to-etchosts)
  - [](#-97)
  - [\[URI:/services/slpnodes\] - The nodes which support SLP in the xCAT cluster](#%5Curiservicesslpnodes%5C---the-nodes-which-support-slp-in-the-xcat-cluster)
    - [GET - Get all the nodes which support slp protocol in the network.](#get---get-all-the-nodes-which-support-slp-protocol-in-the-network)
  - [](#-98)
  - [\[URI:/services/slpnodes/{CEC|FRAME|MM|IVM|RSA|HMC|CMM|IMM2|FSP...}\] - The slp nodes with specific service type in the xCAT cluster](#%5Curiservicesslpnodescec%7Cframe%7Cmm%7Civm%7Crsa%7Chmc%7Ccmm%7Cimm2%7Cfsp%5C---the-slp-nodes-with-specific-service-type-in-the-xcat-cluster)
    - [GET - Get all the nodes with specific slp service type in the network.](#get---get-all-the-nodes-with-specific-slp-service-type-in-the-network)
  - [](#-99)
- [Table Resources](#table-resources)
  - [](#-100)
  - [](#-101)
  - [\[URI:/tables/{tablelist}/nodes/{noderange}\] - The node table resource](#%5Curitablestablelistnodesnoderange%5C---the-node-table-resource)
    - [GET - Get attibutes of tables for a noderange.](#get---get-attibutes-of-tables-for-a-noderange)
  - [](#-102)
  - [](#-103)
    - [PUT - Change the node table attibutes for {noderange}.](#put---change-the-node-table-attibutes-for-noderange)
  - [](#-104)
  - [\[URI:/tables/{tablelist}/nodes/nodes/{noderange}/{attrlist}\] - The node table attributes resource](#%5Curitablestablelistnodesnodesnoderangeattrlist%5C---the-node-table-attributes-resource)
    - [GET - Get table attibutes for a noderange.](#get---get-table-attibutes-for-a-noderange)
  - [](#-105)
  - [\[URI:/tables/{tablelist}/rows\] - The non-node table resource](#%5Curitablestablelistrows%5C---the-non-node-table-resource)
    - [GET - Get all rows from non-node tables.](#get---get-all-rows-from-non-node-tables)
  - [](#-106)
  - [\[URI:/tables/{tablelist}/rows/{keys}\] - The non-node table rows resource](#%5Curitablestablelistrowskeys%5C---the-non-node-table-rows-resource)
    - [GET - Get attibutes for rows from non-node tables.](#get---get-attibutes-for-rows-from-non-node-tables)
  - [](#-107)
    - [PUT - Change the non-node table attibutes for the row that matches the {keys}.](#put---change-the-non-node-table-attibutes-for-the-row-that-matches-the-keys)
  - [](#-108)
    - [DELETE - Delete rows from a non-node table that have the attribute values specified in {keys}.](#delete---delete-rows-from-a-non-node-table-that-have-the-attribute-values-specified-in-keys)
  - [](#-109)
  - [\[URI:/tables/{tablelist}/rows/{keys}/{attrlist}\] - The non-node table attributes resource](#%5Curitablestablelistrowskeysattrlist%5C---the-non-node-table-attributes-resource)
    - [GET - Get specific attibutes for rows from non-node tables.](#get---get-specific-attibutes-for-rows-from-non-node-tables)
  - [](#-110)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)


#Token Resources#
The URI list which can be used to create tokens for account .


---

---
##\[URI:/tokens\] - The authentication token resource.##
###POST - Create a token.###
**Returns:**

* An array of all the global configuration list.

**Example:**
Aquire a token for user 'root'.

    #curl -X POST -k 'https://127.0.0.1/xcatws/tokens?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"userName":"root","password":"cluster"}'
    {
       "token":{
          "id":"a6e89b59-2b23-429a-b3fe-d16807dd19eb",
          "expire":"2014-3-8 14:55:0"
       }
    }

---
#Node Resources#
The URI list which can be used to create, query, change and manage node objects.


---

---
##\[URI:/nodes\] - The node list resource.##
This resource can be used to display all the nodes which have been defined in the xCAT database.

###GET - Get all the nodes in xCAT.###
The attributes details for the node will not be displayed.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An array of node names.

**Example:**
Get all the node names from xCAT database.

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes?userName=root&password=cluster&pretty=1'
    [
       "node1",
       "node2",
       "node3",
    ]

---
##\[URI:/nodes/{noderange}\] - The node resource##
###GET - Get all the attibutes for the node {noderange}.###
The keyword ALLRESOURCES can be used as {noderange} which means to get node attributes for all the nodes.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get all the attibutes for node 'node1'.

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "profile":"compute",
          "netboot":"xnba",
          "arch":"x86_64",
          "mgt":"ipmi",
          "groups":"all",
          ...
       }
    }

---
###PUT - Change the attibutes for the node {noderange}.###
Refer to the man page:[chdef](http://xcat.sourceforge.net/man1/chdef.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {attr1:v1,att2:v2,...}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Change the attributes mgt=dfm and netboot=yaboot.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/nodes/node1?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"mgt":"dfm","netboot":"yaboot"}'

---
###POST - Create the node {noderange}.###
Refer to the man page:[mkdef](http://xcat.sourceforge.net/man1/mkdef.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {attr1:v1,att2:v2,...}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Create a node with attributes groups=all, mgt=dfm and netboot=yaboot

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node1?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"groups":"all","mgt":"dfm","netboot":"yaboot"}'

---
###DELETE - Remove the node {noderange}.###
Refer to the man page:[rmdef](http://xcat.sourceforge.net/man1/rmdef.1.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Delete the node node1

    #curl -X DELETE -k 'https://127.0.0.1/xcatws/nodes/node1?userName=root&password=cluster&pretty=1'

---
##\[URI:/nodes/{noderange}/attrs/{attr1,attr2,attr3 ...}\] - The attributes resource for the node {noderange}##
###GET - Get the specific attributes for the node {noderange}.###
The keyword ALLRESOURCES can be used as {noderange} which means to get node attributes for all the nodes.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get the attributes {groups,mgt,netboot} for node node1

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/attrs/groups,mgt,netboot?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "netboot":"xnba",
          "mgt":"ipmi",
          "groups":"all"
       }
    }

---
##\[URI:/nodes/{noderange}/host\] - The mapping of ip and hostname for the node {noderange}##
###POST - Create the mapping of ip and hostname record for the node {noderange}.###
Refer to the man page:[makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Create the mapping of ip and hostname record for node 'node1'.

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node1/host?userName=root&password=cluster&pretty=1'

---
##\[URI:/nodes/{noderange}/dns\] - The dns record resource for the node {noderange}##
###POST - Create the dns record for the node {noderange}.###
The prerequisite of the POST operation is the mapping of ip and noderange for the node has been added in the /etc/hosts.

Refer to the man page:[makedns](http://xcat.sourceforge.net/man8/makedns.8.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Create the dns record for node 'node1'.

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node1/dns?userName=root&password=cluster&pretty=1'

---
###DELETE - Remove the dns record for the node {noderange}.###
Refer to the man page:[makedns](http://xcat.sourceforge.net/man8/makedns.8.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Delete the dns record for node node1

    #curl -X DELETE -k 'https://127.0.0.1/xcatws/nodes/node1/dns?userName=root&password=cluster&pretty=1'

---
##\[URI:/nodes/{noderange}/dhcp\] - The dhcp record resource for the node {noderange}##
###POST - Create the dhcp record for the node {noderange}.###
Refer to the man page:[makedhcp](http://xcat.sourceforge.net/man8/makedhcp.8.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Create the dhcp record for node 'node1'.

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node1/dhcp?userName=root&password=cluster&pretty=1'

---
###DELETE - Remove the dhcp record for the node {noderange}.###
Refer to the man page:[makedhcp](http://xcat.sourceforge.net/man8/makedhcp.8.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Delete the dhcp record for node node1

    #curl -X DELETE -k 'https://127.0.0.1/xcatws/nodes/node1/dhcp?userName=root&password=cluster&pretty=1'

---
##\[URI:/nodes/{noderange}/nodestat}\] - The attributes resource for the node {noderange}##
###GET - Get the running status for the node {noderange}.###
Refer to the man page:[nodestat](http://xcat.sourceforge.net/man1/nodestat.1.html).

**Returns:**

* An object which includes multiple entries like: <nodename> : { nodestat : <node state> }

**Example:**
Get the running status for node node1

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/nodestat?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "nodestat":"noping"
       }
    }

---
##\[URI:/nodes/{noderange}/subnodes\] - The sub-nodes resources for the node {noderange}##
###GET - Return the Children nodes for the node {noderange}.###
Refer to the man page:[rscan](http://xcat.sourceforge.net/man1/rscan.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get all the children nodes for node 'node1'.

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/subnodes?userName=root&password=cluster&pretty=1'
    {
       "cmm01node09":{
          "mpa":"ngpcmm01",
          "parent":"ngpcmm01",
          "serial":"1035CDB",
          "mtm":"789523X",
          "cons":"fsp",
          "hwtype":"blade",
          "objtype":"node",
          "groups":"blade,all,p260",
          "mgt":"fsp",
          "nodetype":"ppc,osi",
          "slotid":"9",
          "hcp":"10.1.9.9",
          "id":"1"
       },
       ...
    }

---
##\[URI:/nodes/{noderange}/power\] - The power resource for the node {noderange}##
###GET - Get the power status for the node {noderange}.###
Refer to the man page:[rpower](http://xcat.sourceforge.net/man1/rpower.1.html).

**Returns:**

* An object which includes multiple entries like: <nodename> : { power : <powerstate> }

**Example:**
Get the power status.

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/power?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "power":"on"
       }
    }

---
###PUT - Change power status for the node {noderange}.###
Refer to the man page:[rpower](http://xcat.sourceforge.net/man1/rpower.1.html).

**Parameters:**

* Json Formatted DataBody: {action:on/off/reset ...}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Change the power status to on

    #curl -X PUT -k 'https://127.0.0.1/xcatws/nodes/node1/power?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"action":"on"}'

---
##\[URI:/nodes/{noderange}/energy\] - The energy resource for the node {noderange}##
###GET - Get all the energy status for the node {noderange}.###
Refer to the man page:[renergy](http://xcat.sourceforge.net/man1/renergy.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get all the energy attributes.

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/energy?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "cappingmin":"272.3 W",
          "cappingmax":"354.0 W"
          ...
       }
    }

---
###PUT - Change energy attributes for the node {noderange}.###
Refer to the man page:[renergy](http://xcat.sourceforge.net/man1/renergy.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {powerattr:value}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Turn on the cappingstatus to [on]

    #curl -X PUT -k 'https://127.0.0.1/xcatws/nodes/node1/energy?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"cappingstatus":"on"}'

---
##\[URI:/nodes/{noderange}/energy/{cappingmaxmin,cappingstatus,cappingvalue ...}\] - The specific energy attributes resource for the node {noderange}##
###GET - Get the specific energy attributes cappingmaxmin,cappingstatus,cappingvalue ... for the node {noderange}.###
Refer to the man page:[renergy](http://xcat.sourceforge.net/man1/renergy.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get the energy attributes which are specified in the URI.

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/energy/cappingmaxmin,cappingstatus?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "cappingmin":"272.3 W",
          "cappingmax":"354.0 W"
       }
    }

---
##\[URI:/nodes/{noderange}/sp/{community|ip|netmask|...}\] - The attribute resource of service processor for the node {noderange}##
###GET - Get the specific attributes for service processor resource.###
Refer to the man page:[rspconfig](http://xcat.sourceforge.net/man1/rspconfig.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get the snmp community for the service processor of node1.

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/sp/community?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "SP SNMP Community":"public"
       }
    }

---
###PUT - Change the specific attributes for the service processor resource. ###
Refer to the man page:[rspconfig](http://xcat.sourceforge.net/man1/rspconfig.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {community:public}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Set the snmp community to [mycommunity].

    #curl -X PUT -k 'https://127.0.0.1/xcatws/nodes/node1/sp/community?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"value":"mycommunity"}'

---
##\[URI:/nodes/{noderange}/nextboot\] - The temporary bootorder resource in next boot for the node {noderange}##
###GET - Get the next bootorder.###
Refer to the man page:[rsetboot](http://xcat.sourceforge.net/man1/rsetboot.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get the bootorder for the next boot. (It's only valid after setting.)

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/nextboot?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "nextboot":"Network"
       }
    }

---
###PUT - Change the next boot order. ###
Refer to the man page:[rsetboot](http://xcat.sourceforge.net/man1/rsetboot.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {order:net/hd}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Set the bootorder for the next boot.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/nodes/node1/nextboot?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"order":"net"}'

---
##\[URI:/nodes/{noderange}/bootstate\] - The boot state resource for node {noderange}.##
###GET - Get boot state.###
Refer to the man page:[nodeset](http://xcat.sourceforge.net/man8/nodeset.8.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get the next boot state for the node1.

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/bootstate?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "bootstat":"boot"
       }
    }

---
###PUT - Set the boot state.###
Refer to the man page:[nodeset](http://xcat.sourceforge.net/man8/nodeset.8.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {osimage:xxx}/{state:offline}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Set the next boot state for the node1.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/nodes/node1/bootstate?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"osimage":"rhels6.4-x86_64-install-compute"}'

---
##\[URI:/nodes/{noderange}/vitals\] - The vitals resources for the node {noderange}##
###GET - Get all the vitals attibutes.###
Refer to the man page:[rvitals](http://xcat.sourceforge.net/man1/rvitals.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get all the vitails attributes for the node1.

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/vitals?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "SysBrd Fault":"0",
          "CPUs":"0",
          "Fan 4A Tach":"3330 RPM",
          "Drive 15":"0",
          "SysBrd Vol Fault":"0",
          "nvDIMM Flash":"0",
          "Progress":"0"
          ...
       }
    }

---
##\[URI:/nodes/{noderange}/vitals/{temp|voltage|wattage|fanspeed|power|leds...}\] - The specific vital attributes for the node {noderange}##
###GET - Get the specific vitals attibutes.###
Refer to the man page:[rvitals](http://xcat.sourceforge.net/man1/rvitals.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get the 'fanspeed' vitals attribute.

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/vitals/fanspeed?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "Fan 1A Tach":"3219 RPM",
          "Fan 4B Tach":"2688 RPM",
          "Fan 3B Tach":"2560 RPM",
          "Fan 4A Tach":"3330 RPM",
          "Fan 2A Tach":"3293 RPM",
          "Fan 1B Tach":"2592 RPM",
          "Fan 3A Tach":"3182 RPM",
          "Fan 2B Tach":"2592 RPM"
       }
    }

---
##\[URI:/nodes/{noderange}/inventory\] - The inventory attributes for the node {noderange}##
###GET - Get all the inventory attibutes.###
Refer to the man page:[rinv](http://xcat.sourceforge.net/man1/rinv.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get all the inventory attributes for node1.

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/inventory?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "DIMM 21 ":"8GB PC3-12800 (1600 MT/s) ECC RDIMM",
          "DIMM 1 Manufacturer":"Hyundai Electronics",
          "Power Supply 2 Board FRU Number":"94Y8105",
          "DIMM 9 Model":"HMT31GR7EFR4C-PB",
          "DIMM 8 Manufacture Location":"01",
          "DIMM 13 Manufacturer":"Hyundai Electronics",
          "DASD Backplane 4":"Not Present",
          ...
       }
    }

---
##\[URI:/nodes/{noderange}/inventory/{pci|model...}\] - The specific inventory attributes for the node {noderange}##
###GET - Get the specific inventory attibutes.###
Refer to the man page:[rinv](http://xcat.sourceforge.net/man1/rinv.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get the 'model' inventory attribute for node1.

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/inventory/model?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "System Description":"System x3650 M4",
          "System Model/MTM":"7915C2A"
       }
    }

---
##\[URI:/nodes/{noderange}/eventlog\] - The eventlog resource for the node {noderange}##
###GET - Get all the eventlog for the node {noderange}.###
Refer to the man page:[reventlog](http://xcat.sourceforge.net/man1/reventlog.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get all the eventlog for node1.

    #curl -X GET -k 'https://127.0.0.1/xcatws/nodes/node1/eventlog?userName=root&password=cluster&pretty=1'
    {
       "node1":{
          "eventlog":[
             "03/19/2014 15:17:58 Event Logging Disabled, Log Area Reset/Cleared (SEL Fullness)"
          ]
       }
    }

---
###DELETE - Clean up the event log for the node {noderange}.###
Refer to the man page:[reventlog](http://xcat.sourceforge.net/man1/reventlog.1.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Delete all the event log for node1.

    #curl -X DELETE -k 'https://127.0.0.1/xcatws/nodes/node1/eventlog?userName=root&password=cluster&pretty=1'
    [
       {
          "eventlog":[
             "SEL cleared"
          ],
          "name":"node1"
       }
    ]

---
##\[URI:/nodes/{noderange}/beacon\] - The beacon resource for the node {noderange}##
###PUT - Change the beacon status for the node {noderange}.###
Refer to the man page:[rbeacon](http://xcat.sourceforge.net/man1/rbeacon.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {action:on/off/blink}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Turn on the beacon.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/nodes/node1/beacon?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"action":"on"}'
    [
       {
          "name":"node1",
          "beacon":"on"
       }
    ]

---
##\[URI:/nodes/{noderange}/updating\] - The updating resource for the node {noderange}##
###POST - Update the node with file syncing, software maintenance and rerun postscripts.###
Refer to the man page:[updatenode](http://xcat.sourceforge.net/man1/updatenode.1.html).

**Returns:**

* An array of messages for performing the node updating.

**Example:**
Initiate an updatenode process.

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node2/updating?userName=root&password=cluster&pretty=1'
    [
       "There were no syncfiles defined to process. File synchronization has completed.",
       "Performing software maintenance operations. This could take a while, if there are packages to install.
    ",
       "node2: Wed Mar 20 15:01:43 CST 2013 Running postscript: ospkgs",
       "node2: Running of postscripts has completed."
    ]

---
##\[URI:/nodes/{noderange}/filesyncing\] - The filesyncing resource for the node {noderange}##
###POST - Sync files for the node {noderange}.###
Refer to the man page:[updatenode](http://xcat.sourceforge.net/man1/updatenode.1.html).

**Returns:**

* An array of messages for performing the file syncing for the node.

**Example:**
Initiate an file syncing process.

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node2/filesyncing?userName=root&password=cluster&pretty=1'
    [
       "There were no syncfiles defined to process. File synchronization has completed."
    ]

---
##\[URI:/nodes/{noderange}/sw\] - The software maintenance for the node {noderange}##
###POST - Perform the software maintenance process for the node {noderange}.###
Refer to the man page:[updatenode](http://xcat.sourceforge.net/man1/updatenode.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Initiate an software maintenance process.

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node2/sw?userName=root&password=cluster&pretty=1'
    {
       "node2":[
          " Wed Apr  3 09:05:42 CST 2013 Running postscript: ospkgs",
          " Unable to read consumer identity",
          " Postscript: ospkgs exited with code 0",
          " Wed Apr  3 09:05:44 CST 2013 Running postscript: otherpkgs",
          " ./otherpkgs: no extra rpms to install",
          " Postscript: otherpkgs exited with code 0",
          " Running of Software Maintenance has completed."
       ]
    }

---
##\[URI:/nodes/{noderange}/postscript\] - The postscript resource for the node {noderange}##
###POST - Run the postscripts for the node {noderange}.###
Refer to the man page:[updatenode](http://xcat.sourceforge.net/man1/updatenode.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {scripts:\[p1,p2,p3,...\]}.

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Initiate an updatenode process.

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node2/postscript?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"scripts":["syslog","remoteshell"]}'
    {
       "node2":[
          " Wed Apr  3 09:01:33 CST 2013 Running postscript: syslog",
          " Shutting down system logger: [  OK  ]",
          " Starting system logger: [  OK  ]",
          " Postscript: syslog exited with code 0",
          " Wed Apr  3 09:01:33 CST 2013 Running postscript: remoteshell",
          " Stopping sshd: [  OK  ]",
          " Starting sshd: [  OK  ]",
          " Postscript: remoteshell exited with code 0",
          " Running of postscripts has completed."
       ]
    }

---
##\[URI:/nodes/{noderange}/nodeshell\] - The nodeshell resource for the node {noderange}##
###POST - Run the command in the shell of the node {noderange}.###
Refer to the man page:[xdsh](http://xcat.sourceforge.net/man1/xdsh.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {command:\[cmd1,cmd2\]}.

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Run the 'data' command on the node2.

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node2/nodeshell?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"command":["date","ls"]}'
    {
       "node2":[
          " Wed Apr  3 08:30:26 CST 2013",
          " testline1",
          " testline2"
       ]
    }

---
##\[URI:/nodes/{noderange}/nodecopy\] - The nodecopy resource for the node {noderange}##
###POST - Copy files to the node {noderange}.###
Refer to the man page:[xdcp](http://xcat.sourceforge.net/man1/xdcp.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {src:\[file1,file2\],target:dir}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:[msg1,msg2...],errocode:errornum}.

**Example:**
Copy files /tmp/f1 and /tmp/f2 from xCAT MN to the node2:/tmp.

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node2/nodecopy?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"src":["/tmp/f1","/tmp/f2"],"target":"/tmp"}'
    no output for succeeded copy.

---
##\[URI:/nodes/{noderange}/vm\] - The virtualization node {noderange}.##
The node should be a virtual machine of type kvm, esxi ...

###PUT - Change the configuration for the virtual machine {noderange}.###
Refer to the man page:[chvm](http://xcat.sourceforge.net/man1/chvm.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: 
    Set memory size - {"memorysize":"sizeofmemory(MB)"}
    Add new disk - {"adddisk":"sizeofdisk1(GB),sizeofdisk2(GB)"}
    Purge disk - {"purgedisk":"scsi_id1,scsi_id2"}

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example1:**
Set memory to 3000MB.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/nodes/node1/vm?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"memorysize":"3000"}'

---
**Example2:**
Add a new 20G disk.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/nodes/node1/vm?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"adddisk":"20G"}'

---
**Example3:**
Purge the disk 'hdb'.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/nodes/node1/vm?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"purgedisk":"hdb"}'

---
###POST - Create the vm node {noderange}.###
Refer to the man page:[mkvm](http://xcat.sourceforge.net/man1/mkvm.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: 
    Set CPU count - {"cpucount":"numberofcpu"}
    Set memory size - {"memorysize":"sizeofmemory(MB)"}
    Set disk size - {"disksize":"sizeofdisk"}
    Do it by force - {"force":"yes"}

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Create the vm node1 with a 30G disk, 2048M memory and 2 cpus.

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node1/vm?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"disksize":"30G","memorysize":"2048","cpucount":"2"}'

---
###DELETE - Remove the vm node {noderange}.###
Refer to the man page:[rmvm](http://xcat.sourceforge.net/man1/rmvm.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: 
    Purge disk - {"purge":"yes"}
    Do it by force - {"force":"yes"}

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Remove the vm node1 by force and purge the disk.

    #curl -X DELETE -k 'https://127.0.0.1/xcatws/nodes/node1/vm?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"force":"yes","purge":"yes"}'

---
##\[URI:/nodes/{noderange}/vmclone\] - The clone resource for the virtual node {noderange}.##
The node should be a virtual machine of kvm, esxi ...

###POST - Create a clone master from node {noderange}. Or clone the node {noderange} from a clone master.###
Refer to the man page:[clonevm](http://xcat.sourceforge.net/man1/clonevm.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: 
    Clone a master named "mastername" - {"tomaster":"mastername"}
    Clone a node from master "mastername" - {"frommaster":"mastername"}
    Use Detach mode - {"detach":"yes"}
    Do it by force - {"force":"yes"}

**Returns:**

* The messages of creating Clone target.

**Example1:**
Create a clone master named "vmmaster" from the node1.

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node1/vmclone?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"tomaster":"vmmaster","detach":"yes"}'
    {
       "node1":{
          "vmclone":"Cloning of node1.hda.qcow2 complete (clone uses 9633.19921875 for a disk size of 30720MB)"
       }
    }

---
**Example2:**
Clone the node1 from the clone master named "vmmaster".

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node1/vmclone?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"frommaster":"vmmaster"}'

---
##\[URI:/nodes/{noderange}/vmmigrate\] - The virtualization resource for migration.##
The node should be a virtual machine of kvm, esxi ...

###POST - Migrate a node to targe node.###
Refer to the man page:[rmigrate](http://xcat.sourceforge.net/man1/rmigrate.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {"target":"targethost"}.

**Example:**
Migrate node1 to target host host2.

    #curl -X POST -k 'https://127.0.0.1/xcatws/nodes/node1/vmmigrate?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"target":"host2"}'

---
#Osimage resources#
URI list which can be used to query, create osimage resources.


---

---
##\[URI:/osimages\] - The osimage resource.##
###GET - Get all the osimage in xCAT.###
Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An array of osimage names.

**Example:**
Get all the osimage names.

    #curl -X GET -k 'https://127.0.0.1/xcatws/osimages?userName=root&password=cluster&pretty=1'
    [
       "sles11.2-x86_64-install-compute",
       "sles11.2-x86_64-install-iscsi",
       "sles11.2-x86_64-install-iscsiibft",
       "sles11.2-x86_64-install-service"
    ]

---
###POST - Create the osimage resources base on the parameters specified in the Data body.###
Refer to the man page:[copycds](http://xcat.sourceforge.net/man8/copycds.8.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {iso:isopath,file:filename,params:\[{attr1:value1,attr2:value2}\]}

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:[msg1,msg2...],errocode:errornum}.

**Example1:**
Create osimage resources based on the ISO specified

    #curl -X POST -k 'https://127.0.0.1/xcatws/osimages?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"iso":"/iso/RHEL6.4-20130130.0-Server-ppc64-DVD1.iso"}'

---
**Example2:**
Create osimage resources based on an xCAT image or configuration file

    #curl -X POST -k 'https://127.0.0.1/xcatws/osimages?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"file":"/tmp/sles11.2-x86_64-install-compute.tgz"}'

---
##\[URI:/osimages/{imgname}\] - The osimage resource##
###GET - Get all the attibutes for the osimage {imgname}.###
The keyword ALLRESOURCES can be used as {imgname} which means to get image attributes for all the osimages.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get the attributes for the specified osimage.

    #curl -X GET -k 'https://127.0.0.1/xcatws/osimages/sles11.2-x86_64-install-compute?userName=root&password=cluster&pretty=1'
    {
       "sles11.2-x86_64-install-compute":{
          "provmethod":"install",
          "profile":"compute",
          "template":"/opt/xcat/share/xcat/install/sles/compute.sles11.tmpl",
          "pkglist":"/opt/xcat/share/xcat/install/sles/compute.sles11.pkglist",
          "osvers":"sles11.2",
          "osarch":"x86_64",
          "osname":"Linux",
          "imagetype":"linux",
          "otherpkgdir":"/install/post/otherpkgs/sles11.2/x86_64",
          "osdistroname":"sles11.2-x86_64",
          "pkgdir":"/install/sles11.2/x86_64"
       }
    }

---
###PUT - Change the attibutes for the osimage {imgname}.###
Refer to the man page:[chdef](http://xcat.sourceforge.net/man1/chdef.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {attr1:v1,attr2:v2...}

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Change the 'osvers' and 'osarch' attributes for the osiamge.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/osimages/sles11.2-ppc64-install-compute/?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"osvers":"sles11.3","osarch":"x86_64"}'

---
###POST - Create the osimage {imgname}.###
Refer to the man page:[mkdef](http://xcat.sourceforge.net/man1/mkdef.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {attr1:v1,attr2:v2\]

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...],errocode:errornum}.

**Example:**
Create a osimage obj with the specified parameters.

    #curl -X POST -k 'https://127.0.0.1/xcatws/osimages/sles11.3-ppc64-install-compute?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"osvers":"sles11.3","osarch":"ppc64","osname":"Linux","provmethod":"install","profile":"compute"}'

---
###DELETE - Remove the osimage {imgname}.###
Refer to the man page:[rmdef](http://xcat.sourceforge.net/man1/rmdef.1.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Delete the specified osimage.

    #curl -X DELETE -k 'https://127.0.0.1/xcatws/osimages/sles11.3-ppc64-install-compute?userName=root&password=cluster&pretty=1'

---
##\[URI:/osimages/{imgname}/attrs/attr1,attr2,attr3 ...\] - The attributes resource for the osimage {imgname}##
###GET - Get the specific attributes for the osimage {imgname}.###
The keyword ALLRESOURCES can be used as {imgname} which means to get image attributes for all the osimages.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An array of attr:value pairs for the specified osimage.

**Example:**
Get the specified attributes.

    #curl -X GET -k 'https://127.0.0.1/xcatws/osimages/sles11.2-ppc64-install-compute/attrs/imagetype,osarch,osname,provmethod?userName=root&password=cluster&pretty=1'
    {
       "sles11.2-ppc64-install-compute":{
          "provmethod":"install",
          "osname":"Linux",
          "osarch":"ppc64",
          "imagetype":"linux"
       }
    }

---
##\[URI:/osimages/{imgname}/instance\] - The instance for the osimage {imgname}##
###POST - Operate the instance of the osimage {imgname}.###
Refer to the man page of  command.

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {action:gen OR pack OR export,params:\[{attr1:value1,attr2:value2...}\]}

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:[msg1,msg2...],errocode:errornum}.

**Example1:**
Generates a stateless image based on the specified osimage

    #curl -X POST -k 'https://127.0.0.1/xcatws/osimages/sles11.2-x86_64-install-compute/instance?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"action":"gen"}'

---
**Example2:**
Packs the stateless image from the chroot file system based on the specified osimage

    #curl -X POST -k 'https://127.0.0.1/xcatws/osimages/sles11.2-x86_64-install-compute/instance?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"action":"pack"}'

---
**Example3:**
Exports an xCAT image based on the specified osimage

    #curl -X POST -k 'https://127.0.0.1/xcatws/osimages/sles11.2-x86_64-install-compute/instance?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"action":"export"}'

---
###DELETE - Delete the stateless or statelite image instance for the osimage {imgname} from the file system###
Refer to the man page:[rmimage](http://xcat.sourceforge.net/man1/rmimage.1.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Delete the stateless image for the specified osimage

    #curl -X DELETE -k 'https://127.0.0.1/xcatws/osimages/sles11.2-x86_64-install-compute/instance?userName=root&password=cluster&pretty=1'

---
#Network Resources#
The URI list which can be used to create, query, change and manage network objects.


---

---
##\[URI:/networks\] - The network list resource.##
This resource can be used to display all the networks which have been defined in the xCAT database.

###GET - Get all the networks in xCAT.###
The attributes details for the networks will not be displayed.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An array of networks names.

**Example:**
Get all the networks names from xCAT database.

    #curl -X GET -k 'https://127.0.0.1/xcatws/networks?userName=root&password=cluster&pretty=1'
    [
       "network1",
       "network2",
       "network3",
    ]

---
###POST - Create the networks resources base on the network configuration on xCAT MN.###
Refer to the man page:[makenetworks](http://xcat.sourceforge.net/man8/makenetworks.8.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {attr1:v1,att2:v2,...}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Create the networks resources base on the network configuration on xCAT MN.

    #curl -X POST -k 'https://127.0.0.1/xcatws/networks?userName=root&password=cluster&pretty=1'

---
##\[URI:/networks/{netname}\] - The network resource##
###GET - Get all the attibutes for the network {netname}.###
The keyword ALLRESOURCES can be used as {netname} which means to get network attributes for all the networks.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get all the attibutes for network 'network1'.

    #curl -X GET -k 'https://127.0.0.1/xcatws/networks/network1?userName=root&password=cluster&pretty=1'
    {
       "network1":{
          "gateway":"<xcatmaster>",
          "mask":"255.255.255.0",
          "mgtifname":"eth2",
          "net":"10.0.0.0",
          "tftpserver":"10.0.0.119",
          ...
       }
    }

---
###PUT - Change the attibutes for the network {netname}.###
Refer to the man page:[chdef](http://xcat.sourceforge.net/man1/chdef.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {attr1:v1,att2:v2,...}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Change the attributes mgtifname=eth0 and net=10.1.0.0.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/networks/network1?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"mgtifname":"eth0","net":"10.1.0.0"}'

---
###POST - Create the network {netname}. DataBody: {attr1:v1,att2:v2...}.###
Refer to the man page:[mkdef](http://xcat.sourceforge.net/man1/mkdef.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {attr1:v1,att2:v2,...}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Create a network with attributes gateway=10.1.0.1, mask=255.255.0.0 

    #curl -X POST -k 'https://127.0.0.1/xcatws/networks/network1?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"gateway":"10.1.0.1","mask":"255.255.0.0"}'

---
###DELETE - Remove the network {netname}.###
Refer to the man page:[rmdef](http://xcat.sourceforge.net/man1/rmdef.1.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Delete the network network1

    #curl -X DELETE -k 'https://127.0.0.1/xcatws/networks/network1?userName=root&password=cluster&pretty=1'

---
##\[URI:/networks/{netname}/attrs/attr1,attr2,...\] - The attributes resource for the network {netname}##
###GET - Get the specific attributes for the network {netname}.###
The keyword ALLRESOURCES can be used as {netname} which means to get network attributes for all the networks.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get the attributes {groups,mgt,netboot} for network network1

    #curl -X GET -k 'https://127.0.0.1/xcatws/networks/network1/attrs/gateway,mask,mgtifname,net,tftpserver?userName=root&password=cluster&pretty=1'
    {
       "network1":{
          "gateway":"9.114.34.254",
          "mask":"255.255.255.0",
             }
    }

---
#Policy Resources#
The URI list which can be used to create, query, change and manage policy entries.


---

---
##\[URI:/policy\] - The policy resource.##
###GET - Get all the policies in xCAT.###
It will dislplay all the policy resource.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get all the policy objects.

    #curl -X GET -k 'https://127.0.0.1/xcatws/policy?userName=root&password=cluster&pretty=1'
    [
       "1",
       "1.2",
       "2",
       "4.8"
    ]

---
##\[URI:/policy/{policy_priority}\] - The policy resource##
###GET - Get all the attibutes for a policy {policy_priority}.###
It will display all the policy attributes for one policy resource.

The keyword ALLRESOURCES can be used as {policy_priority} which means to get policy attributes for all the policies.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get all the attribute for policy 1.

    #curl -X GET -k 'https://127.0.0.1/xcatws/policy/1?userName=root&password=cluster&pretty=1'
    {
       "1":{
          "name":"root",
          "rule":"allow"
       }
    }

---
###PUT - Change the attibutes for the policy {policy_priority}.###
It will change one or more attributes for a policy.

Refer to the man page:[chdef](http://xcat.sourceforge.net/man1/chdef.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {attr1:v1,att2:v2,...}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Set the name attribute for policy 3.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/policy/3?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"name":"root"}'

---
###POST - Create the policy {policyname}. DataBody: {attr1:v1,att2:v2...}.###
It will creat a new policy resource.

Refer to the man page:[chdef](http://xcat.sourceforge.net/man1/chdef.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {attr1:v1,att2:v2,...}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Create a new policy 10.

    #curl -X POST -k 'https://127.0.0.1/xcatws/policy/10?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"name":"root","commands":"rpower"}'

---
###DELETE - Remove the policy {policy_priority}.###
Remove one or more policy resource.

Refer to the man page:[rmdef](http://xcat.sourceforge.net/man1/rmdef.1.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Delete the policy 10.

    #curl -X DELETE -k 'https://127.0.0.1/xcatws/policy/10?userName=root&password=cluster&pretty=1'

---
##\[URI:/policy/{policyname}/attrs/{attr1,attr2,attr3,...}\] - The attributes resource for the policy {policy_priority}##
###GET - Get the specific attributes for the policy {policy_priority}.###
It will get one or more attributes of a policy.

The keyword ALLRESOURCES can be used as {policy_priority} which means to get policy attributes for all the policies.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get the name and rule attributes for policy 1.

    #curl -X GET -k 'https://127.0.0.1/xcatws/policy/1/attrs/name,rule?userName=root&password=cluster&pretty=1'
    {
       "1":{
          "name":"root",
          "rule":"allow"
       }
    }

---
#Group Resources#
The URI list which can be used to create, query, change and manage group objects.


---

---
##\[URI:/groups\] - The group list resource.##
This resource can be used to display all the groups which have been defined in the xCAT database.

###GET - Get all the groups in xCAT.###
The attributes details for the group will not be displayed.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An array of group names.

**Example:**
Get all the group names from xCAT database.

    #curl -X GET -k 'https://127.0.0.1/xcatws/groups?userName=root&password=cluster&pretty=1'
    [
       "__mgmtnode",
       "all",
       "compute",
       "ipmi",
       "kvm",
    ]

---
##\[URI:/groups/{groupname}\] - The group resource##
###GET - Get all the attibutes for the group {groupname}.###
Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get all the attibutes for group 'all'.

    #curl -X GET -k 'https://127.0.0.1/xcatws/groups/all?userName=root&password=cluster&pretty=1'
    {
       "all":{
          "members":"zxnode2,nodexxx,node1,node4"
       }
    }

---
###PUT - Change the attibutes for the group {groupname}.###
Refer to the man page:[chdef](http://xcat.sourceforge.net/man1/chdef.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {attr1:v1,att2:v2,...}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Change the attributes mgt=dfm and netboot=yaboot.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/groups/all?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"mgt":"dfm","netboot":"yaboot"}'

---
##\[URI:/groups/{groupname}/attrs/{attr1,attr2,attr3 ...}\] - The attributes resource for the group {groupname}##
###GET - Get the specific attributes for the group {groupname}.###
Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get the attributes {mgt,netboot} for group all

    #curl -X GET -k 'https://127.0.0.1/xcatws/groups/all/attrs/mgt,netboot?userName=root&password=cluster&pretty=1'
    {
       "all":{
          "netboot":"yaboot",
          "mgt":"dfm"
       }
    }

---
#Global Configuration Resources#
The URI list which can be used to create, query, change global configuration.


---

---
##\[URI:/globalconf\] - The global configuration resource.##
This resource can be used to display all the global configuration which have been defined in the xCAT database.

###GET - Get all the xCAT global configuration.###
It will display all the global attributes.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get all the global configuration

    #curl -X GET -k 'https://127.0.0.1/xcatws/globalconf?userName=root&password=cluster&pretty=1'
    {
       "clustersite":{
          "xcatconfdir":"/etc/xcat",
          "tftpdir":"/tftpboot",
          ...
       }
    }

---
##\[URI:/globalconf/attrs/{attr1,attr2 ...}\] - The specific global configuration resource.##
###GET - Get the specific configuration in global.###
It will display one or more global attributes.

Refer to the man page:[lsdef](http://xcat.sourceforge.net/man1/lsdef.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get the 'master' and 'domain' configuration.

    #curl -X GET -k 'https://127.0.0.1/xcatws/globalconf/attrs/master,domain?userName=root&password=cluster&pretty=1'
    {
       "clustersite":{
          "domain":"cluster.com",
          "master":"192.168.1.15"
       }
    }

---
###PUT - Change the global attributes.###
It can be used for changing/adding global attributes.

Refer to the man page:[chdef](http://xcat.sourceforge.net/man1/chdef.1.html).

**Parameters:**

* Json format: An object which includes multiple 'att:value' pairs. DataBody: {attr1:v1,att2:v2,...}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Change/Add the domain attribute.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/globalconf/attrs/domain?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"domain":"cluster.com"}'

---
###DELETE - Remove the site attributes.###
Used for femove one or more global attributes.

Refer to the man page:[chdef](http://xcat.sourceforge.net/man1/chdef.1.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Remove the domain configure.

    #curl -X DELETE -k 'https://127.0.0.1/xcatws/globalconf/attrs/domain?userName=root&password=cluster&pretty=1'

---
#Service Resources#
The URI list which can be used to manage the host, dns and dhcp services on xCAT MN.


---

---
##\[URI:/services/dns\] - The dns service resource.##
###POST - Initialize the dns service.###
Refer to the man page:[makedns](http://xcat.sourceforge.net/man8/makedns.8.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Initialize the dns service.

    #curl -X POST -k 'https://127.0.0.1/xcatws/services/dns?userName=root&password=cluster&pretty=1'

---
##\[URI:/services/dhcp\] - The dhcp service resource.##
###POST - Create the dhcpd.conf for all the networks which are defined in the xCAT Management Node.###
Refer to the man page:[makedhcp](http://xcat.sourceforge.net/man8/makedhcp.8.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Create the dhcpd.conf and restart the dhcpd.

    #curl -X POST -k 'https://127.0.0.1/xcatws/services/dhcp?userName=root&password=cluster&pretty=1'

---
##\[URI:/services/host\] - The hostname resource.##
###POST - Create the ip/hostname records for all the nodes to /etc/hosts.###
Refer to the man page:[makehosts](http://xcat.sourceforge.net/man8/makehosts.8.html).

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Create the ip/hostname records for all the nodes to /etc/hosts.

    #curl -X POST -k 'https://127.0.0.1/xcatws/services/host?userName=root&password=cluster&pretty=1'

---
##\[URI:/services/slpnodes\] - The nodes which support SLP in the xCAT cluster##
###GET - Get all the nodes which support slp protocol in the network.###
Refer to the man page:[lsslp](http://xcat.sourceforge.net/man1/lsslp.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get all the nodes which support slp in the network.

    #curl -X GET -k 'https://127.0.0.1/xcatws/services/slpnodes?userName=root&password=cluster&pretty=1'
    {
       "ngpcmm01":{
          "mpa":"ngpcmm01",
          "otherinterfaces":"10.1.9.101",
          "serial":"100037A",
          "mtm":"789392X",
          "hwtype":"cmm",
          "side":"2",
          "objtype":"node",
          "nodetype":"mp",
          "groups":"cmm,all,cmm-zet",
          "mgt":"blade",
          "hidden":"0",
          "mac":"5c:f3:fc:25:da:99"
       },
       ...
    }

---
##\[URI:/services/slpnodes/{CEC|FRAME|MM|IVM|RSA|HMC|CMM|IMM2|FSP...}\] - The slp nodes with specific service type in the xCAT cluster##
###GET - Get all the nodes with specific slp service type in the network.###
Refer to the man page:[lsslp](http://xcat.sourceforge.net/man1/lsslp.1.html).

**Returns:**

* Json format: An object which includes multiple '<name> : {att:value, attr:value ...}' pairs.

**Example:**
Get all the CMM nodes which support slp in the network.

    #curl -X GET -k 'https://127.0.0.1/xcatws/services/slpnodes/CMM?userName=root&password=cluster&pretty=1'
    {
       "ngpcmm01":{
          "mpa":"ngpcmm01",
          "otherinterfaces":"10.1.9.101",
          "serial":"100037A",
          "mtm":"789392X",
          "hwtype":"cmm",
          "side":"2",
          "objtype":"node",
          "nodetype":"mp",
          "groups":"cmm,all,cmm-zet",
          "mgt":"blade",
          "hidden":"0",
          "mac":"5c:f3:fc:25:da:99"
       },
       "Server--SNY014BG27A01K":{
          "mpa":"Server--SNY014BG27A01K",
          "otherinterfaces":"10.1.9.106",
          "serial":"100CF0A",
          "mtm":"789392X",
          "hwtype":"cmm",
          "side":"1",
          "objtype":"node",
          "nodetype":"mp",
          "groups":"cmm,all,cmm-zet",
          "mgt":"blade",
          "hidden":"0",
          "mac":"34:40:b5:df:0a:be"
       }
    }

---
#Table Resources#
URI list which can be used to create, query, change table entries.


---

---
##\[URI:/tables/{tablelist}/nodes/{noderange}\] - The node table resource##
For a large number of nodes, this API call can be faster than using the corresponding nodes resource.  The disadvantage is that you need to know the table names the attributes are stored in.

###GET - Get attibutes of tables for a noderange.###
**Returns:**

* An object containing each table.  Within each table object is an array of node objects containing the attributes.

**Example1:**
Get all the columns from table nodetype for node1 and node2.

    #curl -X GET -k 'https://127.0.0.1/xcatws/tables/nodetype/nodes/node1,node2?userName=root&password=cluster&pretty=1'
    {
       "nodetype":[
          {
             "provmethod":"rhels6.4-x86_64-install-compute",
             "profile":"compute",
             "arch":"x86_64",
             "name":"node1",
             "os":"rhels6.4"
          },
          {
             "provmethod":"rhels6.3-x86_64-install-compute",
             "profile":"compute",
             "arch":"x86_64",
             "name":"node2",
             "os":"rhels6.3"
          }
       ]
    }

---
**Example2:**
Get all the columns from tables nodetype and noderes for node1 and node2.

    #curl -X GET -k 'https://127.0.0.1/xcatws/tables/nodetype,noderes/nodes/node1,node2?userName=root&password=cluster&pretty=1'
    {
       "noderes":[
          {
             "installnic":"mac",
             "netboot":"xnba",
             "name":"node1",
             "nfsserver":"192.168.1.15"
          },
          {
             "installnic":"mac",
             "netboot":"pxe",
             "name":"node2",
             "proxydhcp":"no"
          }
       ],
       "nodetype":[
          {
             "provmethod":"rhels6.4-x86_64-install-compute",
             "profile":"compute",
             "arch":"x86_64",
             "name":"node1",
             "os":"rhels6.4"
          },
          {
             "provmethod":"rhels6.3-x86_64-install-compute",
             "profile":"compute",
             "arch":"x86_64",
             "name":"node2",
             "os":"rhels6.3"
          }
       ]
    }

---
###PUT - Change the node table attibutes for {noderange}.###
**Parameters:**

* A hash of table names and attribute objects.  DataBody: {table1:{attr1:v1,att2:v2,...}}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Change the nodetype.arch and noderes.netboot attributes for nodes node1,node2.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/tables/nodetype,noderes/nodes/node1,node2?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"nodetype":{"arch":"x86_64"},"noderes":{"netboot":"xnba"}}'

---
##\[URI:/tables/{tablelist}/nodes/nodes/{noderange}/{attrlist}\] - The node table attributes resource##
For a large number of nodes, this API call can be faster than using the corresponding nodes resource.  The disadvantage is that you need to know the table names the attributes are stored in.

###GET - Get table attibutes for a noderange.###
**Returns:**

* An object containing each table.  Within each table object is an array of node objects containing the attributes.

**Example:**
Get OS and ARCH attributes from nodetype table for node1 and node2.

    #curl -X GET -k 'https://127.0.0.1/xcatws/tables/nodetype/nodes/node1,node2/os,arch?userName=root&password=cluster&pretty=1'
    {
       "nodetype":[
          {
             "arch":"x86_64",
             "name":"node1",
             "os":"rhels6.4"
          },
          {
             "arch":"x86_64",
             "name":"node2",
             "os":"rhels6.3"
          }
       ]
    }

---
##\[URI:/tables/{tablelist}/rows\] - The non-node table resource##
Use this for tables that don't have node name as the key of the table, for example: passwd, site, networks, polciy, etc.

###GET - Get all rows from non-node tables.###
**Returns:**

* An object containing each table.  Within each table object is an array of row objects containing the attributes.

**Example:**
Get all rows from networks table.

    #curl -X GET -k 'https://127.0.0.1/xcatws/tables/networks/rows?userName=root&password=cluster&pretty=1'
    {
       "networks":[
          {
             "netname":"192_168_13_0-255_255_255_0",
             "gateway":"192.168.13.254",
             "staticrangeincrement":"1",
             "net":"192.168.13.0",
             "mask":"255.255.255.0"
          },
          {
             "netname":"192_168_12_0-255_255_255_0",
             "gateway":"192.168.12.254",
             "staticrangeincrement":"1",
             "net":"192.168.12.0",
             "mask":"255.255.255.0"
          },
       ]
    }

---
##\[URI:/tables/{tablelist}/rows/{keys}\] - The non-node table rows resource##
Use this for tables that don't have node name as the key of the table, for example: passwd, site, networks, polciy, etc.

{keys} should be the name=value pairs which are used to search table. e.g. {keys} should be [net=192.168.1.0,mask=255.255.255.0] for networks table query since the net and mask are the keys of networks table.

###GET - Get attibutes for rows from non-node tables.###
**Returns:**

* An object containing each table.  Within each table object is an array of row objects containing the attributes.

**Example:**
Get row which net=192.168.1.0,mask=255.255.255.0 from networks table.

    #curl -X GET -k 'https://127.0.0.1/xcatws/tables/networks/rows/net=192.168.1.0,mask=255.255.255.0?userName=root&password=cluster&pretty=1'
    {
       "networks":[
          {
             "mgtifname":"eth0",
             "netname":"192_168_1_0-255_255_255_0",
             "tftpserver":"192.168.1.15",
             "gateway":"192.168.1.100",
             "staticrangeincrement":"1",
             "net":"192.168.1.0",
             "mask":"255.255.255.0"
          }
       ]
    }

---
###PUT - Change the non-node table attibutes for the row that matches the {keys}.###
**Parameters:**

* A hash of attribute names and values.  DataBody: {attr1:v1,att2:v2,...}.

**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Create a route row in the routes table.

    #curl -X PUT -k 'https://127.0.0.1/xcatws/tables/routes/rows/routename=privnet?userName=root&password=cluster&pretty=1' -H Content-Type:application/json --data '{"net":"10.0.1.0","mask":"255.255.255.0","gateway":"10.0.1.254","ifname":"eth1"}'

---
###DELETE - Delete rows from a non-node table that have the attribute values specified in {keys}.###
**Returns:**

* No output when execution is successfull. Otherwise output the error information in the Standard Error Format: {error:\[msg1,msg2...\],errocode:errornum}.

**Example:**
Delete a route row which routename=privnet in the routes table.

    #curl -X DELETE -k 'https://127.0.0.1/xcatws/tables/routes/rows/routename=privnet?userName=root&password=cluster&pretty=1'

---
##\[URI:/tables/{tablelist}/rows/{keys}/{attrlist}\] - The non-node table attributes resource##
Use this for tables that don't have node name as the key of the table, for example: passwd, site, networks, polciy, etc.

###GET - Get specific attibutes for rows from non-node tables.###
**Returns:**

* An object containing each table.  Within each table object is an array of row objects containing the attributes.

**Example:**
Get attributes mgtifname and tftpserver which net=192.168.1.0,mask=255.255.255.0 from networks table.

    #curl -X GET -k 'https://127.0.0.1/xcatws/tables/networks/rows/net=192.168.1.0,mask=255.255.255.0/mgtifname,tftpserver?userName=root&password=cluster&pretty=1'
    {
       "networks":[
          {
             "mgtifname":"eth0",
             "tftpserver":"192.168.1.15"
          }
       ]
    }

---
