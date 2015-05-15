<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Near Term Work Items](#near-term-work-items)
- [Longer Term/Someday...](#longer-termsomeday)
- [Completed (Just Here for Reference)](#completed-just-here-for-reference)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Add information here about enhancements to the web interface you are planning on adding, or would like someone else to add. 

## Near Term Work Items

  * **Monitor page**
    * Add Ganglia RPMs into otherpkg list to be installed on the node during provisioning(install method done) 
  * **Nodes page**
    * Node tab with 100's/1000's of nodes: further performance analysis and tuning(Working on this) 
    * Graphical layout for system X(includes the mixed cluster). 
    * support rscan to add new blade node. 
  * **Provision page**
    * On provision page, provide way to view/manage pkglists, view nodes' boot progress, show MN's log message, show nodes' status in the node list area and refreshing nodes' status, etc. 
    * Image mgmt tab under the Provision page: provide a way to associate images with nodes 
  * **Configure page**
    * Preferences - settings for this web interface itself - is this done? 
    * Mgmt Node - help in configuring the xCAT management node (e.g. when the xCAT install on the MN, and log on xCAT GUI first time. run all the mk* or make* commands, start/check necessary daemons, etc.) 
    * Sync Files - set things up on the MN for CFM-like capability. 
    * Cluster initialization &amp; xcatsetup command support for system X(need a mini design) 
  * Improve color scheme(the color scheme as a user preference) 
  * Web services REST API 
  * Web interface requirement from LRZ bid (4Q2011): Graphical high level system overwiew with the ability to zoom into a detailed display of interesting componets (I/O behavior, disk access behavior, CPU load, memory load, paging rate, etc.) are desired. 

## Longer Term/Someday...

  * Restructure the presentation portion of the code to handle different devices so that we can support the web interface on iphone and android. 
  * **Add cluster summary to main page (done)**
    * which needs one wonderful UI design 
    * I have completed the summary page, which looks simple... 
  * Support dynamic node groups so cluster summaries are available, like # of nodes down, etc. 
  * From Jarrod: in the rvitals tab, xcoll-type formatting (and collation) would be good, with gui header elements with collapse capability (i.e. the header has a twisty next to it to toggle the view underneath). This might be a generic widget someone might want to do. 
  * Make the browser back button work 
  * Lab Floor/Racks - show the nodes in 1 of 2 views (these is some code in xCAT-web for this): 
    * Lab Floor – will show the racks as they are arranged on the lab floor. Each frame will be a single icon that shows some aggregate info: frame #, overall status of nodes in that frame, maybe some aggregated performance data. One or more frames can be selected and operations run against the nodes in those frames (using groups that are set up for each frame). 
    * Frames – show an icon for each node arranged in frames like they are in real life. Each node can show status, and when you hover over it, it will show hostname and possibly more attributes/info. You can also select nodes and run operations against them. 
  * Jobs - show jobs currently running on nodes, etc. Vallard has some ideas here. 
  * Diagnose - help the admin check/verify the MN or nodes to assist in finding problems. 
  * Global - Show the Chinese label on the web page. 

## Completed (Just Here for Reference)

  * Packaging changes: 
    * Add Javascript minify to build (Done) 
    * Package open src prereq's (e.g. jquery) in a separate rpm and put in xcat-dep (Done) 
  * **Node table**
    * first list nodes using nodels and show 1st 50 nodes (w/o attrs) as the node names they come back from xcatd (Done) 
    * then get the attributes via lsdef for just the 50 nodes, and show that output as it comes back from xcatd (Done) 
    * Support clicking in cell to modify value 
  * Change submit_request() in functions.php to replace new lines "\n" with ":|:" (Done) 
  * Get rid of close button on tabs that are there permanently (Done) 
  * **Add support for xcat rpms update (could be one button)** (Done) 
    * some code already in support/updateui.php, needed to change 
    * completed on Linux 
    * Working on Redhat 
    * support the choice of both devel and stable branch (radio button and input) 
    * the "webrun" command can be used 
    * remember the user's last choice 
  * **Add a page to show lsdef attributes** (Done) 
    * Make the table in the Attributes tab editable 
    * Provide a button to add new attributes 
  * **Get https work ** (Done) 
  * **Code Structure** (Done) 
    * modify the code to formal code structure 
  * **Fix the menu at top of page so navigation is easier (done)**
  * **Rcons page**(Done) 
    * add one page that users can connect one node's console and show the output 
  * **Graphical display**
    * show CECs on top of frame images (Done) 
    * new way to show that lpars are selected when looking at the CEC image (Done) 
    * Try running xcatsetup and display results in the graphical tab (Done) 
  * **Discover wizard**
    * move to Configure page as a Discover tab (Done) 
    * Cluster Setup Wizard for System P (Done) 
  * **Nodes tab**
    * remove Power column for non-Z (Done) 
    * change pping to nodestat (Done) 
    * add easy way to set up xcatmon and then use nodelist.status attribute instead of running nodestat/pping (Done) 
    * Add a summary by pie chat on the nodes page. Users can click the pie chat to view nodes details(like click the group node on the left side).(Done) 
    * add support for x &amp; p provisioning（Done） 
    * Add new system x node(Done). 
    * Add new system p node by rscan(Done). 
  * **Image mgmt tab under the Provision page**
    * implement server-side file chooser (Done) 
    * give assistance on how to set attributes (Done) 
    * use file browser for path-related attributes (Done) 
  * **Modify monitor page**
    * change the monitor page to show all nodes' status (Done) 
    * Change condition/response association dialog to be columns side by side and start/stop in one dialogure (Done) 
    * Monitor config page: complete the description tab (Done) 
    * Show/modify the monsettings for xcatmon (Done) 
    * Increasing RMC Monitor result showing speed.(Done) 
    * Choose 1 monitoring plugin to set up by default and show results--ganglia (Done) 
    * Allow user to turn on/off monitoring plugin (Done) 
    * On monitor page only RMC plugin finished, Ganglia plugin should be completed (Done) 
  * Add a summary about each page's function into xCAT web gui install document.（Done） 
    * redesign the login dialogue, it should be simple and professional.(Done) 
