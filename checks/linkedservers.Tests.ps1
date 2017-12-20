$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Describe 'Testing Linked Servers' -Tag LinkedServer, Instance, $filename {
	(Get-SqlInstance).ForEach{
        Context "Testing $psitem" {
            $Results = Test-DbaLinkedServerConnection -SqlInstance $psitem 
            $Results.ForEach{
                It "Linked Server $($psitem.LinkedServerName) Should Be Connectable" {
                    $psitem.Connectivity | SHould be $True
                }
            }
        }
    }
}
