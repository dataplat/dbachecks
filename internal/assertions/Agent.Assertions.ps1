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
    $AgentServer.MaximumHistoryRows | Should -Be $minimumJobHistoryRows -Because "you choose to have it disabled."
}

function Assert-JobHistoryRows {
    param (
        $AgentServer,
        $minimumJobHistoryRows
    )
    $AgentServer.MaximumHistoryRows | Should -BeGreaterOrEqual $minimumJobHistoryRows -Because "It should be enough to keep a certain amount of history entries."
}

function Assert-JobHistoryRowsPerJob {
    param (
        $AgentServer,
        $minimumJobHistoryRowsPerJob
    )
    $AgentServer.MaximumJobHistoryRows | Should -BeGreaterOrEqual $minimumJobHistoryRowsPerJob -Because "It should be enough to keep a certain amount of history entries per job."
}
