function Get-DatabaseInfo {
    param (
        [DbaInstanceParameter[]]$SqlInstance
    )
    begin {
        if (!(test-path variable:script:results)) {
            $script:results = @{}
        }
    }
    process {
        foreach ($instance in $SqlInstance) {
            try {
                if (!($script:results.ContainsKey($instance))) {
                    $server = Connect-DbaInstance -SqlInstance $instance -SqlCredential $sqlcredential

                    $dbs = $server.Query("
select d.name                           [Database]
    ,d.collation_name                   DatabaseCollation
    ,suser_sname(d.owner_sid)           Owner
    ,d.recovery_model_desc              RecoveryModel
    ,d.is_auto_close_on                 AutoClose
    ,d.is_auto_create_stats_on          AutoCreateStatistics
    ,d.is_auto_shrink_on                AutoShrink
    ,d.is_auto_update_stats_on          AutoUpdateStatistics
    ,d.is_auto_update_stats_async_on    AutoUpdateStatisticsAsynchronously
    ,d.page_verify_option_desc          PageVerify
    ,isnull((select count(*) from msdb..suspect_pages sp where sp.database_id = d.database_id and event_type in (1,2,3)),0) SuspectPages
    ,d.state_desc                       Status
    ,d.is_trustworthy_on                Trustworthy   
    ,d.compatibility_level              CompatibilityLevel
    ,d.user_access_desc                 UserAccess
    ,d.is_read_only                     IsReadOnly
    ,(	select count(*) 
		from sys.master_files
		where database_id = d.database_id 
			and [type] = 0
			and differential_base_lsn is null
	)                                   DataFilesWithoutBackup
from sys.databases d
$(if($Database) { "where name like '$($Database.Replace("*","%"))'"})
                                        ")

                    foreach($db in $dbs) {
                        $db | Add-Member -Force -MemberType NoteProperty -Name InstanceCollation -Value $server.Collation
                        $db | Add-Member -Force -MemberType NoteProperty -Name InstanceCompatibilityLevel -Value "$($server.VersionMajor)0"
                        $db | Add-Member -Force -MemberType NoteProperty -Name SqlInstance -Value $server.DomainInstanceName
                        $db | Add-Member -Force -MemberType NoteProperty -Name SqlVersion -Value $server.VersionMajor
                    }
                    
                    # make sure the -ExcludeDatabase of Invoke-DbcCheck is honoured
                    $script:results.Add($instance, $dbs.Where{($ExcludedDatabases -notcontains $PsItem.Database)})
                }

                return $script:results[$instance]
            }
            catch {
                throw
            }
        }
    }
}
