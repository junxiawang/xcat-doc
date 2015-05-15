<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT 2 Packaging and Download Structure](#xcat-2-packaging-and-download-structure)
  - [xcat.sf.net:](#xcatsfnet)
  - [FRS:](#frs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# xCAT 2 Packaging and Download Structure

The organization of the xCAT download areas is more complicated than one would like because we have 2 download areas, niether of which satisfy all of our requirements: 

  * [FRS](https://sourceforge.net/project/platformdownload.php?group_id=208749) \- this is the traditional download area for sourceforge projects. The biggest drawbacks: we can't fully automate the uploading of our pkgs (because it requires a manual step via the browser interface), and we can't set up a yum repository and directory structure. 
  * [xcat.sf.net](http://xcat.sourceforge.net/yum) \- this is our web site and shell service space. It has all of the flexibility we want, but is limited to only 100 MB. 

Because of the above restrictions, here's how we organize our downloads. (Note: both Linux and AIX pkgs are organized the same way, so the following applies to both.) 

## xcat.sf.net:

  * The latest xCAT code (as opposed to xcat-dep): 
    * in expanded form and tarball 
    * for the stable and development branches 
    * both snap and official builds. 
  * Only the xcat-dep contents in expanded form. 
  * No xcat-dep tarball, and no back versions of xCAT code 

## FRS:

  * The official xCAT code tarballs for the latest stable release and previous stable releases. 
  * The xcat-dep tarball (both current and previous releases) 
    * The xcat-dep tarball file should be named with the same version number as the latest stable xcat-core, even though it also supports previous versions of xcat. 
    * The xcat-dep tarball should always be put in Release "2.x Linux" or "2.x AIX". No need to (and you should not) create a new Release. 
  * No snap builds, no development builds 
