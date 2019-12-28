function Set-DbcFile {
    [CmdletBinding(SupportsShouldProcess, DefaultParametersetName = "Default")]
    Param(
        # The pester results object
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Append')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Force')]
        $InputObject,
        [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Force')]
        # The Directory for the file
        [string]$FilePath,
        [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Force')]
        # The name for the file
        [string]$FileName,
        # the type of file
        [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Force')]
        [ValidateSet('Csv', 'Json', 'Xml')]
        [string]$FileType,
        # Appending
        [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
        [switch]$Append,
        # Overwrite file
        [Parameter(Mandatory = $true, ParameterSetName = 'Force')]
        [switch]$Force
    ) 

    Write-PSFMessage "Testing we have a Test Results object" -Level Verbose
    if(-not $InputObject){
        Write-PSFMessage "Uh-Oh - I'm really sorry - We don't have a Test Results Object" -Level Significant
        Write-PSFMessage "Did You forget the -PassThru parameter on Invoke-DbcCheck?" -Level Warning
        Return '' 
    }
    Write-PSFMessage "Testing we can access $FilePath" -Level Verbose
    If (Test-Path -Path $FilePath) {

    }
    else {
        Write-PSFMessage "Uh-Oh - We cant access $FilePath - Please check that $Env:USERNAME has access" -Level Significant
        Return '' 
    }
    $File = "$FilePath\$FileName"
    Write-PSFMessage "Testing if $file exists" -Level Verbose
    if (Test-Path -Path $file) {
        if (!$Force -and !$Append) {
            Write-PSFMessage "Uh-Oh - File $File exists - use the Force parameter to overwrite (even if your name is not Luke!)" -Level Significant
            Return ''
        }
        else {
            if (-not $Append) {
                Write-PSFMessage "File $File exists and will be overwritten " -Level Verbose
            }
        }
        if ($Append) {
            if ($FileType -eq 'XML') {
                Write-PSFMessage "I'm not coding appending to XML - Sorry - The Beard loves you but not that much" -Level Significant
                Return ''
            }
            else {
                Write-PSFMessage "File $File exists and will be appended to " -Level Verbose
            }
        }
    }

    try {
        switch ($FileType) {
            'CSV' { 
                if(-not ($FileName.ToLower().EndsWith('.csv'))){
                    $FileName = $FileName + '.csv'
                }
                if ($PSCmdlet.ShouldProcess("$FilePath" , "Creating a CSV named $FileName in ")) {
                    $InputObject  | Select-Object * -ExcludeProperty ItemArray, Table, RowError, RowState, HasErrors | Export-Csv -Path $File -NoTypeInformation -Append:$Append 
                }
                
            }
            'Json' {
                if(-not ($FileName.ToLower().EndsWith('.json'))){
                    $FileName = $FileName + '.json'
                }
                if ($PSCmdlet.ShouldProcess("$FilePath" , "Creating a Json file named $FileName in ")) {
                    $Date = @{Name = 'Date'; Expression = {($_.Date).Tostring('MM/dd/yy HH:mm:ss')}}
                    $InputObject  | Select-Object $Date, Label,Describe,Context,Name,Database,ComputerName,Instance,Result,FailureMessage | ConvertTo-Json | Out-File -FilePath $File -Append:$Append
                }
            }
            'Xml' {
                if(-not ($FileName.ToLower().EndsWith('.xml'))){
                    $FileName = $FileName + '.xml'
                }
                if ($PSCmdlet.ShouldProcess("$FilePath" , "Creating a XML named $FileName in ")) {
                    $InputObject  | Select-Object * -ExcludeProperty ItemArray, Table, RowError, RowState, HasErrors | Export-Clixml -Path $File -Force:$force
                }
            }
        }
        Write-PSFMessage "Exported results to $file" -Level Output
    }
    catch {
        Write-PSFMessage "Uh-Oh - We failed to create the file $file :-("
    }
}