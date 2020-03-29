function Get-Database {
    Param(
        [string]$Instance,
        [string[]]$ExcludedDbs,
        [string[]]$Database,
        [ValidateSet('Name')]
        [string]$Requiredinfo,
        [ValidateSet('NotAccessible')]
        [string]$Exclusions
    )

    switch ($Exclusions) {
        NotAccessible { $dbs = (Connect-DbaInstance -SqlInstance $Instance).Databases.Where{$(if($database){$PsItem.Name -in $Database}else{$ExcludedDbs -notcontains $PsItem.Name}) -and $psitem.IsAccessible -eq $true} }
        Default {
            $dbs = (Connect-DbaInstance -SqlInstance $Instance).Databases.Where{$(if($database){$PsItem.Name -in $Database}else{$ExcludedDbs -notcontains $PsItem.Name})}
        }
    }
    switch ($Requiredinfo) {
        Name { $dbs.Name}
        Default {}
    }
}
function Assert-DatabaseMaxDop {
    Param(
        [pscustomobject]$MaxDop,
        [int]$MaxDopValue
    )
    $MaxDop.DatabaseMaxDop | Should -Be $MaxDopValue -Because "We expect the Database MaxDop Value to be the specified value $MaxDopValue"
}

function Assert-DatabaseStatus {
    Param(
        [string]$instance,
        [string[]]$Database,
        [string[]]$Excludedbs,
        [string[]]$ExcludeReadOnly,
        [string[]]$ExcludeOffline,
        [string[]]$ExcludeRestoring
    )
    if($Database){
        $results = @((Connect-DbaInstance -SqlInstance $Instance).Databases.Where{$psitem.Name -in $Database -and $psitem.Name -notin $Excludedbs} | Select-Object Name, Status, Readonly, IsDatabaseSnapshot)
    }
    else{
    $results = @((Connect-DbaInstance -SqlInstance $Instance).Databases.Where{$psitem.Name -notin $Excludedbs} | Select-Object Name, Status, Readonly, IsDatabaseSnapshot)
    }
    $results.Where{$_.Name -notin $ExcludeReadOnly -and $_.IsDatabaseSnapshot -eq $false}.Readonly | Should -Not -Contain True -Because "We expect that there will be no Read-Only databases except for those specified"
    $results.Where{$_.Name -notin $ExcludeOffline}.Status | Should -Not -Match 'Offline' -Because "We expect that there will be no offline databases except for those specified"
    $results.Where{$_.Name -notin $ExcludeRestoring}.Status | Should -Not -Match 'Restoring' -Because "We expect that there will be no databases in a restoring state except for those specified"
    $results.Where{$_.Name -notin $ExcludeOffline}.Status | Should -Not -Match 'AutoClosed' -Because "We expect that there will be no databases that have been auto closed"
    $results.Status | Should -Not -Match 'Recover' -Because "We expect that there will be no databases going through the recovery process or in a recovery pending state"
    $results.Status | Should -Not -Match 'Emergency' -Because "We expect that there will be no databases in EmergencyMode"
    $results.Status | Should -Not -Match 'Standby' -Because "We expect that there will be no databases in Standby"
    $results.Status | Should -Not -Match 'Suspect' -Because "We expect that there will be no databases in a Suspect state"
}

function Assert-DatabaseDuplicateIndex {
    Param(
        [string]$instance,
        [string]$Database
    )
    @(Find-DbaDbDuplicateIndex -SqlInstance $Instance -Database $Database).Count | Should -Be 0 -Because "Duplicate indexes waste disk space and cost you extra IO, CPU, and Memory"
}

function Assert-DatabaseExists {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param (
        [string]$Instance,
        [string]$ExpectedDB
    )
    $Actual = Get-Database -Instance $instance -Requiredinfo Name
    $Actual | Should -Contain $expecteddb -Because "We expect $expecteddb to be on $Instance"
}

function Assert-GuestUserConnect {
    Param (
        [string]$Instance,
        [string]$Database
    )
    $guestperms = Get-DbaUserPermission -SqlInstance $Instance -Database $psitem.Name | Where-Object {$_.Grantee -eq "guest" -and $_.Permission -eq "CONNECT"}
    $guestperms.Count | Should -Be 0 -Because "We expect the guest user in $Database on $Instance to not have CONNECT permissions"
}

function Assert-CLRAssembliesSafe {
    Param (
        [string]$Instance,
        [string]$Database
    )
    @(Get-DbaDbEncryption -SqlInstance $Instance -Database $Database | Where-Object {$_.Encryption -eq "Symmetric Key" -and $_.KeyLength -LT 2048}).Count | Should -Be 0 -Because "Symmetric keys should have a key length greater than or equal to 2048"
}

function Assert-AsymmetricKeySize {
    Param (
        [string]$Instance,
        [string]$Database
    )
    @(Get-DbaDbEncryption -SqlInstance $Instance -Database $Database | Where-Object {$_.Encryption -eq "Symmetric Key" -and $_.KeyLength -LT 2048}).Count | Should -Be 0 -Because "Symmetric keys should have a key length greater than or equal to 2048"
}

function Assert-SymmetricKeyEncryptionLevel {
    Param (
        [string]$Instance,
        [string]$Database
    )
    @(Get-DbaDbEncryption -SqlInstance $Instance -Database $Database | Where-Object {$_.Encryption -eq "Asymmetric Key" -and $_.EncryptionAlgrothim -notin "AES_128","AES_192","AES_256"}).Count  | Should -Be 0 -Because "Asymmetric keys should have an encryption algrothim of at least AES_128"
}

function Assert-QueryStoreEnabled {
    Param (
        [string]$Instance,
        [string]$Database
    )
    @(Get-DbaDbQueryStoreOption -SqlInstance $Instance -Database $Database | Where-Object {$_.ActualState -notin @("OFF", "ERROR") } ).Count  | Should -Be 1 -Because "We expect the Query Store to be enabled in $Database on $Instance"
}
function Assert-ContainedDBSQLAuth {
    Param (
        [string]$Instance,
        [string]$Database
    )
    @(Get-DbaDbUser -SQLInstance $Instance -Database $Database | Where-Object {$_.LoginType -eq "SqlLogin" -and $_.HasDbAccess -eq $true}).Count | Should -Be 0 -Because "We expect there to be no sql authenticated users in contained database $Database on $Instance"
}