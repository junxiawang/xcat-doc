<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT Documentation Goals](#xcat-documentation-goals)
- [Comment on the Existing Documentation](#comment-on-the-existing-documentation)
- [Request Editor Access to the Wiki](#request-editor-access-to-the-wiki)
- [Edit xCAT Documentation Pages](#edit-xcat-documentation-pages)
  - [Consistent Format and Style in xCAT Documentation](#consistent-format-and-style-in-xcat-documentation)
- [SourceForge Markdown syntax](#sourceforge-markdown-syntax)
- [Tips for Converting MediaWiki docs to SourceForge Markdown](#tips-for-converting-mediawiki-docs-to-sourceforge-markdown)
- [Bugs Opened to Souceforge Site-support Team](#bugs-opened-to-souceforge-site-support-team)
- [Including Pages/Sections Into Other Pages using MarkDown wiki](#including-pagessections-into-other-pages-using-markdown-wiki)
  - [HPC Integration Related:](#hpc-integration-related)
- [Experimenting With Documentation](#experimenting-with-documentation)
- [Organizing the Documentation](#organizing-the-documentation)
- [Converting Existing Cookbooks](#converting-existing-cookbooks)
- [Converting Wiki Pages to HTML and PDFs](#converting-wiki-pages-to-html-and-pdfs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)

Help us make the xCAT documentation better! Here's some tips on how to edit the documentation. 


## xCAT Documentation Goals

The xCAT documentation has been converted to mediawiki format and reorganized. The goals of/reasons for this new format are: 

  * Organize the information better so it is easier to find the information you want, including the use of the wiki search feature 
  * Have each cookbook be more complete and self-contained, making use of transcluding and links to accomplish this 
  * Enable users to comment on the documentation (suggestions, etc.) in the Discussion page of each document so that we can improve it. In some cases, let users update the documentation directly. 
  * Improve some of the most used documents, for example, the xCAT iDataPlex cookbook 
  * Still enable users to download HTML and PDF versions of the documentation for offline use 

## Comment on the Existing Documentation

We would appreciate your feedback on our documentation.  Please give us your comments about how the documents could be improved, for example, information that is missing, incorrect, or poorly worded. We really want to know specific suggestions of how to make the documentation better! 

You can post your document suggestions/corrections/additions to the [xCAT mailing list](https://lists.sourceforge.net/lists/listinfo/xcat-user) or open a defect in our [bug tracker](http://sourceforge.net/p/xcat/bugs/). 

## Request Editor Access to the Wiki

To get edit authority to the xCAT wiki: 

  1. [create a SourceForge account](https://sourceforge.net/account/registration/) if you don't already have one 
  2. go to the [xCAT Wiki](https://sourceforge.net/p/xcat/wiki/Main_Page/) and login with your SourceForge ID by clicking on the "Log In" link in the upper right hand corner. (This is necessary to do once in order for the sourceforge wiki to establish a user id for you, so we can give you editor access in the steps below.) 
  3. post to the [xCAT mailing list](https://lists.sourceforge.net/lists/listinfo/xcat-user) requesting editor access to the wiki, specifying your sourceforge username 
  4. we will give you editor access and respond to your posting 
  5. then you can log in to the wiki and edit pages 


## Edit xCAT Documentation Pages

Yes, you can. If we have granted you editor access, you can make updates to the documentation pages, as long as you know what you are talking about. This is MarkDown style contributions: xCAT developers are tracking all of the changes, and we will back out your updates (The wiki keeps a history of all changes) if we think they are not an improvement. So do your homework, make good changes, and everyone will benefit. Especially remember that xCAT is used in a lot of environments, so you have to think about more than just your situation when updating the documentation. 

### Consistent Format and Style in xCAT Documentation

In order for the xCAT documentation pages to look clean, nice, and consistent, follow these guidelines, this is for MarkDown WIKI.  


  * Documents must not have / in the name.  Markdown cannot load it. 
  * Headings should have each word capitalized (except for minor words like: and, in, the, at, for, etc.). 
  * Headings should not have special characters, especially [ and keep the text short. Makes linking easier.
  * Actual commands should just be indented and surrounded with 4 tildas.  Markdown wiki will highlite. 
  * "setup" is a noun ("the CMM setup looks good"), "set up" is a verb ("now set up the CMM").  
  * If you a giving the user a choice of 2 ways to do something (but they should only do one of them), summarize the choices ahead of time, and then put in the subsequent headings "Option 1: blah", "Option 2: blah blah". This makes it more obvious that they should skip the section they didn't choose. 
  * Even though in high school english they told us not to use "you" in papers, we should use "you" in our documentation. It often makes the sentences more natural and clear. 
  * After writing the 1st pass of the documentation, re-read it trying to look at it from the user's perspective and think about if the flow is optimum and think about what they might not know as they are going through this. Also, please correct grammar and typos. Those of you from China, please have someone review it that is especially good at English. 
  * The 1st time you mention a command in a section, make it a link to its man page, using the links the [man page index](http://xcat.sourceforge.net/man1/xcat.1.html). Same things goes for 
[tables or objects](http://xcat.sourceforge.net/man5/xcatdb.5.html). 

## SourceForge Markdown syntax

* https://sourceforge.net/p/forge/documentation/markdown_syntax/

## Tips for Converting MediaWiki docs to SourceForge Markdown

As of June 19th, 2014, xCAT MediaWiki docs were imported into SourceForge Wiki which uses Markdown syntax.  However, the import process was not perfect, and manual cleanup of all of our documents is required.  As you work through this cleanup, please add here issues that you have found, and ways that you fixed them.  This will help others know what to look for and an idea of what needs to be done.

* Missing content:  The import process lost information from your doc.  
    - <u>Problem</u>:  The import process lost entire chunks of data from the original doc.  The original doc contained character strings such as:
        + &nbsp;&nbsp;/xxx/&lt;''hostname''&gt;  this text and other data got lost until some next tag &lt;b&gt;resume text   
got imported as:   
&nbsp;&nbsp;/xxx/resume text

    - <u>Fix</u>:  Find a copy of the MediaWiki doc and manually add back the missing text.    
 
* Code examples:
    - <u>Problem</u>:  In MediaWiki a code example was created simply by indenting a block of text.  These get lost in Markup.  And even worse, some of the special characters in your code block may have caused other import or strange formatting errors.    
      <u>Fix</u>:  Surround each code block or command example with lines containing four tildes and note you need a blank line between the ~~~~ and text and after the ~~~~ and text for the PDF generation to work. 
   
~~~~
&nbsp;&nbsp;&tilde;&tilde;&tilde;&tilde;
&nbsp;&nbsp;your example command or code block
&nbsp;&nbsp;&tilde;&tilde;&tilde;&tilde;
~~~~
 
    - Many command examples and code blocks were imported with bold and/or italic formatting characters on each line.  These now show up as `_ and *` characters within the Markdown code block and must be manually removed.


* Use of <  >  in code examples.  If the code example contained a < and >, it probably was not converted from the html characters &lt  and   &gt .  You will have to manually change to <  >  and should surround the code block or command with lines containing four tildes.

* If your line was bold in mediawiki, that is it was surrounded with double quotes;  the import will have converted the double quotes to underbar(_).  All these will have to be fixed, for example it now looks like this in the document (_/usr/bin/mysql_install_db --user=mysql_)



*  Text formatting:
    - <u>Problem</u>:  Occasionally, highlighted MediaWiki text that may contain Markup formatting characters may cause strange results.  A very common one is italicized strings containing imbedded underscores, especially in paragraphs that contained many different cases of these.  For example, this MediaWiki source:     
&nbsp;&nbsp;the ''lpp_source'' location    
was imported as:    
&nbsp;&nbsp;the \_lpp_source \_location \_    
So instead of getting 'the _lpp_source_ location', we got 'the _lpp_source _location _'.    
<u>Fix</u>:  Carefully review your formatting for these types of strings and adjust the underscores correctly.

    - Indented paragraphs may have been turned into code blocks.  The most obvious symptom is that the new wiki page now has a scroll bar in the middle of it where you weren't expecting one.  You will need to remove the blanks preceding the paragraph and use some other formatting.  Blockquotes may do what you want:  use the &gt; character in front of the paragraph.

    - Only italics (as single \* or \_) and bold (double \*\* or \_\_) are available as Markdown basic text formatting.  For others such as underlining or strikethrough, you need to drop into HTML (e.g. `<u>underlined text</u> and <s>strikethrough text</s> respectively`).  I have found that <u>underlined text</u> was converted to _italicized text_ with the import, so take special note if there was something that you really needed underlined.

    - Backticks \` are special Markdown characters to signify a piece of inline text that should not be formatted.  Be sure to verify anywhere you may have used backticks as part of a command example. 

    - The backslash could be used to display the special characters like \*, \[ and \> in markdown, for example, there are a lot of cases in our doc that embedded some words using [], for example [RH],[SLES], needs to change to \\[RH\\] and \\[SLES\\].

     -  If any pages had a "/" in the name, it will have to be renamed. Markdown wiki will not load it. 



* Links to other xCAT wiki docs:
    - Links to wiki docs need to change.  For example, update    
&nbsp;&nbsp;\[Cluster_Name_Resolution\]    
to     
&nbsp;&nbsp;\[Cluster Name Resolution\](Cluster_Name_Resolution) . Note you  need to use the [Description](Name of page format). If you just put [Name of page] the link will work in the wiki but not in the generated PDF, we ship. 

    - All of the links that are linking to a sub-section of a doc need to be changed, because this new wiki makes the anchor for headings by lowercasing all the words and replacing the spaces with "-",  
    - Links to subsections of other docs must change from :    
&nbsp;&nbsp;\[XCAT_iDataPlex_Advanced_Setup#Updating_Node_Firmware\]    
to
&nbsp;&nbsp;\[XCAT_iDataPlex_Advanced_Setup#Updating_Node_Firmware\](XCAT_iDataPlex_Advanced_Setup/#updating-node-firmware)
or a more simple notation if it the section is in the same doc:
&nbsp;&nbsp;\[#Updating_Node_Firmware\](#updating-node-firmware)

* Transcludes need to be changed
    - For example, update:    
&nbsp;&nbsp;{{:Installing Stateful Linux Nodes}}     
to     
&nbsp;&nbsp;\[\[include ref=Installing_Stateful_Linux_Nodes\]\] 


* All attachments and hyperlinks need to be verified that they are correct especially those that have full links to the now obsolete `https://sourceforge.net/apps/mediawiki/xcat/....` pages.


* Headers: 
    - <u>Problem</u>:  the markdown font size between different level of headers is not easy to read.
    - <u>Fix</u>: A best practice found on internet is to add a horizontal line after the header1, here is example:

\# this is a header 1
\-\-\-
\#\# this is a header 2
this is some test words.

* Tables: 
    - <u>Problem</u>:  the tables in mediawiki is not imported correctly in the markdown wiki.
    - <u>Fix</u>: Needs to manually convert the tables. The syntax of markdown tables is quite easy. There is an example in the [HA MN doc](https://sourceforge.net/p/xcat/wiki/Highly_Available_Management_Node/#configuration-options)
    - We are now using pandoc to convert all of our wiki pages to standalone pdf files and html pages to be used offline.  The Allura wiki markdown format for tables is not compatible with pandoc markdown.  In order for getxcatdocs to convert the tables to the correct format please insert these HTML comment blocks before and after each table, specifiying the correct number of columns and column widths as character counts:

~~~~

    &lt;!---
    begin_xcat_table;
    numcols=3;
    colwidths=20,20,20;
    --&gt;

    | YOUR | TABLE | HEADERS
    -------|-------|-----------------
    | YOUR | TABLE | ROWS
    
    &lt;!---
    end_xcat_table
    --&gt;

~~~~


## Bugs Opened to Souceforge Site-support Team

* "Search" is not working correctly in Allura Wiki, see [sourceforge site support bug 8031](https://sourceforge.net/p/forge/site-support/8031/) - **Status: Fixed**

* Print the docs in Allura wiki, see [sourceforge site support feature request 100](https://sourceforge.net/p/forge/feature-requests/100/) - **Status: Open**

* Allura Wiki page TOC does not include the headers from "included" pages, see [sourceforge site support bug 4771](https://sourceforge.net/p/allura/tickets/4771/) - **Status: target for Sep 19 2014**

* Subscribe to the whole wiki, see [sourceforge site support bug 4905](https://sourceforge.net/p/allura/tickets/4905/) - **Status: target for Sep 19 2014**

* Last modified info for the Allura wiki pages, see [sourceforge site support feature request 285](https://sourceforge.net/p/forge/feature-requests/285/) - **Status: Open**

* Can not display the pages that have "/" in the title, see [sourceforge site support bug 8157](https://sourceforge.net/p/forge/site-support/8157/) - **Status: Open**

* Can not show show which pages that this page "includes" and which pages that "include" this page, see [sourceforge site support feature request 289](https://sourceforge.net/p/forge/feature-requests/289) - **Status: Open**

## Including Pages/Sections Into Other Pages using MarkDown wiki

A page can be included into another page (they call this [transcluding](http://meta.wikimedia.org/wiki/Transcluded)), using &nbsp;&nbsp;\[\[include ref=Installing_Stateful_Linux_Nodes\]\] . We can use this for some of the common info that is needed in many places. 

When two pages need to discuss the same material in the same way, they can share a section. This involves creating a third page and transcluding that page onto both pages. Please the details in [Pages with a common section](http://en.wikipedia.org/wiki/Wikipedia:Transclusion#Pages_with_a_common_section)

The small "pagelets" that we have created for including into other pages are listed here for ease of editing: 

  * Headers: 
    * [Howto_Warning] 
    * [Design_Warning] 
    * ![](https://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png)
    * [XCAT_Discussion_Page_Header] 
    * [No_Longer_Used_Warning] 
  * AIX: 
    * [Create_an_AIX_Diskless_Image] 
    * [Update_the_image_-_SPOT] 
    * [AIX_SN_backup_-_no_reboot] 
    * [AIX_Overview] 
    * [Using_AIX_service_nodes] 
    * [Installing_AIX_diskful_nodes_-_using_NIM_rte_method] 
  * p775: 
    * [Setup_for_Power_775_Cluster_on_xCAT_MN] 
    * [Power_775_Cluster_on_MN] 
    * [Generate_Pack_Image_for_Power_775] 
  * Linux MN setup: 
    * [Prepare_the_Management_Node_for_xCAT_Installation] (used in: idpx quick start, flex x doc, xCAT-pLinux Clusters) 
    * [Configure_ethernet_switches] (used in&nbsp;: idpx quick start, flex x doc) 
    * [Install_xCAT_on_the_Management_Node] (used in: idpx quick start, flex x doc, xCAT_pLinux Clusters) 
    * [Configuring_xCAT] (used in: xCAT_pLinux Cluster full) 
  * Linux deployment: 
    * [Using_Provmethod=osimagename] (used in: idpx quickstart, flex x and p docs, plinux full doc) 
    * [Installing_Stateful_Linux_Nodes] (used in: idpx quickstart, flex x doc, pdocs) 
    * [Using_Provmethod=install,netboot_or_statelite] (not used) 
    * [Build_and_Boot_Stateless_Images] (not used) 
    * [Building_a_Stateless_Image_of_a_Different_Architecture_or_OS] (used in: Using Provmethod=osimagename doc, bladecenter doc) 
    * [Install_Additional_Packages] (used in provmethod=osimagename and plinux full doc) 
    * [Monitor_Installation] (used in idpx quickstart, flex x and pdocs) 
  * Name Resolution and Networking: 
    * [Cluster_Name_Resolution] 
    * [Configuring_name_resolution_on_AIX] (not used) 
    * [Setting_Up_Name_Resolution] (not used) 
    * [Defining_Networks]     
    * [Updating_etc_hosts] 
    * [setup_hosts]  ( replace Updating_etc_hosts)
  * Utilities: 
    * [The_location_of_synclist_file_for_updatenode_and_install_process] 
    * [Gather_MAC_information_for_the_node_boot_adapters] 
    * [Switching_Databases] 
    * [Managing_Large_Tables] 
    * [Energy_Management] 
    * [IB_Interface_Configuration_ON_Management_node] (used in both IB docs)
    * [HAMN_OS_Image] (used in HA docs) 
    * [Template_of_mypostscript] (used in Using Updatenode, and others)
  * REST API 
    * [REST_API_Reference] 
  * For Developers: 
    * [Writing_Man_Pages] 
  * [Temporary_xCAT_zVM_Fixed_Doc] 

  


### HPC Integration Related:

  * [Copy_the_HPC_software_to_your_xCAT_management_node] 
  * [Add_to_pkglist] 

     Note: The login nodes install the same base OS packages that are installed on compute nodes. References to compute.*.pkglist in this step are correct. 

  * [Synchronize_system_configuration_files] 
  * [Synchronize_system_configuration_files_AIX] 
  * [Instructions_for_adding_IBM_HPC_products_to_existing_xCAT_nodes_Linux] 
  * [Instructions_for_adding_IBM_HPC_products_to_existing_xCAT_nodes_AIX] 
  * [Network_boot_the_nodes_Linux] 
  * [Network_boot_the_nodes_AIX] 
  * [Install_the_optional_xCAT-IBMhpc_rpm_on_your_xCAT_management_node] 
  * [Add_the_HPC_packages_to_the_lpp_source_used_to_build_your_image] 
  * [Add_additional_base_AIX_packages_to_your_lpp_source] 
  * [Set_up_LoadlLeveler_DB_access_node_and_Central_Manager] 
  * [Initiate_a_network_boot_over_HFI_on_Power_775] 
  * [Setting_up_IBM_HPC_Products_on_an_IO_node]

## Experimenting With Documentation

TODO: This must be changed for MarkDown wiki.   mediawiki no longer supported 

A couple pages have been created to experiment with the various aspects of mediawiki pages. Feel free to edit these pages to try something out: 

  * [XCAT_Doc_Test_Page] 
  * [XCAT_Doc_Test_Transcluded_Page] 
  * [Node_Network_Boot_Flow] 

## Organizing the Documentation

  * Each cluster environment (hardware, OS, type of node, etc.) should be documented in its own cookbook that is a streamlined, but sufficient description of how to get the cluster up and running. The cookbook should be complete by transcluding, or linking to, information that is common among multiple environments. 
  * Common topics (that apply to more than one environment) should be in their own page to facilitate including them in the cookbooks 
  * Reference material (documenting every option of every command, and every file format) should be put in the [man pages](https://xcat.svn.sourceforge.net/svnroot/xcat/xcat-core/trunk/xCAT-client/pods/) in SVN in pod format. The xCAT RPM build will automatically convert the pods to nroff and html format. 
  * Links from the cookbooks to man pages should go to the html version of the [man pages](http://xcat.sf.net/man1/xcat.1.html) or [DB table/object descriptions](http://xcat.sf.net/man5/xcatdb.5.html) on SourceForge. 

## Converting Existing Cookbooks

This is the third rendition of the xCAT cookbooks, created in June 2014, managed by Allura Wiki stored in SourceForge.  These were converted from the previous Mediawiki format.  Many manual changes were required after the initial automated conversion.  Please be patient while we continue this process and let us know if there are critical changes you need that are missing that still need to be made.

The original xCAT cookbooks were written in ODT format and were converted to Mediawiki. 

## Converting Wiki Pages to HTML and PDFs

The xCAT documentation is periodically converted to HTML and PDF and [stored on sourceforge for downloading](http://sourceforge.net/projects/xcat/files/doc), for use when you are working in a cluster environment that doesn't have internet access. 

The xCAT command [getxcatdocs](https://sourceforge.net/p/xcat/xcat-core/ci/master/tree/xCAT-client/bin/getxcatdocs) is provided to download/convert all of the latest xCAT wiki docs to HTML and PDF. It is a stand-alone perl script that can be copied to and executed on any machine that has perl and is connected to the internet.  The conversion uses the Allura wiki API to download the markdown with curl, which is then converted to html and pdf using Pandoc and LaTex.  Before you can use the getxcatdocs command on your machine, you must install these packages, the following example runs on RHEL 6.x, the procedure on other Linux distributions might be slightly different. 

+ Setup OS repo and EPEL.  

~~~~
    rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
~~~~

+ CentOS repo, there are some packages only available on CentOS repo, so need to copy the CentOS repo from some CentOS machine, see the page attachment for a sample CentOS repo file.

~~~~
    texlive-xetex  x86_64  2007-57.el6_2           C6.2-updates 2.1 M

    Installing for dependencies:
    dvipdfmx       x86_64  0-0.31.20090708cvs.el6  C6.0-base   344 k
    libpaper       x86_64  1.1.23-6.1.el6          C6.0-base    34 k
    perl-PDF-Reuse noarch  0.35-3.el6              C6.0-base    89 k
    teckit         x86_64  2.5.1-4.1.el6           C6.0-base   275 k
    texlive-texmf-errata-xetex  
                   noarch  2007-7.1.el6            C6.0-base   4.7 k
    texlive-texmf-xetex  
                   noarch  2007-38.el6             C6.2-base   137 k
    xdvipdfmx      x86_64  0.4-5.1.el6             C6.0-base   487 k
~~~~


+ Install pandoc and the texlive packages:

~~~~
    yum install pandoc texlive-latex texlive-xetex 
~~~~

+ Download [getxcatdocs](https://sourceforge.net/p/xcat/xcat-core/ci/master/tree/xCAT-client/bin/getxcatdocs) 

+ Run the command help for options:
   
~~~~
    getxcatdocs -h
~~~~

+ Run the command to download and convert all of the xCAT wiki docs into your current working directory:

~~~~
    getxcatdocs
~~~~

