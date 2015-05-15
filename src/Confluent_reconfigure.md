When a parameter in confluent changes, the relevant persistent entities should automatically change.

This is most obvious in the console sessions.

If you have misconfigured the password on an ipmi device, the state of the console session
will say badcredentials.  If in a separate session someone fixes the credentials, the console session immediately responds by trying to re-establish the connection using the credentials set at the time.