<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Introduction](#introduction)
- [Set Up the WEB Service for REST API](#set-up-the-web-service-for-rest-api)
  - [Enable the HTTPS service for REST API](#enable-the-https-service-for-rest-api)
    - [RHEL 6 (x86_64/ppc64) and RHEL 5 (x86_64)](#rhel-6-x86_64ppc64-and-rhel-5-x86_64)
    - [RHEL 5 (ppc64)](#rhel-5-ppc64)
    - [SLES 10/11 (x86_64/ppc64)](#sles-1011-x86_64ppc64)
    - [Ubuntu](#ubuntu)
  - [Enable the Certificate of HTTPs Server (Optional)](#enable-the-certificate-of-https-server-optional)
  - [Extend the Timeout of Web Server](#extend-the-timeout-of-web-server)
  - [Set Up an Account for Web Service Access](#set-up-an-account-for-web-service-access)
    - [Use root Account](#use-root-account)
    - [Use non-root Account](#use-non-root-account)
- [Overview of the xCAT REST API](#overview-of-the-xcat-rest-api)
  - [The Resource Categories](#the-resource-categories)
  - [The Authentication Methods for REST API](#the-authentication-methods-for-rest-api)
    - [**User Account**](#user-account)
    - [**Access Token**](#access-token)
  - [The Common Parameters for Resource URI](#the-common-parameters-for-resource-uri)
  - [The Output of REST API request](#the-output-of-rest-api-request)
    - [**When an Error occurs during the operation**](#when-an-error-occurs-during-the-operation)
    - [When NO Error occurs during the operation](#when-no-error-occurs-during-the-operation)
      - [For the GET method](#for-the-get-method)
      - [For the PUT/DELETE methods](#for-the-putdelete-methods)
      - [For POST methods](#for-post-methods)
  - [Testing the API](#testing-the-api)
    - [An Example of How to Use xCAT REST API from PERL](#an-example-of-how-to-use-xcat-rest-api-from-perl)
    - [An Example Script of How to Use curl to Test Your xCAT REST API Service](#an-example-script-of-how-to-use-curl-to-test-your-xcat-rest-api-service)
    - [Examples of making an API call using curl:](#examples-of-making-an-api-call-using-curl)
- [REST API Resources](#rest-api-resources)
- [Web Service Status Codes](#web-service-status-codes)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](http://sourceforge.net/p/xcat/wiki/XCAT_Documentation/attachment/Official-xcat-doc.png) 


## Introduction 

xCAT provides a REST API (also called a web services API) that is currently implemented as a front end (translation layer) to xcatd. This provides programmatic access to xCAT from any language. This document describes how to set it up and use it. 

Post problems, suggestions, etc. to the xCAT mailing list. 

**NOTE:** This doc is working with xCAT 2.8.4 and later. 


## Set Up the WEB Service for REST API 

The following steps describe how to setup the WEB Service to use the REST API

### Enable the HTTPS service for REST API 

To improve the security between the REST API client and server, enabling the HTTPS service on the xCAT management is recommended. And the REST API client should use the 'https' to access web server instead of the 'http'. 

#### RHEL 6 (x86_64/ppc64) and RHEL 5 (x86_64)

~~~~
    yum install mod_ssl
    service httpd restart
    yum install perl-JSON
~~~~

#### RHEL 5 (ppc64)


Uninstall httpd.ppc64 and install httpd.ppc: 

~~~~
    rpm -e --nodeps httpd.ppc64 
    rpm -i httpd.ppc mod_ssl.ppc
~~~~

#### SLES 10/11 (x86_64/ppc64)

~~~~
    a2enmod ssl
    a2enflag SSL
    /usr/bin/gensslcert
    cp /etc/apache2/vhosts.d/vhost-ssl.template /etc/apache2/vhosts.d/vhost-ssl.conf
    Insert line 'NameVirtualHost *:443' before the line '## SSL Virtual Host Context'
    /etc/init.d/apache2 restart
    zypper install perl-JSON
~~~~

#### Ubuntu

~~~~
    sudo a2enmod ssl
    ln -s ../sites-available/default-ssl.conf  /etc/apache2/sites-enabled/ssl.conf
    sudo service apache2 restart
~~~~
    
verify it is loaded:

~~~~
    sudo apache2ctl -t -D DUMP_MODULES | grep ssl
    apt-get install libjson-perl
~~~~

### Enable the Certificate of HTTPs Server (Optional)

Enabling the certificate functionality of https server is useful for the Rest API client to authenticate the server. 

Since a certificate for xcatd has already been generated when installing xCAT, it can be reused by the https server. To enable the server certificate authentication, the hostname of xCAT MN must be a fully qualified domain name (FQDN) that the REST API client must use when accessing the https server. If the hostname of the xCAT MN is not a FQDN, you need to change the hostname. Also, typically the hostname of the xCAT MN is initially set to correspond to the NIC that faces the cluster, which is usually an internal/private NIC. If you want to be able to use the REST API from a remote client, you should make the xCAT MN hostname correspond to the public NIC. To change the hostname, edit /etc/sysconfig/network (RHEL) or /etc/HOSTNAME (SLES) and run: 

~~~~
    hostname <newFQDN>
~~~~

Rerun xcatconfig to generate a new server certificate with the correct hostname. 

~~~~
    xcatconfig -c
~~~~

Notes: If you had previously generated a certificate for non-root userids to use xCAT, you must regenerate them using: /opt/xcat/share/xcat/scripts/setup-local-client.sh <username>

The steps to configure the certificate for https server: 

~~~~
    export sslcfgfile=/etc/httpd/conf.d/ssl.conf              # rhel
    export sslcfgfile=/etc/apache2/vhosts.d/vhost-ssl.conf    # sles
    export sslcfgfile=/etc/apache2/sites-enabled/ssl.conf     # ubuntu

    sed -i 's/^\(\s*\)SSLCertificateFile.*$/\1SSLCertificateFile \/etc\/xcat\/cert\/server-cred.pem/' $sslcfgfile    
    sed -i 's/^\(\s*\)SSLCertificateKeyFile.*$/\1SSLCertificateKeyFile \/etc\/xcat\/cert\/server-cred.pem/' $sslcfgfile
        
     service httpd restart        # rhel
     service apache2 restart      # sles/ubuntu

~~~~

The REST API client needs to download the xCAT certificate CA from the xCAT http server to 
      authenticate the certificate of the server. 
 
~~~~   
    cd /root
    wget http://<xcat MN>/install/postscripts/ca/ca-cert.pem
~~~~    

When accessing using the REST API, the certificate CA must be specified and the FQDN of the https server hostname must be used. For example: 
 
~~~~   
    curl -X GET --cacert /root/ca-cert.pem 'https://<FQDN of xCAT MN>/xcatws/nodes?userName=root& \
      password=cluster'
~~~~    

### Extend the Timeout of Web Server

Some operations like 'create osimage' (copycds) need a long time (longer than 3 minutes sometimes) to complete. It would fail with a timeout (504 Gateway Time-out) if the timeout setting in the web server is not extended: 
 
~~~~   
    For rhel
        sed -i 's/^Timeout.*/Timeout 600/' /etc/httpd/conf/httpd.conf
        service htttd restart
    For sles
        echo "Timeout 600" >> /etc/apache2/httpd.conf
        service apache2 restart
~~~~~    

### Set Up an Account for Web Service Access

The REST API calls need to provide a username and password. When this request is passed to xcatd, it will first verify that this user/pw is in the xCAT [passwd](http://xcat.sourceforge.net/man5/passwd.5.html) table, and then xcatd will look in the [policy](http://xcat.sourceforge.net/man5/policy.5.html) table to see if that user is allowed to do the requested operation. 

You can use the root userid for your API calls, but we recommend you create a new userid (for example wsuser) for the APi calls and give it the specific privileges you want it to have: 

#### Use root Account

Since the certificate and ssh keys for **root** account has been created during the install of xCAT. And the public ssh key has been uploaded to computer node so that xCAT MN can ssh to CN without password. Then the only thing needs to do is to add the password for the **root** in the passwd table. 
   
~~~~ 
    tabch key=xcat,username=root passwd.password=<root-pw>
 
~~~~   

#### Use non-root Account

Create new user and setup the password and policy rules. 
 
~~~~    
    useradd wsuser
    passwd wsuser     # set the password
    tabch key=xcat,username=wsuser passwd.password=cluster
    mkdef -t policy 6 name=wsuser rule=allow
~~~~ 

Note: in the tabch command above you can put the salted password (from /etc/shadow) in the xCAT passwd table instead of the clear text password, if you prefer. 

Create the SSL certificate under that user's home directory so that user can be authenticated to xCAT. This is done by running the following command on the Management node as root: 
  
~~~~   
    /opt/xcat/share/xcat/scripts/setup-local-client.sh <username>
~~~~ 

When running this command you'll see SSL certificates created. Enter "y" where prompted and take the defaults. 

To enable the POST method of resources like nodeshell,nodecopy,updating,filesyncing for the non-root user, you need to enable the ssh communication between xCAT MN and CN without password. Log in as <username> and run following command:

~~~~     
    xdsh <noderange> -K
~~~~ 

Refer to the doc to [Granting_Users_xCAT_privileges] for details. 

Run a test request to see if everything is working: 
 
~~~~   
    curl -X GET --cacert /root/ca-cert.pem \
     'https://<xcat-mn-host>/xcatws/nodes?userName=<user>&password=<password>'
~~~~

or if you did not set up the certificate: 

~~~~    
    curl -X GET -k 'https://<xcat-mn-host>/xcatws/nodes?userName=<user>&password=<password>'
~~~~

You should see some output that includes your list of nodes. 




## Overview of the xCAT REST API

### The Resource Categories

The API lets you query, change, and manage the resources in following categories: 

  * Token Resources 
  * Node Resources 
  * Osimage Resources 
  * Network Resources 
  * Policy Resources 
  * Group Resources 
  * Global Configuration Resources 
  * Service Resources 
  * Table Resources 


### The Authentication Methods for REST API

xCAT REST API supports two ways to authenticate the access user: user account (username + password) and access token (acquired by username + password). 

#### **User Account**

Follow the steps in [WEB Service Setup](WS_API#set-up-the-web-service-for-rest-api), you have created an account for yourself. Use this pair of username and password, you can access the https server. 

The general format of the URL used in the REST API call is: 

~~~~
    https://<FQDN of xCAT MN>/xcatws/<resource>?userName=<user>&password=<pw>&<parameters>
~~~~

where: 

  * **FQDN of xCAT MN**: the hostname of the xCAT management node. It also can be the IP of xCAT MN if you don't want to enable the web server certificate 
  * **resource**: one of the xCAT resources listed above 
  * **user**: the userid that the operation should be run on behalf of. See the previous section on how to add/authorize a userid. 
  * **pw**: the password of the userid (can be the salted version from /etc/shadow) 

Example: 

~~~~    
    curl -X GET --cacert /root/ca-cert.pem \
     'https://<FQDN of xCAT MN>/xcatws/nodes?userName=root&password=cluster'
~~~~

#### **Access Token**

xCAT also supports to use the Access Token to replace the using of username+password in every access. Before the access to any resource, you need get a token first with your account (username+password) 

~~~~    
    # curl -X POST --cacert /root/ca-cert.pem \
        'https://<FQDN of xCAT MN>/xcatws/tokens?pretty=1' -H Content-Type:application/json --data \
        '{"userName":"root","password":"cluster"}'
     {
        "token":{
          "id":"5cabd675-bc2e-4318-b1d6-831fd1f32f97",
          "expire":"2014-3-10 9:56:12"
        }
     }
~~~~    

Then in the subsequent REST API access, the token can be used to replace the user account (username+password) 
    curl -X GET --cacert /root/ca-cert.pem -H X-Auth-Token:5cabd675-bc2e-4318-b1d6-831fd1f32f97 'https://<FQDN of xCAT MN>/xcatws/<resource>?<parameters> 

The validity of token of 24 hours. If an used token has been expired, you will get a 'Authentication failure' error. Then you need reacquire a token with your account. 


### The Common Parameters for Resource URI

xCAT REST API supports to use several common parameters in the resource URI to enable 

**pretty=1** \- It is used to format the json output for easier viewing on the screen. 

~~~~
    https://<xCAT MN>/xcatws/nodes?pretty=1
~~~~    

**debug=1** \- It is used to display more debug messages for a REST API request. 

~~~~
    https://<xCAT MN>/xcatws/nodes?debug=1
~~~~    

**xcoll=1** \- It is used to specify that the output should be grouped with the values of objects. 

~~~~
    GET https://<xCAT MN>/xcatws/nodes/node1,node2,node3/power?xcoll=1
     {
       "node2":{
         "power":"off"
       },
       "node1,node3":{
         "power":"on"
       }
     }
~~~~    

Note: All the above parameters can be used in mixed. 

    https://<xCAT MN>/xcatws/nodes?pretty=1&debug=1
    

### The Output of REST API request

xCAT REST API only supports the [JSON](http://www.json.org/) formatted output. 

#### **When an Error occurs during the operation**
(i.e. there's error/errorcode in the output of xcat xml response):

For all the GET/PUT/POST/DELETE methods, the output will only includes 'error' and 'errorcode' properties: 

~~~~
    { 
       error:[
           msg1,
           msg2,
           ...
       ], 
       errorcode:error_number 
    }
~~~~    

#### When NO Error occurs during the operation
(i.e. there's no error/errorcode in the output of xcat xml response):

##### For the GET method
If the output can be grouped by the object (resource) name, and the information being returned is attributes of the object, then use the object name as the hash key and make the value be a hash of its attributes/values: 

~~~~
    {
      object1: {
         a1: v1,
         a2: v2,
         ...
      },
      object2: {
         a1: v1,
         a2: v2,
         ...
      },
    }
~~~~

If the output can be grouped by the object (resource) name, but the information being returned is **not** attributes of the object, then use the object name as the hash key and make the value be an array of strings: 

~~~~
    {
      object1: [
         msg1,
         msg2,
         ...
      ],
      object2: [
         msg1,
         msg2
         ...
      ],
    }
~~~~

An example of this case is the output of reventlog: 

~~~~
    {
      "node1": [
         "09/07/2013 10:05:02 Event Logging Disabled, Log Area Reset/Cleared (SEL Fullness)",
         ...
      ],
    }
~~~~

If the output is not object related, put all the output in a list (array): 
~~~~
    [
       msg1,
       msg2,
       ...
    ]
~~~~

##### For the PUT/DELETE methods

There will be no output for operations that succeed. (We made this decision because the output for them is always not formatted, and no program will read it if xcat indicates the operation has succeeded.) 

##### For POST methods

Since POST methods can either be creates or general actions, there is not as much consistency. In the case of a create, the rule is the same as PUT/DELETE (no output if successful). For actions that have output that matters (e.g. nodeshell, filesyncing, sw, postscript), the rules are like the GET method. 


### Testing the API

Normally you will make REST API calls from your code. You can use any language that has REST API bindings (most modern languages do). 

#### An Example of How to Use xCAT REST API from PERL
   
~~~~ 
    /opt/xcat/ws/xcatws-test.pl
    ./xcatws-test.pl -m GET -u "https://127.0.0.1/xcatws/nodes?userName=root&password=cluster"
~~~~    

#### An Example Script of How to Use curl to Test Your xCAT REST API Service

It can be used as an initial script to make your xCAT REST API script to access and control xCAT resources. From the output message, you also could get the idea of how to access xCAT resources. 
  
~~~~  
    /opt/xcat/ws/xcatws-test.sh
    ./xcatws-test.sh -u root -p cluster
    ./xcatws-test.sh -u root -p cluster -h <FQDN of xCAT MN>
    ./xcatws-test.sh -u root -p cluster -h <FQDN of xCAT MN> -c
    ./xcatws-test.sh -u root -p cluster -h <FQDN of xCAT MN> -t
    ./xcatws-test.sh -u root -p cluster -h <FQDN of xCAT MN> -c -t
~~~~    

But for exploration and experimentation, you can make API calls from your browser or using the **curl** command. 

To make an API call from your browser, use the desired URL from this document. To simplify the test step, all the examples for the resources uses 'curl -k' to use insecure http connection and use the 'username+password' to authenticate the user. 

~~~~    
    curl -X GET -k 'https://myserver/xcatws/nodes?userName=xxx&password=xxx&pretty=1'
~~~~

#### Examples of making an API call using curl:

** To query resources:**
  
~~~~  
    curl -X GET -k 'https://xcatmnhost/xcatws/nodes?userName=xxx&password=xxx&pretty=1'
~~~~

** To change attributes of resources:**

~~~~    
    curl -X PUT -k 'https://xcatmnhost/xcatws/nodes/{noderange}?userName=xxx&password=xxx' \
       -H Content-Type:application/json --data '{"room":"hi","unit":"7"}'
~~~~

** To run an operation on a resource:**
 
~~~~   
    curl -X POST -k 'https://xcatmnhost/xcatws/nodes/{noderange}?userName=xxx&password=xxx' \
       -H Content-Type:application/json --data '{"groups":"wstest"}'
~~~~

**To delete a resource:**

~~~~
    curl -X DELETE -k 'https://xcatmnhost/xcatws/nodes/{noderange}?userName=xxx&password=xxx'
~~~~



## REST API Resources

For a detailed description of the REST API interface and supported function, read this doc:

[REST_API_Reference]




## Web Service Status Codes

Here are the HTTP defined status codes that the Web Service can return: 

  * 401 Unauthorized 
  * 403 Forbidden 
  * 404 Not Found 
  * 405 Method Not Allowed 
  * 406 Not Acceptable 
  * 408 Request Timeout 
  * 417 Expectation Failed 
  * 418 I'm a teapot 
  * 503 Service Unavailable 
  * 200 OK 
  * 201 Created 




## References

  * REST: http://en.wikipedia.org/wiki/Representational_State_Transfer 
  * REST: http://rest.elkstein.org/2008/02/what-is-rest.html 
  * HTTP Status codes: http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html 
  * HTTP Request Methods: http://tools.ietf.org/html/rfc2616#section-9.1  

  * HTTP Request Tool: http://soft-net.net/SendHTTPTool.aspx (haven't tried it yet) 
  * HTTP PATCH: http://tools.ietf.org/html/rfc5789 
  * HTTP BASIC Security: http://httpd.apache.org/docs/2.2/mod/mod_auth_basic.html 
  * Asynchronous Rest: http://www.infoq.com/news/2009/07/AsynchronousRest 
  * General JSON: http://www.json.org/ 
  * JSON wrapping: http://search.cpan.org/~makamaka/JSON-2.27/lib/JSON.pm 
  * Apache CGI: http://httpd.apache.org/docs/2.2/howto/cgi.html 
  * Perl CGI: http://perldoc.perl.org/CGI.html 