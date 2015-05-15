[Design_Warning](Design_Warning)

Some thoughts from jarrod about our own replacement for conserver: 

  * IPv6 support 
  * Precise SSL client certficate authentication for SSL socket client operation 
  * HTTP access (i.e. being an external FastCGI handler, interoperable directly with shellinabox's javascript code). 
  * Baked in ipmi support in the same manner than conserver could do telnet (i.e. fewer processes) 
    * contemplating going a bit further by having non-console IPMI commands over the sessions and helping do some IPMI secret management and rotation to implement IPMI more securely than is typical). 
  * SSL target support (e.g. smoother/possible consoles for KVM/ESXi guests, where the target acts like a client rather than a server) 
  * Smoother configuration reload 
  * Exception-only logging (i.e. a logging option to request the console be monitored for events like firmware errors or kernel oops and only log those sorts of events) 
  * Improved logging performance and function. Reduce IO cost per console whilst adding more precise timing information (eschews plain text logs, but would provide tooling to extract plain text logs optionally stripping control codes alongside potentially a more accurate replaycons) 

I fully anticipate full logging whilst etiher a FastCGI or SSL socket client is connected. It would be site preference as to whether full logging, exception-only logging, or no logging is performed while no clients are connected to a given console, but hopefully the reduced IO cost and more efficient IPMI console support renders it a less costly feature to enact.. 

For authentication, aside from SSL client certs, would support user/password auth with admin having the option to addiotnally require TOTP (TOTP support would have the secret encrypted using user password as key). The TOTP algorithm would be interoperable with the Google Authenticator mobile app. Or could use TOTP from PAM. 
