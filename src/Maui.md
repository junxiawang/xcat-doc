[Howto_Warning](Howto_Warning)

Maui Installation 

If you need torque installation help, check out section 12 in the cookbook. 

**Download Maui**

Go to http://clusterresources.com, create an account and download here:  
http://www.clusterresources.com/product/maui/index.php?  
Put the tarball in /tmp 

**Configure and Build**
    
    **tar zxvf maui-3.2.6p20.tar.gz
    cd maui-3.2.6p20
    # If you set torque up as specified in xCAT docs, you'll need to create some links:
    cd /opt/torque
    ln -s x86_64/bin .
    ln -s x86_64/lib .
    ln -s x86_64/sbin .
    export PATH=$PATH:/opt/torque/x86_64/bin/
    ./configure --prefix=/opt/maui --with-pbs=/opt/torque/
    make -j8
    make install
    cp /opt/xcat/share/xcat/netboot/add-on/torque/moab /etc/init.d/maui
    # Edit /etc/init.d/maui so that all MOAB is MAUI and all moab becomes maui
    service start maui
    chkconfig --level 345 maui on
    # edit /etc/profile.d/maui so that it says:
    export PATH=$PATH:/opt/maui/bin
    source /etc/profile.d/maui
    # edit /usr/local/maui/maui.cfg
    Change: RMCFG[&lt;YOURHOSTNAME&gt;] TYPE=PBS@...@ to:
    RMCFG[&lt;YOURHOSTNAME&gt;] TYPE=PBS
    service maui restart

Now run: 
    
    showq

You should see all of the processors.  
Next try running a job to make sure that maui picks it up.  
QED 
