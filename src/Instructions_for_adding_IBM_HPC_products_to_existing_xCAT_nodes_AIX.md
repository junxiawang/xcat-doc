If your nodes are already installed with the correct OS, and you are adding HPC software to the existing nodes, continue with these instructions and skip the next step to "Network boot the nodes".

The updatenode command will be used to synchronize configuration files, add the HPC software and run the postscripts. To have updatenode install both the OS prereqs and the base HPC packages, complete the previous instructions to add HPC software to your image.

Synchronize configuration files to your nodes (optional):

~~~~
   updatenode <noderange> -F
~~~~

Update the software on your nodes:

~~~~
   updatenode <noderange> -S  installp_flags="-agQXY"
~~~~

Run postscripts and postbootscripts on your nodes:

~~~~
   updatenode <noderange> -P
~~~~