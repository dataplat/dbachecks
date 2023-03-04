<#
.SYNOPSIS
Takes the results of Invoke-DbcCheck, parses it and converts it to a datatable object

.DESCRIPTION
You need to run Invoke-DbcCheck with the PassThru parameter and this command will take the
results and parse them creating a datatable object with column headings
Date Label Describe Context Name Database ComputerName Instance Result FailureMessage
so that it can be written to a database with Write-DbcTable (or Write-DbaDataTable) or to
a file with Set-DbcFile

.PARAMETER TestResults
The output of Invoke-DbcCheck (WITH -PassThru)

.PARAMETER Label
An optional label to add to the set of results to identify them - Think Morning-Checks or New-instance

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Write-DbcTable -SqlInstance sql2017n5 -Database tempdb -Table newdbachecks

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and writes it to a table newdbachecks in tempdb on SQL2017N5 (NB Don't use tempdb!!)

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.json -FileType Json

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to JSON and saves in C:\temp\dbachecks\Auto-close.json

.NOTES
Initial - RMS 28/12/2019
#>
function Convert-DbcResult {
    [OutputType([System.Data.DataTable])]
    Param(
        # The pester results object
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias('TestsResults')]
        [PSCustomObject]$Results,
        [Parameter(Mandatory = $false)]
        # the label for the Tests
        [string]$Label = 'NoLabel'
    )

    begin {
        Write-PSFMessage "Creating a datatable" -Level Verbose

        # Create DataTable Object
        $table = New-Object system.Data.DataTable Results

        # Create Columns
        $col1 = New-Object system.Data.DataColumn Date, ([datetime])
        $col2 = New-Object system.Data.DataColumn Label, ([string])
        $col3 = New-Object system.Data.DataColumn Describe, ([string])
        $col4 = New-Object system.Data.DataColumn Context, ([string])
        $col5 = New-Object system.Data.DataColumn Name, ([string])
        $col6 = New-Object system.Data.DataColumn Database, ([string])
        $col7 = New-Object system.Data.DataColumn ComputerName, ([string])
        $col8 = New-Object system.Data.DataColumn Instance, ([string])
        $col9 = New-Object system.Data.DataColumn Result, ([string])
        $col10 = New-Object system.Data.DataColumn FailureMessage, ([string])

        #Add the Columns to the table
        $table.columns.add($col1)
        $table.columns.add($col2)
        $table.columns.add($col3)
        $table.columns.add($col4)
        $table.columns.add($col5)
        $table.columns.add($col6)
        $table.columns.add($col7)
        $table.columns.add($col8)
        $table.columns.add($col9)
        $table.columns.add($col10)


    }
    process {
        Write-PSFMessage "Testing we have a Test Results object" -Level Verbose
        if ( $Results.TestResult) {
            Write-PSFMessage "Processing the v4 test results" -Level Verbose
            $Results.TestResult.ForEach{
                $ContextSplit = ($PSitem.Context -split ' ')
                $ComputerName = ($ContextSplit[-1] -split '\\')[0]
                $NameSplit = ($PSitem.Name -split ' ')
                if ($PSitem.Name -match '^Database\s(.*?)\s') {
                    $Database = $Matches[1]
                } else {
                    $Database = $null
                }
                $Date = Get-Date
                if ($Label) {

                } else {
                    $Label = 'NoLabel'
                }
                # Create a new Row
                $row = $table.NewRow()
                # Add values to new row
                $Row.Date = [datetime]$Date
                $Row.Label = $Label
                $Row.Describe = $PSitem.Describe
                $Row.Context = $ContextSplit[0..($ContextSplit.Count - 3)] -join ' '
                $Row.Name = $NameSplit[0..($NameSplit.Count - 3)] -join ' '
                $Row.Database = $Database
                $Row.ComputerName = $ComputerName
                $Row.Instance = $ContextSplit[-1]
                $Row.Result = $PSitem.Result
                $Row.FailureMessage = $PSitem.FailureMessage
                #Add new row to table
                $table.Rows.Add($row)
            }
        } else {
            Write-PSFMessage "Processing the v5 test results" -Level Verbose
            $Results.Tests.Where{ $Psitem.Result -ne 'NotRun' }.ForEach{
                $TestResult = $Psitem
                switch ($TestResult.Result) {
                    'skipped' { 
                        $PathSplit = $TestResult.ExpandedPath.split('.')
                        $Describe = $PathSplit[0]
                        $Context = $PathSplit[1]
                        $ContextSplit = ($Context -split ' ')
                        $Instance = $ContextSplit[-1]
                        $CheckName = $TestResult.ExpandedName -replace '<_.Name>', 'CheckSkipped' -replace '<_.SqlInstance>', $Instance
                        if ($TestResult.ExpandedName -match '<_\.Name>') {
                            $Database = 'CheckSkipped'
                        } else {
                            $Database = $null
                        }
                    }
                    Default {
                        $PathSplit = $TestResult.ExpandedPath.split('.')
                        $Describe = $PathSplit[0]
                        $Context = $PathSplit[1]
                        $ContextSplit = ($Context -split ' ')
                        $Instance = $ContextSplit[-1]
                        $CheckName = $TestResult.ExpandedName
                        if ($TestResult.ExpandedName -match '^Database\s(.*?)\s') {
                            $Database = $Matches[1]
                        } else {
                            $Database = $null
                        }
                    }
                }
                $ComputerName = ($ContextSplit[-1] -split '\\')[0]


                $Date = Get-Date

                # Create a new Row
                $row = $table.NewRow()
                # Add values to new row
                $Row.Date = [datetime]$Date
                $Row.Label = $Label
                $Row.Describe = $Describe
                $Row.Context = $Context
                $Row.Name = $CheckName
                $Row.Database = $Database
                $Row.ComputerName = $ComputerName
                $Row.Instance = $Instance
                $Row.Result = $PSitem.Result
                $Row.FailureMessage = $PSitem.FailureMessage
                #Add new row to table
                $table.Rows.Add($row)
            }
        }
    }
    end {
        Write-Output -NoEnumerate -InputObject $table
    }
}
