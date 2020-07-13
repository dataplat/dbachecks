[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingComputerNameHardcoded", "")]
[CmdletBinding()]
param ()
# load all of the assertion functions
(Get-ChildItem $PSScriptRoot/../../internal/assertions/).ForEach{. $Psitem.FullName}

Describe "Checking ServerChecks.Tests" {
    Context "Testing Assert-CPUPrioritisation" {
        #Mock for passing
        function Get-RemoteRegistryValue {}
        Mock Get-RemoteRegistryValue {
            24
        }
        It "Should Pass When value set correctly" {
            Assert-CPUPrioritisation
        }
        #Mock for failing
        function Get-RemoteRegistryValue {}
        Mock Get-RemoteRegistryValue {
            2
        }
        It "Should fail When value set incorrectly" {
            {Assert-CPUPrioritisation} | Should -Throw -ExpectedMessage "Expected exactly 24, because a server should prioritise CPU to it's Services, not to the user experience when someone logs on, but got 2."
        }
    }
    Context "Testing Assert-DiskAllocationUnit" {
        it "Should pass when all SQLDisks are formatted with the 65536b (64kb) block allocation unit size" {
            Mock Test-DbaDiskAllocation {
                @(
                    [PSObject]@{
                        'BlockSize'      = 4096
                        'IsBestPractice' = $True
                        'IsSqlDisk'      = $True
                        'Label'          = $Null
                        'Name'           = 'C:\'
                        'Server'         = 'DummyServer'
                    },
                    [PSObject]@{
                        'BlockSize'      = 65536
                        'IsBestPractice' = $True
                        'IsSqlDisk'      = $True
                        'Label'          = 'SQL Data'
                        'Name'           = 'D:\'
                        'Server'         = 'DummyServer'
                    },
                    [PSObject]@{
                        'BlockSize'      = 65536
                        'IsBestPractice' = $True
                        'IsSqlDisk'      = $False
                        'Label'          = 'SQL Archive'
                        'Name'           = 'F:\'
                        'Server'         = 'DummyServer'
                    },
                    [PSObject]@{
                        'BlockSize'      = 65536
                        'IsBestPractice' = $True
                        'IsSqlDisk'      = $True
                        'Label'          = 'SQL Logs'
                        'Name'           = 'L:\'
                        'Server'         = 'DummyServer'
                    },
                    [PSObject]@{
                        'BlockSize'      = 65536
                        'IsBestPractice' = $True
                        'IsSqlDisk'      = $True
                        'Label'          = 'SQL Performance'
                        'Name'           = 'P:\'
                        'Server'         = 'DummyServer'
                    }
                )
            }

            $DiskAllocationObjects = Test-DbaDiskAllocation -ComputerName Dummy
            $DiskAllocationObjects.ForEach{
                Assert-DiskAllocationUnit -DiskAllocationObject $PSItem
            }
        }

        it "Should fail when any SQLDisks is formatted with a block allocation unit size that isn't 65536b (64KB)" {
            Mock Test-DbaDiskAllocation {
                @(
                    [PSObject]@{
                        'BlockSize'      = 4096
                        'IsBestPractice' = $True
                        'IsSqlDisk'      = $True
                        'Label'          = $Null
                        'Name'           = 'C:\'
                        'Server'         = 'DummyServer'
                    },
                    [PSObject]@{
                        'BlockSize'      = 65536
                        'IsBestPractice' = $True
                        'IsSqlDisk'      = $True
                        'Label'          = 'SQL Data'
                        'Name'           = 'D:\'
                        'Server'         = 'DummyServer'
                    },
                    [PSObject]@{
                        'BlockSize'      = 65536
                        'IsBestPractice' = $True
                        'IsSqlDisk'      = $False
                        'Label'          = 'SQL Archive'
                        'Name'           = 'F:\'
                        'Server'         = 'DummyServer'
                    },
                    [PSObject]@{
                        'BlockSize'      = 65536
                        'IsBestPractice' = $True
                        'IsSqlDisk'      = $True
                        'Label'          = 'SQL Logs'
                        'Name'           = 'L:\'
                        'Server'         = 'DummyServer'
                    },
                    [PSObject]@{
                        'BlockSize'      = 65536
                        'IsBestPractice' = $false # changed this to make it fail
                        'IsSqlDisk'      = $True
                        'Label'          = 'SQL Performance'
                        'Name'           = 'P:\'
                        'Server'         = 'DummyServer'
                    }
                )
            }
            $DiskAllocationObjects = Test-DbaDiskAllocation -ComputerName Dummy
            {Assert-DiskAllocationUnit -DiskAllocationObject $DiskAllocationObjects[4] } | should -Throw -ExpectedMessage "Expected `$true, because SQL Server performance will be better when accessing data from a disk that is formatted with 64Kb block allocation unit, but got `$false."
        }
    }
    Context "Testing Get-AllServerInfo for Tags Server with a server that exists" {
        Mock Test-Connection {
            @(
                [PSObject]@{
                    'Address'                        = 'DummyServer'
                    'BufferSize'                     = 32
                    'NoFragmentation'                = $False
                    'PrimaryAddressResolutionStatus' = 0
                    'ProtocolAddress'                = '10.10.10.10'
                    'ProtocolAddressResolved'        = ''
                    'RecordRoute'                    = 0
                    'ReplyInconsistency'             = $False
                    'ReplySize'                      = 32
                    'ResolveAddressNames'            = $False
                    'ResponseTime'                   = 1
                    'ResponseTimeToLive'             = 128
                    'RouteRecord'                    = $Null
                    'RouteRecordResolved'            = $Null
                    'SourceRoute'                    = ''
                    'SourceRouteType'                = 0
                    'StatusCode'                     = 0
                    'Timeout'                        = 4000
                    'TimeStampRecord'                = $Null
                    'TimeStampRecordAddress'         = $Null
                    'TimeStampRecordAddressResolved' = $Null
                    'TimestampRoute'                 = 0
                    'TimeToLive'                     = 80
                    'TypeofService'                  = 0
                    '__CLASS'                        = 'Win32_PingStatus'
                    '__DERIVATION'                   = @()
                    '__DYNASTY'                      = 'Win32_PingStatus'
                    '__GENUS'                        = 2
                    '__NAMESPACE'                    = 'root\cimv2'
                    '__PATH'                         = '\\SourceServer\root\cimv2:Win32_PingStatus.Address="DummyServer",BufferSize=32,NoFragmentation=FALSE,RecordRoute=0,ResolveAddressNames=FALSE,SourceRoute="",SourceRouteType=0,Ti
            meout=4000,TimestampRoute=0,TimeToLive=80,TypeofService=0'
                    '__PROPERTY_COUNT'               = 24
                    '__RELPATH'                      = 'Win32_PingStatus.Address="DummyServer",BufferSize=32,NoFragmentation=FALSE,RecordRoute=0,ResolveAddressNames=FALSE,SourceRoute="",SourceRouteType=0,Timeout=4000,TimestampRoute=
            0,TimeToLive=80,TypeofService=0'
                    '__SERVER'                       = 'SourceServer'
                    '__SUPERCLASS'                   = $Null
                },
                [PSObject]@{
                    'Address'                        = 'DummyServer'
                    'BufferSize'                     = 32
                    'NoFragmentation'                = $False
                    'PrimaryAddressResolutionStatus' = 0
                    'ProtocolAddress'                = '10.10.10.10'
                    'ProtocolAddressResolved'        = ''
                    'RecordRoute'                    = 0
                    'ReplyInconsistency'             = $False
                    'ReplySize'                      = 32
                    'ResolveAddressNames'            = $False
                    'ResponseTime'                   = 0
                    'ResponseTimeToLive'             = 128
                    'RouteRecord'                    = $Null
                    'RouteRecordResolved'            = $Null
                    'SourceRoute'                    = ''
                    'SourceRouteType'                = 0
                    'StatusCode'                     = 0
                    'Timeout'                        = 4000
                    'TimeStampRecord'                = $Null
                    'TimeStampRecordAddress'         = $Null
                    'TimeStampRecordAddressResolved' = $Null
                    'TimestampRoute'                 = 0
                    'TimeToLive'                     = 80
                    'TypeofService'                  = 0
                    '__CLASS'                        = 'Win32_PingStatus'
                    '__DERIVATION'                   = @()
                    '__DYNASTY'                      = 'Win32_PingStatus'
                    '__GENUS'                        = 2
                    '__NAMESPACE'                    = 'root\cimv2'
                    '__PATH'                         = '\\SourceServer\root\cimv2:Win32_PingStatus.Address="DummyServer",BufferSize=32,NoFragmentation=FALSE,RecordRoute=0,ResolveAddressNames=FALSE,SourceRoute="",SourceRouteType=0,Ti
            meout=4000,TimestampRoute=0,TimeToLive=80,TypeofService=0'
                    '__PROPERTY_COUNT'               = 24
                    '__RELPATH'                      = 'Win32_PingStatus.Address="DummyServer",BufferSize=32,NoFragmentation=FALSE,RecordRoute=0,ResolveAddressNames=FALSE,SourceRoute="",SourceRouteType=0,Timeout=4000,TimestampRoute=
            0,TimeToLive=80,TypeofService=0'
                    '__SERVER'                       = 'SourceServer'
                    '__SUPERCLASS'                   = $Null
                },
                [PSObject]@{
                    'Address'                        = 'DummyServer'
                    'BufferSize'                     = 32
                    'NoFragmentation'                = $False
                    'PrimaryAddressResolutionStatus' = 0
                    'ProtocolAddress'                = '10.10.10.10'
                    'ProtocolAddressResolved'        = ''
                    'RecordRoute'                    = 0
                    'ReplyInconsistency'             = $False
                    'ReplySize'                      = 32
                    'ResolveAddressNames'            = $False
                    'ResponseTime'                   = 0
                    'ResponseTimeToLive'             = 128
                    'RouteRecord'                    = $Null
                    'RouteRecordResolved'            = $Null
                    'SourceRoute'                    = ''
                    'SourceRouteType'                = 0
                    'StatusCode'                     = 0
                    'Timeout'                        = 4000
                    'TimeStampRecord'                = $Null
                    'TimeStampRecordAddress'         = $Null
                    'TimeStampRecordAddressResolved' = $Null
                    'TimestampRoute'                 = 0
                    'TimeToLive'                     = 80
                    'TypeofService'                  = 0
                    '__CLASS'                        = 'Win32_PingStatus'
                    '__DERIVATION'                   = @()
                    '__DYNASTY'                      = 'Win32_PingStatus'
                    '__GENUS'                        = 2
                    '__NAMESPACE'                    = 'root\cimv2'
                    '__PATH'                         = '\\SourceServer\root\cimv2:Win32_PingStatus.Address="DummyServer",BufferSize=32,NoFragmentation=FALSE,RecordRoute=0,ResolveAddressNames=FALSE,SourceRoute="",SourceRouteType=0,Ti
            meout=4000,TimestampRoute=0,TimeToLive=80,TypeofService=0'
                    '__PROPERTY_COUNT'               = 24
                    '__RELPATH'                      = 'Win32_PingStatus.Address="DummyServer",BufferSize=32,NoFragmentation=FALSE,RecordRoute=0,ResolveAddressNames=FALSE,SourceRoute="",SourceRouteType=0,Timeout=4000,TimestampRoute=
            0,TimeToLive=80,TypeofService=0'
                    '__SERVER'                       = 'SourceServer'
                    '__SUPERCLASS'                   = $Null
                }
            )
        }

        Mock Test-DbaDiskAllocation {
            @(
                [PSObject]@{
                    'BlockSize'      = 4096
                    'IsBestPractice' = $False
                    'IsSqlDisk'      = $True
                    'Label'          = $Null
                    'Name'           = 'C:\'
                    'Server'         = 'DummyServer'
                },
                [PSObject]@{
                    'BlockSize'      = 65536
                    'IsBestPractice' = $True
                    'IsSqlDisk'      = $True
                    'Label'          = 'SQL Data'
                    'Name'           = 'D:\'
                    'Server'         = 'DummyServer'
                },
                [PSObject]@{
                    'BlockSize'      = 65536
                    'IsBestPractice' = $True
                    'IsSqlDisk'      = $False
                    'Label'          = 'SQL Archive'
                    'Name'           = 'F:\'
                    'Server'         = 'DummyServer'
                },
                [PSObject]@{
                    'BlockSize'      = 65536
                    'IsBestPractice' = $True
                    'IsSqlDisk'      = $True
                    'Label'          = 'SQL Logs'
                    'Name'           = 'L:\'
                    'Server'         = 'DummyServer'
                },
                [PSObject]@{
                    'BlockSize'      = 65536
                    'IsBestPractice' = $True
                    'IsSqlDisk'      = $True
                    'Label'          = 'SQL Performance'
                    'Name'           = 'P:\'
                    'Server'         = 'DummyServer'
                }
            )
        }

        Mock Test-DbaPowerPlan {
            [PSObject]@{
                'ActivePowerPlan'      = 'High performance'
                'ComputerName'         = [PSObject]@{
                    'ComputerName'       = 'DummyServer'
                    'FullName'           = 'DummyServer'
                    'FullSmoName'        = 'DummyServer'
                    'InputObject'        = 'DummyServer'
                    'InstanceName'       = 'MSSQLSERVER'
                    'IsConnectionString' = $False
                    'IsLocalHost'        = $False
                    'LinkedLive'         = $False
                    'LinkedServer'       = $Null
                    'NetworkProtocol'    = [Sqlcollaborative.Dbatools.Connection.SqlConnectionProtocol]'Any'
                    'Port'               = 1433
                    'SqlComputerName'    = '[DummyServer]'
                    'SqlFullName'        = '[DummyServer]'
                    'SqlInstanceName'    = '[MSSQLSERVER]'
                    'Type'               = [Sqlcollaborative.Dbatools.Parameter.DbaInstanceInputType]'Default'
                }
                'isBestPractice'       = $True
                'RecommendedPowerPlan' = 'High performance'
            }
        }

        Mock Test-DbaSpn {
            @(
                [PSObject]@{
                    'Cluster'                = $False
                    'ComputerName'           = 'DummyServer'
                    'Credential'             = $Null
                    'DynamicPort'            = $False
                    'Error'                  = 'SPN missing'
                    'InstanceName'           = 'MSSQLSERVER'
                    'InstanceServiceAccount' = 'Domain\Account'
                    'IsSet'                  = $False
                    'Port'                   = $Null
                    'RequiredSPN'            = 'MSSQLSvc/DummyServer'
                    'SqlProduct'             = 'SQL Server 2017 Enterprise Edition: Core-based Licensing (64-bit)'
                    'TcpEnabled'             = $True
                    'Warning'                = 'None'
                },
                [PSObject]@{
                    'Cluster'                = $False
                    'ComputerName'           = 'DummyServer'
                    'Credential'             = $Null
                    'DynamicPort'            = $False
                    'Error'                  = 'SPN missing'
                    'InstanceName'           = 'NoneDefaultInstance'
                    'InstanceServiceAccount' = 'Domain\Account'
                    'IsSet'                  = $False
                    'Port'                   = $Null
                    'RequiredSPN'            = 'MSSQLSvc/DummyServer:NoneDefaultInstance'
                    'SqlProduct'             = 'SQL Server 2016 Enterprise Edition: Core-based Licensing (64-bit)'
                    'TcpEnabled'             = $True
                    'Warning'                = 'None'
                },
                [PSObject]@{
                    'Cluster'                = $False
                    'ComputerName'           = 'DummyServer'
                    'Credential'             = $Null
                    'DynamicPort'            = $False
                    'Error'                  = 'SPN missing'
                    'InstanceName'           = 'MSSQLSERVER'
                    'InstanceServiceAccount' = 'Domain\Account'
                    'IsSet'                  = $False
                    'Port'                   = '1433'
                    'RequiredSPN'            = 'MSSQLSvc/DummyServer:1433'
                    'SqlProduct'             = 'SQL Server 2017 Enterprise Edition: Core-based Licensing (64-bit)'
                    'TcpEnabled'             = $True
                    'Warning'                = 'None'
                },
                [PSObject]@{
                    'Cluster'                = $False
                    'ComputerName'           = 'DummyServer'
                    'Credential'             = $Null
                    'DynamicPort'            = $False
                    'Error'                  = 'SPN missing'
                    'InstanceName'           = 'NoneDefaultInstance'
                    'InstanceServiceAccount' = 'Domain\Account'
                    'IsSet'                  = $False
                    'Port'                   = '1437'
                    'RequiredSPN'            = 'MSSQLSvc/DummyServer:1437'
                    'SqlProduct'             = 'SQL Server 2016 Enterprise Edition: Core-based Licensing (64-bit)'
                    'TcpEnabled'             = $True
                    'Warning'                = 'None'
                }
            )

        }

        Mock Get-DbaDiskSpace {
            @(
                [PSObject]@{
                    'BlockSize'    = 4096
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 42355126272
                        'Digits'   = 2
                        'Gigabyte' = 39.4462852478027
                        'Kilobyte' = 41362428
                        'Megabyte' = 40392.99609375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0385217629373074
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 19814010880
                        'Digits'   = 2
                        'Gigabyte' = 18.4532356262207
                        'Kilobyte' = 19349620
                        'Megabyte' = 18896.11328125
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0180207379162312
                    }
                    'FreeInBytes'  = 19814010880
                    'FreeInGB'     = 18.45
                    'FreeInKB'     = 19349620
                    'FreeInMB'     = 18896.11
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.02
                    'IsSqlDisk'    = $Null
                    'Label'        = ''
                    'Name'         = 'C:\'
                    'PercentFree'  = 46.78
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 42355126272
                    'SizeInGB'     = 39.45
                    'SizeInKB'     = 41362428
                    'SizeInMB'     = 40393
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.04
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                },
                [PSObject]@{
                    'BlockSize'    = 65536
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 153408700416
                        'Digits'   = 2
                        'Gigabyte' = 142.872985839844
                        'Kilobyte' = 149813184
                        'Megabyte' = 146301.9375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.139524400234222
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 82363809792
                        'Digits'   = 2
                        'Gigabyte' = 76.707275390625
                        'Kilobyte' = 80433408
                        'Megabyte' = 78548.25
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0749094486236572
                    }
                    'FreeInBytes'  = 82363809792
                    'FreeInGB'     = 76.71
                    'FreeInKB'     = 80433408
                    'FreeInMB'     = 78548.25
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.07
                    'IsSqlDisk'    = $Null
                    'Label'        = 'SQL Logs'
                    'Name'         = 'L:\'
                    'PercentFree'  = 53.69
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 153408700416
                    'SizeInGB'     = 142.87
                    'SizeInKB'     = 149813184
                    'SizeInMB'     = 146301.94
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.14
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                },
                [PSObject]@{
                    'BlockSize'    = 65536
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 382116757504
                        'Digits'   = 2
                        'Gigabyte' = 355.873962402344
                        'Kilobyte' = 373160896
                        'Megabyte' = 364414.9375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.347533166408539
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 84496482304
                        'Digits'   = 2
                        'Gigabyte' = 78.6934814453125
                        'Kilobyte' = 82516096
                        'Megabyte' = 80582.125
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.076849102973938
                    }
                    'FreeInBytes'  = 84496482304
                    'FreeInGB'     = 78.69
                    'FreeInKB'     = 82516096
                    'FreeInMB'     = 80582.12
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.08
                    'IsSqlDisk'    = $Null
                    'Label'        = 'SQL Performance'
                    'Name'         = 'P:\'
                    'PercentFree'  = 22.11
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 382116757504
                    'SizeInGB'     = 355.87
                    'SizeInKB'     = 373160896
                    'SizeInMB'     = 364414.94
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.35
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                },
                [PSObject]@{
                    'BlockSize'    = 65536
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 42813292544
                        'Digits'   = 2
                        'Gigabyte' = 39.8729858398438
                        'Kilobyte' = 41809856
                        'Megabyte' = 40829.9375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0389384627342224
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 42719117312
                        'Digits'   = 2
                        'Gigabyte' = 39.7852783203125
                        'Kilobyte' = 41717888
                        'Megabyte' = 40740.125
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0388528108596802
                    }
                    'FreeInBytes'  = 42719117312
                    'FreeInGB'     = 39.79
                    'FreeInKB'     = 41717888
                    'FreeInMB'     = 40740.12
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.04
                    'IsSqlDisk'    = $Null
                    'Label'        = 'Archive Data (SLOW!)'
                    'Name'         = 'F:\'
                    'PercentFree'  = 99.78
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 42813292544
                    'SizeInGB'     = 39.87
                    'SizeInKB'     = 41809856
                    'SizeInMB'     = 40829.94
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.04
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                },
                [PSObject]@{
                    'BlockSize'    = 65536
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 580757946368
                        'Digits'   = 2
                        'Gigabyte' = 540.872985839844
                        'Kilobyte' = 567146432
                        'Megabyte' = 553853.9375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.528196275234222
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 580605968384
                        'Digits'   = 2
                        'Gigabyte' = 540.7314453125
                        'Kilobyte' = 566998016
                        'Megabyte' = 553709
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.528058052062988
                    }
                    'FreeInBytes'  = 580605968384
                    'FreeInGB'     = 540.73
                    'FreeInKB'     = 566998016
                    'FreeInMB'     = 553709
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.53
                    'IsSqlDisk'    = $Null
                    'Label'        = 'SQL Data'
                    'Name'         = 'D:\'
                    'PercentFree'  = 99.97
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 580757946368
                    'SizeInGB'     = 540.87
                    'SizeInKB'     = 567146432
                    'SizeInMB'     = 553853.94
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.53
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                }
            )

        }

        $tags = 'PowerPlan', 'SPN', 'DiskCapacity', 'PingComputer', 'CPUPrioritisation', 'DiskAllocationUnit', 'InstanceConnection'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should get the right results for PingComputer" {
            $serverInfo.PingComputer.Count | Should -Be 3
            $serverInfo.PingComputer[0].Address | Should -Be 'DummyServer'
            $serverInfo.PingComputer[0].ProtocolAddress | Should -Be '10.10.10.10'
            $serverInfo.PingComputer[0].ProtocolAddress | Should -Be '10.10.10.10'
            $serverInfo.PingComputer[0].ResponseTime | Should -Be 1
        }
        It "Should get the right results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation[0].Name | Should -Be 'C:\'
            $serverInfo.DiskAllocation[0].isBestPractice| Should -BeFalse
            $serverInfo.DiskAllocation[0].isSqlDisk| Should -BeTrue
        }
        It "Should get the right results for PowerPlan" {
            $serverInfo.PowerPlan | Should -BeTrue
        }
        It "Should get the right results for SPN" {
            $serverInfo.SPNs[0].ComputerName | Should -Be 'DummyServer'
            $serverInfo.SPNs[0].Error | Should -Be 'SPN missing'
            $serverInfo.SPNs[0].RequiredSPN | Should -Be 'MSSQLSvc/DummyServer'
        }
        It "Should get the right results for DiskCapacity" {
            $serverInfo.DiskSpace[0].ComputerName | Should -Be 'DummyServer'
            $serverInfo.DiskSpace[0].Name | Should -Be 'C:\'
            $serverInfo.DiskSpace[0].PercentFree | Should -Be 46.78
        }
    }

    Context "Testing Get-AllServerInfo for Tags Server with a server that doesn't exist" {
        Mock Test-Connection {Throw}

        Mock Test-DbaDiskAllocation {Throw}

        Mock Test-DbaPowerPlan {Throw}

        Mock Test-DbaSpn {Throw}

        Mock Get-DbaDiskSpace {Throw}

        $tags = 'PowerPlan', 'SPN', 'DiskCapacity', 'PingComputer', 'CPUPrioritisation', 'DiskAllocationUnit', 'InstanceConnection'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should get the right results for PingComputer" {
            $serverInfo.PingComputer.Count | Should -Be -1 -Because "This is what the function should return for no server"
            $serverInfo.PingComputer[0].Address | Should -BeNullOrEmpty -Because "This is what the function should return for no server"
            $serverInfo.PingComputer[0].ResponseTime  | Should -Be 50000000  -Because "This is what the function should return for no server"
        }
        It "Should get the right results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation[0].Name | Should -Be '? '  # Yes there is a space for formatting the PowerBi
            $serverInfo.DiskAllocation[0].isBestPractice| Should -BeFalse
            $serverInfo.DiskAllocation[0].isSqlDisk| Should -BeTrue
        }
        It "Should get the right results for PowerPlan" {
            $serverInfo.PowerPlan | Should -Be 'An Error occurred'
        }
        It "Should get the right results for SPN" {
            $serverInfo.SPNs[0].Error | Should -Be 'An Error occurred'
            $serverInfo.SPNs[0].RequiredSPN | Should -Be 'Dont know the SPN'
        }
        It "Should get the right results for DiskCapacity" {
            $serverInfo.DiskSpace.ComputerName| Should -Be 'An Error occurred Dummy'
            $serverInfo.DiskSpace.Name | Should -Be 'Do not know the Name'
            $serverInfo.DiskSpace.PercentFree | Should -Be -1
        }
    }

    # There is probably a way of using test cases for this and making it dynamic
    # Some bearded fellow wrote about it!!
    # https://sqldbawithabeard.com/2017/07/06/writing-dynamic-and-random-tests-cases-for-pester/
    # But right now I cant see it so this will do

    Context "Testing Get-AllServerInfo for Tags PowerPlan with a server that exists" {

        Mock Test-DbaPowerPlan {
            [PSObject]@{
                'ActivePowerPlan'      = 'High performance'
                'ComputerName'         = [PSObject]@{
                    'ComputerName'       = 'DummyServer'
                    'FullName'           = 'DummyServer'
                    'FullSmoName'        = 'DummyServer'
                    'InputObject'        = 'DummyServer'
                    'InstanceName'       = 'MSSQLSERVER'
                    'IsConnectionString' = $False
                    'IsLocalHost'        = $False
                    'LinkedLive'         = $False
                    'LinkedServer'       = $Null
                    'NetworkProtocol'    = [Sqlcollaborative.Dbatools.Connection.SqlConnectionProtocol]'Any'
                    'Port'               = 1433
                    'SqlComputerName'    = '[DummyServer]'
                    'SqlFullName'        = '[DummyServer]'
                    'SqlInstanceName'    = '[MSSQLSERVER]'
                    'Type'               = [Sqlcollaborative.Dbatools.Parameter.DbaInstanceInputType]'Default'
                }
                'isBestPractice'       = $True
                'RecommendedPowerPlan' = 'High performance'
            }
        }

        Mock Test-Connection {}

        Mock Test-DbaDiskAllocation {}

        Mock Test-DbaSpn {}

        Mock Get-DbaDiskSpace {}

        $tags = 'PowerPlan'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should have no results for PingComputer" {
            $serverInfo.PingComputer| Should -BeNullOrEmpty
            $assertMockParams = @{
                'CommandName' = 'Test-Connection'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have no results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation | Should -BeNullOrEmpty

            $assertMockParams = @{
                'CommandName' = 'Test-DbaDiskAllocation'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should get the right results for PowerPlan" {
            $serverInfo.PowerPlan | Should -BeTrue
        }
        It "Should have no results for SPN" {
            $serverInfo.SPNs | Should -BeNullOrEmpty
            $assertMockParams = @{
                'CommandName' = 'Test-DbaSPN'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have no results for DiskCapacity" {
            $serverInfo.DiskSpace | Should -BeNullOrEmpty
            $assertMockParams = @{
                'CommandName' = 'Get-DbaDiskSpace'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }

    Context "Testing Get-AllServerInfo for Tags PowerPlan with a server that doesn't exist" {
        Mock Test-Connection {}

        Mock Test-DbaDiskAllocation {}

        Mock Test-DbaPowerPlan {Throw}

        Mock Test-DbaSpn {}

        Mock Get-DbaDiskSpace {}

        $tags = 'PowerPlan'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should have no results for PingComputer" {
            $serverInfo.PingComputer| Should -BeNullOrEmpty
        }
        It "Should have no results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation | Should -BeNullOrEmpty
        }
        It "Should get the right results for PowerPlan" {
            $serverInfo.PowerPlan | Should -Be 'An Error occurred'
        }
        It "Should have no results for SPN" {
            $serverInfo.SPNs | Should -BeNullOrEmpty
        }
        It "Should have no results for DiskCapacity" {
            $serverInfo.DiskSpace | Should -BeNullOrEmpty
        }
    }

    Context "Testing Get-AllServerInfo for Tags PingComputer with a server that exists" {

        Mock Test-Connection {
            @(
                [PSObject]@{
                    'Address'                        = 'DummyServer'
                    'BufferSize'                     = 32
                    'NoFragmentation'                = $False
                    'PrimaryAddressResolutionStatus' = 0
                    'ProtocolAddress'                = '10.10.10.10'
                    'ProtocolAddressResolved'        = ''
                    'RecordRoute'                    = 0
                    'ReplyInconsistency'             = $False
                    'ReplySize'                      = 32
                    'ResolveAddressNames'            = $False
                    'ResponseTime'                   = 1
                    'ResponseTimeToLive'             = 128
                    'RouteRecord'                    = $Null
                    'RouteRecordResolved'            = $Null
                    'SourceRoute'                    = ''
                    'SourceRouteType'                = 0
                    'StatusCode'                     = 0
                    'Timeout'                        = 4000
                    'TimeStampRecord'                = $Null
                    'TimeStampRecordAddress'         = $Null
                    'TimeStampRecordAddressResolved' = $Null
                    'TimestampRoute'                 = 0
                    'TimeToLive'                     = 80
                    'TypeofService'                  = 0
                    '__CLASS'                        = 'Win32_PingStatus'
                    '__DERIVATION'                   = @()
                    '__DYNASTY'                      = 'Win32_PingStatus'
                    '__GENUS'                        = 2
                    '__NAMESPACE'                    = 'root\cimv2'
                    '__PATH'                         = '\\SourceServer\root\cimv2:Win32_PingStatus.Address="DummyServer",BufferSize=32,NoFragmentation=FALSE,RecordRoute=0,ResolveAddressNames=FALSE,SourceRoute="",SourceRouteType=0,Ti
            meout=4000,TimestampRoute=0,TimeToLive=80,TypeofService=0'
                    '__PROPERTY_COUNT'               = 24
                    '__RELPATH'                      = 'Win32_PingStatus.Address="DummyServer",BufferSize=32,NoFragmentation=FALSE,RecordRoute=0,ResolveAddressNames=FALSE,SourceRoute="",SourceRouteType=0,Timeout=4000,TimestampRoute=
            0,TimeToLive=80,TypeofService=0'
                    '__SERVER'                       = 'SourceServer'
                    '__SUPERCLASS'                   = $Null
                },
                [PSObject]@{
                    'Address'                        = 'DummyServer'
                    'BufferSize'                     = 32
                    'NoFragmentation'                = $False
                    'PrimaryAddressResolutionStatus' = 0
                    'ProtocolAddress'                = '10.10.10.10'
                    'ProtocolAddressResolved'        = ''
                    'RecordRoute'                    = 0
                    'ReplyInconsistency'             = $False
                    'ReplySize'                      = 32
                    'ResolveAddressNames'            = $False
                    'ResponseTime'                   = 0
                    'ResponseTimeToLive'             = 128
                    'RouteRecord'                    = $Null
                    'RouteRecordResolved'            = $Null
                    'SourceRoute'                    = ''
                    'SourceRouteType'                = 0
                    'StatusCode'                     = 0
                    'Timeout'                        = 4000
                    'TimeStampRecord'                = $Null
                    'TimeStampRecordAddress'         = $Null
                    'TimeStampRecordAddressResolved' = $Null
                    'TimestampRoute'                 = 0
                    'TimeToLive'                     = 80
                    'TypeofService'                  = 0
                    '__CLASS'                        = 'Win32_PingStatus'
                    '__DERIVATION'                   = @()
                    '__DYNASTY'                      = 'Win32_PingStatus'
                    '__GENUS'                        = 2
                    '__NAMESPACE'                    = 'root\cimv2'
                    '__PATH'                         = '\\SourceServer\root\cimv2:Win32_PingStatus.Address="DummyServer",BufferSize=32,NoFragmentation=FALSE,RecordRoute=0,ResolveAddressNames=FALSE,SourceRoute="",SourceRouteType=0,Ti
            meout=4000,TimestampRoute=0,TimeToLive=80,TypeofService=0'
                    '__PROPERTY_COUNT'               = 24
                    '__RELPATH'                      = 'Win32_PingStatus.Address="DummyServer",BufferSize=32,NoFragmentation=FALSE,RecordRoute=0,ResolveAddressNames=FALSE,SourceRoute="",SourceRouteType=0,Timeout=4000,TimestampRoute=
            0,TimeToLive=80,TypeofService=0'
                    '__SERVER'                       = 'SourceServer'
                    '__SUPERCLASS'                   = $Null
                },
                [PSObject]@{
                    'Address'                        = 'DummyServer'
                    'BufferSize'                     = 32
                    'NoFragmentation'                = $False
                    'PrimaryAddressResolutionStatus' = 0
                    'ProtocolAddress'                = '10.10.10.10'
                    'ProtocolAddressResolved'        = ''
                    'RecordRoute'                    = 0
                    'ReplyInconsistency'             = $False
                    'ReplySize'                      = 32
                    'ResolveAddressNames'            = $False
                    'ResponseTime'                   = 0
                    'ResponseTimeToLive'             = 128
                    'RouteRecord'                    = $Null
                    'RouteRecordResolved'            = $Null
                    'SourceRoute'                    = ''
                    'SourceRouteType'                = 0
                    'StatusCode'                     = 0
                    'Timeout'                        = 4000
                    'TimeStampRecord'                = $Null
                    'TimeStampRecordAddress'         = $Null
                    'TimeStampRecordAddressResolved' = $Null
                    'TimestampRoute'                 = 0
                    'TimeToLive'                     = 80
                    'TypeofService'                  = 0
                    '__CLASS'                        = 'Win32_PingStatus'
                    '__DERIVATION'                   = @()
                    '__DYNASTY'                      = 'Win32_PingStatus'
                    '__GENUS'                        = 2
                    '__NAMESPACE'                    = 'root\cimv2'
                    '__PATH'                         = '\\SourceServer\root\cimv2:Win32_PingStatus.Address="DummyServer",BufferSize=32,NoFragmentation=FALSE,RecordRoute=0,ResolveAddressNames=FALSE,SourceRoute="",SourceRouteType=0,Ti
            meout=4000,TimestampRoute=0,TimeToLive=80,TypeofService=0'
                    '__PROPERTY_COUNT'               = 24
                    '__RELPATH'                      = 'Win32_PingStatus.Address="DummyServer",BufferSize=32,NoFragmentation=FALSE,RecordRoute=0,ResolveAddressNames=FALSE,SourceRoute="",SourceRouteType=0,Timeout=4000,TimestampRoute=
            0,TimeToLive=80,TypeofService=0'
                    '__SERVER'                       = 'SourceServer'
                    '__SUPERCLASS'                   = $Null
                }
            )
        }

        Mock Test-DbaDiskAllocation {}

        Mock Test-DbaSpn {}

        Mock Get-DbaDiskSpace {}

        $tags = 'PingComputer'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should have the right  results for PingComputer" {
            $serverInfo.PingComputer.Count | Should -Be 3
            $serverInfo.PingComputer[0].Address | Should -Be 'DummyServer'
            $serverInfo.PingComputer[0].ProtocolAddress | Should -Be '10.10.10.10'
            $serverInfo.PingComputer[0].ProtocolAddress | Should -Be '10.10.10.10'
            $serverInfo.PingComputer[0].ResponseTime | Should -Be 1
            $assertMockParams = @{
                'CommandName' = 'Test-Connection'
                'Times'       = 1
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have no results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation | Should -BeNullOrEmpty

            $assertMockParams = @{
                'CommandName' = 'Test-DbaDiskAllocation'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have no results results for PowerPlan" {
            $serverInfo.PowerPlan | Should -BeNullOrEmpty
        }
        It "Should have no results for SPN" {
            $serverInfo.SPNs | Should -BeNullOrEmpty
            $assertMockParams = @{
                'CommandName' = 'Test-DbaSPN'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have no results for DiskCapacity" {
            $serverInfo.DiskSpace | Should -BeNullOrEmpty
            $assertMockParams = @{
                'CommandName' = 'Get-DbaDiskSpace'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }

    Context "Testing Get-AllServerInfo for Tags PingComputer with a server that doesn't exist" {
        Mock Test-Connection {Throw}

        Mock Test-DbaDiskAllocation {}

        Mock Test-DbaPowerPlan {}

        Mock Test-DbaSpn {}

        Mock Get-DbaDiskSpace {}

        $tags = 'PingComputer'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should get the right results for PingComputer" {
            $serverInfo.PingComputer.Count | Should -Be -1 -Because "This is what the function should return for no server"
            $serverInfo.PingComputer[0].Address | Should -BeNullOrEmpty -Because "This is what the function should return for no server"
            $serverInfo.PingComputer[0].ResponseTime  | Should -Be 50000000  -Because "This is what the function should return for no server"
        }
        It "Should have no results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation | Should -BeNullOrEmpty
        }
        It "Should have no results for PowerPlan" {
            $serverInfo.PowerPlan | Should -BeNullOrEmpty
        }
        It "Should have no results for SPN" {
            $serverInfo.SPNs | Should -BeNullOrEmpty
        }
        It "Should have no results for DiskCapacity" {
            $serverInfo.DiskSpace | Should -BeNullOrEmpty
        }
    }

    Context "Testing Get-AllServerInfo for Tags DiskAllocationUnit with a server that exists" {

        Mock Test-Connection { }

        Mock Test-DbaDiskAllocation {
            @(
                [PSObject]@{
                    'BlockSize'      = 4096
                    'IsBestPractice' = $False
                    'IsSqlDisk'      = $True
                    'Label'          = $Null
                    'Name'           = 'C:\'
                    'Server'         = 'DummyServer'
                },
                [PSObject]@{
                    'BlockSize'      = 65536
                    'IsBestPractice' = $True
                    'IsSqlDisk'      = $True
                    'Label'          = 'SQL Data'
                    'Name'           = 'D:\'
                    'Server'         = 'DummyServer'
                },
                [PSObject]@{
                    'BlockSize'      = 65536
                    'IsBestPractice' = $True
                    'IsSqlDisk'      = $False
                    'Label'          = 'SQL Archive'
                    'Name'           = 'F:\'
                    'Server'         = 'DummyServer'
                },
                [PSObject]@{
                    'BlockSize'      = 65536
                    'IsBestPractice' = $True
                    'IsSqlDisk'      = $True
                    'Label'          = 'SQL Logs'
                    'Name'           = 'L:\'
                    'Server'         = 'DummyServer'
                },
                [PSObject]@{
                    'BlockSize'      = 65536
                    'IsBestPractice' = $True
                    'IsSqlDisk'      = $True
                    'Label'          = 'SQL Performance'
                    'Name'           = 'P:\'
                    'Server'         = 'DummyServer'
                }
            )
        }

        Mock Test-DbaSpn {}

        Mock Get-DbaDiskSpace {}

        $tags = 'DiskAllocationUnit'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should have no results for PingComputer" {
            $serverInfo.PingComputer| Should -BeNullOrEmpty
            $assertMockParams = @{
                'CommandName' = 'Test-Connection'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have the right results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation[0].Name | Should -Be 'C:\'
            $serverInfo.DiskAllocation[0].isBestPractice| Should -BeFalse
            $serverInfo.DiskAllocation[0].isSqlDisk| Should -BeTrue

            $assertMockParams = @{
                'CommandName' = 'Test-DbaDiskAllocation'
                'Times'       = 1
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have no results results for PowerPlan" {
            $serverInfo.PowerPlan | Should -BeNullOrEmpty
        }
        It "Should have no results for SPN" {
            $serverInfo.SPNs | Should -BeNullOrEmpty
            $assertMockParams = @{
                'CommandName' = 'Test-DbaSPN'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have no results for DiskCapacity" {
            $serverInfo.DiskSpace | Should -BeNullOrEmpty
            $assertMockParams = @{
                'CommandName' = 'Get-DbaDiskSpace'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }

    Context "Testing Get-AllServerInfo for Tags DiskAllocationUnit with a server that doesn't exist" {
        Mock Test-Connection {}

        Mock Test-DbaDiskAllocation {Throw}

        Mock Test-DbaPowerPlan {}

        Mock Test-DbaSpn {}

        Mock Get-DbaDiskSpace {}

        $tags = 'DiskAllocationUnit'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should have no results for PingComputer" {
            $serverInfo.PingComputer| Should -BeNullOrEmpty
        }
        It "Should have the right results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation[0].Name | Should -Be '? '  # Yes there is a space for formatting the PowerBi
            $serverInfo.DiskAllocation[0].isBestPractice| Should -BeFalse
            $serverInfo.DiskAllocation[0].isSqlDisk| Should -BeTrue
        }
        It "Should have no results for PowerPlan" {
            $serverInfo.PowerPlan | Should -BeNullOrEmpty
        }
        It "Should have no results for SPN" {
            $serverInfo.SPNs | Should -BeNullOrEmpty
        }
        It "Should have no results for DiskCapacity" {
            $serverInfo.DiskSpace | Should -BeNullOrEmpty
        }
    }

    Context "Testing Get-AllServerInfo for Tags SPN with a server that exists" {

        Mock Test-Connection { }

        Mock Test-DbaDiskAllocation { }

        Mock Test-DbaSpn {
            @(
                [PSObject]@{
                    'Cluster'                = $False
                    'ComputerName'           = 'DummyServer'
                    'Credential'             = $Null
                    'DynamicPort'            = $False
                    'Error'                  = 'SPN missing'
                    'InstanceName'           = 'MSSQLSERVER'
                    'InstanceServiceAccount' = 'Domain\Account'
                    'IsSet'                  = $False
                    'Port'                   = $Null
                    'RequiredSPN'            = 'MSSQLSvc/DummyServer'
                    'SqlProduct'             = 'SQL Server 2017 Enterprise Edition: Core-based Licensing (64-bit)'
                    'TcpEnabled'             = $True
                    'Warning'                = 'None'
                },
                [PSObject]@{
                    'Cluster'                = $False
                    'ComputerName'           = 'DummyServer'
                    'Credential'             = $Null
                    'DynamicPort'            = $False
                    'Error'                  = 'SPN missing'
                    'InstanceName'           = 'NoneDefaultInstance'
                    'InstanceServiceAccount' = 'Domain\Account'
                    'IsSet'                  = $False
                    'Port'                   = $Null
                    'RequiredSPN'            = 'MSSQLSvc/DummyServer:NoneDefaultInstance'
                    'SqlProduct'             = 'SQL Server 2016 Enterprise Edition: Core-based Licensing (64-bit)'
                    'TcpEnabled'             = $True
                    'Warning'                = 'None'
                },
                [PSObject]@{
                    'Cluster'                = $False
                    'ComputerName'           = 'DummyServer'
                    'Credential'             = $Null
                    'DynamicPort'            = $False
                    'Error'                  = 'SPN missing'
                    'InstanceName'           = 'MSSQLSERVER'
                    'InstanceServiceAccount' = 'Domain\Account'
                    'IsSet'                  = $False
                    'Port'                   = '1433'
                    'RequiredSPN'            = 'MSSQLSvc/DummyServer:1433'
                    'SqlProduct'             = 'SQL Server 2017 Enterprise Edition: Core-based Licensing (64-bit)'
                    'TcpEnabled'             = $True
                    'Warning'                = 'None'
                },
                [PSObject]@{
                    'Cluster'                = $False
                    'ComputerName'           = 'DummyServer'
                    'Credential'             = $Null
                    'DynamicPort'            = $False
                    'Error'                  = 'SPN missing'
                    'InstanceName'           = 'NoneDefaultInstance'
                    'InstanceServiceAccount' = 'Domain\Account'
                    'IsSet'                  = $False
                    'Port'                   = '1437'
                    'RequiredSPN'            = 'MSSQLSvc/DummyServer:1437'
                    'SqlProduct'             = 'SQL Server 2016 Enterprise Edition: Core-based Licensing (64-bit)'
                    'TcpEnabled'             = $True
                    'Warning'                = 'None'
                }
            )
        }

        Mock Get-DbaDiskSpace {}

        $tags = 'SPN'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should have no results for PingComputer" {
            $serverInfo.PingComputer| Should -BeNullOrEmpty
            $assertMockParams = @{
                'CommandName' = 'Test-Connection'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have no results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation | Should -BeNullOrEmpty

            $assertMockParams = @{
                'CommandName' = 'Test-DbaDiskAllocation'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have no results results for PowerPlan" {
            $serverInfo.PowerPlan | Should -BeNullOrEmpty
        }
        It "Should have the right results for SPN" {
            $serverInfo.SPNs[0].ComputerName | Should -Be 'DummyServer'
            $serverInfo.SPNs[0].Error | Should -Be 'SPN missing'
            $serverInfo.SPNs[0].RequiredSPN | Should -Be 'MSSQLSvc/DummyServer'

            $assertMockParams = @{
                'CommandName' = 'Test-DbaSPN'
                'Times'       = 1
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have no results for DiskCapacity" {
            $serverInfo.DiskSpace | Should -BeNullOrEmpty
            $assertMockParams = @{
                'CommandName' = 'Get-DbaDiskSpace'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }

    Context "Testing Get-AllServerInfo for Tags SPN with a server that doesn't exist" {
        Mock Test-Connection {}

        Mock Test-DbaDiskAllocation {}

        Mock Test-DbaPowerPlan {}

        Mock Test-DbaSpn {Throw}

        Mock Get-DbaDiskSpace {}

        $tags = 'SPN'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should have no results for PingComputer" {
            $serverInfo.PingComputer| Should -BeNullOrEmpty
        }
        It "Should have no results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation| Should -BeNullOrEmpty
        }
        It "Should have no results for PowerPlan" {
            $serverInfo.PowerPlan | Should -BeNullOrEmpty
        }
        It "Should have the right results for SPN" {
            $serverInfo.SPNs[0].Error | Should -Be 'An Error occurred'
            $serverInfo.SPNs[0].RequiredSPN | Should -Be 'Dont know the SPN'
        }
        It "Should have no results for DiskCapacity" {
            $serverInfo.DiskSpace | Should -BeNullOrEmpty
        }
    }

    Context "Testing Get-AllServerInfo for Tags DiskCapacity with a server that exists" {

        Mock Test-Connection { }

        Mock Test-DbaDiskAllocation { }

        Mock Test-DbaSpn { }

        Mock Get-DbaDiskSpace {
            @(
                [PSObject]@{
                    'BlockSize'    = 4096
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 42355126272
                        'Digits'   = 2
                        'Gigabyte' = 39.4462852478027
                        'Kilobyte' = 41362428
                        'Megabyte' = 40392.99609375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0385217629373074
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 19814010880
                        'Digits'   = 2
                        'Gigabyte' = 18.4532356262207
                        'Kilobyte' = 19349620
                        'Megabyte' = 18896.11328125
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0180207379162312
                    }
                    'FreeInBytes'  = 19814010880
                    'FreeInGB'     = 18.45
                    'FreeInKB'     = 19349620
                    'FreeInMB'     = 18896.11
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.02
                    'IsSqlDisk'    = $Null
                    'Label'        = ''
                    'Name'         = 'C:\'
                    'PercentFree'  = 46.78
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 42355126272
                    'SizeInGB'     = 39.45
                    'SizeInKB'     = 41362428
                    'SizeInMB'     = 40393
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.04
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                },
                [PSObject]@{
                    'BlockSize'    = 65536
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 153408700416
                        'Digits'   = 2
                        'Gigabyte' = 142.872985839844
                        'Kilobyte' = 149813184
                        'Megabyte' = 146301.9375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.139524400234222
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 82363809792
                        'Digits'   = 2
                        'Gigabyte' = 76.707275390625
                        'Kilobyte' = 80433408
                        'Megabyte' = 78548.25
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0749094486236572
                    }
                    'FreeInBytes'  = 82363809792
                    'FreeInGB'     = 76.71
                    'FreeInKB'     = 80433408
                    'FreeInMB'     = 78548.25
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.07
                    'IsSqlDisk'    = $Null
                    'Label'        = 'SQL Logs'
                    'Name'         = 'L:\'
                    'PercentFree'  = 53.69
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 153408700416
                    'SizeInGB'     = 142.87
                    'SizeInKB'     = 149813184
                    'SizeInMB'     = 146301.94
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.14
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                },
                [PSObject]@{
                    'BlockSize'    = 65536
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 382116757504
                        'Digits'   = 2
                        'Gigabyte' = 355.873962402344
                        'Kilobyte' = 373160896
                        'Megabyte' = 364414.9375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.347533166408539
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 84496482304
                        'Digits'   = 2
                        'Gigabyte' = 78.6934814453125
                        'Kilobyte' = 82516096
                        'Megabyte' = 80582.125
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.076849102973938
                    }
                    'FreeInBytes'  = 84496482304
                    'FreeInGB'     = 78.69
                    'FreeInKB'     = 82516096
                    'FreeInMB'     = 80582.12
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.08
                    'IsSqlDisk'    = $Null
                    'Label'        = 'SQL Performance'
                    'Name'         = 'P:\'
                    'PercentFree'  = 22.11
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 382116757504
                    'SizeInGB'     = 355.87
                    'SizeInKB'     = 373160896
                    'SizeInMB'     = 364414.94
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.35
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                },
                [PSObject]@{
                    'BlockSize'    = 65536
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 42813292544
                        'Digits'   = 2
                        'Gigabyte' = 39.8729858398438
                        'Kilobyte' = 41809856
                        'Megabyte' = 40829.9375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0389384627342224
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 42719117312
                        'Digits'   = 2
                        'Gigabyte' = 39.7852783203125
                        'Kilobyte' = 41717888
                        'Megabyte' = 40740.125
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0388528108596802
                    }
                    'FreeInBytes'  = 42719117312
                    'FreeInGB'     = 39.79
                    'FreeInKB'     = 41717888
                    'FreeInMB'     = 40740.12
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.04
                    'IsSqlDisk'    = $Null
                    'Label'        = 'Archive Data (SLOW!)'
                    'Name'         = 'F:\'
                    'PercentFree'  = 99.78
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 42813292544
                    'SizeInGB'     = 39.87
                    'SizeInKB'     = 41809856
                    'SizeInMB'     = 40829.94
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.04
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                },
                [PSObject]@{
                    'BlockSize'    = 65536
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 580757946368
                        'Digits'   = 2
                        'Gigabyte' = 540.872985839844
                        'Kilobyte' = 567146432
                        'Megabyte' = 553853.9375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.528196275234222
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 580605968384
                        'Digits'   = 2
                        'Gigabyte' = 540.7314453125
                        'Kilobyte' = 566998016
                        'Megabyte' = 553709
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.528058052062988
                    }
                    'FreeInBytes'  = 580605968384
                    'FreeInGB'     = 540.73
                    'FreeInKB'     = 566998016
                    'FreeInMB'     = 553709
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.53
                    'IsSqlDisk'    = $Null
                    'Label'        = 'SQL Data'
                    'Name'         = 'D:\'
                    'PercentFree'  = 99.97
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 580757946368
                    'SizeInGB'     = 540.87
                    'SizeInKB'     = 567146432
                    'SizeInMB'     = 553853.94
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.53
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                }
            )

        }

        $tags = 'DiskCapacity'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should have no results for PingComputer" {
            $serverInfo.PingComputer| Should -BeNullOrEmpty
            $assertMockParams = @{
                'CommandName' = 'Test-Connection'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have no results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation | Should -BeNullOrEmpty

            $assertMockParams = @{
                'CommandName' = 'Test-DbaDiskAllocation'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have no results results for PowerPlan" {
            $serverInfo.PowerPlan | Should -BeNullOrEmpty
        }
        It "Should have no results for SPN" {
            $serverInfo.SPNs|Should -BeNullOrEmpty
            $assertMockParams = @{
                'CommandName' = 'Test-DbaSPN'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should have the right results for DiskCapacity" {
            $serverInfo.DiskSpace[0].ComputerName | Should -Be 'DummyServer'
            $serverInfo.DiskSpace[0].Name | Should -Be 'C:\'
            $serverInfo.DiskSpace[0].PercentFree | Should -Be 46.78
            $assertMockParams = @{
                'CommandName' = 'Get-DbaDiskSpace'
                'Times'       = 1
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
    }

    Context "Testing Get-AllServerInfo for Tags DiskCapacity with a server that doesn't exist" {
        Mock Test-Connection {}

        Mock Test-DbaDiskAllocation {}

        Mock Test-DbaPowerPlan {}

        Mock Test-DbaSpn {}

        Mock Get-DbaDiskSpace {Throw}

        $tags = 'DiskCapacity'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should have no results for PingComputer" {
            $serverInfo.PingComputer| Should -BeNullOrEmpty
        }
        It "Should have no results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation| Should -BeNullOrEmpty
        }
        It "Should have no results for PowerPlan" {
            $serverInfo.PowerPlan | Should -BeNullOrEmpty
        }
        It "Should have no results for SPN" {
            $serverInfo.SPNs| Should -BeNullOrEmpty
        }
        It "Should have the right results for DiskCapacity" {
            $serverInfo.DiskSpace.ComputerName| Should -Be 'An Error occurred Dummy'
            $serverInfo.DiskSpace.Name | Should -Be 'Do not know the Name'
            $serverInfo.DiskSpace.PercentFree | Should -Be -1
        }
    }

    Context "Testing Get-AllServerInfo for Tags DiskCapacity,SPN,DiskAllocationUnit with a server that exists" {

        Mock Test-Connection { }

        Mock Test-DbaDiskAllocation {
            @(
                [PSObject]@{
                    'BlockSize'      = 4096
                    'IsBestPractice' = $False
                    'IsSqlDisk'      = $True
                    'Label'          = $Null
                    'Name'           = 'C:\'
                    'Server'         = 'DummyServer'
                },
                [PSObject]@{
                    'BlockSize'      = 65536
                    'IsBestPractice' = $True
                    'IsSqlDisk'      = $True
                    'Label'          = 'SQL Data'
                    'Name'           = 'D:\'
                    'Server'         = 'DummyServer'
                },
                [PSObject]@{
                    'BlockSize'      = 65536
                    'IsBestPractice' = $True
                    'IsSqlDisk'      = $False
                    'Label'          = 'SQL Archive'
                    'Name'           = 'F:\'
                    'Server'         = 'DummyServer'
                },
                [PSObject]@{
                    'BlockSize'      = 65536
                    'IsBestPractice' = $True
                    'IsSqlDisk'      = $True
                    'Label'          = 'SQL Logs'
                    'Name'           = 'L:\'
                    'Server'         = 'DummyServer'
                },
                [PSObject]@{
                    'BlockSize'      = 65536
                    'IsBestPractice' = $True
                    'IsSqlDisk'      = $True
                    'Label'          = 'SQL Performance'
                    'Name'           = 'P:\'
                    'Server'         = 'DummyServer'
                }
            )
        }

        Mock Test-DbaSpn {
            @(
                [PSObject]@{
                    'Cluster'                = $False
                    'ComputerName'           = 'DummyServer'
                    'Credential'             = $Null
                    'DynamicPort'            = $False
                    'Error'                  = 'SPN missing'
                    'InstanceName'           = 'MSSQLSERVER'
                    'InstanceServiceAccount' = 'Domain\Account'
                    'IsSet'                  = $False
                    'Port'                   = $Null
                    'RequiredSPN'            = 'MSSQLSvc/DummyServer'
                    'SqlProduct'             = 'SQL Server 2017 Enterprise Edition: Core-based Licensing (64-bit)'
                    'TcpEnabled'             = $True
                    'Warning'                = 'None'
                },
                [PSObject]@{
                    'Cluster'                = $False
                    'ComputerName'           = 'DummyServer'
                    'Credential'             = $Null
                    'DynamicPort'            = $False
                    'Error'                  = 'SPN missing'
                    'InstanceName'           = 'NoneDefaultInstance'
                    'InstanceServiceAccount' = 'Domain\Account'
                    'IsSet'                  = $False
                    'Port'                   = $Null
                    'RequiredSPN'            = 'MSSQLSvc/DummyServer:NoneDefaultInstance'
                    'SqlProduct'             = 'SQL Server 2016 Enterprise Edition: Core-based Licensing (64-bit)'
                    'TcpEnabled'             = $True
                    'Warning'                = 'None'
                },
                [PSObject]@{
                    'Cluster'                = $False
                    'ComputerName'           = 'DummyServer'
                    'Credential'             = $Null
                    'DynamicPort'            = $False
                    'Error'                  = 'SPN missing'
                    'InstanceName'           = 'MSSQLSERVER'
                    'InstanceServiceAccount' = 'Domain\Account'
                    'IsSet'                  = $False
                    'Port'                   = '1433'
                    'RequiredSPN'            = 'MSSQLSvc/DummyServer:1433'
                    'SqlProduct'             = 'SQL Server 2017 Enterprise Edition: Core-based Licensing (64-bit)'
                    'TcpEnabled'             = $True
                    'Warning'                = 'None'
                },
                [PSObject]@{
                    'Cluster'                = $False
                    'ComputerName'           = 'DummyServer'
                    'Credential'             = $Null
                    'DynamicPort'            = $False
                    'Error'                  = 'SPN missing'
                    'InstanceName'           = 'NoneDefaultInstance'
                    'InstanceServiceAccount' = 'Domain\Account'
                    'IsSet'                  = $False
                    'Port'                   = '1437'
                    'RequiredSPN'            = 'MSSQLSvc/DummyServer:1437'
                    'SqlProduct'             = 'SQL Server 2016 Enterprise Edition: Core-based Licensing (64-bit)'
                    'TcpEnabled'             = $True
                    'Warning'                = 'None'
                }
            )

        }

        Mock Get-DbaDiskSpace {
            @(
                [PSObject]@{
                    'BlockSize'    = 4096
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 42355126272
                        'Digits'   = 2
                        'Gigabyte' = 39.4462852478027
                        'Kilobyte' = 41362428
                        'Megabyte' = 40392.99609375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0385217629373074
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 19814010880
                        'Digits'   = 2
                        'Gigabyte' = 18.4532356262207
                        'Kilobyte' = 19349620
                        'Megabyte' = 18896.11328125
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0180207379162312
                    }
                    'FreeInBytes'  = 19814010880
                    'FreeInGB'     = 18.45
                    'FreeInKB'     = 19349620
                    'FreeInMB'     = 18896.11
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.02
                    'IsSqlDisk'    = $Null
                    'Label'        = ''
                    'Name'         = 'C:\'
                    'PercentFree'  = 46.78
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 42355126272
                    'SizeInGB'     = 39.45
                    'SizeInKB'     = 41362428
                    'SizeInMB'     = 40393
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.04
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                },
                [PSObject]@{
                    'BlockSize'    = 65536
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 153408700416
                        'Digits'   = 2
                        'Gigabyte' = 142.872985839844
                        'Kilobyte' = 149813184
                        'Megabyte' = 146301.9375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.139524400234222
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 82363809792
                        'Digits'   = 2
                        'Gigabyte' = 76.707275390625
                        'Kilobyte' = 80433408
                        'Megabyte' = 78548.25
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0749094486236572
                    }
                    'FreeInBytes'  = 82363809792
                    'FreeInGB'     = 76.71
                    'FreeInKB'     = 80433408
                    'FreeInMB'     = 78548.25
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.07
                    'IsSqlDisk'    = $Null
                    'Label'        = 'SQL Logs'
                    'Name'         = 'L:\'
                    'PercentFree'  = 53.69
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 153408700416
                    'SizeInGB'     = 142.87
                    'SizeInKB'     = 149813184
                    'SizeInMB'     = 146301.94
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.14
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                },
                [PSObject]@{
                    'BlockSize'    = 65536
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 382116757504
                        'Digits'   = 2
                        'Gigabyte' = 355.873962402344
                        'Kilobyte' = 373160896
                        'Megabyte' = 364414.9375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.347533166408539
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 84496482304
                        'Digits'   = 2
                        'Gigabyte' = 78.6934814453125
                        'Kilobyte' = 82516096
                        'Megabyte' = 80582.125
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.076849102973938
                    }
                    'FreeInBytes'  = 84496482304
                    'FreeInGB'     = 78.69
                    'FreeInKB'     = 82516096
                    'FreeInMB'     = 80582.12
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.08
                    'IsSqlDisk'    = $Null
                    'Label'        = 'SQL Performance'
                    'Name'         = 'P:\'
                    'PercentFree'  = 22.11
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 382116757504
                    'SizeInGB'     = 355.87
                    'SizeInKB'     = 373160896
                    'SizeInMB'     = 364414.94
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.35
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                },
                [PSObject]@{
                    'BlockSize'    = 65536
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 42813292544
                        'Digits'   = 2
                        'Gigabyte' = 39.8729858398438
                        'Kilobyte' = 41809856
                        'Megabyte' = 40829.9375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0389384627342224
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 42719117312
                        'Digits'   = 2
                        'Gigabyte' = 39.7852783203125
                        'Kilobyte' = 41717888
                        'Megabyte' = 40740.125
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.0388528108596802
                    }
                    'FreeInBytes'  = 42719117312
                    'FreeInGB'     = 39.79
                    'FreeInKB'     = 41717888
                    'FreeInMB'     = 40740.12
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.04
                    'IsSqlDisk'    = $Null
                    'Label'        = 'Archive Data (SLOW!)'
                    'Name'         = 'F:\'
                    'PercentFree'  = 99.78
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 42813292544
                    'SizeInGB'     = 39.87
                    'SizeInKB'     = 41809856
                    'SizeInMB'     = 40829.94
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.04
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                },
                [PSObject]@{
                    'BlockSize'    = 65536
                    'Capacity'     = [PSObject]@{
                        'Byte'     = 580757946368
                        'Digits'   = 2
                        'Gigabyte' = 540.872985839844
                        'Kilobyte' = 567146432
                        'Megabyte' = 553853.9375
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.528196275234222
                    }
                    'ComputerName' = 'DummyServer'
                    'DriveType'    = 'Local Disk'
                    'FileSystem'   = 'NTFS'
                    'Free'         = [PSObject]@{
                        'Byte'     = 580605968384
                        'Digits'   = 2
                        'Gigabyte' = 540.7314453125
                        'Kilobyte' = 566998016
                        'Megabyte' = 553709
                        'Style'    = [Sqlcollaborative.Dbatools.Utility.SizeStyle]'Dynamic'
                        'Terabyte' = 0.528058052062988
                    }
                    'FreeInBytes'  = 580605968384
                    'FreeInGB'     = 540.73
                    'FreeInKB'     = 566998016
                    'FreeInMB'     = 553709
                    'FreeInPB'     = 0
                    'FreeInTB'     = 0.53
                    'IsSqlDisk'    = $Null
                    'Label'        = 'SQL Data'
                    'Name'         = 'D:\'
                    'PercentFree'  = 99.97
                    'Server'       = 'DummyServer'
                    'SizeInBytes'  = 580757946368
                    'SizeInGB'     = 540.87
                    'SizeInKB'     = 567146432
                    'SizeInMB'     = 553853.94
                    'SizeInPB'     = 0
                    'SizeInTB'     = 0.53
                    'Type'         = [Sqlcollaborative.Dbatools.Computer.DriveType]'LocalDisk'
                }
            )

        }


        $tags = 'DiskCapacity', 'SPN', 'DiskAllocationUnit'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should have no results for PingComputer" {
            $serverInfo.PingComputer| Should -BeNullOrEmpty
            $assertMockParams = @{
                'CommandName' = 'Test-Connection'
                'Times'       = 0
                'Exactly'     = $true
            }
            Assert-MockCalled @assertMockParams
        }
        It "Should get the right results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation[0].Name | Should -Be 'C:\'
            $serverInfo.DiskAllocation[0].isBestPractice| Should -BeFalse
            $serverInfo.DiskAllocation[0].isSqlDisk| Should -BeTrue
        }
        It "Should have no results results for PowerPlan" {
            $serverInfo.PowerPlan | Should -BeNullOrEmpty
        }
        It "Should get the right results for SPN" {
            $serverInfo.SPNs[0].ComputerName | Should -Be 'DummyServer'
            $serverInfo.SPNs[0].Error | Should -Be 'SPN missing'
            $serverInfo.SPNs[0].RequiredSPN | Should -Be 'MSSQLSvc/DummyServer'
        }
        It "Should have the right results for DiskCapacity" {
            $serverInfo.DiskSpace[0].ComputerName | Should -Be 'DummyServer'
            $serverInfo.DiskSpace[0].Name | Should -Be 'C:\'
            $serverInfo.DiskSpace[0].PercentFree | Should -Be 46.78
        }
    }
    Context "Testing Get-AllServerInfo for Tags DiskCapacity,SPN,DiskAllocationUnit with a server that doesn't exist" {
        Mock Test-Connection {}

        Mock Test-DbaDiskAllocation {Throw}

        Mock Test-DbaPowerPlan {}

        Mock Test-DbaSpn {Throw}

        Mock Get-DbaDiskSpace {Throw}

        $tags = 'DiskCapacity', 'SPN', 'DiskAllocationUnit'

        $ServerInfo = Get-AllServerInfo -ComputerName Dummy -Tags $tags
        It "Should have no results for PingComputer" {
            $serverInfo.PingComputer| Should -BeNullOrEmpty
        }
        It "Should get the right results for DiskAllocationUnit" {
            $serverInfo.DiskAllocation[0].Name | Should -Be '? '  # Yes there is a space for formatting the PowerBi
            $serverInfo.DiskAllocation[0].isBestPractice| Should -BeFalse
            $serverInfo.DiskAllocation[0].isSqlDisk| Should -BeTrue
        }
        It "Should have no results for PowerPlan" {
            $serverInfo.PowerPlan | Should -BeNullOrEmpty
        }
        It "Should get the right results for SPN" {
            $serverInfo.SPNs[0].Error | Should -Be 'An Error occurred'
            $serverInfo.SPNs[0].RequiredSPN | Should -Be 'Dont know the SPN'
        }
        It "Should have the right results for DiskCapacity" {
            $serverInfo.DiskSpace.ComputerName| Should -Be 'An Error occurred Dummy'
            $serverInfo.DiskSpace.Name | Should -Be 'Do not know the Name'
            $serverInfo.DiskSpace.PercentFree | Should -Be -1
        }
    }

}
# SIG # Begin signature block
# MIINEAYJKoZIhvcNAQcCoIINATCCDP0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUL01THUaCV9L44n0ZH2D2uzfl
# cN6gggpSMIIFGjCCBAKgAwIBAgIQAsF1KHTVwoQxhSrYoGRpyjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTH7zwJAi7gLC7ht/hzywWrAI8H
# cDANBgkqhkiG9w0BAQEFAASCAQA7vsLJAEpmYk85S0thhFFsVVMBVLC1dWqUxjkG
# uy/xOG1cpn0yuHjYvil/CaLcXt1N+paOl0iLk1kI165x+OZ2BC9zw8gbAg/+J/YG
# 0c0GUOxl03d4ZrqnGapviKWYbPpbADS3UIk5MzdM10g50VTk6ODrQDaJWOZJZ2nS
# CMJZ9xb7pGVtFYnv6uhK3nv3BquRsyGnRGLSZlBFUQ3GCs535GFkWoyniXuua8Gq
# rNgI9B5pds9sPJTpMz1OXEgRGbVzI69OIdL39uERVdRIAvETFtAABjs24zQ8R9G6
# zgjk/thuvbppWavKt8dq691e5ka/NpFN+tgTIZez5zHTCl7c
# SIG # End signature block
