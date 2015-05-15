[Design_Warning](Design_Warning)

The configuration backend will have replication model baked in.  Every instance in an aggregation of confluent servers should have a full copy of data.

Some behaviors require a definitive 'owner'.  Console connection is a very prominent one.