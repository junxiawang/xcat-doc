[Design_Warning](Design_Warning)

Provide a means by which clients can cheaply have a channel to receive updates on changes as they happen, but not actively poll.

This will be via some resource in the tree.  It would behave in many ways similar to a console/session resource.  Meaning it can be opened and data will come as it is available depending on the criteria used to initiate a new event session.  For the socket interface, it's straightforward as we get to define the semantics just like the console interface.  For HTTP interface, the client has to have a long-lived request as a hook for confluent to fire back data (just like console data in the console/session resource)