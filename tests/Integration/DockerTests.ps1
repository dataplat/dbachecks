<#
    # Need to create a credential to be saved using user sa and password Password0! by running
    Get-Credential | Export-Clixml -Path $CredentialPath
#>
$CredentailPath = 'C:\MSSQL\BACKUP\KEEP\sacred.xml'
$dbacheckslocalpath = 'GIT:\dbachecks\'


Remove-Module dbatools, dbachecks -ErrorAction SilentlyContinue
Import-Module $dbacheckslocalpath\dbachecks.psd1
$null = Reset-DbcConfig
Set-Location $dbacheckslocalpath\tests\Integration

docker-compose up -d

$containers = 'localhost,15589', 'localhost,15588', 'localhost,15587', 'localhost,15586'
$cred = Import-Clixml $CredentailPath 

$null = Set-DbcConfig -Name app.sqlinstance $containers
$null = Set-DbcConfig -Name policy.connection.authscheme -Value SQL
$null = Set-DbcConfig -Name policy.network.latencymaxms -Value 100 # because the containers run a bit slow!

$ConnectivityTests = Invoke-DbcCheck -SqlCredential $cred -Check Connectivity -Show None -PassThru

#region error Log Count - PR 583
# default test
$errorlogscountdefault = Invoke-DbcCheck -SqlCredential $cred -Check ErrorLogCount -Show None  -PassThru
# set a value and then it will fail
$null = Set-DbcConfig -Name policy.errorlog.logcount -Value 10
$errorlogscountconfigchanged = Invoke-DbcCheck -SqlCredential $cred -Check ErrorLogCount -Show None  -PassThru

# set the value and then it will pass
Set-DbaErrorLogConfig -SqlInstance $containers -SqlCredential $cred -LogCount 10
$errorlogscountvaluechanged = Invoke-DbcCheck -SqlCredential $cred -Check ErrorLogCount -Show None  -PassThru
#endregion

#region Pester Functions
function DefaultCheck {
    It "All Checks should pass with default for $Check" {
        $Tests = get-variable "$($Check)default"  -ValueOnly
        $Tests.FailedCount | Should -Be 0 -Because "We expect all of the checks to run and pass with default setting (Yes we may set some values before but you get my drift)"
    }
}
function ConfigCheck {
    It "All Checks should fail when config changed for $Check" {
        $Tests = get-variable "$($Check)configchanged"  -ValueOnly
        $Tests.PassedCount | Should -Be 0 -Because "We expect all of the checks to run and fail when we have changed the config values"
    }
}
function ValueCheck {
    It "All Checks should pass when setting changed for $Check" {
        $Tests = get-variable "$($Check)valuechanged"  -ValueOnly
        $Tests.FailedCount | Should -Be 0 -Because "We expect all of the checks to run and pass when we have changed the settingns to match the config values"
    }
}
#endregion

Describe "Testing the checks are running as expected" -Tag Integration {
    Context "Connectivity Checks" {
        It "All Tests should pass" {
            $ConnectivityTests.FailedCount | Should -Be 0 -Because "We expect all of the checks to run and pass with default settings"
        }
    }

    $TestingTheChecks = @('errorlogscount')
    Foreach ($Check in $TestingTheChecks) {
        Context "$Check Checks" {
            write-host "$Check"
            DefaultCheck
            ConfigCheck
            ValueCheck
        }
    }
}