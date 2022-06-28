[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Because this is just for testing and developing')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Because this is for the prompt and it is required')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'containers', Justification = 'Because it is a global variable used later')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'SQLInstances', Justification = 'Because it is a global variable used later')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'currentAccountName', Justification = 'Because silly script analyuser cant see it is used')]
[CmdletBinding()]
param()

Import-Module /workspace/containers/JessAndBeard.psm1
Import-Module dbatools
$VerbosePreference = 'Continue' # So we can see ALL of the verbose in the psm1 file if we need to!
Import-Module /workspace/dbachecks.psd1 -Verbose
$VerbosePreference = 'SilentlyContinue'

$containers = $SQLInstances = $dbachecks1, $dbachecks2 , $dbachecks3 = 'dbachecks1', 'dbachecks2', 'dbachecks3'
#region Set up connection
$securePassword = ('dbatools.IO' | ConvertTo-SecureString -AsPlainText -Force)
$containercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)


$Global:PSDefaultParameterValues = @{
    "*dba*:SqlCredential"            = $containercredential
    "*dba*:SourceSqlCredential"      = $containercredential
    "*dba*:DestinationSqlCredential" = $containercredential
    "*dba*:DestinationCredential"    = $containercredential
    "*dba*:PrimarySqlCredential"     = $containercredential
    "*dba*:SecondarySqlCredential"   = $containercredential
}
#endregion

Remove-Item '/var/opt/backups/dbachecks1' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '/shared' -Recurse -Force -ErrorAction SilentlyContinue
Import-Module Pansies
$ShallWePlayAGameSetting = Get-PSFConfigValue -Name JessAndBeard.shallweplayagame

# if ($Host.Name -eq 'ConsoleHost') {
#     if ($ShallWePlayAGameSetting ) {
#         Set-PSFConfig -Module JessAndBeard -Name shallweplayagame -Value $false
#         Start-Game
#     } else {
#         Get-Index
#     }
# }

######## POSH-GIT
# with props to https://bradwilson.io/blog/prompt/powershell
# ... Import-Module for posh-git here ...
Import-Module posh-git

# maybe we can add something here if we want a path?if (-not (Get-PSDrive -Name Git -ErrorAction SilentlyContinue)) {
# maybe we can add something here if we want a path?    $Error.Clear()
# maybe we can add something here if we want a path?    $null = New-PSDrive -Name Git -PSProvider FileSystem -Root $GitRoot
# maybe we can add something here if we want a path?}

$ShowError = $false
$ShowKube = $false
$ShowAzure = $false
$ShowAzureCli = $false
$ShowGit = $true
$ShowPath = $true
$ShowDate = $true
$ShowTime = $true
$ShowUser = $true
$ShowCountDown = $false
$CountDownMessage = "Set `$CountDownMessage and `$CountDownEndDate Rob"
$CountDownEndDate = 0
# Background colors

$GitPromptSettings.AfterStash.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.AfterStatus.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BeforeIndex.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BeforeStash.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BeforeStatus.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchAheadStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchBehindAndAheadStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchBehindStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchColor.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchGoneStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchIdenticalStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.DefaultColor.BackgroundColor = [ConsoleColor]::DarkCyan
$GitPromptSettings.DelimStatus.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.ErrorColor.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.IndexColor.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.LocalDefaultStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.LocalStagedStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.LocalWorkingStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.StashColor.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.WorkingColor.BackgroundColor = [ConsoleColor]::DarkGray


# Foreground colors

$GitPromptSettings.AfterStatus.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.BeforeStatus.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.BranchColor.ForegroundColor = [ConsoleColor]::White
$GitPromptSettings.BranchGoneStatusSymbol.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.BranchIdenticalStatusSymbol.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.DefaultColor.ForegroundColor = [ConsoleColor]::White
$GitPromptSettings.DelimStatus.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.IndexColor.ForegroundColor = [ConsoleColor]::Cyan
$GitPromptSettings.WorkingColor.ForegroundColor = [ConsoleColor]::Yellow
$GitPromptSettings.BranchBehindStatusSymbol.ForegroundColor = [ConsoleColor]::Black
$GitPromptSettings.LocalWorkingStatusSymbol.ForegroundColor = [ConsoleColor]::Black
# Prompt shape

$GitPromptSettings.AfterStatus.Text = " "
$GitPromptSettings.BeforeStatus.Text = "  "
$GitPromptSettings.BranchAheadStatusSymbol.Text = " "
$GitPromptSettings.BranchBehindStatusSymbol.Text = " "
$GitPromptSettings.BranchGoneStatusSymbol.Text = ""
$GitPromptSettings.BranchBehindAndAheadStatusSymbol.Text = ""
$GitPromptSettings.BranchIdenticalStatusSymbol.Text = ""
$GitPromptSettings.BranchUntrackedText = ""
$GitPromptSettings.DelimStatus.Text = " ॥"

$GitPromptSettings.EnableStashStatus = $false
$GitPromptSettings.ShowStatusWhenZero = $false

######## PROMPT

Set-Content Function:prompt {
    if ($ShowDate) {
        Write-Host " $(Get-Date -Format "ddd dd MMM HH:mm:ss")" -ForegroundColor Black -BackgroundColor DarkGray -NoNewline
    }

    # Reset the foreground color to default
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultColor.ForegroundColor

    if ($ShowUser) {
        Write-Host " " -NoNewline
        Write-Host "  " -NoNewline -BackgroundColor DarkYellow -ForegroundColor Black
        Write-Host  (whoami)  -NoNewline -BackgroundColor DarkYellow -ForegroundColor Black
    }
    # Write ERR for any PowerShell errors
    if ($ShowError) {
        if ($Error.Count -ne 0) {
            Write-Host " " -NoNewline
            Write-Host " $($Error.Count) ERR " -NoNewline -BackgroundColor DarkRed -ForegroundColor Yellow
            # $Error.Clear()
        }
    }

    # Write non-zero exit code from last launched process
    if ($LASTEXITCODE -ne "") {
        Write-Host " " -NoNewline
        Write-Host " x $LASTEXITCODE " -NoNewline -BackgroundColor DarkRed -ForegroundColor Yellow
        $LASTEXITCODE = ""
    }

    if ($ShowKube) {
        # Write the current kubectl context
        if ((Get-Command "kubectl" -ErrorAction Ignore) -ne $null) {
            $currentContext = (& kubectl config current-context 2> $null)
            $nodes = kubectl get nodes -o json | ConvertFrom-Json

            $nodename = ($nodes.items.metadata | Where-Object labels  -Like '*master*').name
            Write-Host " " -NoNewline
            Write-Host "" -NoNewline -BackgroundColor DarkGray -ForegroundColor Green
            #Write-Host " $currentContext " -NoNewLine -BackgroundColor DarkYellow -ForegroundColor Black
            Write-Host " $([char]27)[38;5;112;48;5;242m  $([char]27)[38;5;254m$currentContext - $nodename $([char]27)[0m" -NoNewline
        }
    }

    if ($ShowAzureCli) {
        # Write the current public cloud Azure CLI subscription
        # NOTE: You will need sed from somewhere (for example, from Git for Windows)
        if (Test-Path ~/.azure/clouds.config) {
            if ((Get-Command "sed" -ErrorAction Ignore) -ne $null) {
                $currentSub = & sed -nr "/^\[AzureCloud\]/ { :l /^subscription[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" ~/.azure/clouds.config
            } else {
                $file = Get-Content ~/.azure/clouds.config
                $currentSub = ([regex]::Matches($file, '^.*subscription\s=\s(.*)').Groups[1].Value).Trim()
            }
            if ($null -ne $currentSub) {
                $currentAccount = (Get-Content ~/.azure/azureProfile.json | ConvertFrom-Json).subscriptions | Where-Object { $_.id -eq $currentSub }
                if ($null -ne $currentAccount) {
                    Write-Host " " -NoNewline
                    Write-Host "" -NoNewline -BackgroundColor DarkCyan -ForegroundColor Yellow
                    $currentAccountName = ($currentAccount.Name.Split(' ') | ForEach-Object { $_[0..5] -join '' }) -join ' '
                    Write-Host "$([char]27)[38;5;227;48;5;30m  $([char]27)[38;5;254m$($currentAccount.name) $([char]27)[0m"  -NoNewline -BackgroundColor DarkBlue -ForegroundColor Yellow
                }
            }
        }
    }

    if ($ShowAzure) {
        $context = Get-AzContext
        Write-Host "$([char]27)[38;5;227;48;5;30m  $([char]27)[38;5;254m$($context.Account.Id) in $($context.subscription.name) $([char]27)[0m"  -NoNewline -BackgroundColor DarkBlue -ForegroundColor Yellow
    }
    if ($ShowGit) {
        # Write the current Git information
        if ((Get-Command "Get-GitDirectory" -ErrorAction Ignore) -ne $null) {
            if (Get-GitDirectory -ne $null) {
                Write-Host (Write-VcsStatus) -NoNewline
            }
        }
    }

    if ($ShowPath) {
        # Write the current directory, with home folder normalized to ~
        # $currentPath = (get-location).Path.replace($home, "~")
        # $idx = $currentPath.IndexOf("::")
        # if ($idx -gt -1) { $currentPath = $currentPath.Substring($idx + 2) }
        if ($IsLinux) {
            $currentPath = $($pwd.path.Split('/')[-2..-1] -join '/')
        } else {
            $currentPath = $($pwd.path.Split('\')[-2..-1] -join '\')
        }
        Write-Host " " -NoNewline
        Write-Host "$([char]27)[38;5;227;48;5;28m  $([char]27)[38;5;254m$currentPath $([char]27)[0m " -NoNewline -BackgroundColor DarkGreen -ForegroundColor Black

    }
    # Reset LASTEXITCODE so we don't show it over and over again
    $global:LASTEXITCODE = 0

    if ($ShowTime) {
        try {
            Write-Host " " -NoNewline
            $history = Get-History -ErrorAction Ignore
            if ($history) {
                if (([System.Management.Automation.PSTypeName]'Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty').Type) {
                    $timemessage = " " + ( [Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty]($history[-1].EndExecutionTime - $history[-1].StartExecutionTime))
                    Write-Host $timemessage -ForegroundColor DarkYellow -BackgroundColor DarkGray -NoNewline
                } else {
                    Write-Host " $([Math]::Round(($history[-1].EndExecutionTime - $history[-1].StartExecutionTime).TotalMilliseconds,2))" -ForegroundColor DarkYellow -BackgroundColor DarkGray  -NoNewline
                }
            }
            Write-Host " " -ForegroundColor DarkBlue -NoNewline
        } catch { "" }
    }
    # Write one + for each level of the pushd stack
    if ((Get-Location -Stack).Count -gt 0) {
        Write-Host " " -NoNewline
        Write-Host (("+" * ((Get-Location -Stack).Count))) -NoNewline -ForegroundColor Cyan
    }

    # Newline
    Write-Host ""

    if ($ShowCountDown) {
        $Date = Get-Date
        $Mins = ($CountDownEndDate - $Date).TotalMinutes
        Write-Host $CountDownMessage -ForegroundColor DarkGreen -NoNewline
        switch ($Mins) {
            { $_ -ge 30 } {
                $ToGo = [Math]::Round($mins, 1)
                $Time = $Date.ToShortTimeString()
                Write-Host " $Time $ToGo Mins to go" -ForegroundColor DarkGreen -NoNewline
            }
            { $_ -lt 30 -and $_ -gt 10 } {
                $ToGo = [Math]::Round($mins, 1)
                $Time = $Date.ToShortTimeString()
                Write-Host " $Time " -ForegroundColor DarkGreen -NoNewline
                Write-Host " $ToGo Mins to go" -ForegroundColor Yellow -NoNewline
            }
            { $_ -le 10 } {
                $ToGo = [Math]::Round($mins, 1)
                $Time = $Date.ToShortTimeString()
                Write-Host " $Time " -ForegroundColor DarkGreen -NoNewline
                Write-Host " $ToGo Mins to go" -ForegroundColor Red -BackgroundColor DarkYellow -NoNewline
            }
            Default { }
        }
        # Newline
        Write-Host ""
    }

    # Determine if the user is admin, so we color the prompt green or red
    $isAdmin = $false
    $isDesktop = ($PSVersionTable.PSEdition -eq "Desktop")

    if ($isDesktop -or $IsWindows) {
        $windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $windowsPrincipal = New-Object 'System.Security.Principal.WindowsPrincipal' $windowsIdentity
        $isAdmin = $windowsPrincipal.IsInRole("Administrators") -eq 1
    } else {
        $isAdmin = ((& id -u) -eq 0)
    }

    if ($isAdmin) { $color = $color = "`e[38;5;9;48;5;237m"; }
    else { $color = "`e[38;5;231;48;5;27m "; }


    # Write PS> for desktop PowerShell, pwsh> for PowerShell Core
    if ($isDesktop) {
        Write-Host " PS5>" -NoNewline -ForegroundColor $color
    } else {
        $version = $PSVersionTable.PSVersion.ToString()
        #Write-Host " pwsh $Version>" -NoNewLine -ForegroundColor $color
        Write-Host "$($color)pwsh $Version>" -NoNewline
    }

    # Always have to return something or else we get the default prompt
    return " "
}

function whatsmyip {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $clip
    )
    if ($clip) {
            (Invoke-WebRequest -Uri "http://ifconfig.me/ip").Content | Set-Clipboard
    } else {
            (Invoke-WebRequest -Uri "http://ifconfig.me/ip").Content
    }
}

