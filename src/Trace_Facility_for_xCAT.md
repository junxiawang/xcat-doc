<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [**Overview**](#overview)
  - [**Enable the subroutine calling trace**](#enable-the-subroutine-calling-trace)
  - [**Enable the commented debug trace in debug mode**](#enable-the-commented-debug-trace-in-debug-mode)
- [**External Interface**](#external-interface)
  - [**The trace format**](#the-trace-format)
  - [**The location of trace log**](#the-location-of-trace-log)
- [**Internal implementation**](#internal-implementation)
  - [**Enable the subroutine calling trace**](#enable-the-subroutine-calling-trace-1)
  - [**Enable the debug trace only in debug mode**](#enable-the-debug-trace-only-in-debug-mode)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

Mini-design of Trace Facility for xCAT 


## **Overview**

In the present code of xCAT that no common approach for developer to generate the debug trace. Generally, developer adds the 'print/Dumper/MsgUtils' code inside the xcatd/plugins to display some run-time variables/status in the development phase and remove/comment out them for the release version. The operations of adding/removing debug trace have to be done for every debugging, it's especially hard from the perspective of FVT or customer to get the trace log. 

In this design, I'll add two types of trace facilities for xCAT: 

### **Enable the subroutine calling trace**

Display the calling trace for the subroutines. The trace message includes: The called subroutine name; The arguments which passed to the called subroutine; The calling stack of the subroutine. By default, the trace will be enabled to all the subroutines in xcatd and plugin modules. The subroutine list also can be configured by configuration file or through command line. 

### **Enable the commented debug trace in debug mode**

We always concern about the trace code in the source code that it impacts the performance or even causes the possible defects for a release version. In this design I'll introduce an approach that only enable the trace code in the debug mode. At common mode, the trace code existed as comments. 

## **External Interface**

Offer a command named 'xcatdebug' (It already existed, adding the new functions) to enable/disable and configure the trace facility. 

**xcatdebug [-f enable|disable [-c configuration file| subroutine list]**

Enable/Disable subroutine calling trace. If no -c flag is specified, the enable/disable will impact to all the subroutines which defined in the xcatd and plugins. 

'-c' flag can be used to specify a 'configuration file' or 'subroutine list': 

'SUBROUTINE_DEFINITION': To make user easier to define the subroutine list, I defined this object. The format of it can be [pkgname](sub1,sub2,...). If [pkgname] is ignored, that means the subsequence subroutines belongs to the 'xcatd' (main process). 

'configuration file': Multiple entries of SUBROUTINE_DEFINITION; 

e.g. -c /tmp/xcattrace.cfg. The format inside the configuration file: 
    
    (daemonize,do_installm_service,do_udp_service)
    xCAT::Utils(isMN,Version)
    xCAT_plugin::DBobjectdefs(defls,process_request)
    

'subroutine list': Multiple SUBROUTINE_DEFINITION split with '|'. 
    
    e.g. -c (daemonize,do_installm_service,do_udp_service)|
    xCAT::Utils(isMN,Version)|
    xCAT_plugin::DBobjectdefs(defls,process_request)
    

Note: The xcatd processes will not be restarted when execute the [-f enable|disable]. 

**xcatdebug [-d enable|disable]**

Enable/Disbale the trace code in the source code of xCAT project. 

Note: Since the enable process will be done before the compiling of source code, the xcatd process have be to restarted when executing the enable/disable operation. 

### **The trace format**

A typical trace log includes three parts: Subroutine name; Arguments; Calling stack. Following is a log example of the calling of xCAT_plugin::DBobjectdefs::process_request subroutine: 

Calling *xCAT_plugin::DBobjectdefs::process_request; Argus[{'_xcat_clientfqdn' =&gt; ['localhost'],'_xcat_clientport' =&gt; [41891] ...; Calling stack [ at /opt/xcat/sbin/xcatd line 785#012#011main::__ANON__('HASH(0x32c9038)', 'CODE(0x2ed1b38)', 'CODE(0x2ee1820)') called at /opt/xcat/sbin/xcatd line 1539#012#011main::dispatch_request('HASH(0x32c9038)', 'CODE(0x2ed1b38)', 'DBobjectdefs') called at /opt/xcat/sbin/xcatd line 1349#012#011eval {...} called at /opt/xcat/sbin/xcatd line 1348#012#011main::plugin_command('HASH(0x32c9038)', 'IO::Socket::SSL=GLOB(0x30cefc0)', 'CODE(0x2ed1b38)') called at /opt/xcat/sbin/xcatd line 1842#012#011eval {...} called at /opt/xcat/sbin/xcatd line 1803#012#011main::service_connection('IO::Socket::SSL=GLOB(0x30cefc0)', 'root', 'localhost', 'localhost') called at /opt/xcat/sbin/xcatd line 1073#012] 

main::dispatch_request('HASH(0x32c9038)', 'CODE(0x2ed1b38)', 'DBobjectdefs') 
    
       xCAT_plugin::DBobjectdefs::process_request({'_xcat_clientfqdn' =&gt; ['localhost'],'_xcat_clientport' =&gt; [41891] ...)
           IO::Socket::SSL=GLOB(0x30cefc0)', 'CODE(0x2ed1b38)')
           IO::Socket::SSL=GLOB(0x30cefc0)', 'CODE(0x2ed1b38)')
    

main::service_connection('IO::Socket::SSL=GLOB(0x30cefc0)', 'root', 'localhost', 'localhost') 

  


### **The location of trace log**

The trace log (inside ## DEBUG_BEGIN - ## DEBUG_END) which added by the developer in the subroutine can be displayed to any place (output in cli; syslog, log file) base on how the trace code is written. 

The trace log of subroutines calling trace can be put to syslog or log file; The current decision is put the log in the /var/log/xcat/subcallingtrace. 

  


## **Internal implementation**

### **Enable the subroutine calling trace**

Enable/Disable the function - define two signal handle subroutine for signal (NUM50 - Enable; NUM51 - Disable) in the xcatd. From the xcatdebug to send signal NUM50/NUM51 to enable or disable the functions. 

Enable: Get all the symbols from the symbol table (includes xcatd and plugin modules) and figure out the subroutines that really defined and has been specified in the enable list, then replace the subroutine with a new one that added the debug trace. And store the original one in a global hash for the restoring. 

Disable: Restore the original definition of the subroutines. 

### **Enable the debug trace only in debug mode**

Add the following part of code in the BEGIN{} section to do the filter thing during the loading of source file that change some code in the source file. 
    
    if (defined $ENV{ENABLE_TRACE_CODE}) {
     use xCAT::Enabletrace qw(loadtrace filter);
     loadtrace();
    }
    

Added a new xCAT module /opt/xcat/lib/perl/xCAT/Enabletrace.pm to enable the commented trace log. 

Note: This section has to be added to any package or xcatd if you want to use this function. 

And add the trace code as following format in any place (xcat/plugin modules) 
    
    Trace section
                   ## TRACE_BEGIN
                   # print "In the debug\n";
                   ## TRACE_END
    
    
    Trace in a single line
                   ## TRACE_LINE print "In the trace line\n";
    

  
In common mode, the code keeps as above. But in debug mode, the first # of all the lines between the ' ## DEBUG_BEGIN' and '## DEBUG_END' (e.g. '# `logger -t xcat "debug in plugin_command"`;' will be removed. 
