$ModuleBase = Split-Path -Parent $MyInvocation.MyCommand.Path
Remove-Module dbachecks -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\dbachecks.psd1"
. $ModuleBase\..\..\internal\functions\Get-CheckInformation.ps1
Describe "Testing Get-CheckInformation" -Tag Get-CheckInformation, Unittest {
    Context "Input" {
        It "Should have a Group Parameter"{
        (Get-Command Get-CheckInformation).Parameters['group'] | Should -Not -BeNullOrEmpty -Because 'We are using this parameter'
        }
        It "Should have a Check Parameter"{
        (Get-Command Get-CheckInformation).Parameters['Check'] | Should -Not -BeNullOrEmpty -Because 'We are using this parameter'
        }
        It "Should have a AllChecks Parameter"{
        (Get-Command Get-CheckInformation).Parameters['AllChecks'] | Should -Not -BeNullOrEmpty -Because 'We are using this parameter'
        }
        It "Should have a ExcludeCheck Parameter"{
        (Get-Command Get-CheckInformation).Parameters['ExcludeCheck'] | Should -Not -BeNullOrEmpty -Because 'We are using this parameter'
        }
    }
    Context "Output" {
        $results = (Get-Content $ModuleBase\get-check.json) -join "`n"| ConvertFrom-Json
        Mock Get-DbcCheck {$results.Where{$_.Group -eq $Group}} -ParameterFilter {$Group -and $Group -in ('Server','Database')}
        It "Should Return All of the checks for a group when the Check equals the group and nothing excluded" {
            Get-CheckInformation -Group Server -Check Server | Should -Be 'PowerPlan', 'InstanceConnection', 'Connectivity', 'SPN', 'DiskCapacity', 'Storage', 'DISA', 'PingComputer', 'CPUPrioritisation', 'DiskAllocationUnit' -Because 'When the Check is specified and is a group it should return all of the tags for that group and not the groupname if nothing is exclueded'
        }
        It "Should Return All of the checks for a group When AllChecks is specified and nothing excluded" {
            Get-CheckInformation -Group Server -AllChecks $true | Should -Be 'PowerPlan', 'InstanceConnection', 'Connectivity', 'SPN', 'DiskCapacity', 'Storage', 'DISA', 'PingComputer', 'CPUPrioritisation', 'DiskAllocationUnit' -Because 'When AllChecks is specified  it should return all of the tags for that group and not the groupname if nothing is excluded'
        }
        It "Should Return one check for a group when one unique tag is specified and nothing excluded" {
            Get-CheckInformation -Group Server -Check SPN | Should -Be  'SPN' -Because 'When a Check is specified it should return just that check'
        }
        It "Should Return two checks for a group when two unique tags are specified and nothing excluded" {
            Get-CheckInformation -Group Server -Check SPN,InstanceConnection | Should -Be  'SPN', 'InstanceConnection' -Because 'When a Check is specified it should return just that check'
        }
        It "Should return a the unique tags for the none-unique tag if a none-unique tag is specified and nothing is excluded"{
            Get-CheckInformation -Group Database -Check LastBackup | Should -Be 'TestLastBackup', 'TestLastBackupVerifyOnly', 'LastFullBackup', 'LastDiffBackup', 'LastLogBackup' -Because 'When a none-unique tag is specified it should return all of the unique tags'
        }
        It "Should return the unique tags for the none-unique tags if two none-unique tags are specified and nothing is excluded"{
            Get-CheckInformation -Group Database -Check LastBackup, MaxDop  | Should -Be 'TestLastBackup', 'TestLastBackupVerifyOnly', 'LastFullBackup', 'LastDiffBackup', 'LastLogBackup', 'MaxDopDatabase', 'MaxDopInstance' -Because 'When a none-unique tag is specified it should return all of the unique tags'
        }
        It "Should Return All of the checks for a group except the excluded ones when the Check equals the group and one check is excluded" {
            Get-CheckInformation -Group Server -Check Server -ExcludeCheck PowerPlan | Should -Be  'InstanceConnection', 'Connectivity', 'SPN', 'DiskCapacity', 'Storage', 'DISA', 'PingComputer', 'CPUPrioritisation', 'DiskAllocationUnit' -Because 'When the Check is specified and is a group it should return all of the tags for that group except the excluded one and not the groupname'
        }
        It "Should Return All of the checks for a group except the excluded ones when the Check equals the group and two checks are excluded" {
            Get-CheckInformation -Group Server -Check Server -ExcludeCheck PowerPlan, CPUPrioritisation | Should -Be  'InstanceConnection', 'Connectivity', 'SPN', 'DiskCapacity', 'Storage', 'DISA', 'PingComputer', 'DiskAllocationUnit' -Because 'When the Check is specified and is a group it should return all of the tags for that group except the excluded ones and not the groupname'
        }
        It "Should Return All of the checks for a group except the excluded ones when AllChecks is specified and one check is excluded" {
            Get-CheckInformation -Group Server -AllChecks $true -ExcludeCheck PowerPlan | Should -Be  'InstanceConnection', 'Connectivity', 'SPN', 'DiskCapacity', 'Storage', 'DISA', 'PingComputer', 'CPUPrioritisation', 'DiskAllocationUnit' -Because 'When the Check is specified and is a group it should return all of the tags for that group except the excluded one and not the groupname'
        }
        It "Should Return All of the checks for a group except the excluded ones when AllChecks is specified and two checks are excluded" {
            Get-CheckInformation -Group Server --AllChecks $true -ExcludeCheck PowerPlan, CPUPrioritisation | Should -Be  'InstanceConnection', 'Connectivity', 'SPN', 'DiskCapacity', 'Storage', 'DISA', 'PingComputer', 'DiskAllocationUnit' -Because 'When the Check is specified and is a group it should return all of the tags for that group except the excluded ones and not the groupname'
        }
        It "Mocks Get-DbcCheck"{
            $assertMockParams = @{
                'CommandName' = 'Get-DbcCheck'
                'Times'       = 10
                'Exactly'     = $true
                }
                Assert-MockCalled @assertMockParams
        }
    }
}