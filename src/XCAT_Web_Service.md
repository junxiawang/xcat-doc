<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [class="xcat-green-heading"Web Service Architecture](#classxcat-green-headingweb-service-architecture)
- [class="xcat-green-heading"Web Service Output](#classxcat-green-headingweb-service-output)
- [class="xcat-green-heading"Web Service Status Codes](#classxcat-green-headingweb-service-status-codes)
- [class="xcat-green-heading"Web Service Security](#classxcat-green-headingweb-service-security)
- [class="xcat-green-heading"WS Reference Links](#classxcat-green-headingws-reference-links)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


  
http://server/xcatws/ is the root of the web service. The next piece of the URI specifies the base resource a Request is being sent to, for instance, a GET sent to http://server/xcatws/nodes/ would be handled by the nodes resource. Often users of xCAT 2.x make changes to their cluster by changing data directly in the database. This will be exposed via the resource tables. For example, to access the nodepos data table, use http://server/xcatws/tables/nodepos.   


## class="xcat-green-heading"Web Service Architecture

Representational State Transfer (REST) has been chosen as the architecture for the xCAT Web Service interface. A simple explanation can be found at [REST on Wikipedia](http://en.wikipedia.org/wiki/Representational_State_Transfer)

  


## class="xcat-green-heading"Web Service Output

The outputs supported by the Web Service are HTML, JSON and XML. HTML is the default format. The format can be specified by setting the 'format' field of a request. For example: 

https://myxcatserver/xcatws/tables?format=json 

  


## class="xcat-green-heading"Web Service Status Codes

Here are the HTTP defined status codes that the Web Service can return.   
  
401 Unauthorized  
403 Forbidden  
404 Not Found  
405 Method Not Allowed  
406 Not Acceptable  
408 Request Timeout  
417 Expectation Failed  
418 I'm a teapot  
503 Service Unavailable  
  
200 OK  
201 Created  


  


## class="xcat-green-heading"Web Service Security

SSL will be used to protect the data sent between the client and the Web Service. The xCAT passwd table will control access and the user id and password will be passed in the userName and password fields. A GET example:  
  
https://myserver/xcatws/tables?userName=foo&amp;password=bar 

  


## class="xcat-green-heading"WS Reference Links

Misc Links:  
REST: http://en.wikipedia.org/wiki/Representational_State_Transfer  
REST: http://rest.elkstein.org/2008/02/what-is-rest.html  
HTTP Status codes: http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html  
HTTP Request Methods: http://tools.ietf.org/html/rfc2616#section-9.1  
HTTP Request Tool: http://soft-net.net/SendHTTPTool.aspx (haven't tried it yet)  
HTTP PATCH: http://tools.ietf.org/html/rfc5789  
HTTP BASIC Security: http://httpd.apache.org/docs/2.2/mod/mod_auth_basic.html  
Asynchronous Rest: http://www.infoq.com/news/2009/07/AsynchronousRest  
General JSON: http://www.json.org/  
JSON wrapping: http://search.cpan.org/~makamaka/JSON-2.27/lib/JSON.pm  
Apache CGI: http://httpd.apache.org/docs/2.2/howto/cgi.html  
Perl CGI: http://perldoc.perl.org/CGI.html  


  

