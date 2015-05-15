<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Overview](#overview)
  - [Postage.pm](#postagepm)
  - [updatenode](#updatenode)
  - [xcatdsklspost](#xcatdsklspost)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 


## Overview

There is a requirement to allow updatenode to run postscripts/postbootscripts that are defined in the osimage table and not automatically run the xCAT default postscripts and/or the postscripts defined for the node in the postscripts table. Note this is being implemented in 2.8 as an internal function. The next sections list the changes required. 

### Postage.pm

Postage.pm will be changed to build a new mypostscript file with multiple sections based on where they were defined in the database. The changes start at the line # postscripts-start-here in the current file. 

  

    
              .
              .
              .
    #postscripts-start-here 
    #defaults-postscripts-start-here    
    run_ps postscript1
           .
    #defaults-postscripts-end-here
    #osimage-postscripts-start-here
    run_ps postscript2
           .
    #osimage-postscripts-end-here
    #node-postscripts-start-here
    run_ps postscript3
           .
    #node-postscripts-end-here
    #postscripts-end-here 
    #postbootscripts-start-here  
    #defaults-postbootscripts-start-here
    run_ps postbootscript1
           .
    #defaults-postbootscripts-end-here
    #osimage-postbootscripts-start-here
    run_ps postbootscript2
           .
    #osimage-postbootscripts-end-here
    #node-postbootscripts-start-here
    run_ps postbootscript3
            .
    #node-postbootscripts-end-here
    #postbootscripts-end-here
    

### updatenode

updatenode will take on the -P flag, as if a postscript name the title a section of the new mypostscript file. It will pass this section name to xcatdsklspost which will build a correct mypostscript file containing only the postscript from the section designated. Only one sections can be selected at a time. Note the long name is to try and not conflict with any previously defined postscripts, created by users. 

To run all the postscripts, all sections 
    
    updatenode &lt;noderange&gt; -P postscripts-start-here
    

To run all the postbootscripts, all sections 
    
    updatenode &lt;noderange&gt; -P postbootscripts-start-here
    

To run only the postbootscripts defined in the osimage postbootscripts attribute 
    
    updatenode &lt;noderange&gt; -P osimage-postbootscripts-start-here
    

  


### xcatdsklspost

xcatdsklspost will be change to recognize the new postscripts/postbootscripts name in the above section. Based on that name modify the mypostscript file created by Postage.pm and create a new mypostscript file with only the required postscript/postbootscripts. 
