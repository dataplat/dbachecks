Get-Help TestDbaDatabaseCollation -ShowWindow

## Test a server

Test-DbaDatabaseCollation -SqlServer ''

## Only show teh mis matching databases

(Test-DbaDatabaseCollation -SqlServer '').Where{$_.IsEqual -eq $false}

## Detailed info

Test-DbaDatabaseCollation -SqlServer '' -Detailed

## Do thigns with results
## Output to a file
Test-DbaDatabaseCollation -SqlServer '' -Detailed |Out-File C:\Temp\CollationCheck.txt
## Output to CSV
Test-DbaDatabaseCollation -SqlServer '' -Detailed |Export-Csv  C:\temp\CollationCheck.csv -NoTypeInformation
## Output to JSON
Test-DbaDatabaseCollation -SqlServer '' -Detailed | ConvertTo-Json | Out-file c:\temp\CollationCheck.json
## Look at the files
notepad C:\temp\CollationCheck.json
notepad C:\temp\CollationCheck.csv
notepad C:\temp\CollationCheck.txt

## Linux or SQL Auth

$cred = Get-Credential
Test-DbaDatabaseCollation -SqlServer LinuxvServer -Credential $cred -Detailed | Format-Table -AutoSize