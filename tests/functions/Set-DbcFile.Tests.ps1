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