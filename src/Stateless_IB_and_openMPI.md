Something that we need to be aware of when we install any infiniband network and run MPI jobs using openMPI, it will require some part of the memory for the Shared Memory Process (SMP). If you are using the openib interface with openMPI then you need to at least have 100m of /tmp available using, i.e. adding the size of /tmp explicitly in fstab as shown below 
    
    none            /tmp     tmpfs  defaults,size=100m 0

You could instead take this line totally and the /tmp would automatically be in your / filesystem 

With regards to Infinipath (i.e. PSM interface) openMPI uses /dev/shm folder instead and you definitely need to add entries into fstab 
    
    none            /dev/shm     tmpfs  defaults,size=100m 0 2

One thing to take care of with infinipath is that the temporary flles created in /dev/shm are not automatically removed, so whichever resource manager you are using it should cleanup after the job finishes (i.e. using epilogue/prologue scripts) 
