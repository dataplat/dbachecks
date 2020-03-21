# PSScriptAnalyzerSettings.psd1
# Settings for PSScriptAnalyzer invocation.
@{
    Rules = @{
        PSUseCompatibleCommands = @{
            # Turns the rule on
            Enable = $true

            # Lists the PowerShell platforms we want to check compatibility with
            TargetProfiles = @(
                'win-8_x64_10.0.17763.0_6.1.3_x64_4.0.30319.42000_core',
                'ubuntu_x64_18.04_6.1.3_x64_4.0.30319.42000_core',
                'win-8_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework'
             #   'win-8_x64_6.2.9200.0_3.0_x64_4.0.30319.42000_framework'
            )
            # You can specify commands to not check like this, which also will ignore its parameters:
            IgnoreCommands = @(
                'It', # Because Pester!
                'Should', # Because Pester!
                'Context', # Because Pester!
                'BeforeAll', # Because Pester!
                'AfterAll', # Because Pester!
                'Describe' # Because Pester!
                'Invoke-Pester' #Because Pester!
                'InModuleScope' #Because Pester!
                'Mock' #Because Pester!
                'Assert-MockCalled' #Because Pester!
                'Get-LocalGroupMember' # Because we handle it
            )
        }
        PSUseCompatibleSyntax = @{
            # This turns the rule on (setting it to false will turn it off)
            Enable = $true

            # Simply list the targeted versions of PowerShell here
            TargetVersions = @(
                '5.1'
                '6.1',
                '6.2'
            )
        }
    }
        # Do not analyze the following rules. Use ExcludeRules when you have
    # commented out the IncludeRules settings above and want to include all
    # the default rules except for those you exclude below.
    # Note: if a rule is in both c and ExcludeRules, the rule
    # will be excluded.
    # ExcludeRules = @('PSAvoidTrailingWhitespace')
}