function Assert-DatabaseMailEnabled {
    param (
        $SQLInstance,
        $DatabaseMailEnabled
    )
   (Get-DbaSpConfigure -SqlInstance $SQLInstance -Name DatabaseMailEnabled).ConfiguredValue -eq 1 | Should -Be $DatabaseMailEnabled -Because 'The Database Mail XPs setting should be set correctly'
}

function Assert-JobHistoryRowsDisabled {
    param (
        $AgentServer,
        $minimumJobHistoryRows
    )
    $AgentServer.MaximumHistoryRows | Should -Be $minimumJobHistoryRows -Because "Maximum job history configuration should be disabled"
}

function Assert-JobHistoryRows {
    param (
        $AgentServer,
        $minimumJobHistoryRows
    )
    $AgentServer.MaximumHistoryRows | Should -BeGreaterOrEqual $minimumJobHistoryRows -Because "We expect the maximum job history row configuration to be greater than the configured setting $minimumJobHistoryRows"
}

function Assert-JobHistoryRowsPerJob {
    param (
        $AgentServer,
        $minimumJobHistoryRowsPerJob
    )
    $AgentServer.MaximumJobHistoryRows | Should -BeGreaterOrEqual $minimumJobHistoryRowsPerJob -Because "We expect the maximum job history row configuration per agent job to be greater than the configured setting $minimumJobHistoryRowsPerJob"
}
