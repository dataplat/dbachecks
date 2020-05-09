$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Remove-Module dbachecks -ErrorAction SilentlyContinue
# Import-Module "$PSScriptRoot\..\..\dbachecks.psd1"
. "$PSScriptRoot\..\..\functions\Set-DbcFile.ps1"
. "$PSScriptRoot\..\..\functions\Convert-DbcResult.ps1"
. "$PSScriptRoot\..\constants.ps1"


Describe "$commandname Unit Tests" -Tags UnitTest {
    Context "Parameters and parameter sets" {
        $ParametersList =  'InputObject','FilePath', 'FileName', 'FileType', 'Append', 'Force'

        $ParametersList.ForEach{
            It "$commandname Should have a mandatory parameter $psitem" {
                (Get-Command $commandname ).Parameters[$psitem].Attributes.Mandatory | Should -BeTrue -Because "These parameters need to be mandatory because of the Parameter Sets"
            }
            It "$commandname Should have a parameter $psitem" {
                (Get-Command $commandname ).Parameters[$psitem].Count | Should -Be 1 -Because "This parameter should exist"
            }
        }
        $ParameterSets = 'Default', 'Append', 'Force'
        $ParameterSets.ForEach{
            It "$commandname should have a parameter set named $psitem" {
                (Get-Command Set-DbcFile).ParameterSets.Name | Should -Contain $psitem -Because "We need these parameter sets so users cannot run with force and append"
            }
        }
    }
}

Describe "$commandname Unit Tests - Execution" -Tags UnitTest {
    Context "Execution" {
        # So that we dont get any output in the tests but can test for It
        Mock Write-PSFMessage { } -ParameterFilter { $Level -and $Level -eq 'Significant' }
        Mock Write-PSFMessage { } -ParameterFilter { $Level -and $Level -eq 'Verbose' }
        Mock Write-PSFMessage { } -ParameterFilter { $Level -and $Level -eq 'Output' }
        Mock Write-PSFMessage { } -ParameterFilter { $Level -and $Level -eq 'Warning' }
        # So that we dont create files
        Mock Export-Csv { }
        Mock ConvertTo-Json {'dummy'}
        Mock Out-File { }
        Mock Export-Clixml { }

        $TheTestResults = Get-Content $PSScriptRoot\results.json -raw | ConvertFrom-Json
        It "Should produce an error message if test results are not passed via pipeline and stop" {
            # mock for test-path to fail
            Mock Test-Path {}
            $Nothing | Set-DbcFile -FilePath DummyDirectory -FileName DummyFileName -FileType CSV  -ErrorAction SilentlyContinue

            #Check that Test-Path mock was not called
            $assertMockParams = @{
                'CommandName'     = 'Test-Path'
                'Times'           = 0
                'Exactly'         = $true
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we check for directory - we should not have - Because we need to know that the Mocks are working"

            #Check that correct Write-PsfMessage mock was called
            $assertMockParams = @{
                'CommandName'     = 'Write-PsfMessage'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Level -and $Level -eq 'Significant' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we provide Significant output - Because we need to know that the Mocks are working"
            #Check that correct Write-PsfMessage mock was called
            $assertMockParams = @{
                'CommandName'     = 'Write-PsfMessage'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Level -and $Level -eq 'Verbose' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we provide Verbose output - Because we need to know that the Mocks are working"

            #Check that correct Write-PsfMessage mock was called
            $assertMockParams = @{
                'CommandName'     = 'Write-PsfMessage'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Level -and $Level -eq 'Warning' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we provide Warning output - Because we need to know that the Mocks are working"
        }
        It "Should produce an error message if the path does not exist or we cannot access it" {
            # mock for test-path to fail
            Mock Test-Path { $false } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory' }
            Mock Test-Path { $false } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory\DummyFileName' }

            Set-DbcFile -InputObject $TheTestResults -FilePath DummyDirectory -FileName DummyFileName -FileType CSV  -verbose

            #Check that Test-Path mock was called
            $assertMockParams = @{
                'CommandName'     = 'Test-Path'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Path -and $Path -eq 'DummyDirectory' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we check for directory - Because we need to know that the Mocks are working"

            #Check that Test-Path mock was not called
            $assertMockParams = @{
                'CommandName'     = 'Test-Path'
                'Times'           = 0
                'Exactly'         = $true
                'ParameterFilter' = { $Path -and $Path -eq 'DummyDirectory\DummyFileName' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we check for file - Because we need to know that the Mocks are working"

            #Check that correct Write-PsfMessage mock was called
            $assertMockParams = @{
                'CommandName'     = 'Write-PsfMessage'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Level -and $Level -eq 'Significant' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we provide Significant output - Because we need to know that the Mocks are working"
            #Check that correct Write-PsfMessage mock was called
            $assertMockParams = @{
                'CommandName'     = 'Write-PsfMessage'
                'Times'           = 2
                'Exactly'         = $true
                'ParameterFilter' = { $Level -and $Level -eq 'Verbose' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we provide Verbose output - Because we need to know that the Mocks are working"
        }
        It "Should produce a message if the file exists and Force and Append were not specified" {
            # mock for test-path to fail
            Mock Test-Path { $true } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory' }
            Mock Test-Path { $true } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory\DummyFileName' }

            Set-DbcFile -InputObject $TheTestResults -FilePath DummyDirectory -FileName DummyFileName -FileType CSV -Verbose

            #Check that Test-Path mock was called
            $assertMockParams = @{
                'CommandName'     = 'Test-Path'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Path -and $Path -eq 'DummyDirectory' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we check for directory - Because we need to know that the Mocks are working"

            #Check that Test-Path mock was not called
            $assertMockParams = @{
                'CommandName'     = 'Test-Path'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Path -and $Path -eq 'DummyDirectory\DummyFileName' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we check for file - Because we need to know that the Mocks are working"
            #Check that correct Write-PsfMessage mock was called
            $assertMockParams = @{
                'CommandName'     = 'Write-PsfMessage'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Level -and $Level -eq 'Significant' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we provide Significant output - Because we need to know that the Mocks are working"
            #Check that correct Write-PsfMessage mock was called
            $assertMockParams = @{
                'CommandName'     = 'Write-PsfMessage'
                'Times'           = 3
                'Exactly'         = $true
                'ParameterFilter' = { $Level -and $Level -eq 'Verbose' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we provide Verbose output - Because we need to know that the Mocks are working"
        }
        It "Should produce a verbose message if the file exists and Force was specified" {
            # mock for test-path to fail
            Mock Test-Path { $true } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory' }
            Mock Test-Path { $true } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory\DummyFileName' }

            Set-DbcFile -InputObject $TheTestResults -FilePath DummyDirectory -FileName DummyFileName -Force -FileType CSV

            #Check that Test-Path mock was called
            $assertMockParams = @{
                'CommandName'     = 'Test-Path'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Path -and $Path -eq 'DummyDirectory' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we check for directory - Because we need to know that the Mocks are working"

            #Check that Test-Path mock was not called
            $assertMockParams = @{
                'CommandName'     = 'Test-Path'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Path -and $Path -eq 'DummyDirectory\DummyFileName' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we check for file - Because we need to know that the Mocks are working"
            #Check that correct Write-PsfMessage mock was called
            $assertMockParams = @{
                'CommandName'     = 'Write-PsfMessage'
                'Times'           = 5
                'Exactly'         = $true
                'ParameterFilter' = { $Level -and $Level -eq 'Verbose' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we provide Verbose output - Because we need to know that the Mocks are working"
            #Check that correct Write-PsfMessage mock was called
            $assertMockParams = @{
                'CommandName'     = 'Write-PsfMessage'
                'Times'           = 0
                'Exactly'         = $true
                'ParameterFilter' = { $Level -and $Level -eq 'Significant' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we provide Significant output - Because we need to know that the Mocks are working"
        }

        It "Should produce a verbose message if the file exists and Append was specified and the filetype is not XML" {
            # mock for test-path to fail
            Mock Test-Path { $true } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory' }
            Mock Test-Path { $true } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory\DummyFileName' }

            Set-DbcFile -InputObject $TheTestResults -FilePath DummyDirectory -FileName DummyFileName -FileType CSV -Verbose

            #Check that Test-Path mock was called
            $assertMockParams = @{
                'CommandName'     = 'Test-Path'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Path -and $Path -eq 'DummyDirectory' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we check for directory - Because we need to know that the Mocks are working"

            #Check that Test-Path mock was not called
            $assertMockParams = @{
                'CommandName'     = 'Test-Path'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Path -and $Path -eq 'DummyDirectory\DummyFileName' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we check for file - Because we need to know that the Mocks are working"
            #Check that correct Write-PsfMessage mock was called
            $assertMockParams = @{
                'CommandName'     = 'Write-PsfMessage'
                'Times'           = 3
                'Exactly'         = $true
                'ParameterFilter' = { $Level -and $Level -eq 'Verbose' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we provide Verbose output - Because we need to know that the Mocks are working"
            #Check that correct Write-PsfMessage mock was called
            $assertMockParams = @{
                'CommandName'     = 'Write-PsfMessage'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Level -and $Level -eq 'Significant' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we provide Significant output - Because we need to know that the Mocks are working"
        }

        It "Should produce a significant message if the file exists and Append was specified and the filetype is XML" {
            # mock for test-path to suceed
            Mock Test-Path { $true } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory' }
            Mock Test-Path { $true } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory\DummyFileName' }

            Set-DbcFile -InputObject $TheTestResults -FilePath DummyDirectory -FileName DummyFileName -FileType XML

            #Check that Test-Path mock was called
            $assertMockParams = @{
                'CommandName'     = 'Test-Path'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Path -and $Path -eq 'DummyDirectory' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we check for directory - Because we need to know that the Mocks are working"

            #Check that Test-Path mock was not called
            $assertMockParams = @{
                'CommandName'     = 'Test-Path'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Path -and $Path -eq 'DummyDirectory\DummyFileName' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we check for file - Because we need to know that the Mocks are working"
            #Check that correct Write-PsfMessage mock was called
            $assertMockParams = @{
                'CommandName'     = 'Write-PsfMessage'
                'Times'           = 3
                'Exactly'         = $true
                'ParameterFilter' = { $Level -and $Level -eq 'Verbose' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we provide Verbose output - Because we need to know that the Mocks are working"

            #Check that correct Write-PsfMessage mock was called
            $assertMockParams = @{
                'CommandName'     = 'Write-PsfMessage'
                'Times'           = 1
                'Exactly'         = $true
                'ParameterFilter' = { $Level -and $Level -eq 'Significant' }
                'Scope'           = 'It'
            }
            { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we provide Signicificant output - Because we need to know that the Mocks are working"
        }

        It "Should export to csv when called with filetype csv"{
    # mock for test-path to suceed
    Mock Test-Path { $true } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory' }
    Mock Test-Path { $false } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory\DummyFileName' }
    Set-DbcFile -InputObject $TheTestResults -FilePath DummyDirectory -FileName DummyFileName -FileType CSV
      #Check that correct Export-Csv mock was called
      $assertMockParams = @{
        'CommandName'     = 'Export-Csv'
        'Times'           = 1
        'Exactly'         = $true
        'Scope'           = 'It'
    }
    { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we output a csv - Because we need to know that the Mocks are working"
        }
        It "Should export to json when called with filetype json"{
    # mock for test-path to suceed
    Mock Test-Path { $true } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory' }
    Mock Test-Path { $false } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory\DummyFileName' }
    Set-DbcFile -InputObject $TheTestResults -FilePath DummyDirectory -FileName DummyFileName -FileType json
      #Check that ConvertTo-Json mock was called
      $assertMockParams = @{
        'CommandName'     = 'ConvertTo-Json'
        'Times'           = 1
        'Exactly'         = $true
        'Scope'           = 'It'
    }
    { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we output a json - Because we need to know that the Mocks are working"
      #Check that correct Out-File mock was called
      $assertMockParams = @{
        'CommandName'     = 'Out-File'
        'Times'           = 1
        'Exactly'         = $true
        'Scope'           = 'It'
    }
    { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we output a json - Because we need to know that the Mocks are working"
        }
        It "Should export to XML when called with filetype xml"{
    # mock for test-path to suceed
    Mock Test-Path { $true } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory' }
    Mock Test-Path { $false } -ParameterFilter { $Path -and $Path -eq 'DummyDirectory\DummyFileName' }
    Set-DbcFile -InputObject $TheTestResults -FilePath DummyDirectory -FileName DummyFileName -FileType xml
      #Check that Export-Clixml  mock was called
      $assertMockParams = @{
        'CommandName'     = 'Export-Clixml'
        'Times'           = 1
        'Exactly'         = $true
        'Scope'           = 'It'
    }
    { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we output a XML - Because we need to know that the Mocks are working"
        }
    }
}

Describe "$commandname integration tests" -Tag UnitTest {
    $TheTestResults = Get-Content $PSScriptRoot\results.json -raw | ConvertFrom-Json | Convert-DbcResult -Label 'Testing'
     # So that we dont get any output in the tests but can test for It
     Mock Write-PSFMessage { } -ParameterFilter { $Level -and $Level -eq 'Output' }
    Context "File Creation"{
        $TestCases = @{
            FileName1 = 'DummyFileName'
            FileName2= 'DummyFileName1.csv'
            Filetype = 'csv'
        },
         @{
            FileName1 = 'DummyFileName'
            FileName2= 'DummyFileName1.json'
            Filetype = 'json'
        },
         @{
            FileName1 = 'DummyFileName'
            FileName2= 'DummyFileName1.xml'
            Filetype = 'xml'
        }
        It "Should create a file with an extension .<Filetype> even if the extension is not specified" -TestCases $TestCases{
            Param($FileName1,$FileType)
            Set-DbcFile -InputObject $TheTestResults -FilePath $TestDrive -FileName $FileName1 -FileType $Filetype
            $FileName = "$TestDrive\$filename1" + '.' + $FileType
            $FileName| Should -Exist
        }
        It "Should create a file with an extension .<Filetype> if the extension is specified"-TestCases $TestCases{
            Param($FileName2,$FileType)
            Set-DbcFile -InputObject $TheTestResults -FilePath $TestDrive -FileName $FileName2 -FileType $Filetype
            $FileName = "$TestDrive\$FileName2"
            $FileName| Should -Exist
        }
    }

# Need ot have .* whereveer there is a date as the date is dynamic
$JsonFileContent = @"
    [
        {
            "Date":  ".*",
            "Label":  "Testing",
            "Describe":  "Last Good DBCC CHECKDB",
            "Context":  "Testing Last Good DBCC CHECKDB",
            "Name":  "Database master last good integrity check should be less than 3 days old",
            "Database":  "master",
            "ComputerName":  "localhost,15592",
            "Instance":  "localhost,15592",
            "Result":  "Failed",
            "FailureMessage":  "Expected the actual value to be greater than .*, because You should have run a DBCC CheckDB inside that time, but got .*"
        },
        {
            "Date":  ".*",
            "Label":  "Testing",
            "Describe":  "Last Good DBCC CHECKDB",
            "Context":  "Testing Last Good DBCC CHECKDB",
            "Name":  "Database master has Data Purity Enabled",
            "Database":  "master",
            "ComputerName":  "localhost,15592",
            "Instance":  "localhost,15592",
            "Result":  "Passed",
            "FailureMessage":  ""
        },
    ]
"@
$CSVFileContent = @"
".*","Testing","Last Good DBCC CHECKDB","Testing Last Good DBCC CHECKDB","Database master last good integrity check should be less than 3 days old","master","localhost,15592","localhost,15592","Failed","Expected the actual value to be greater than .*, because You should have run a DBCC CheckDB inside that time, but got .*"
".*","Testing","Last Good DBCC CHECKDB","Testing Last Good DBCC CHECKDB","Database master has Data Purity Enabled","master","localhost,15592","localhost,15592","Passed",""
"@
$XMLFileContent = @"
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
  <Obj RefId="0">
    <TN RefId="0">
      <T>Selected.System.Data.DataRow</T>
      <T>System.Management.Automation.PSCustomObject</T>
      <T>System.Object</T>
    </TN>
    <MS>
      <DT N="Date">.*</DT>
      <S N="Label">Testing</S>
      <S N="Describe">Last Good DBCC CHECKDB</S>
      <S N="Context">Testing Last Good DBCC CHECKDB</S>
      <S N="Name">Database master last good integrity check should be less than 3 days old</S>
      <S N="Database">master</S>
      <S N="ComputerName">localhost,15592</S>
      <S N="Instance">localhost,15592</S>
      <S N="Result">Failed</S>
      <S N="FailureMessage">Expected the actual value to be greater than .*, because You should have run a DBCC CheckDB inside that time, but got .*</S>
    </MS>
  </Obj>
  <Obj RefId="1">
    <TNRef RefId="0" />
    <MS>
      <DT N="Date">.*</DT>
      <S N="Label">Testing</S>
      <S N="Describe">Last Good DBCC CHECKDB</S>
      <S N="Context">Testing Last Good DBCC CHECKDB</S>
      <S N="Name">Database master has Data Purity Enabled</S>
      <S N="Database">master</S>
      <S N="ComputerName">localhost,15592</S>
      <S N="Instance">localhost,15592</S>
      <S N="Result">Passed</S>
      <S N="FailureMessage"></S>
    </MS>
  </Obj>
</Objs>
"@

    Context "File Content"{
        $TestCases = @{
            FileName1 = 'DummyFileName'
            FileName2= 'DummyFileName1.csv'
            Filetype = 'csv'
            FileContent = $CSVFileContent
        },
         @{
            FileName1 = 'DummyFileName'
            FileName2= 'DummyFileName1.json'
            Filetype = 'json'
            FileContent = $JsonFileContent
        },
         @{
            FileName1 = 'DummyFileName'
            FileName2= 'DummyFileName1.xml'
            Filetype = 'xml'
            FileContent = $XMLFileContent
        }
        It "<FileType> File should have the correct contents" -TestCases $TestCases{
            Param($FileName1,$FileType, $FileContent)
            Set-DbcFile -InputObject $TheTestResults -FilePath $TestDrive -FileName $FileName1 -FileType $Filetype
            $FileName = "$TestDrive\$filename1" + '.' + $FileType
            $FileName | Should -FileContentMatchMultiline $FileContent
        }
    }
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUaU2PiV/2/Zd/mivp1JQkfU0h
# 64+gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE3MDUwOTAwMDAwMFoXDTIwMDUx
# MzEyMDAwMFowVzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMQ8wDQYD
# VQQHEwZWaWVubmExETAPBgNVBAoTCGRiYXRvb2xzMREwDwYDVQQDEwhkYmF0b29s
# czCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAI8ng7JxnekL0AO4qQgt
# Kr6p3q3SNOPh+SUZH+SyY8EA2I3wR7BMoT7rnZNolTwGjUXn7bRC6vISWg16N202
# 1RBWdTGW2rVPBVLF4HA46jle4hcpEVquXdj3yGYa99ko1w2FOWzLjKvtLqj4tzOh
# K7wa/Gbmv0Si/FU6oOmctzYMI0QXtEG7lR1HsJT5kywwmgcjyuiN28iBIhT6man0
# Ib6xKDv40PblKq5c9AFVldXUGVeBJbLhcEAA1nSPSLGdc7j4J2SulGISYY7ocuX3
# tkv01te72Mv2KkqqpfkLEAQjXgtM0hlgwuc8/A4if+I0YtboCMkVQuwBpbR9/6ys
# Z+sCAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5LfZldQ5Y
# MB0GA1UdDgQWBBRcxSkFqeA3vvHU0aq2mVpFRSOdmjAOBgNVHQ8BAf8EBAMCB4Aw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAzoDGGL2h0
# dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMEwG
# A1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3
# LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4MHYwJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEFBQcwAoZC
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJ
# RENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQAD
# ggEBANuBGTbzCRhgG0Th09J0m/qDqohWMx6ZOFKhMoKl8f/l6IwyDrkG48JBkWOA
# QYXNAzvp3Ro7aGCNJKRAOcIjNKYef/PFRfFQvMe07nQIj78G8x0q44ZpOVCp9uVj
# sLmIvsmF1dcYhOWs9BOG/Zp9augJUtlYpo4JW+iuZHCqjhKzIc74rEEiZd0hSm8M
# asshvBUSB9e8do/7RhaKezvlciDaFBQvg5s0fICsEhULBRhoyVOiUKUcemprPiTD
# xh3buBLuN0bBayjWmOMlkG1Z6i8DUvWlPGz9jiBT3ONBqxXfghXLL6n8PhfppBhn
# daPQO8+SqF5rqrlyBPmRRaTz2GQwggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7Vv
# lVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0Rp
# Z2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEw
# MjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx
# 6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEj
# lpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJN
# YBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2
# DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9
# hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNV
# HRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEF
# BQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDig
# NoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAo
# BggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgB
# hv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAU
# Reuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi
# 0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6l
# jlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0k
# riTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/P
# QMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d
# 9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJm
# oecYpJpkUe8xggIoMIICJAIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
# RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQD
# EyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBAhACwXUo
# dNXChDGFKtigZGnKMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTfRSlwVrEIKMwGmYGY7sPFIXAv
# ojANBgkqhkiG9w0BAQEFAASCAQA37CSp24Izu7mKVjXGuNLdR74HI1OrzEgxyBtM
# Y1R9g8CHU8KWJrPkkhiPO3MKghookjZVCW/IbELw/l/um7wjG0Rak13Ka+YGEyvN
# /3EzzcaH55vA+wMsR3eBQCO/sNi1r8lorzw/jxsROgupEL3jzrYmHZXkbGikOe2V
# BYSE6/Ln/uaw35VXujiJ/Ln7QbyedlccM6WfyCk38IUxttF0Ms3oUVqIrMV/3nkR
# ofBdzULzyaS2iSHS/ZQ/A5XHgqhJhJz3D22LI74Jo2QAeueEhrRNNz/pVLd59z4i
# 5G9PgBvGtRhVetWd6hsZW+ysKqXFZ1TxW50Fx3G604ejXnV9
# SIG # End signature block
