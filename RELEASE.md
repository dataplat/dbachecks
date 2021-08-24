## 23rd August 2021

Fixed bug where custom tests left an empty DbcResult #846
Added feature to overwrite config file if it already exists for Export-DbcConfig #844
Enabled ping latency testing in PowerShell Core

##Latest
## 23rd August 2021

Removed the Verbose for the Pester load - Apologies, this was Rob!
Thank you [@MikeyBronowski](https://www.github.com/MikeyBronowski) Get the file at the end so Export-DbcConfig can be used with Invoke-Item addresses #843 #845
Thank you [@MikeyBronowski](https://www.github.com/MikeyBronowski) spelling and full stops #842
Thank you [ashdar](https://github.com/ashdar) Check for existence in the Tag list before adding a Tag to the Tag list #853
Thank you [ashdar](https://github.com/ashdar) Updated PowerPlan Assertion #850
Thank you [tboggiano](https://github.com/tboggiano) CIS check for SQL Mail XPS for SQL Server 2008 and below (was) #779
Thank you [tboggiano](https://github.com/tboggiano) Added function to set CIS config (was) #776
Thank you [tboggiano](https://github.com/tboggiano) CIS check for TCP IP Protocols (was) #775

## April 7th 2021

Thank you [@mikedavem](https://www.github.com/mikedavem) Fixed rogue verbose when importing [#834](https://github.com/sqlcollaborative/dbachecks/issues/834)

Thank you [@mikedavem](https://www.github.com/mikedavem) Test NetBios Over TCP/IP should be disabled for cluster network interface [#833](https://github.com/sqlcollaborative/dbachecks/issues/833)

Thank you [@conseilit](https://www.github.com/conseilit) Add LogfilePercentUsed check. Log might fill even if simple recovery model or full recovery model + Tlog backup in case of replication, CDC, HADR issues. [#831](https://github.com/sqlcollaborative/dbachecks/issues/831) [#832](https://github.com/sqlcollaborative/dbachecks/issues/832)

Thank you [@conseilit](https://www.github.com/conseilit) Getting SQL Server instance DateTime prevent Log Backup checks to fail if the instance is not in the same timezone than the computer running dbaChecks scripts. [#830](https://github.com/sqlcollaborative/dbachecks/issues/830)

Thank you [@MikeyBronowski](https://www.github.com/MikeyBronowski) Get-DbcConfig Adding support to multiple names [#829](https://github.com/sqlcollaborative/dbachecks/issues/829)

Thank you [@MikeyBronowski](https://www.github.com/MikeyBronowski) Spellings [#827](https://github.com/sqlcollaborative/dbachecks/issues/827)

Thank you [@TheAntGreen](https://www.github.com/TheAntGreen) updated variables to make errors obvious [#825](https://github.com/sqlcollaborative/dbachecks/issues/825)

Thank you [@MrBlueSky](https://www.github.com/MrBlueSky) - add info to suggest using Duplicate index command [#807](https://github.com/sqlcollaborative/dbachecks/issues/807)

Thank you [@PsPsam](https://www.github.com/PsPsam) - Ping check to work on core and 5.1 [#763](https://github.com/sqlcollaborative/dbachecks/issues/763)

Thank you [@zikato](https://www.github.com/zikato) - certificate expiration gives two failures if in the past [#785](https://github.com/sqlcollaborative/dbachecks/issues/785)

Thank you [@mikedavem](https://www.github.com/mikedavem) - allow more than 99 days for retention for Olas jobs [#835](https://github.com/sqlcollaborative/dbachecks/issues/835)

Thank you [@Shashtsoh](https://www.github.com/Shashtsoh) - Remove aliases to work in core [#837](https://github.com/sqlcollaborative/dbachecks/issues/837)

Thank you [@a4ic6n](https://www.github.com/a4ic6n) - Max Memory check false succeeds [#836](https://github.com/sqlcollaborative/dbachecks/issues/836)


## December 14th 2020

Thank you tboggiano Browser check altered for instance count #758
Thank you zikato - Fixing datafile auto growth #786
Thank you fatherjack Typos #767
Thank you tboggiano Query Store enabled and disabled test improvements #791
Thank you relsna fixed issue with error log window #814
Thank you @TheAntGreen Typos #815
Thank you @TheAntGreen Add additional filter to filter out negative run_durations #816
Thank you @TheAntGreen Add policy for additional excluded dbs from the SAFE CLR check #817
Thank you @MikeyBronowski Fix the check for enabled alerts #819
Thank you @MikeyBronowski Updating the link in documentation #820
Thank you @mikedavem Updated HADR checks with additional checks #822
Thank you @mikedavem Database backup diff check - fix issue #812 #824

## Date November 23rd 2020

Finally Rob gets around to working on PRs - Really sorry it has taken so long

Fixes for bug 780 & 783 #784 - Thank you @TheAntGreen
Fix local windows groups, additional filter needed on the object filter #789 - Thank you @TheAntGreen
$null check for anything running SQL2008R2 or below as containment doesnt exist in those versions. #790 - Thank you @TheAntGreen

Fix for IsClustered checks for service startup types #792  - Thank you @TheAntGreen

CertCheck took ages to run, was still checking excluded DB's then filtering, change to not query the excluded DBs #793  - Thank you @TheAntGreen

Fixed few typos in docs #799 - Thank you @jpomfret

Fixed few typos in docs #799 - Thank you @TheAntGreen

DuplicateIndex Check - Added new configuration option to allow people to filter out databases, as SSRS DB's have duplicate indexes and names are configuration in older versions, defaults to ReportServer & ReportServerTempDB

GuestUserConnect - Changes method to Get-Database instead of InstanceSMO so its easier to filter out none accessable databases as the check would report false positives for offline or restoring databases

NotExpectedTraceFlag - added a filter to filter out any trace flags which WHERE expected to prevent false positive alerts #801 - Thank you @TheAntGreen

Add policy to exclude databases on the trustworthy check #806  - Thank you @TheAntGreen

Unused Index Check wasn't executing correctly #808   - Thank you @TheAntGreen

#803 Addition of the date filter for File Autogrowth detection #809   - Thank you @TheAntGreen

New Check - Agent Mail Profile #811   - Thank you @TheAntGreen

Scan for startup procs, use config option to override the value in use #813  - Thank you @TheAntGreen

##Latest

## Date September 22nd 2020

Only Importing Pester v4 and lower to reduce Pester v5 errors

## Date July 13th 2020

Thank you jpomfret Added skip.backup.readonly config  #777
Thank you jpomfret typos  #771
Thank you jpomfret Added MSDB suspect pages table check  #768
Thank you markaugust Added instance name to Agent Service ACcount checks #766
Thank you tboggiano fixed Agent Run time calculation #746

## Date 9th May 2020

UPDATED TO VERSION 2

New Commands

    Convert-DbcResult - To parse results and add Label, ComputerName, Instance and Database
    Set-DbcFile - To save the parsed results to a file json, csv or xml
    Write-DbcTable - to add results to a database

New Parameter
    -FromDatabase on Star-DbcPowerBi - to open new Power Bi template file

New PowerBi template file for reporting on results from the database

Improved Spelling

Updated Unit Tests for Checks to enabled results to be parsed

Improved Check Titles

Configuration for Max history days for Job duration

Stop trying to check inaccessible databases for checks

Improved Query Store checks

Ensure long running agent jobs ignores durations longer than 24 hours

Ignore jobs that never stop from the duration check

##Latest

## Date 29th March 2020

UPDATED MINIMUM POWERSHELL VERSION

Updated Required versions of Pester, dbatools and PSFramework modules

Thank you @dstrait
    Fix variable for SaDisabled check #750
    Fix errant braces in SQL Browser Service Check #751
    Fix PingComputer Check #752

Thank you markaugust
    Fix to ensure AG Name is in HADR checks #755

Thank you Tracey Boggiano
    Added Contained Database auth check and Query Store Enabled Checks #756

Thank you Rob
    Added exclude database config for Query store checks
    Version check for Query Store Checks
    Some spellings!

##Latest

## Date 18th March 2020
Thank you Tracey tboggiano
    New CIS user-defined CLRs to be set to SAFE_ACCESS #734
    CIS tests for if service accounts are local admins #736

Thank you Rob
    Getting service accounts tests to pass if no service
    Made long running jobs check work as expected
    Improved Database Mail check
    Made sure disk allocations dont run on Core

Thank you mikedavem
    Fixed bug in disk allocation check exclusions
    Added multiple ags to the HADR check #742

## Date 14th March 2020
Thank you Tracey tboggiano
    New CIS Check Hide Instance #728
    New CIS Check Symmetric Key #732
    New CIS Check Agent Proxy not have access to public Role #732

## Date 8th January 2020
Thank you Tracey tboggiano
    New CIS Check Guest Account connect permissions #725
    New CIS Check BuiltIn Admins login #726
    New CIS Check public role permissions #729
    New CIS Check local windows groups do not have logins #731
    Update sa login check #730

Thank you Rob
    Added Tag parameter to Get-DbcCheck
    Updated tests to work with PowerShell 7

## Date 22nd December
Thank you Tracey tboggiano
    Two New CIS Checks Contained databases should be auto-closed #721
    sa login disabled and should not exist #719

Thank you Rob
    Fix bug in Agent Tests #723

## Date 28th November
Thank you Tracey tboggiano
    Added new CIS Check for the latest SQL build #716

Thank you Rob
    Making the SQL Engine Service Check configurable #706

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
Updated Set-DbcConfig to allow Append to append arrays to arrays closes #535
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
Fixed #504 by enabling FileName parameter on Update-PowerBiDataSource
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

