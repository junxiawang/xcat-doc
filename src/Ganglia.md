<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Ganglia Installation Notes](#ganglia-installation-notes)
- [Install Prereqs](#install-prereqs)
- [Get and Install RRDTool](#get-and-install-rrdtool)
- [Get and Install Ganglia](#get-and-install-ganglia)
- [Configure Ganglia on the Management Node](#configure-ganglia-on-the-management-node)
- [Compute Nodes (Quick and Dirty method)](#compute-nodes-quick-and-dirty-method)
- [Compute Nodes (Stateless more permanent method)](#compute-nodes-stateless-more-permanent-method)
- [Add rvitals to Ganglia monitoring](#add-rvitals-to-ganglia-monitoring)
- [...](#)
- [Conclusion](#conclusion)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Howto_Warning](Howto_Warning)


## Ganglia Installation Notes

This HOWTO will cover installing the base Ganglia on to a system running xCAT that uses stateless images. Please update it if you find errors. For this example we're using RedHat 5.x. Also, this is just a simple example. You can get better documentation at the Ganglia site [here](https://sourceforge.net/docman/display_doc.php?docid=128909&group_id=43021). This is just a quick howto where we install Ganglia on the management node and then on stateless images. 

## Install Prereqs
    
    yum -y install apr-devel apr-util check-devel cairo-devel pango-devel
    wget \ ftp://ftp.muug.mb.ca/mirror/fedora/linux/releases/9/Everything/source/SRPMS/libconfuse-2.6-1.fc9.src.rpm
    rpm -ivh libconfuse-2.6-1.fc9.src.rpm
    cd /usr/src/redhat/SPECS
    rpmbuild -ba x86_64 libconfuse.spec
    cd ../RPMS/x86_64/
    rpm -ivh libconfuse-devel-2.6-1.x86_64.rpm libconfuse-2.6-1.x86_64.rpm

## Get and Install RRDTool

This example will use all the defaults to install RRDTool. RRDTool is the round robin database engine behind Ganglia and also the way Ganglia plots graphs. 
    
    cd /install/packages/
    wget http://oss.oetiker.ch/rrdtool/pub/rrdtool.tar.gz
    tar zxvf rrdtool*
    cd rrdtool-*
    ./configure
    make -j8
    make install
    which rrdtool
    echo "/usr/local/rrdtool-1.3.4/lib" &gt;/etc/ld.so.conf.d/rrd.conf
    ldconfig

## Get and Install Ganglia

Get it [here](http://sourceforge.net/project/showfiles.php?group_id=43021&package_id=35280). Download the ganglia-3.1.1.tar.gz file and place it in /install/packages 
    
    cd /install/packages/
    tar zxvf ganglia*tgz
    cd ganglia-3.1.1/
    ./configure --with-gmetad
    make -j8
    make install
    cp -a web /var/www/html/ganglia/
    cp gmetad/gmetad.init /etc/rc.d/init.d/gmetad
    mkdir /etc/ganglia
    gmond -t | tee /etc/ganglia/gmond.conf
    cp gmetad/gmetad.conf /etc/ganglia/
    mkdir -p /var/lib/ganglia/rrds
    chown nobody:nobody /var/lib/ganglia/rrds
    chkconfig --add gmetad
    chkconfig --add gmond

## Configure Ganglia on the Management Node

Edit /etc/ganglia/gmond.conf so that: 
    
    name = "unspecified"

becomes 
    
    name = "yourclustername"

Then, we need to allow support for the python modules. Add the following in the modules { } stanza: 
    
    modules {
      #... a bunch of modules
      module {
        name = "python_module"
        path = "modpython.so"
        params = "/usr/lib64/ganglia/python_modules/"
      }
    }
    include ('/etc/ganglia/conf.d/*.conf')
    include ('/etc/ganglia/conf.d/*.pyconf')

Change /var/www/html/ganglia/conf.php so that 
    
    define("RRDTOOL", "/usr/bin/rrdtool");

becomes 
    
    define("RRDTOOL", "/usr/local/bin/rrdtool");

On my cluster, eth1 on the management server is the interface that connects to the compute nodes. Therefore, to make it so that my gmond traffic goes out on the same broadcast domain as the compute nodes I did this: 
    
    route add -host 239.2.11.71 dev eth1

(You should use the same 239.2.11.71 unless you changed it in the gmond.conf file, but attach it to whatever interface is connected to the nodes.) 

To permanently add this route, so that it is available upon reboot, create the file /etc/sysconfig/network-scripts/route-&lt;your ethernet&gt;. (I wanted to bind Ganglia to eth1, so I created /etc/sysconfig/network-scripts/route-eth1). Then add the contents: 
    
    239.2.11.71 dev eth1

At this point we can now restart everything and look at the web page and see our management node: 
    
    service gmond start
    service gmetad start
    service httpd restart

Now pull up a web browser and look at the management node:  
http://localhost/ganglia 

If you followed the instructions... (or if I documented it correctly) then you should now see the graphs of your cluster and the management node. Nice work! Now lets install the compute nodes. 

## Compute Nodes (Quick and Dirty method)

For compute nodes, we just need to copy the files on to them and it will work fine. Assuming you have a compute group, just run the following: 
    
    pscp /usr/sbin/gmond compute:/usr/sbin/gmond
    psh compute mkdir -p /etc/ganglia/
    pscp /etc/ganglia/gmond.conf compute:/etc/ganglia/
    pscp /etc/init.d/gmond compute:/etc/init.d/
    pscp /usr/lib64/libganglia-3.1.1.so.0 compute:/usr/lib64/
    pscp /lib64/libexpat.so.0 compute:/lib64/
    pscp /usr/lib64/libconfuse.so.0 compute:/usr/lib64/
    pscp /usr/lib64/libapr-1.so.0 compute:/usr/lib64/
    pscp -r /usr/lib64/ganglia compute:/usr/lib64/
    psh compute service gmond start

Now if you restart gmetad or refresh your web browser on the management node you should see all the nodes in it. 

## Compute Nodes (Stateless more permanent method)

This is basically the same as the other method. But here, we put those files in the stateless image. My stateless image is called 'compute'. In this example we've already ran genimage to create the base stateless image. So to add Ganglia to the existing stateless image I do the following: 
    
    export IMGROOT=/install/netboot/rhels5.2/x86_64/compute/rootimg
    echo $IMGROOT
    cp /usr/sbin/gmond $IMGROOT/usr/sbin/gmond
    mkdir -p $IMGROOT/etc/ganglia/
    cp /etc/ganglia/gmond.conf $IMGROOT/etc/ganglia/
    cp /etc/init.d/gmond $IMGROOT/etc/init.d/
    cp /usr/lib64/libganglia-3.1.1.so.0 $IMGROOT/usr/lib64/
    cp /lib64/libexpat.so.0 $IMGROOT/lib64/
    cp /usr/lib64/libconfuse.so.0 $IMGROOT/usr/lib64/
    cp /usr/lib64/libapr-1.so.0 $IMGROOT/usr/lib64/
    cp -a /usr/lib64/ganglia $IMGROOT/usr/lib64/
    chroot $IMGROOT chkconfig --add gmond

Now I pack the image up and deploy it to nodes: 
    
    packimage -p compute -a x86_64 -o rhels5.2
    nodeset compute netboot
    rpower compute boot

Now when these nodes come up they're all set and you should see them in your Ganglia web page. 

## Add rvitals to Ganglia monitoring

You can add rvitals to Ganglia monitoring by using the spoofing mechanisms of gmetric. This is a two step process: 1. Use a script to run rvitals and 2. Use a cron job to run it however often you feel you should. The following script can be saved as /opt/xcat/share/xcat/scripts/xcat-gmetric.pl 
    
    #!/usr/bin/perl
    use strict;
    use Socket;
    
    my $nr = shift;
    if($nr eq ""){
            print "please supply an xCAT noderange as an argument\n";
            exit 1;
    }
    #if($ENV{XCATROOT} eq ""){
    #       print "XCATROOT is not defined in environment\n";
    #       print "Is xCAT installed?\n";
    #       exit 1;
    #}
    
    my %vitals = (
            temp =&gt; ["Celsius", "int16"],
            voltage =&gt;  ["Voltage", "float"],
            fanspeed =&gt; ["RPM", "float"]
    );
    
    foreach my $k (keys %vitals){
            foreach my $i (`rvitals $nr $k`) {
                    my $ip;
                    chomp $i;
                    my($host,$desc,$val) = split(": ", $i);
                    $val = (split(" ", $val))[0];
    
                    my $packet_ip = gethostbyname($host);
                    if(defined $packet_ip){
                            $ip = inet_ntoa($packet_ip);
                    }else{
                            print "Could not get IP for $host\n";
                            next;
                    }
                    my $type = $vitals{$k}-&gt;[1];
                    my $unit = $vitals{$k}-&gt;[0];
                    my $cmd = "gmetric -n '$desc' -v $val -t $type -u $unit -S $ip:$host";
                    `$cmd`;
            }
    }

Then you can create a contab that will run it as often as you like. To run it every minute run: 
    
    crontab -e

Then add the following line to it: 
    
    * * * * * /opt/xcat/share/xcat/scripts/xcat-gmetric.pl compute

That will run the script every minute and run IPMI commands on the compute group. You can use the xCAT noderange options to run on different compute groups. Once the cron job is running you will start to see IPMI entries in the Ganglia graph. Mine looks kind of like this: 

[[img src=Xcat-ganglia.png]] 

## ...

## Conclusion

Hopefully this helps you get started with gmond. I would encourage other readers to add their customizations and send to the xCAT mailing list or me directly so I can post them: vallard AT benincosa.com 
