<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [============================================](#)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

{{:Design Warning}} 

There are a lot of "grep(/something/, @arrayname)" in xCAT code, actually this is not an efficient way to search the array, especially in the scaling environment, we have been seeing significant performance problems in DBObjectdefs.pm in scaling environment caused by the "grep(/something/, @arrayname)", we need to go through xCAT code to improve the "grep(/something/, @arrayname)" if necessary. 

Here is a mail got from Jarrod about the solution: 

###### ============================================

I can suggest two things to try when faced with a circumstance where you do have a massive dataset to repeatedly grep through. You already did the most significant improvement by identifying and skipping when not needed, but for situations where you are in that position: -If it makes sense, you may want to have the list as a hash, i.e., a structure like: @arr = (2, 3, 4 ); 
    
    Takes a lot more time to figure out if 3 is in there than:
    

%arr = (2=&gt;1,3=&gt;1,4=&gt;1); 
    
    Note that the value in this use of a hash I always do as one, as I'm just taking advantage of whatever hashing algorithm perl things best for this sort of thing.  That is doing the most generic thing when I don't need to care about ordering or preserving duplicates for the sake of comparison.  I haven't looked at the code, you may even be able to iterate through the loop once and reorginize the flat list into a hash of lists with objtype as a key, meaning a single hash lookup gets you a list reference with all the items.  There are a few ways to go about it that cause a relatively small penalty for small datasets, but scale exceptionally well for large datasets.
    

-If the above is not applicable or non-trivial to do, changing: grep /^$type$/,@list 
    
    to
    

grep { $_ eq $type },@list 
    
    Will be faster as eq is faster than a regex.
    

There are a few places in xcat that uses one of the above two best practices. 
