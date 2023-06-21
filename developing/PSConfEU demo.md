# PSConfEU demo

1. Develop in the source repository
  - copy existing check & rewrite - add check to `source/checks/Databasev5.Tests.ps1`
  - add configuration to `source/internal/configurations/configuration.ps1`
    - `skip.database.pseudosimple`
    - `policy.database.pseudosimpleexcludedb`
  - add object info to `source/internal/functions/Get-AllDatabaseInfo.ps1`


2. Build the module
    ```PowerShell
    ./build.ps1 -Tasks build
    ```

3. Sampler automatically adds the new version to your path
    ```PowerShell
    get-module dbachecks -ListAvailable | select name, modulebase
    ```

4. Import new version of the module (if you get a bogus error the first time retry it)
    ```PowerShell
    Import-Module dbachecks -force
    ```

5. Test out the new code

    ```PowerShell
    # save the password to make for easy connections
    $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password

    $show = 'All'
    $checks = 'RecoveryModel'

    #$sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'
    $sqlinstances = 'dbachecks1', 'dbachecks2', 'dbachecks3' # need client aliases for this to work New-DbaClientAlias

    # Run v4 checks
    $v4code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $true -Show $show -PassThru
    # Run v5 checks
    $v5code = Invoke-DbcCheck -SqlInstance $Sqlinstances -SqlCredential $cred -Check $Checks -legacy $false -Show $show -PassThru -Verbose

    Invoke-PerfAndValidateCheck -SQLInstances $sqlinstances -Checks $Checks
    Invoke-PerfAndValidateCheck -SQLInstances $sqlinstances -Checks $Checks -PerfDetail
    Invoke-PerfAndValidateCheck -SQLInstances $sqlinstances -Checks $Checks -showTestResults
    ```

