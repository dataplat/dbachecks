function Convert-DbcResult {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Data.DataTable])]
    Param(
        # The pester results object
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$TestResults,
        [Parameter(Mandatory = $false)]
        # the label for the Tests
        [string]$Label
    )
    Write-PSFMessage "Testing we have a Test Results object" -Level Verbose
    if (-not $TestResults) {
        Write-PSFMessage "Uh-Oh - I'm really sorry - We don't have a Test Results Object" -Level Significant
        Write-PSFMessage "Did You forget the -PassThru parameter on Invoke-DbcCheck?" -Level Warning
        Return '' 
    }
    # Create DataTable Object
    $table = New-Object system.Data.DataTable Results
    
    # Create Columns
    $col1 = New-Object system.Data.DataColumn Date, ([datetime])
    $col2 = New-Object system.Data.DataColumn Label, ([string])
    $col3 = New-Object system.Data.DataColumn Describe, ([string])
    $col4 = New-Object system.Data.DataColumn Context, ([string])
    $col5 = New-Object system.Data.DataColumn Name, ([string])
    $col6 = New-Object system.Data.DataColumn Database, ([string])
    $col7 = New-Object system.Data.DataColumn Instance, ([string])
    $col8 = New-Object system.Data.DataColumn Result, ([string])
    $col9 = New-Object system.Data.DataColumn FailureMessage, ([string])


    
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
    
    Write-PSFMessage "Processing the test results" -Level Verbose
    $TestResults.TestResult.ForEach{
        $ContextSplit = ($PSitem.Context -split ' ')
        $NameSplit = ($PSitem.Name -split ' ')
        if ($PSitem.Name -match '^Database\s(.*?)\s') {
            $Database = $Matches[1]
        }
        else {
            $Database = $null
        }
        $Date = Get-Date # -Format "yyyy-MM-dd"
        if ($Label) {
    
        }
        else {
            $Label = 'NoLabel'
        }
        # Create a new Row
        $row = $table.NewRow() 
        # Add values to new row
        $Row.Date = $Date
        $Row.Label = $Label
        $Row.Describe = $PSitem.Describe
        $Row.Context = $ContextSplit[0..($ContextSplit.Count - 3)] -join ' '
        $Row.Name = $NameSplit[0..($NameSplit.Count - 3)] -join ' '
        $Row.Database = $Database
        $Row.Instance = $ContextSplit[-1]
        $Row.Result = $PSitem.Result
        $Row.FailureMessage = $PSitem.FailureMessage
        #Add new row to table
        $table.Rows.Add($row)
        
    }
    Write-Output -NoEnumerate $table
}

