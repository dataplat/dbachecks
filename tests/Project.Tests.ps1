
Describe "PSScriptAnalyzer rule-sets" -Tag Build , ScriptAnalyzer {
    BeforeDiscovery {
        $script:ModuleName = 'dbachecks'
        $ModuleBase = (Get-Module -Name $ModuleName -ListAvailable).ModuleBase
        $Rules = Get-ScriptAnalyzerRule
        $scripts = Get-ChildItem $ModuleBase -Include *.ps1, *.psm1, *.psd1 -Recurse | Where-Object fullname -NotMatch 'classes'
        # Get last commit that was merged from main
        $lastCommit = git log --grep="Updated Version Number and docs from master" -1  --format='%H'
        # Get the files that have been altered in since the last merge from master
        $scripts = git diff --name-only $lastCommit HEAD | Where-Object { $psitem.EndsWith('ps1') }
        # only the ones in these folders
        $scripts = $scripts | Where-object { ($_ -like 'internal*')  -or  ($_ -like 'functions*') -or ( $_ -like 'checks*')}
    }
    BeforeAll {
        $PsScriptAnalyzerSettings = '/workspace/PSScriptAnalyzerSettings.psd1'

    }


    Context "Checking PSScriptAnalyzer on Script <_>" -ForEach $scripts {

        It "The Script Analyzer Rule <_> Should not fail" -ForEach $Rules.RuleName {
            
            $rulefailures = Invoke-ScriptAnalyzer -Path "$ModuleBase\$script" -IncludeRule $_ -Settings $PsScriptAnalyzerSettings
            $message = ($rulefailures | Select-Object Message -Unique).Message
            $lines = $rulefailures.Line -join ','
            $rulefailures.Count | Should -Be 0 -Because "Script Analyzer says the rules have been broken on lines $lines with Message '$message' Check in VSCode Problems tab or Run Invoke-ScriptAnalyzer -Script $ModuleBase\$script -Settings $PsScriptAnalyzerSettings"
        }
    }
}

