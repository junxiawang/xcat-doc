<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Confluent Authentication model](#confluent-authentication-model)
- [UNIX Socket](#unix-socket)
- [TLS Socket](#tls-socket)
- [HTTP](#http)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

Confluent Authentication model
---------------------------------
This will be a developer toned document for now, going into more detail
than most any user will care to think about.

Confluent does/will offer a number of authentication schemes:
*Passphrases in its configuration stores:
    -PBKDF transformed passphrase
    -Users need not exist in anything outside the service (e.g. /etc/passwd) if not appropriate
*PAM configuration
    -If /etc/pam.d/confluent exists, the above passphrase backend is totally ignored in favor of PAM
    -Users and/or groups still must exist in the cfg to be authorized
*Certificates
    -For TLS direct client to be supported
    -Might not be supported for HTTP
*Console access tokens
    -Allowing a client service to authenticate and request a token which is bound to a particular console
*System authentication
    -Unix domain socket uses the kernel attested user/password values to correlate to groups

To be clear about priorities, the various services are described:

UNIX Socket
-------------------------------------
1.If client is either root or the owner of the process, they are allowed in.
2.Otherwise, the username and groups are checked against known users/groups
3.If 1 and 2 find no matches, revert to generic passphrase mechanism common with TLS socket.

TLS Socket
-----------------------------------------
1. If client certificate is provided and verified, then subjectaltname is used if present, else subject to identify user.  If certificate does not work, fail.
2. If no client certificate provided, go to generic passphrase mechanism as in unix socket.

HTTP
----------------------------------------
1. If and only if over a unix socket, consider evaluating client certificate passed in headers
2. Go to generic passphrase mechanism