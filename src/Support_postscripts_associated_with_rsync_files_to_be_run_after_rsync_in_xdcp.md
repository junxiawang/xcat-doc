<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
- [Format of the synclist file](#format-of-the-synclist-file)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

## Overview

This design is to cover adding new function to the xdcp rsync support to allow a post-processing script to be run when a file (for example test) is sync'd to the node. If a &lt;test.post&gt; script exists in the same directory on the Management Node as the file &lt;test&gt;, the &lt;test.post&gt; script or executable is run on the destination node after the file &lt;test&gt; is sync'd to the node. If the file &lt;test&gt; is not updated on the node, the &lt;test.post&gt; is not run. A good example of the use, is to have a script to restart a daemon, when the configuration file is sync'd to the node. 

## Format of the synclist file

The synclist file contains the configuration entries that specify where the files should be synced to. In the synclist file, each line is an entry which describes the location of the source files and the destination location of files on the target node. 

  
The basic entry format looks like following: 
    
    path_of_src_file1 -&gt; path_of_dst_file1
    path_of_src_file1 -&gt; path_of_dst_directory ( must end in /) 2.5 or later
    path_of_src_file1 path_of_src_file2 ... -&gt; path_of_dst_directory
    

  
The path_of_src_file* should be the full path of the source file on the Management Node. 

The path_of_dst_file* should be the full path of the destination file on target node. 

The path_of_dst_directory should be the full path of the destination directory. 

Since the synclist file is for common purpose, the target node need not be configured in it. 

  
Example: the following synclist formats are supported: 

  
sync file /etc/file2 to the file /etc/file2 on the node (with same file name) 
    
    /etc/file2 -&gt; /etc/file2
    

sync file /etc/file2 to the file /etc/file3 on the node (with different file name) 
    
    /etc/file2 -&gt; /etc/file3
    

sync file /etc/file4 to the file /etc/tmp/file5 on the node( different file name and directory). The directory will be automatically created for you. 
    
    /etc/file4 -&gt; /etc/tmp/file5
    

sync the multiple files /etc/file1, /etc/file2, /etc/file3, ... to the directory /tmp/etc (/tmp/etc must be a directory when multiple files are synced at one time). If the directory does not exist, xdcp will create it. 
    
    /etc/file1 /etc/file2 /etc/file3 -&gt; /tmp/etc
    

sync file /etc/file2 to the file /etc/file2 on the node ( with the same file name) (2.5 or later) 
    
    /etc/file2 -&gt; /etc/
    

sync all files in /home/mikey to directory /home/mikev on the node (2.5 or later) 
    
    /home/mikey/* -&gt; /home/mikey/
    

**As of 2.6 a new stanza (EXECUTE:)** will be added to the synclist file for the post script processing. 

After the list of files to rsync ( as indicated above), you add the EXECUTE Stanza, followed by the list of postscripts to be run. The postscripts will be of the format /..../&lt;filename&gt;.post, where filename is one of the files that would be eligible to rsync in the file list above. 

For example, the following synclist: xdcp syncs /.../file2, /.../file3 /.../file2.post to /.../file2, /.../file3 /.../file2.post on the node and runs /.../file2.post, if /.../file2 is updated by rsync on the node. 
    
    /.../file2 -&gt; /.../file3
    /.../file2.post -&gt; /.../file2.post (optional, if not hierarchical cluster)
    /.../file3 -&gt; /.../file3
    /.../file3.post -&gt; /.../file3.post (optional, if not hierarchical cluster)
    # the following are postscripts
    EXECUTE:
    /.../file2.post
    /.../file3.post
    

Another example, the following rsyncs all the files in /home/mikey to the node and will execute filex.post, if the filex from /home/mikey was updated on the node. 
    
    /home/mikey/* -&gt; /home/mikey/
    # the following are postscripts
    EXECUTE:
    /home/mikey/filex.post
    /home/mikey/filey.post
         .
         .
         .
    
