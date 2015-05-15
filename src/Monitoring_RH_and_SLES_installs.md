xCAT puts a small daemon in the RH and SuSE preinstall code. You can see this if you examine the INSTALLDIR/scripts/OS/ARCH/... files. 

This daemon allows remote shell access and the ability to query the state of the install, including the current RPM being installed. 

To monitor the installs type: 

watch 'nodestat noderange | sort' 

This is prefered to watching with wcons/rcons. 

To run a remote command type: 

cd $XCATROOT/lib  
./nodecmd.awk nodename command 

To get a remote console screen dump (same as Alt-F1, Alt-F2, etc... on the console) type: 

xterm -geometry 80x26 

In the xterm window type: 

cd $XCATROOT/lib  
./nodescreendump.awk nodename screen_number (1-7), e.g.: 

./nodescreendump.awk node01 3 
