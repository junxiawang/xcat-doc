<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Writing Man Pages](#writing-man-pages)
  - [Testing Man Pages](#testing-man-pages)
  - [Debugging pod Errors](#debugging-pod-errors)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Writing Man Pages

A man page must be created for every new xCAT command that is written. xCAT automatically creates man pages out of pod files during the build process. To create a man page for a new command, a pod file must be created and checked into SVN under xCAT-client/pods and one of the man* subdirectories. Here's some guidance about which man directory to put your man page in: 

  * If the corresponding command is in bin, the man page should generally be in man1. 
  * If the command is in sbin, the man page should generally be in man8. 
  * File format man pages belong in man 5. 
  * Reusable concepts (that are not actually commands) like noderange we are putting in man3. 
  * See the [wikipedia article on man sections](http://en.wikipedia.org/wiki/Man_page#Manual_sections) for more info. 

BTW, man pages for the xCAT database tables and objects are automatically created during the build process from the description information in perl-xCAT/xCAT/Schema.pm . 

There is quite a bit of inconsistency in the formatting of our man pages. See the [official pod documentation](http://perldoc.perl.org/perlpod.html), here are also a few recommendations: 

  * **You need to have a blank line between each element (paragraph, keyword, etc.) in your file. And the blank line can't have any spaces or tabs in it.**
  * Use nodels.1.pod as an example, if creating a new man page. I tried to make this one completely right. 
  * Showing command syntax within your man page: 
    * Bold (B
            
            =over 4
            

=item -h 

Display usage. 

=item -v 

Display verbose messages. 

=back 

  * Links to other man pages should look like: 
    
    See also the L&lt;lsdef(1)|lsdef.1&gt; command.
    You can even link to a db table man page (e.g. L&lt;nodehm(5)|nodehm.5&gt;) or to an object definition (L&lt;osimage(7)|osimage.7&gt;).

  * To show verbatim (unformatted) text, put one or more blanks at the beginning of the line. Remember to have a completely blank line at the start of the verbatim text, or it will get flowed into the paragraph before it. 
  * In the examples section, both the command and the output should in the verbatim format. 

### Testing Man Pages

You should test the formatting of your pod file before checking it in. Verify not only the text man page, but also the html man page. All the man pages are at &lt;http://xcat.sf.net/man1/xcat.1.html&gt;, and we point a lot of users to this, so you don't want your man page to be all messed up there. I use the following 2 .bashrc functions to be able to test the formatting of a pod file in my local git repository: 
    
    # To test the formatting of a pod file as a man page:
    #   cd to the specific pod dir in git, e.g:  cd xCAT-client/pods/man1
    #   podit nodels.1.pod
    function podit
    {
     mkdir -p ~/tmp/man
     pod2man $1 ~/tmp/man/${1/.pod/}
     #echo "rc=$?"
     cd ~/tmp/man/
     manit ${1/.pod/}
     cd - &gt;/dev/null
    }
    
    # To test the formatting of a pod file as an html page:
    #   cd to the specific pod dir in git, e.g:  cd xCAT-client/pods/man1
    #   htmlit nodels.1.pod
    #   use your browser to view ~/tmp/html/nodels.1.html
    function htmlit
    {
     mkdir -p $HOME/tmp/html
     pod2html --infile=$1 --outfile=$HOME/tmp/html/${1/.pod/.html} --podroot=.. --podpath=man1:man3:man5:man8 --htmldir=$HOME/tmp/html --recurse
     #echo "rc=$?"
     rm -f pod2htmd.tmp pod2htmi.tmp
    }
    
    # Needed by podit
    function manit
    {
     num=${1/*./}
     mkdir -p ~/tmp/man/man$num
     ln -sf $PWD/$1 ~/tmp/man/man$num
     man -M ~/tmp/man ${1/.*/}
    }

### Debugging pod Errors

There is a tool podchecker, in /git/xcat-core/xCAT-client directory. It will help you debug errors that you get when you run podit or htmlit. 
    
    /git/xcat-core/xCAT-client/podchecker /git/xcat-core/xCAT-client/pods/man8/tabprune.8.pod
    /git/xcat-core/xCAT-client/pods/man8/tabprune.8.pod pod syntax OK.
    
