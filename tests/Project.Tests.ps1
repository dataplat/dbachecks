BeforeDiscovery {
    $script:ModuleName = 'dbachecks'
    $ModuleBase = (Get-Module -Name $ModuleName -ListAvailable).ModuleBase
    # $commands = Get-Command -Module $ModuleName -CommandType Cmdlet, Function
    function whateverthatis {
        <#
        .SYNOPSIS
        a synposis
        
        .DESCRIPTION
        a description
        
        .PARAMETER Name
        Parameter description
        
        .PARAMETER Name1
        This is my Name1 description
        
        .EXAMPLE
        An example
        .EXAMPLE
         codey code code

         descripty descripty descripty
        
        .NOTES
        General notes
        #>
        param (
            [Parameter(Mandatory)]
            [string]$Name,
            [Parameter(Mandatory)]
            [int]$Name1
        )
        Write-Output "Hello $Name, $Name1"

    }
    $commands = Get-Command whateverthatis
}
Describe 'PSScriptAnalyzer rule-sets' -Tag Build , ScriptAnalyzer {
    BeforeDiscovery {
        $script:ModuleName = 'dbachecks'
        $ModuleBase = (Get-Module -Name $ModuleName -ListAvailable).ModuleBase
        $Rules = Get-ScriptAnalyzerRule
        $scripts = Get-ChildItem $ModuleBase -Include *.ps1, *.psm1, *.psd1 -Recurse | Where-Object fullname -NotMatch 'classes'
        # Get last commit that was merged from main
        $lastCommit = git log --grep="Updated Version Number and docs from master" -1 --format='%H'
        # Get the files that have been altered in since the last merge from master
        $scripts = git diff --name-only $lastCommit HEAD | Where-Object { $psitem.EndsWith('ps1') }
        # only the ones in these folders
        $scripts = $scripts | Where-Object { ($_ -like 'internal*') -or ($_ -like 'functions*') -or ( $_ -like 'checks*') }
    }



    Context 'Checking PSScriptAnalyzer on Script <_>' -ForEach $scripts {

        BeforeDiscovery {
            $PsScriptAnalyzerSettings = '/workspace/PSScriptAnalyzerSettings.psd1'
            $scriptpath = Join-Path -Path $ModuleBase -ChildPath $PsItem
            
            $Tests = $rules.ForEach{
                @{
                    scriptpath               = $scriptpath
                    RuleName                 = $_.RuleName
                    PsScriptAnalyzerSettings = $PsScriptAnalyzerSettings
                }
            }
        }

        It 'The Script Analyzer Rule <_.RuleName> Should not fail' -ForEach $Tests {
            $rulefailures = Invoke-ScriptAnalyzer -Path $PsItem.scriptpath -IncludeRule $PsItem.RuleName -Settings $PsItem.PsScriptAnalyzerSettings
            $message = ($rulefailures | Select-Object Message -Unique).Message
            $lines = $rulefailures.Line -join ','
            $Because = 'Script Analyzer says the rules have been broken on lines {3} with Message {0} Check in VSCode Problems tab or Run Invoke-ScriptAnalyzer -Script {1} -Settings {2}' -f $message, $scriptpath, $PsScriptAnalyzerSettings, $lines
            $rulefailures.Count | Should -Be 0 -Because $Because
        }
    }
}



Describe 'Testing help for <_.Name>' -Tag Help -ForEach $commands {

    BeforeAll {
        $Help = Get-Help $PsItem.Name -ErrorAction SilentlyContinue
    }

    Context 'General help' {
        It 'Synopsis should not be auto-generated or empty' {
            $Because = 'We are good citizens and write good help'
            $Help.Synopsis | Should -Not -BeLike 'Short description*' -Because $Because
            $Help.Synopsis | Should -Not -BeLike "*$($PsItem.Name)*" -Because $Because
            $Help.Synopsis | Should -Not -BeNullOrEmpty -Because $Because
        }
        It 'Description should not be auto-generated or empty' {
            $Because = 'We are good citizens and write good help'
            $Help.Description | Should -Not -BeLike '*Long description*' -Because $Because
            $Help.Description | Should -Not -BeNullOrEmpty -Because $Because
        }
    }

    Context 'Examples help' {
        It 'There should be more than one example' {
            $Because = 'Most commands should have more than one example to explain and we are good citizens and write good help'
            $Help.Examples.example.Count | Should -BeGreaterThan 1 -Because $Because
        }

        It 'There should be code for <_.title>' -ForEach $Help.Examples.Example {
            $Because = 'All examples should have code otherwise what is the point? and we are good citizens and write good help'
            $PsItem.Code | Should -Not -BeNullOrEmpty -Because $Because
            $PsItem.Code | Should -Not -BeLike '*An example*' -Because $Because
        }
        It 'There should be remarks for <_.title>' -ForEach $Help.Examples.Example {
            $Because = 'All examples should have explanations otherwise what is the point? and we are good citizens and write good help'
            $PsItem.remarks[0] | Should -Not -Be '@{Text=}' -Because $Because
        }
    }

    Context 'Parameters help' {
        It 'Parameter <_.name> should have help' -ForEach ($command.ParameterSets.Parameters | Where-Object Name -NotIn 'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable', 'OutBuffer', 'OutVariable', 'PipelineVariable', 'Verbose', 'WarningAction', 'WarningVariable', 'Confirm', 'WhatIf') {
            $Because = 'Every parameter should have help and we are good citizens and write good help'
            $_.Description.Text | Should -Not -BeNullOrEmpty -Because $Because
            $_.Description.Text | Should -Not -Be 'Parameter description' -Because $Because
        }
    }
}


