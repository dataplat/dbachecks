[cmdletbinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Justification='stupid implicit aliasing')]
Param()
# load all of the assertion functions
. /../internal/assertions/Database.Assertions.ps1
Describe "Checking Database.Assertions.ps1 assertions" -Tag UnitTest, Assertions, DatabaseAssertions {
    Context "Testing Get-Database" {
        It "Should have a Instance parameter" {
            (Get-Command Get-Database).Parameters['Instance'] | Should -Not -BeNullOrEmpty -Because "We Need to pass the instance in"
        }
        It "Should have a ExcludedDbs parameter" {
            (Get-Command Get-Database).Parameters['ExcludedDbs'] | Should -Not -BeNullOrEmpty -Because "We need to pass in the Excluded Databases - Don't forget that the ExcludedDatabases parameter is set by default so dont use that"
        }
        It "Should have a Requiredinfo parameter" {
            (Get-Command Get-Database).Parameters['Requiredinfo'] | Should -Not -BeNullOrEmpty -Because "We want to be able to choose the information we return"
        }
        It "Should have a Exclusions parameter" {
            (Get-Command Get-Database).Parameters['Exclusions'] | Should -Not -BeNullOrEmpty -Because "We need to be able to excluded databases for various reasons like readonly etc"
        }
        Mock Connect-DbaInstance {
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name         = 'Dummy1';
                        ReadOnly     = $False;
                        Status       = 'Normal';
                        IsAccessible = $True;
                    },
                    [PSCustomObject]@{
                        Name         = 'Dummy2';
                        ReadOnly     = $False;
                        Status       = 'Normal';
                        IsAccessible = $false;
                    }
                );
            }
        }
        It "Should return the Database Names with the Requiredinfo switch parameter value Name" {
            Get-Database -Instance Dummy -Requiredinfo Name | Should -Be 'Dummy1', 'Dummy2'
        }
        It "Should Exclude Databases that are specified for the Name  Required Info" {
            Get-Database -Instance Dummy -Requiredinfo Name -ExcludedDbs Dummy1 | Should -Be 'Dummy2'
        }
        It "Should Exclude none accessible databases if the NotAccessible value for Exclusions parameter is used" {
            Get-Database -Instance Dummy -Requiredinfo Name -Exclusions NotAccessible | Should -Be 'Dummy1'

        }
        It "Should call the Mocks" {
            $assertMockParams = @{
                'CommandName' = 'Connect-DbaInstance'
                'Times'       = 3
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }
    Context "Testing Assert-DatabaseMaxDop " {
        ## Mock for Passing
        Mock Test-DbaMaxDop {
            @{Database = 'N/A'; DatabaseMaxDop = 'N/A'},
            @{Database = 'Dummy1'; DatabaseMaxDop = '1'}
        }
        @(Test-DbaMaxDop -SqlInstance Dummy).Where{$_.Database -ne 'N/A'}.ForEach{
            It "Passes the test successfully" {
                Assert-DatabaseMaxDop -MaxDop $PsItem -MaxDopValue 1
            }
        }
        ## Mock for Failing
        Mock Test-DbaMaxDop {
            @{Database = 'N/A'; DatabaseMaxDop = 'N/A'},
            @{Database = 'Dummy1'; DatabaseMaxDop = '5'}
        }
        @(Test-DbaMaxDop -SqlInstance Dummy).Where{$_.Database -ne 'N/A'}.ForEach{
            It "Fails the test successfully" {
                {Assert-DatabaseMaxDop -MaxDop $PsItem -MaxDopValue 4} | Should -Throw -ExpectedMessage "Expected 4, because We expect the Database MaxDop Value to be the specified value 4, but got '5'."
            }
        }

        It "Calls the Mocks successfully" {
            $assertMockParams = @{
                'CommandName' = 'Test-DbaMaxDop'
                'Times'       = 2
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }
    Context "Testing Assert-DatabaseStatus " {
        #mock for passing
        Mock Connect-DbaInstance {
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    },
                    [PSCustomObject]@{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Pass when all databases are ok" {
            Assert-DatabaseStatus Dummy
        }
        # Mock for readonly failing
        Mock Connect-DbaInstance {
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Normal';
                        IsDatabaseSnapshot = $false;
                    },
                    [PSCustomObject]@{
                        Name     = 'Dummy2';
                        ReadOnly = $True;
                        Status   = 'Normal';
                        IsDatabaseSnapshot = $false;
                    }
                );
            }
        }
        It "It Should Fail for a database that is readonly" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected 'True' to not be found in collection @(`$false, `$true), because We expect that there will be no Read-Only databases except for those specified, but it was found."
        }
        It "It Should Not Fail for a database that is readonly when it is excluded" {
            Assert-DatabaseStatus -Instance Dummy -ExcludeReadOnly 'Dummy2'
        }
        It "It Should Not Fail for a snapshots" {

            Mock Connect-DbaInstance {
                [PSCustomObject]@{
                    Databases = @(
                        [PSCustomObject]@{
                            Name     = 'Dummy1';
                            ReadOnly = $False;
                            Status   = 'Normal';
                            IsDatabaseSnapshot = $false;
                        },
                        [PSCustomObject]@{
                            Name     = 'Dummy2';
                            ReadOnly = $True;
                            Status   = 'Normal';
                            IsDatabaseSnapshot = $true;
                        }
                    );
                }
            }
            Assert-DatabaseStatus -Instance Dummy
        }
        # Mock for offline failing
        Mock Connect-DbaInstance {
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Offline, AutoClosed';
                    },
                    [PSCustomObject]@{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is offline" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Offline' to not match 'Offline, AutoClosed', because We expect that there will be no offline databases except for those specified, but it did match."
        }
        It "It Should Not Fail for a database that is offline when it is excluded" {
            Assert-DatabaseStatus Dummy -ExcludeOffline 'Dummy1'
        }
        # Mock for restoring failing
        Mock Connect-DbaInstance {
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Restoring';
                    },
                    [PSCustomObject]@{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is restoring" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Restoring' to not match 'Restoring', because We expect that there will be no databases in a restoring state except for those specified, but it did match."
        }
        It "It Should Not Fail for a database that is restoring when it is excluded" {
            Assert-DatabaseStatus Dummy -ExcludeRestoring 'Dummy1'
        }
        # Mock for recovery failing
        Mock Connect-DbaInstance {
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Recovering';
                    },
                    [PSCustomObject]@{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is Recovering" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Recover' to not match 'Recovering', because We expect that there will be no databases going through the recovery process or in a recovery pending state, but it did match."
        }
        # Mock for recovery pending failing
        Mock Connect-DbaInstance {
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'RecoveryPending';
                    },
                    [PSCustomObject]@{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is Recovery pending" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Recover' to not match 'RecoveryPending', because We expect that there will be no databases going through the recovery process or in a recovery pending state, but it did match."
        }
        # Mock for autoclosed failing
        Mock Connect-DbaInstance {
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'AutoClosed';
                    },
                    [PSCustomObject]@{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is AutoClosed" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'AutoClosed' to not match 'AutoClosed', because We expect that there will be no databases that have been auto closed, but it did match."
        }

        # Mock for EmergencyMode failing
        Mock Connect-DbaInstance {
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'EmergencyMode';
                    },
                    [PSCustomObject]@{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is EmergencyMode" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Emergency' to not match 'EmergencyMode', because We expect that there will be no databases in EmergencyMode, but it did match."
        }

        # Mock for Suspect failing
        Mock Connect-DbaInstance {
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Suspect';
                    },
                    [PSCustomObject]@{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is Suspect" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Suspect' to not match 'Suspect', because We expect that there will be no databases in a Suspect state, but it did match."
        }

        # Mock for Standby failing
        Mock Connect-DbaInstance {
            [PSCustomObject]@{
                Databases = @(
                    [PSCustomObject]@{
                        Name     = 'Dummy1';
                        ReadOnly = $False;
                        Status   = 'Standby';
                    },
                    [PSCustomObject]@{
                        Name     = 'Dummy2';
                        ReadOnly = $False;
                        Status   = 'Normal';
                    }
                );
            }
        }
        It "It Should Fail for a database that is Standby" {
            { Assert-DatabaseStatus Dummy} | Should -Throw -ExpectedMessage "Expected regular expression 'Standby' to not match 'Standby', because We expect that there will be no databases in Standby, but it did match."
        }

        It "Should Not Fail for databases that are excluded" {
            Assert-DatabaseStatus Dummy -Excludedbs 'Dummy1'
        }
        It "Should call the Mocks successfully" {
            $assertMockParams = @{
                'CommandName' = 'Connect-DbaInstance'
                'Times'       = 15
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }
    Context "Testing Assert-DatabaseDuplicateIndex" {
        #Mock for passing
        Mock Find-DbaDbDuplicateIndex {}
        It "Should pass when there are no Duplicate Indexes" {
            Assert-DatabaseDuplicateIndex -Instance Dummy -Database Dummy1
        }
        # Mock for failing for 1 index
        Mock Find-DbaDbDuplicateIndex {
            [PSCustomObject]@{
                DatabaseName           = "msdb"
                TableName              = "dbo.log_shipping_primary_databases"
                IndexName              = "UQ__log_ship__2A5EF6DCB9BFAE2F"
                KeyColumns             = "primary_database ASC"
                IncludedColumns        = ""
                IndexType              = "NONCLUSTERED"
                IndexSizeMB            = "0.000000"
                CompressionDescription = "NONE"
                RowCount               = "0"
                IsDisabled             = "False"
                IsFiltered             = "False"
            }
        }
        It "Should fail for one duplicate index" {
            {Assert-DatabaseDuplicateIndex -Instance Dummy -Database Dummy1 } | Should -Throw -ExpectedMessage 'Expected 0, because Duplicate indexes waste disk space and cost you extra IO, CPU, and Memory, but got 1.'
        }
        #Mock for failing for 2 indexes
        Mock Find-DbaDbDuplicateIndex {
            @([PSCustomObject]@{
                    DatabaseName           = "msdb"
                    TableName              = "dbo.log_shipping_primary_databases"
                    IndexName              = "UQ__log_ship__2A5EF6DCB9BFAE2F"
                    KeyColumns             = "primary_database ASC"
                    IncludedColumns        = ""
                    IndexType              = "NONCLUSTERED"
                    IndexSizeMB            = "0.000000"
                    CompressionDescription = "NONE"
                    RowCount               = "0"
                    IsDisabled             = "False"
                    IsFiltered             = "False"
                },
                [PSCustomObject]@{
                    DatabaseName           = "msdb"
                    TableName              = "dbo.log_shipping_primary_databases"
                    IndexName              = "UQ__log_ship__2A5EF6DCB9BFAE2F"
                    KeyColumns             = "primary_database ASC"
                    IncludedColumns        = ""
                    IndexType              = "NONCLUSTERED"
                    IndexSizeMB            = "0.000000"
                    CompressionDescription = "NONE"
                    RowCount               = "0"
                    IsDisabled             = "False"
                    IsFiltered             = "False"
                }
            )
        }

        It "Should fail for more than one duplicate index" {
            {Assert-DatabaseDuplicateIndex -Instance Dummy -Database Dummy1 } | Should -Throw -ExpectedMessage 'Expected 0, because Duplicate indexes waste disk space and cost you extra IO, CPU, and Memory, but got 2.'
        }
    }
    Context "Testing Assert-DatabaseExists" {
        It "Should have a Instance parameter" {
            (Get-Command Assert-DatabaseExists).Parameters['Instance'] | Should -Not -BeNullOrEmpty -Because "We Need to pass the instance in"
        }
        It "Should have a ExpectedDB parameter" {
            (Get-Command Assert-DatabaseExists).Parameters['ExpectedDB'] | Should -Not -BeNullOrEmpty -Because "We Need to pass the Expected DB in"
        }

        # Mock for Passing
        Mock Get-Database {
             @('Expected1','Expected2','Expected3','Expected4')
        }
        @('Expected1', 'Expected2', 'Expected3', 'Expected4').ForEach{
            It "Should Pass when the database exists" {
                Assert-DatabaseExists -Instance Instance -ExpectedDb $psitem
            }
        }

        It "Should Fail when the database does not exist" {
            {Assert-DatabaseExists -Instance Instance -ExpectedDb NotThere} | Should -Throw -ExpectedMessage "We expect NotThere to be on Instance"
        }
    }
}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPgcaRfnImNd3g22AxhoOTA7s
# s/2gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE3MDUwOTAwMDAwMFoXDTIwMDUx
# MzEyMDAwMFowVzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCFZpcmdpbmlhMQ8wDQYD
# VQQHEwZWaWVubmExETAPBgNVBAoTCGRiYXRvb2xzMREwDwYDVQQDEwhkYmF0b29s
# czCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAI8ng7JxnekL0AO4qQgt
# Kr6p3q3SNOPh+SUZH+SyY8EA2I3wR7BMoT7rnZNolTwGjUXn7bRC6vISWg16N202
# 1RBWdTGW2rVPBVLF4HA46jle4hcpEVquXdj3yGYa99ko1w2FOWzLjKvtLqj4tzOh
# K7wa/Gbmv0Si/FU6oOmctzYMI0QXtEG7lR1HsJT5kywwmgcjyuiN28iBIhT6man0
# Ib6xKDv40PblKq5c9AFVldXUGVeBJbLhcEAA1nSPSLGdc7j4J2SulGISYY7ocuX3
# tkv01te72Mv2KkqqpfkLEAQjXgtM0hlgwuc8/A4if+I0YtboCMkVQuwBpbR9/6ys
# Z+sCAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrEuXsqCqOl6nEDwGD5LfZldQ5Y
# MB0GA1UdDgQWBBRcxSkFqeA3vvHU0aq2mVpFRSOdmjAOBgNVHQ8BAf8EBAMCB4Aw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAwbjA1oDOgMYYvaHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwNaAzoDGGL2h0
# dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMEwG
# A1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3
# LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGEBggrBgEFBQcBAQR4MHYwJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBOBggrBgEFBQcwAoZC
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJ
# RENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQAD
# ggEBANuBGTbzCRhgG0Th09J0m/qDqohWMx6ZOFKhMoKl8f/l6IwyDrkG48JBkWOA
# QYXNAzvp3Ro7aGCNJKRAOcIjNKYef/PFRfFQvMe07nQIj78G8x0q44ZpOVCp9uVj
# sLmIvsmF1dcYhOWs9BOG/Zp9augJUtlYpo4JW+iuZHCqjhKzIc74rEEiZd0hSm8M
# asshvBUSB9e8do/7RhaKezvlciDaFBQvg5s0fICsEhULBRhoyVOiUKUcemprPiTD
# xh3buBLuN0bBayjWmOMlkG1Z6i8DUvWlPGz9jiBT3ONBqxXfghXLL6n8PhfppBhn
# daPQO8+SqF5rqrlyBPmRRaTz2GQwggUwMIIEGKADAgECAhAECRgbX9W7ZnVTQ7Vv
# lVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0Rp
# Z2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBaFw0yODEw
# MjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNI
# QTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/lqJ3bMtdx
# 6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fTeyOU5JEj
# lpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqHCN8M9eJN
# YBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+bMt+dDk2
# DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLoLFH3c7y9
# hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIByTASBgNV
# HRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEF
# BQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDig
# NoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwAAgQwKjAo
# BggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAKBghghkgB
# hv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0jBBgwFoAU
# Reuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7sDVoks/Mi
# 0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGSdQ9RtG6l
# jlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6r7VRwo0k
# riTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo+MUSaJ/P
# QMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qzsIzV6Q3d
# 9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHqaGxEMrJm
# oecYpJpkUe8xggIoMIICJAIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMM
# RGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQD
# EyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBAhACwXUo
# dNXChDGFKtigZGnKMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQvONhty9MasvcoHTA4QqQhp6X4
# WDANBgkqhkiG9w0BAQEFAASCAQAFBW2/JsbUG6TudyVtS3mAXLNSNfCSpWM17WrG
# q0SndYWvx8xeduvDlH3Zv1tmHzhX6TM2uVOG2UXGP7Q91T4KH082bkDYEMZPcDA7
# NwmDZl6GF60zH3uIajno0xHXALZAiCWW/jvWpkb4fseed0k3WWZKl3st2L+Sa9Yw
# X0+/1gcPJoqXLKujEM4yl5zyz2hh/0k8Di7MTSiifD47wpUwfuttJAprDybX52eV
# pTbO0iEE8BLgkkK6CsvYY4c3DrlXTKalKEPdzKUGIAVh9TmFFrrE5wXu7BD90qqE
# 2paTerM1+6VRveN01QC9xltlfijUxMDh/jXJ/jnztcJvyDG1
# SIG # End signature block
