$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Remove-Module dbachecks -ErrorAction SilentlyContinue
# Import-Module "$PSScriptRoot\..\..\dbachecks.psd1"
. "$PSScriptRoot\..\..\functions\Set-DbcFile.ps1"
. "$PSScriptRoot\..\..\functions\Convert-DbcResult.ps1"
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot\..\constants.ps1"


Describe "$commandname Unit Tests" -Tags UnitTest {
    Context "Parameters and parameter sets" {
        $ParametersList = 'TestResults', 'FilePath', 'FileName', 'FileType', 'Append', 'Force'

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
            
            Set-DbcFile -InputObject $TheTestResults -FilePath DummyDirectory -FileName DummyFileName -Force -FileType CSV -Verbose
              
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
        'Times'           = 20 # No idea why
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
        'Times'           = 20 
        'Exactly'         = $true
        'Scope'           = 'It'
    }
    { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we output a json - Because we need to know that the Mocks are working" 
      #Check that correct Out-File mock was called
      $assertMockParams = @{
        'CommandName'     = 'Out-File'
        'Times'           = 20 
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
        'Times'           = 20 
        'Exactly'         = $true
        'Scope'           = 'It'
    }
    { Assert-MockCalled @assertMockParams } | Should -Not -Throw -Because "Did we output a XML - Because we need to know that the Mocks are working" 
        }

    }
}
