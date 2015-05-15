<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
Table of Contents

- [xCAT 2.0.2 Release Notes](#xcat-202-release-notes)
    - [Behavior Change](#behavior-change)
    - [Feature enhancements](#feature-enhancements)
    - [Bug fixes:](#bug-fixes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# xCAT 2.0.2 Release Notes

Changes from 2.0.1: 

### Behavior Change

xCAT noderange syntax behavior has changed. Previously, commas and @ were evaluated at equal priority left to right. Now, @ is evaluated before commas. Examples: 

  * **compute,[storage@rack1](mailto:storage@rack1)** was evaluated like **(compute,storage)@rack1**, but now is evaluated like **compute,([storage@rack1](mailto:storage@rack1))**
  * **[compute@rack1](mailto:compute@rack1),[storage@rack2](mailto:storage@rack2)** was evaluated like **(([compute@rack1](mailto:compute@rack1)),storage)@rack2**, but now is evaluated like **([compute@rack1](mailto:compute@rack1)),([storage@rack2](mailto:storage@rack2))**

This change is to be more xCAT 1.x like with respect to noderange expansion. 

### Feature enhancements

  * xCAT servers now will generally precede "unexpected client disconnects" with a more useful message. 
  * rsetboot support for floppy boot devices in IPMI systems that support it 

### Bug fixes:

  * Fix severe makedns bug where it didn't work 
  * Fix severe makehosts bug where it didn't work. 
  * authorized_keys permission is now checked to make sure nodes can retrieve the file. 
  * Fix noderange bug where parentheses used in certain positions could cause tasks to abort 
  * Fix problem where copycds would on occasion not cleanly unmount on completion 
  * IPMI spreset now translates BMC provided messages like other commands 
  * Fix init script on RH4 to operate more as expected 
  * Fix problem with 'rspconfig mm sshcfg' 
  * Understand SLES hint for timezone as well as RH 
  * Ignore occurrences of 127.0.0.0 networks when presented in certain places 
  * Provide hint in nfs stateless for init scripts to understand the netdev root 
  * Add missing perl-IO-Tty dependency for SLES dependency resolving at install time 
  * Fix SLES path check to be at command execution time in makedns rather than service startup 
  * Fix problem where wcons menu font was unreadable if an unreadable font was used for the actual console 
  * Fix to allow RH4 systems to pack images for other platforms. RH4 images still not supported. 
  * Stateless image creation fix for case where image build host kernel was preferred incorrectly over another valid option 
  * Various documentation corrections 
