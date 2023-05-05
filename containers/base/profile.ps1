[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Because this is just for testing and developing')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Because this is for the prompt and it is required')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'containers', Justification = 'Because it is a global variable used later')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'SQLInstances', Justification = 'Because it is a global variable used later')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'currentAccountName', Justification = 'Because silly script analyuser cant see it is used')]
[CmdletBinding()]
param()

# Set these defaults for all future sessions on this machine
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true -Register
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false -Register

if (Test-Path /workspace/containers -ErrorAction SilentlyContinue) {
    Import-Module /workspace/containers/JessAndBeard.psm1
} else {
    Import-Module /workspaces/dbachecks/containers/JessAndBeard.psm1
}


Remove-Item '/var/opt/backups/dbachecks1' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '/shared' -Recurse -Force -ErrorAction SilentlyContinue
function Load-Profile {
    Import-Module posh-git
    # Import-Module oh-my-posh
    # Set-PoshPrompt -Theme atomic

    $env:POSH_THEMES_PATH = '~/.poshthemes'

    function global:Set-PoshPrompt {
        param(
            $theme
        )
        & oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\$theme.omp.json" | Invoke-Expression
    }
    # Create scriptblock that collects information and name it
    Register-PSFTeppScriptblock -Name "poshthemes" -ScriptBlock { Get-ChildItem $env:POSH_THEMES_PATH | Select-Object -ExpandProperty Name -Unique | ForEach-Object { $_ -replace '\.omp\.json$', '' } }
    #Assign scriptblock to function
    Register-PSFTeppArgumentCompleter -Command Set-PoshPrompt -Parameter theme -Name poshthemes
    $themes = @(
        'neko',
        'sonicboom_dark',
        'neko',
        'easy-term',
        'if_tea',
        'neko',
        'kushal'
        'nigfht-owl',
        'neko',
        'powerlevel10k_rainbow',
        'quick-term',
        'neko',
        'stelbent.minimal',
        'tokyo',
        'neko',
        'unicorn',
        'wholespace',
        'sonicboom_dark',
        'lambdageneration'
    )
    $global:__currentTheme = (Get-Random -InputObject $themes)
    function global:Get-CurrentPoshTheme { $__currentTheme }
    Set-PoshPrompt -Theme $__currentTheme

    if ($psstyle) {
        $psstyle.FileInfo.Directory = $psstyle.FileInfo.Executable = $psstyle.FileInfo.SymbolicLink = ""
        $PSStyle.FileInfo.Extension.Clear()
        $PSStyle.Formatting.TableHeader = ""
        $PsStyle.Formatting.FormatAccent = ""
    }
}
"Load-Profile for full profile"
function prompt {
    #Load-Profile
    "PS > "
}

function whatsmyip {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $clip
    )
    if ($clip) {
            (Invoke-WebRequest -Uri 'http://ifconfig.me/ip').Content | Set-Clipboard
    } else {
            (Invoke-WebRequest -Uri 'http://ifconfig.me/ip').Content
    }
}

function whatsmyip {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $clip
    )
    if ($clip) {
            (Invoke-WebRequest -Uri 'http://ifconfig.me/ip').Content | Set-Clipboard
    } else {
            (Invoke-WebRequest -Uri 'http://ifconfig.me/ip').Content
    }
}

