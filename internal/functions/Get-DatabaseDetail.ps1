function Get-DatabaseDetail {
    param (
        [DbaInstanceParameter[]]$SqlInstance,
        [object[]]$ExcludeDatabase
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
select quotename(d.name) [Database]
    ,d.collation_name                   DatabaseCollation
    ,suser_sname(d.owner_sid)           CurrentOwner
    ,d.recovery_model_desc              RecoveryModel
    ,d.is_auto_shrink_on                AutoShrink
    ,d.is_auto_close_on                 AutoClose
    ,d.is_auto_create_stats_on          AutoCreateStatisticsEnabled
    ,d.is_auto_update_stats_on          AutoUpdateStatisticsEnabled
    ,d.is_auto_update_stats_async_on    AutoUpdateStatisticsAsync
    ,d.is_trustworthy_on                Trustworthy
    ,d.page_verify_option_desc          PageVerify
    ,isnull((select count(*) from msdb..suspect_pages sp where sp.database_id = d.database_id and event_type in (1,2,3)),0) SuspectPages
    ,d.state_desc                       Status
    ,d.compatibility_level              CompatibilityLevel
    ,d.user_access_desc                 UserAccess
    ,d.is_read_only                     IsReadOnly
from sys.databases d
                                        ")

                    foreach($db in $dbs) {
                        $db | Add-Member -Force -MemberType NoteProperty -Name ServerCollation -Value $server.Collation
                        $db | Add-Member -Force -MemberType NoteProperty -Name SqlInstance -Value $server.DomainInstanceName
                        $db | Add-Member -Force -MemberType NoteProperty -Name SqlVersion -Value $server.VersionMajor
                    }
                    
                    $script:results.Add($instance, $dbs)
                }

                $server.DomainInstanceName
                $server.VersionMajor

                return $script:results[$instance] | Where-Object { $psitem.Database -notin $ExcludeDatabase -or !$ExcludeDatabase }
            }
            catch {
                throw
            }
        }
    }
}
