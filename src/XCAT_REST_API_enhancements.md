<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Problems](#problems)
- [Enhancements](#enhancements)
- [Other Design Considerations](#other-design-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning) 

## Problems

The current xcat rest api has several deficiencies that need correcting: 

  * not all xcat functionality is covered, or even the most commonly used function 
  * the documentation was poor and incomplete 
  * the code was disorganized and not commented 
  * the implementation is slow, it doesn't always use the best xml cmd for the function 
  * the input and output data structures follow the current xml poor and inconsistent structure 

## Enhancements

This is the list of what should be done to correct these problems (in approximate priority order): 

  * **test, fix, &amp; document the api calls for the resources that are currently in the document: images, networks, site, table, vms.**
    * i've completed most of the node api calls as a model for how the code should be structured, for how the json input and output should be structured, and what the documentation should be like. The rest of the resources should follow this example. 
    * the highest priority are the calls that are needed when going thru the [XCAT_iDataPlex_Cluster_Quick_Start]. These are the main calls that a software component above xCAT will need to automate. For example: makehost, makedns, makedhcp, makeconservercf, pasu, copycds, def cmds of osimages, nodeset, rsetboot. 
    * the [xcat rest api document](https://sourceforge.net/apps/mediawiki/xcat/index.php?title=WS_API) needs to include input and output for all calls (bai yuan - 2 days) 
    * there should be an automated test driver in both curl (xcatws-test.sh) and native perl (xcatws-test.pl) so that improvements to xcatws.cgi can be quickly and easily tested. (I've completed xcatws-test.sh for most of the node api calls.) The test drivers only need to test the json output format. (bai yuan - 3 days) 
    * change/fix the json input structure of all put and post calls that i haven't fixed yet, and change the json output structure of all get calls that i haven't fixed yet (bai yuan - 1 week) 
      * most of the put and post calls weren't using json correctly - most of them just had an array of "attr=val" strings. That should be a json object instead (equivalent to a perl hash). I fixed most of the node calls as examples. The rest of the put/post calls should be patterned after those. 
      * the json output of most of the get calls just follows the same kind of structure as the xml output of xcatd, which has never been good (it is inconsistent and structured strangely). Even though it will make the get api calls a little slower (because of more processing), the wrapJson() function should restructure the output to the correct format for the json option. I've already fixed: the get node list and attributes, power, vitals, inventory, and energy as examples. The others should be patterned after that. 
      * i'm using the [openstack api](http://api.openstack.org/api-ref.html) as a model (mostly) 
      * i think the json output format should be the primary one that we document and tell people to use. So just leave the formatting of the xml and html output the way it is now (don't bother improving it). 
      * once the input and output structure is corrected for each call, the corresponding documentation should be corrected 
    * change the implementation of the table api calls to use lissa's xml interface that she did for pcm (its faster) (bruce or bai yuan - 3 days) 
      * document them as a faster/better alternative to the get api calls that use lsdef 
      * here's info from lissa about her api: "the drivers that show how to use it are on 9.114.34.44 in /root/lissa/PCM/api. The driver I use is pcmdriver. All the XML input files are in there. I think they match the lastest code. I think the files that start with PCM* were actually given to me by PCM so I could see exactly how I was called. I don't see them in our release, so maybe they add them later. If you look at pcmdriver, it is pretty simple. Also the interface is commented at the top of each routine in tabutils.pm. The number files like getTablesAllNodeAttribsreq1 are just variations on the call like multiple table vs 1 table. Uncomment # $ENV{'XCATXMLTRACE'}=1; in pcmdriver and you will see the XML" 
    * instead of checking for each individual keyword in the params and correlating it to an xcat flag, have a hash that maps keyword to flag, and then just process them all in a loop. I did this for xdsh &amp; xdcp as an example. Do this for the other api calls too. Since xcatws.cgi is loaded/processed by apache on every api call, if we let it get super big, it will slow each call down. 
  * **eliminate the need to put the pw in the url (bai yuan - 1 week)**
    * use an api key or certificate instead. See what openstack does. 
    * also figure out why we have to use -k in the curl cmd right now 
  * **figure out if the data sent back is given the correct Content/Type (bai yuan - 1 day)**
  * **compare the xcatws.cgi code that talks to xcatd (sendRequest()) to the Client.pm code to make sure it isn't missing any bug fixes in the last couple years (bai yuan (ask xiao peng for help) - 1 day)**
  * **test, document, and fix/improve the code for the other resource handlers that are in the code, but not in the document: groups, logs, notifications, policies, accounts, hypervisor(bai yuan - 1 week)**
  * **add api calls for functionality that is missing (bai yuan - 2 days)**
    * osimage definition create, change, delete, and also and copycds 
    * nodeset stat (to query current nodeset setting) 
  * **don't have to do it right away, but we might want to eventually break the different resource handlers (and corresponding json wrapper functions) into separate pm files, one for each resource. Each api call only references one resource, so only 1 pm would have to be loaded.**
  * **investigate trying to send output back to the rest api client as it is coming from xcatd (instead of waiting for all of the data from xcatd before sending anything to the rest api client) (bai yuan - 1 week)**
    * some api calls can take a long time, especially for a lot of nodes, so to see nothing until the call is complete is not very good usability 
    * this might be tricky, maybe only do it for xml output where it doesn't really do much processing of the ouput anyway? (altho you would have to change the code to avoid converting the output from xml -&gt; perl -&gt; xml, which is what i think it does now. 
  * **do performance/scale tests with lots of nodes and optimize code (bai yuan - 1 week)**
  * **add api calls to return meta-data of resources (list of possible attributes of def objects)(bai yuan - 3 days)**
  * **convert this to use FASTCGI (bai yuan - 1 week)**

## Other Design Considerations

  * **Required reviewers**: Bruce Potter 
  * **Required approvers**: Guang Cheng 
  * **Database schema changes**: N/A 
  * **Affect on other components**: N/A 
  * **External interface changes, documentation, and usability issues**: N/A 
  * **Packaging, installation, dependencies**: N/A 
  * **Portability and platforms (HW/SW) supported**: N/A 
  * **Performance and scaling considerations**: N/A 
  * **Migration and coexistence**: N/A 
  * **Serviceability**: N/A 
  * **Security**: N/A 
  * **NLS and accessibility**: N/A 
  * **Invention protection**: N/A 
