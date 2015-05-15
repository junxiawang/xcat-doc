this is some text before the table

~~~~
   this
    is
    code
    before 
     the 
        table
~~~~

this is text after code before the table


<!---
begin_xcat_table;
numcols=3;
colwidths=7,25,40;
-->


| Option     | Example | Remarks
-------------|---------|---------
P:tmpfs <br>C:tmpfs       | "ALL","/root/testblank/",,, <br>"ALL","/root/testblanktempfschild","tempfs",, | Both the parent and the child are mounted to tmpfs on the booted node following their respective options.Only the parent are mounted to the local file system.
P:tmpfs <br>C:persistent| "ALL","/root/testblank/",,, <br>"ALL","/root/testblank/testpersfile","persistent",,|   Both the parent and the child are mounted to tmpfs on the booted node following their respective options. Only the parent is mounted to the local file system.
P:persistent <br>C:tmpfs|"ALL","/root/testblank/","persistent",, <br>"ALL","/root/testblank/tempfschild",,,| Not permitted now. But plan to support it.
P:persistent <br>C:persistent|"ALL","/root/testblank/","persistent",, <br>"ALL","/root/testblank/testpersfile","persistent",,| Both the parent and the child are mounted to tmpfs on the booted node following their respective options. Only the parent are mounted to the local file system.
P:ro <br>C:any | |  Not permitted
P:tmpfs <br>C:ro| | Both the parent and the child are mounted to tmpfs on the booted node following their respective options. Only the parent are mounted to the local file system.
P:tmpfs <br>C:con | | Both the parent and the child are mounted to tmpfs on the booted node following their respective options. Only the parent are mounted to the local file system.
P:link <br>C:link |"ALL","/root/testlink/","link",, <br>"ALL","/root/testlink/testlinkchild","link",, | Both the parent and the child are created in tmpfs on the booted node following their respective options; there's only one symbolic link of the parent is created in the local file system.
P: link <br>C:link,persistent |"ALL","/root/testlinkpers/","link",, <br>ALL","/root/testlink/testlinkchild","link,persistent" | Both the parent and the child are created in tmpfs on the booted node following their respective options; there's only one symbolic link of the parent is created in the local file system.
P:link persistent <br>C:link |"ALL","/root/testlinkpers/","link,persistent",, <br>"ALL","/root/testlink/testlinkchild","link" |NOT permitted
P:link, persistent <br>C:link, persistent |"ALL","/root/testlinkpers/","link,persistent",, <br>"ALL","/root/testlink/testlinkperschild","link,persistent",, |Both the parent and the child are created in tmpfs on the booted node following the "link,persistent" way; there's only one symbolic link of the parent is created in the local file system.
P:link <br>C:link,ro |"ALL","/root/testlink/","link",, <br>"ALL","/root/testlink/testlinkro","link,ro",, |Both the parent and the child are created in tmpfs on the booted node, there's only one symbolic link of the parent is created in the local file system.
P:link <br>C:link,con |"ALL","/root/testlink/","link",, <br>"ALL","/root/testlink/testlinkconchild","link,con",,  |Both the parent and the child are created in tmpfs on the booted node, there's only one symbolic link of the parent in the local file system.
P:link.persistent <br>C:link,ro | |NOT Permitted
P:link,persistent <br>C:link,con | |NOT Permitted
P:tmpfs <br>C:link | |NOT Permitted
P:link <br>C:persistent | |NOT Permitted

<!---
end_xcat_table
-->

this is some text after the table

~~~~
   this
    is
    code
     after 
     the 
        table
~~~~

this is text after code after the table

