<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Python](#python)
- [Shell](#shell)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

[Design_Warning](Design_Warning)

Console support is provided via console plugins.  There are two types of plugins

Python
====================================
Python plugins may provide both console and other capabilities.  confluent.interface.console defines the base classes for the Console handler and non-text events for a python plugin to emit.  If a plugin is asked to 'create' a '_console/session' resource for a node, it should return an instance of a subclass of Console.  The ipmi.py plugin is an example of a plugin that supports multiple things including console objects.  It is an example where resource usage is reduced (no forks, pooled filehandles, shared sessions between console and non-console directives) that is possible with a python plugin that is infeasible with a shell plugin.

Shell
=======================================
Shell plugins are a quick way to implement a backend without the full capabilities of a python plugin and worse performance.  CONFLUENT_NODE shall be passed in as an environment variable.  A syntax shall be defined where a shell plugin can have a comment line requesting other configuration data to be pushed in as environment variables.  Disconnect is only possible through exiting.  Receiving break currently is not defined in structure, but may provide a syntax to tell confluent how to send a break to a particular plugin.  Rapidly supporting current conserver backends is as easy as:

    #!/bin/bash
    exec /opt/xcat/share/xcat/cons/kvm $CONFLUENT_NODE