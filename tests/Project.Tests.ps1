
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

