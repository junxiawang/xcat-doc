<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [Always Use strict and warnings](#always-use-strict-and-warnings)
- [Use "defined" Function in "if" Statements](#use-defined-function-in-if-statements)
- ["Require" Instead of "Use"](#require-instead-of-use)
- [Plugin exit code](#plugin-exit-code)
- [Client/server response structure](#clientserver-response-structure)
- [GetOptions()](#getoptions)
- [Adding To/Subtracting From a Comma-Separated List in the DB](#adding-tosubtracting-from-a-comma-separated-list-in-the-db)
- [Do not use the Perl Switch.pm library](#do-not-use-the-perl-switchpm-library)
- [Performance considerations](#performance-considerations)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Always Use strict and warnings

Always use the strict and warnings pragmas near the top of each file. This causes perl to warn you about undeclared variables and other bad things. 
    
    use strict;
    use warnings;

If you need to turn off one aspect of strict checking because perl is complaining about something valid you are doing, use one of the following: 
    
    no strict "refs";
    no strict "vars";
    no strict "subs";

## Use "defined" Function in "if" Statements

If you just put a variable by itself in a boolean expression to check to see if the variable was assigned a value, you will get incorrect results if the variable was assigned "0". For example: 
    
    my $stab = xCAT::Table->new('site');
    my $sent = $stab->getAttribs({key=>'svloglocal'},'value');
    if ($sent and $sent->{value}) {
        # this section will not get executed if svloglocal has the value "0", which is a value valid
    }

Instead, it should be coded like this: 
    
    my $stab = xCAT::Table->new('site');
    my $sent = $stab->getAttribs({key=>'svloglocal'},'value');
    if ($sent and defined($sent->{value}) ) {
        # blah, blah
    }

In the above example, the 1st occurrence of $sent doesn't need to be wrapped in defined(), because a reference to a hash can never validly be zero. (But of course it wouldn't hurt to wrap it in defined().) 

The **exception** to this rule is that you should **not** put an entire hash variable in the defined() function, e.g.: 
    
    if (defined(%myhash)) { blah; blah; }   # incorrect
    if (defined(%::MYHASH)) { blah; blah; }   # incorrect

This is deprecated in more recent versions of perl. If the hash name is syntactically correct at all (i.e. you've done a declaration like "my %myhash", or you are using the explicit package form like %::MYHASH which doesn't need to be declared), then you can just check for the key you are interested using: 
    
    if (defined($myhash{mykey})) { blah; blah;}   # correct

No need to 1st check if the hash itself exists. If you really want to see if there are any keys at all in the hash, then use: 
    
    if (%myhash) { blah; blah; }   # correct

## "Require" Instead of "Use"

If you include perl modules using the **require** statement instead of **use**, perl will wait until that part of code is executed at runtime before reading the module file. This is what we want in general. As the amount of xCAT code grows, loading that code becomes a non-negligible amount of time. This is especially important for anything that runs in the client commands or other forked environment. (xcatd loads the perl code once and remains running, so it is not as big of a hit there.) Using **require** within the functions that need them whenever possible/sensible allows us to avoid many perl module loads if the code path executed doesn't happen to hit them. 

Using **require** instead of **use** does mean that you have to fully qualify all references to functions or vars in the module, when referring to them from outside of the module. But this is good practice anyway, because it makes the code more self-documenting. (Normally, within the module it can refer to its own functions and variables w/o fully qualifying them.) There are 2 ways to fully qualify a reference to something in a module: 
    
    xCAT::NodeRange::noderange($range);
    xCAT::Utils->isLinux();

The 1st form is normal function invocation semantics. The 2nd form will actually pass the class name as the 1st parameter into the function, which the function must be expecting or it will cause errors in your logic. In general, the 1st form is preferable, since it is simpler. The 2nd form should be used if the module can also be used in an object-oriented fashion, because then the class name or object is passed in as the 1st argument in both cases. 

Technically, 
    
    use MyModule.pm

is equivalent to: 
    
    BEGIN { require MyModule; import MyModule; }

This means the only 2 differences between **require** and **use** are: 

  1. The **use** will get performed as soon as the perl interpreter scans (compiles) the file that has the **use** in it. This has the subtle side affect that a BEGIN statement within the module will be run during compile time, whereas a BEGIN statement within a module that is pulled in via **require** won't be run until the **require** is executed at run time (which could be never, if that code path is not hit). But, in general, it is bad practice to depend on a BEGIN statement within a module being run before the runtime of all code starts. The BEGIN statement within a module should just need to be run before any of the code within that module is run (which will happen with either **require** or **use**). 
  2. The **use** can cause its symbols (functions and variables) to be imported into the calling file's namespace (a feature we sometimes use in our xCAT code, but many of the built-in perl modules do). I don't like this practice for our xCAT code and we should minimize it. It is simply a convenience so you don't have to fully qualify a reference to a function or variable in a module, but that means it is hard to tell where that function comes from. A search for the string "@EXPORT" will show the modules that import symbols into the calling code. We should try to reduce this list over time. 

## Plugin exit code

Doing "return 1;" from a plugin doesn't accomplish anything. The proper way is to do: 
    
    push @{$rsp->{errorcode}}, $someexitcode;
    push @{$rsp->{error}}, "my error message";

## Client/server response structure

A lot of our code isn't handling the response structure correctly. A lot of places seem to just be **incorrectly** setting, for example: 
    
    $rsp->{data}->[0] = 'foo';    # wrong

But this is only valid if you are sure no code has already put something in $rsp->{data} . A **better** way is to do this is: 
    
    push @{$rsp->{data}}, 'foo';    # right

BTW, you can also put a whole list on to that array using push, instead of using a foreach loop: 
    
    push @{$rsp->{data}}, @myarray;

## GetOptions()

Unless there is a specific need to, do **not** set: 
    
    Getopt::Long::Configure("pass_through");

This causes GetOptions() to return true even if the user specified an invalid option. Plus, this is a global value that will be inherited by the rest of our code without it knowing. For now, to be safe, before calling GetOptions() set: 
    
    Getopt::Long::Configure("no_pass_through");

## Adding To/Subtracting From a Comma-Separated List in the DB

When an attribute in the table contains a comma-separated list (e.g. nodelist.groups), you can add or remove one item from that list with a single command: 
    
    nodech n1 groups,=g2                # adds g2 to n1's group list
    nodech n1 groups^=g3                # removes g3 from n1's group list
    nodech n1 groups^=g2 groups,=g3          # replaces g2 with g3 in n1's group list

## Do not use the Perl Switch.pm library

Using the Perl Switch.pm library affects the ability to use Perl debugger on AIX. 

## Performance considerations

  * Always keep in mind that tables can be very large. Although our development clusters tend to be just a few nodes, one of the key strengths of xcat is that it can manage very large clusters. Don't read table entries one at a time. Use the fewest calls to routines in Table.pm as possible. This is why routines like getNodesAttribs and getAllNodeAttribs were created to be able to get attributes for multiple nodes in a single call. Much faster. 
  * Try not to process a table multiple times for a single command. If you can use a single call to getNodesAttribs or getAllNodeAttribs and then loop thru the hash, do that. If for some reason you need to read the whole table (like with getAllAttribs(), read it into a hash and process the hash multiple times. 
  * Do not search an array using "grep(/something/, @arrayname)" if the array has more than several items, the performance of this code is very bad, especially in a large scale environment. Convert the array to a hash like: 
    
    %nodehash = map { $_ => 1 } @nodes;
    

    If the above line of code is a mystery to you, here's what is happening: map takes each element of the array and evaluates what is in the braces and adds that to the list it is returning to the lefthand side of the equals. In this case, each element of the @nodes array gets converted to 2 elements, for example: node5, 1. So map returns a list like: node1, 1, node2, 1, node3, 1, etc. In perl, when an array/list is assigned to a hash, it takes every other element as a key, and the alternate elements as the values. 
    Now that you have a hash with a value of 1 associated with all keys, you can efficiently check for the element with: 
    
    if ($nodehash{node5} == 1)
    

  * If you are reading an entire file into an array, do **not** do: 
    
    my @filecontent;
    while (
    
