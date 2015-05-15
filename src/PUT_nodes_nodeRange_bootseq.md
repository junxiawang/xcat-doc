Set the boot sequence of the nodes(only Blade &amp; PPC LPARS). 

Example:  

    
    PUT https://127.0.0.1/xcatws/nodes/b1-b4/bootseq?userName=xxx&password=xxx

  
With data:  

    
    ["hd0,network"]

  
For more bootdevice type, can refer [the man page of rbootseq](http://xcat.sourceforge.net/man1/rbootseq.1.html)
