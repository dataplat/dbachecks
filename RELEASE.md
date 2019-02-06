## Date 05/02/2019
Thank you Chrissy! @cl
added default environment #596
altered configuration validation for mail to stop errors
Ensured database status check doesnt fail as readonly for snapshots

##Latest

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

