{{:Design Warning}} 

We need to be able to represent System z in a hierarchical tree. We decided to follow the convention Power uses for their hierarchy. The zvm table will be modified to have the following columns: 

node: The node name.  
hcp: The hardware control point for this node.  
nodetype: The node type. Valid values: cec (Central electronic complex), lpar (Logical partition), zvm (zVM host operating system), and vm (virtual machine).  
parent: The parent node. For LPAR, this specifies the CEC. For zVM, this specifies the LPAR. For VM, this specifies the zVM.  
userid: The z/VM user ID of this node.  
comments: Any user provided notes.  
disable: Set to 'yes' or '1' to comment out this row.  


With this solution, each CEC, LPAR, zVM, and zLinux would have a separate row in the zvm table. 

When using the chdef or mkdef command to make changes to a node attribute, the user would have to use hwnodetype (hardware nodetype) to reference ppc.nodetype or zvm.nodetype depending on the mgt value of the node. This is to distinguished which table (ppc, zvm, or nodetype) to set the nodetype column in. The nodetype keyword would continue to refer to nodetype.nodetype. Changes would be need in the data abstraction part of Schema.pm to handle hwnodetype. 
