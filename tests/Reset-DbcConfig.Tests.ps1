$testSettingsDefinition = '
# config needed for testing
Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.a -Value "DefaultValueA" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.b -Value "DefaultValueB" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.group.a -Value "DefaultValueA" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.group.b -Value "DefaultValueB" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
'

Invoke-Expression $testSettingsDefinition

Describe "Testing Reset-DbcConfig" {
    InModuleScope -Module dbachecks {
        Mock Invoke-ConfigurationScript { 
            Invoke-Expression '

            # config needed for testing
            Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.a -Value "DefaultValueA" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
            Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.b -Value "DefaultValueB" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
            Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.group.a -Value "DefaultValueA" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
            Set-PSFConfig -Module dbachecks -Name testing.samplesettingforunittest.group.b -Value "DefaultValueB" -Initialize -Description "This setting is only to validate Reset-DbcConfig"
            '
        }

        It "Resetting specific setting works" {
            Set-DbcConfig -Name testing.samplesettingforunittest.a -Value "newvalue"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.a) | Should -Be "newvalue"
            Reset-DbcConfig -Name testing.samplesettingforunittest.a
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.a) | Should -Be "DefaultValueA"
        }

        It "Resetting specific setting doesn't change anything else" {
            Set-DbcConfig -Name testing.samplesettingforunittest.a -Value "newvalue"
            Set-DbcConfig -Name testing.samplesettingforunittest.b -Value "customvalue"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
            Reset-DbcConfig -Name testing.samplesettingforunittest.a
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.a) | Should -Be "DefaultValueA"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
        }

        It "Resetting with wildcard resets all matching settings" {
            Set-DbcConfig -Name testing.samplesettingforunittest.group.a -Value "newvalue1"
            Set-DbcConfig -Name testing.samplesettingforunittest.group.b -Value "newvalue2"
            Set-DbcConfig -Name testing.samplesettingforunittest.b -Value "customvalue"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.a) | Should -Be "newvalue1"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.b) | Should -Be "newvalue2"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
            Reset-DbcConfig -Name "testing.samplesettingforunittest.group.*"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.a) | Should -Be "DefaultValueA"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.b) | Should -Be "DefaultValueB"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
        }

        It "Resetting with wildcard resets only matching settings" {
            Set-DbcConfig -Name testing.samplesettingforunittest.b -Value "customvalue"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
            Reset-DbcConfig -Name testing.samplesettingforunittest.group.*
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
        }

        Mock Get-DbcConfig {
            param([string]$Name = "*")
            process {
                $results = [PSFramework.Configuration.ConfigurationHost]::Configurations.Values | 
                    Where-Object { ($_.Name.startswith("testing.samplesettingforunittest.")) -and ($_.Name -like $Name) -and ($_.Module -like "dbachecks") } | 
                    Sort-Object Module, Name
                return $results | Select-Object Name, Value, Description
            }
        }

        It "Resetting all resets really all" {
            Set-DbcConfig -Name testing.samplesettingforunittest.group.a -Value "newvalue1"
            Set-DbcConfig -Name testing.samplesettingforunittest.group.b -Value "newvalue2"
            Set-DbcConfig -Name testing.samplesettingforunittest.b -Value "customvalue"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.a) | Should -Be "newvalue1"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.b) | Should -Be "newvalue2"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "customvalue"
            Reset-DbcConfig
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.a) | Should -Be "DefaultValueA"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.group.b) | Should -Be "DefaultValueB"
            (Get-DbcConfigValue -Name testing.samplesettingforunittest.b) | Should -Be "DefaultValueB"
        }
    }
}

# cleanup, we don't want those test configuration options left in the system
# the cleanup from within AfterAll did not work, so it is here
Reset-DbcConfig -Name testing.samplesettingforunittest.a
Reset-DbcConfig -Name testing.samplesettingforunittest.b
Reset-DbcConfig -Name testing.samplesettingforunittest.group.a
Reset-DbcConfig -Name testing.samplesettingforunittest.group.b
