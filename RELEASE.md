## Date 28th November
Thank you Tracey tboggiano
    Added new CIS Check for the latest SQL build #716
    
Thank you Rob
    Making the SQL Engine Service Check configurable #706

##Latest

## Date 26th November
Thank you Tracey @tboggiano
    Added new CIS Check for OLE AUtomation Procedures to be disabled #707
    Moving the Cross DB Ownership Chaining check into the AllInstance check to help speed up checks #708
Thank you Rob
    Fixing the Tags so that they are picked up by AllInstanceInfo Fixes #715

## Date 16th November
Thank you Matt @matt2005
    Removed rogue else from Agents Tests #713

## Date 17th October
Thank you Shane @SOZDBA
    Improved Documentation
Thank you Gareth NewMan
    Added New Check - Default File Path

## Date 1st October 2019
Thank you Rob
Fixed some merge issues with a load of code :-(
Created GitHub Action to run Pester Checks on PR
Thank you @TracyBoggiano
Added New Checks 
    RemoteAccessDisabled
    ScanForStartUpProcedures
Thank you Gareth Newman
    Improved wording in tests #700 , #697
    Fix incorrect calculation in last agent run time #696 #698
Fixed bug in AllInstanceInfo
Thank you Richard Imenes 
    Fixed dead links in readme #702
Thank you Benjamin Schenk
    Fixed Send-MailMessage in readme #705

## Date 30th July 2019
Thank you Rob ;-)
Added two new checks #239
    LastJobRunTime and LongRunningJob
Added four new configs
    skip.agent.longrunningjobs
    skip.agent.lastjobruntime
    agent.longrunningjob.percentage
    agent.lastjobruntime.percentage

## Date 29th July 2019
Thank you @TracyBoggiano
Added tags for checks that will be part of CIS checks #642
CIS project started
Added check for default trace enabled #684

## Date 23rd July 2019
Thank you @dstrait, @Sozdba
Fix tests that use time to work if client and instance are in different time zones #610
Fixed Maintenance Solution clean up time test #633
Improved Run time #635
Improved Error Log warning window honouring #637
Ignore SQL 2005 for some tests #630,629,#628
Skip TF1118 test if SQL2016 or above

## Date 8th July 2019
Thanks to Chuck for notifying of error
Fixed Update-DbcPowerBiDataSource


## Date 2nd July 2019
dbachecks works with PowerShell Core #620
dbachecks works with dbatools v1 #624
Minimum PowerShell Now 5.0 #568
Prettier output in test names for @cl because she is ace #495
Fixes for none-readable secondaries causing tests to fail #611
Added ability to exclude disks from disk allocation check #561
Added ability to exclude cancelled jobs from failed job check #552
Added max job history for failed jobs #552
Some extra tags added

## Date 22nd May 2019 at Techorama in Room 12
Thank You @SOZDBA, @djfcc, @wsmelton
Improved validation for IP addresses in clusters
Ignored Off-line databases for Pseudo Recovery Checks
Some internal testing changes


## Date 05/02/2019
Thank you Chrissy! @cl
added default environment #596
altered configuration validation for mail to stop errors
Ensured database status check doesnt fail as readonly for snapshots

## Date 31/01/2019 
Thank you Chrissy!
add support for inline config file, fixes #501 #594

## Date 29/01/2019 
Added skip for authentication scheme #587
Added WhatIf to Update-DbcPowerBiDataSource Thank you @shaneis #590
$null to the left Thank you @jwmoss #588 

## Date 19/01/2019 
Thank you Claudio
Added extra check for Job History Settings #582
Added extra check for Error Log Count #583
Added integration test code and docker compose file

##Latest

## Date 22/11/2018
Spelling - Thanks RonaldHensbergen 
Fix for #576 When calling just Invoke-DbcCheck without a Check it fails to run the Server Tests correctly


## Date 12/11/2018
Added more information to the output - thanks @ClaudioESSilva
Spelling - Thanks ChrisTuckerNM 
Fix for #564 - Error Importing DbcConfig in PowerShell 4 - Thanks @niphod

## Date 29/10/2018
Fixed #435 Page verify on SQL 2000 and SQL2005
Reduced number of calls to the instance for database checks improving performance

## Date 27/10/2018
Fixed #435 Page verify on SQL 2000 and SQL2005
Reduced number of calls to the instance for database checks improving performance

## Date 17/10/2018
Spelling and Because added - Thank you @LowlyDBA
New Check for XPCmdShell enabled added

## Date 11/10/2018
Added Check for CLR Enabled
Added Check for Cross Database Ownership Chaining
Added Check for Database Mail XPs
Added Check for Ad Hoc Distributed Queries
Added Tag for security
Demo CI/CD at Polar Conf

## Date 24/09/2018
Moved the Instance Connection Check to the Instance Tests
Fixed bug with Set-DbcConfig not adding none-arrays!
New Check for Expected Trace Flags
New Check for Not Expected TraceFlags
Stopped dbatools chatty messages polluting the test results

## Date 07/09/2018
Updated dbatools required module to 0.9.410
Renamed all dbatools commands to new naming convention
Fixed Bug with JSON file naming
Improved Server Checks to remove Red and improve speed for none contactable servers
Altered all server checks to use assertions and added pester Tests
Removed left over ogv entry 

## Date 05/09/2018
New Check for 2 digit cut off thanks @CláudioESSilva
https://claudioessilva.eu/2018/09/04/dont-cutoff-yourself-when-dealing-with-dates-in-t-sql-did-you-know/
Fixed bug with adding NoneContactable Instances to variable
Improved error handling for HADR checks 

## Date 28/08/2018
Added MaxBehind to SupportedBuild Tests - Thank you @LowlyDBA
Ensured the Database parameter checks only the specified Databases - Thank you @jpomfret
Updated Set-DbcConifg to allow Append to append arrays to arrays closes #535
Altered json filename creation to avoid max characters error
Altered PowerBi to display information correctly with filename changes

## Date 24/08/2017
Fixed Error with using Credential and stopped changing path when running checks from custom repos - Thank you @sammyxx

## Date 23/08/2017
Update to the help message for clusters by @LowlyDBA
Potential Breaking Change - Removed Tags from names of json files so that PowerBi will correctly show Environment names

## Date 15/08/2018
Fixed issue 521 ExcludeDatabase parameter doesn't work - THANK YOU @jpomfret
THANK YOU @jpomfret - Issue 509 -Database should only check databases listed and exclude all others
Further update to Update-DbcPowerBiDataSource to allow Environment as well as specify filename
Improved performance of the Server checks
Improved performance of the Instance checks
Improved performance of the Database checks
Improved performance of the ErrorLog checks
Removed Send-DbcSendMailMessage until it can be re-coded

## Date 13/08/2018
Fixed #504 by enabling FileName parameter on Update-PowerBiDataSouce
Added in new function to begin to reduce the number of calls to each instance
Reduced required Pester version to 4.3.1
Further PowerShell V4 improvements

## Date 06/08/2018
Added New Check for tempdb data file sizes to be the same - Thank you @garethnewman #512
Altered Services Check so that clustered instances start mode is checked correctly thank you @kylejdoyle #516
Skip PowerPlan test if no connection thanks @cl #490
Fixed bug with XESession and PSv4 thank you @kylejdoyle #517
Error silently on failing Service check (thanks Rob ;-) ) 
Fixed dbatools command names
Fixed PSv4 support for importing the module also

## Date 31/07/2018

Added check for Database Exists - Thanks @sqldbawithbeard
Added excluded databases config to each Database Check and wrote Pester Test for that #506
Added msdb to exclusion fro duplicate index #506
Fixed offline install bug #484

## Date 30/07/2018

Updated Required Module versions - Thank you @cl
Updated Agent Checks to fail a test on no connection rather than throw all the PowerShell errors - Thanks @sqldbawithbeard
Updated HADR Checks for PS4 compatibility Issue #513

## Date 28/06/2018

Don't check versions before 2008 for AdHocWorkloads Thank you John McCall @LowlyDBA
More Spelling! Thank you John McCall @LowlyDBA
Updated required version and dbatools error log command name Thank you Our Glorious Chrissy @cl

## Date 30/05/2018
New Release Notes command added
Spelling

## Date 29/05/2012

