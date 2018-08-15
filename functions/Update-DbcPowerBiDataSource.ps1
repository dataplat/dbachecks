function Update-DbcPowerBiDataSource {
    <#
        .SYNOPSIS
            Converts Pester results and exports file in required format for launching the Power BI command. **You will need refresh* the Power BI dashboard every time to see the new results.

        .DESCRIPTION
            Converts Pester results and exports file in required format for launching the Power BI command. **You will need refresh* the Power BI dashboard every time to see the new results.

            Basically does this:
                $InputObject.TestResult | Select-Object -First 20 | ConvertTo-Json -Depth 3 | Out-File "$env:windir\temp\dbachecks.json"

        .PARAMETER InputObject
            Required. Resultset from Invoke-DbcCheck. If InputObject is not provided, it will be generated using a very generic resultset:

            Invoke-DbcCheck -Show Summary -PassThru

        .PARAMETER Path
            The directory to store your JSON files. "C:\windows\temp\dbachecks\*.json" by default

        .PARAMETER FileName
            Name your Json File
    
        .PARAMETER Force
            Delete all json files in the data source folder.
    
        .PARAMETER EnableException
            By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
            This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
            Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

        .EXAMPLE
            Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource 

            Runs the DatabaseStatus checks against $Instance then saves to json to $env:windir\temp\dbachecks\dbachecks_1_DatabaseStatus.json

        .EXAMPLE
            Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Path C:\Temp

            Runs the DatabaseStatus checks against $Instance then saves to json to C:\Temp\dbachecks_1_DatabaseStatus.json

        .EXAMPLE
            Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Path C:\Temp  -FileName BeardyTests

            Runs the DatabaseStatus checks against $Instance then saves to json to C:\Temp\BeardyTests.json

        .EXAMPLE
            Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Path C:\Temp  -FileName BeardyTests.json

            Runs the DatabaseStatus checks against $Instance then saves to json to C:\Temp\BeardyTests.json

        .EXAMPLE
            Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Path C:\Temp  -Environment Prod_DBChecks

            Runs the DatabaseStatus checks against $Instance then saves to json to  C:\Temp\dbachecks_1_Prod_DBChecks_DatabaseStatus.json

        .EXAMPLE
            Invoke-DbcCheck -SqlInstance $Instance -Check DatabaseStatus -Show None -PassThru | Update-DbcPowerBiDataSource -Environment Prod_DBChecks

            Runs the DatabaseStatus checks against $Instance then saves to json to  C:\Windows\temp\dbachecks\dbachecks_1_Prod_DBChecks_DatabaseStatus.json

        .EXAMPLE
            Invoke-DbcCheck -SqlInstance sql2017 -Tag Backup -Show Summary -PassThru | Update-DbcPowerBiDataSource -Path \\nas\projects\dbachecks.json
            Start-DbcPowerBi -Path \\nas\projects\dbachecks.json

            Runs tests, saves to json to \\nas\projects\dbachecks.json but then you'll have to change your data source in Power BI because by default it points to C:\Windows\Temp (limitation of Power BI)
    #>
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        [pscustomobject]$InputObject,
        [string]$Path = "$env:windir\temp\dbachecks",
        [string]$FileName,
        [string]$Environment,
        [switch]$Force,
        [switch]$EnableException
    )
    begin {
        if ($FileName -ne "Default") {
            $null = Remove-Item "$Path\*Default*.json" -ErrorAction SilentlyContinue
        }
        if ($Force) {
            $null = Remove-Item "$Path\*.json" -ErrorAction SilentlyContinue
        }
    }
    process {
        ++$i
        try {
            if (-not (Test-Path -Path $Path)) {
                $null = New-Item -ItemType Directory -Path $Path -ErrorAction Stop
            }
        }
        catch {
            Stop-PSFFunction -Message "Failure" -ErrorRecord $_
            return
        }
        $basename = "dbachecks_$i"
        if($Environment){
            $basename = "dbachecks_$i" + "_$Environment"
        }
        if ($FileName) {
            $basename = $FileName
            if($basename.EndsWith('.json')){}
            else{
                $basename = $basename + ".json"
            }
        }
        else {
            if ($InputObject.TagFilter) {
                $basename = "$basename`_$($InputObject.TagFilter -join "_")" + ".json"
            }
        }  

        $FilePath = "$Path\$basename"

        if ($InputObject.TotalCount -gt 0) {
            try {
                $InputObject.TestResult | ConvertTo-Json -Depth 3 | Out-File -FilePath $FilePath
                Write-PSFMessage -Level Output -Message "Wrote results to $FilePath"
            }
            catch {
                Stop-PSFFunction -Message "Failure" -ErrorRecord $_
                return
            }
        }
    }
    end {
        if ($InputObject.TotalCount -isnot [int]) {
            Stop-PSFFunction -Message "Invalid TestResult. Did you forget to use -Passthru with Invoke-DbcCheck?"
            return
        }
    }
}