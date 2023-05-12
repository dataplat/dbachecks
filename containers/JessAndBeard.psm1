# TODO remove all the training day code :-)
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Because this is just for testing and developing')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Because this is for the prompt and it is required')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'containers', Justification = 'Because it is a global variable used later')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'SQLInstances', Justification = 'Because it is a global variable used later')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'currentAccountName', Justification = 'Because silly script analyuser cant see it is used')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'v4code', Justification = 'Because silly script analyuser cant see it is used')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'v5code', Justification = 'Because silly script analyuser cant see it is used')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'originalCodeMessage', Justification = 'Because silly script analyuser cant see it is used')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'cred', Justification = 'Because silly script analyuser cant see it is used')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', 'Global:allofTheThings', Justification = 'Dont tell me what to do')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', 'Global:Italwaysis', Justification = 'Dont tell me what to do')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', 'Global:v4code', Justification = 'Dont tell me what to do')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', 'Global:v5code', Justification = 'Dont tell me what to do')]
[CmdletBinding()]
param()
#region words
$ShallWePLayAGame = @"

  _____ _           _ _  __          __    _____  _                           _____                     ___
 / ____| |         | | | \ \        / /   |  __ \| |                 /\      / ____|                   |__ \
| (___ | |__   __ _| | |  \ \  /\  / /__  | |__) | | __ _ _   _     /  \    | |  __  __ _ _ __ ___   ___  ) |
 \___ \| '_ \ / _` | | |   \ \/  \/ / _ \ |  ___/| |/ _` | | | |   / /\ \   | | |_ |/ _` | '_ ` _ \ / _ \/ /
 ____) | | | | (_| | | |    \  /\  /  __/ | |    | | (_| | |_| |  / ____ \  | |__| | (_| | | | | | |  __/_|
|_____/|_| |_|\__,_|_|_|     \/  \/ \___| |_|    |_|\__,_|\__, | /_/    \_\  \_____|\__,_|_| |_| |_|\___(_)
                                                           __/ |
                                                          |___/
"@
#ANSI Shadow https://patorjk.com/software/taag/#p=testall&f=Doom&t=Shall%20We%20Play%20A%20Game%3F
$ShallWePLayAGame = @"

 ███████╗██╗  ██╗ █████╗ ██╗     ██╗         ██╗    ██╗███████╗    ██████╗ ██╗      █████╗ ██╗   ██╗     █████╗      ██████╗  █████╗ ███╗   ███╗███████╗██████╗
 ██╔════╝██║  ██║██╔══██╗██║     ██║         ██║    ██║██╔════╝    ██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝    ██╔══██╗    ██╔════╝ ██╔══██╗████╗ ████║██╔════╝╚════██╗
 ███████╗███████║███████║██║     ██║         ██║ █╗ ██║█████╗      ██████╔╝██║     ███████║ ╚████╔╝     ███████║    ██║  ███╗███████║██╔████╔██║█████╗    ▄███╔╝
 ╚════██║██╔══██║██╔══██║██║     ██║         ██║███╗██║██╔══╝      ██╔═══╝ ██║     ██╔══██║  ╚██╔╝      ██╔══██║    ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝    ▀▀══╝
 ███████║██║  ██║██║  ██║███████╗███████╗    ╚███╔███╔╝███████╗    ██║     ███████╗██║  ██║   ██║       ██║  ██║    ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗  ██╗
 ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝     ╚══╝╚══╝ ╚══════╝    ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝       ╚═╝  ╚═╝     ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝  ╚═╝


"@

$OhNo1 = @"
 ██████  ██░ ██  ▄▄▄       ██▓     ██▓        █     █░▓█████     ██▓███   ██▓    ▄▄▄     ▓██   ██▓    ▄▄▄           ▄████  ▄▄▄       ███▄ ▄███▓▓█████
▒██    ▒ ▓██░ ██▒▒████▄    ▓██▒    ▓██▒       ▓█░ █ ░█░▓█   ▀    ▓██░  ██▒▓██▒   ▒████▄    ▒██  ██▒   ▒████▄        ██▒ ▀█▒▒████▄    ▓██▒▀█▀ ██▒▓█   ▀
░ ▓██▄   ▒██▀▀██░▒██  ▀█▄  ▒██░    ▒██░       ▒█░ █ ░█ ▒███      ▓██░ ██▓▒▒██░   ▒██  ▀█▄   ▒██ ██░   ▒██  ▀█▄     ▒██░▄▄▄░▒██  ▀█▄  ▓██    ▓██░▒███
  ▒   ██▒░▓█ ░██ ░██▄▄▄▄██ ▒██░    ▒██░       ░█░ █ ░█ ▒▓█  ▄    ▒██▄█▓▒ ▒▒██░   ░██▄▄▄▄██  ░ ▐██▓░   ░██▄▄▄▄██    ░▓█  ██▓░██▄▄▄▄██ ▒██    ▒██ ▒▓█  ▄
▒██████▒▒░▓█▒░██▓ ▓█   ▓██▒░██████▒░██████▒   ░░██▒██▓ ░▒████▒   ▒██▒ ░  ░░██████▒▓█   ▓██▒ ░ ██▒▓░    ▓█   ▓██▒   ░▒▓███▀▒ ▓█   ▓██▒▒██▒   ░██▒░▒████▒
▒ ▒▓▒ ▒ ░ ▒ ░░▒░▒ ▒▒   ▓▒█░░ ▒░▓  ░░ ▒░▓  ░   ░ ▓░▒ ▒  ░░ ▒░ ░   ▒▓▒░ ░  ░░ ▒░▓  ░▒▒   ▓▒█░  ██▒▒▒     ▒▒   ▓▒█░    ░▒   ▒  ▒▒   ▓▒█░░ ▒░   ░  ░░░ ▒░ ░
░ ░▒  ░ ░ ▒ ░▒░ ░  ▒   ▒▒ ░░ ░ ▒  ░░ ░ ▒  ░     ▒ ░ ░   ░ ░  ░   ░▒ ░     ░ ░ ▒  ░ ▒   ▒▒ ░▓██ ░▒░      ▒   ▒▒ ░     ░   ░   ▒   ▒▒ ░░  ░      ░ ░ ░  ░
░  ░  ░   ░  ░░ ░  ░   ▒     ░ ░     ░ ░        ░   ░     ░      ░░         ░ ░    ░   ▒   ▒ ▒ ░░       ░   ▒      ░ ░   ░   ░   ▒   ░      ░      ░
      ░   ░  ░  ░      ░  ░    ░  ░    ░  ░       ░       ░  ░                ░  ░     ░  ░░ ░              ░  ░         ░       ░  ░       ░      ░  ░
                                                                                           ░ ░
"@

$OhNo2 = @"

▄████  ▒█████   ▒█████  ▓█████▄     ▄▄▄▄ ▓██   ██▓▓█████
██▒ ▀█▒▒██▒  ██▒▒██▒  ██▒▒██▀ ██▌   ▓█████▄▒██  ██▒▓█   ▀
▒██░▄▄▄░▒██░  ██▒▒██░  ██▒░██   █▌   ▒██▒ ▄██▒██ ██░▒███
░▓█  ██▓▒██   ██░▒██   ██░░▓█▄   ▌   ▒██░█▀  ░ ▐██▓░▒▓█  ▄
░▒▓███▀▒░ ████▓▒░░ ████▓▒░░▒████▓    ░▓█  ▀█▓░ ██▒▓░░▒████▒
░▒   ▒ ░ ▒░▒░▒░ ░ ▒░▒░▒░  ▒▒▓  ▒    ░▒▓███▀▒ ██▒▒▒ ░░ ▒░ ░
 ░   ░   ░ ▒ ▒░   ░ ▒ ▒░  ░ ▒  ▒    ▒░▒   ░▓██ ░▒░  ░ ░  ░
░ ░   ░ ░ ░ ░ ▒  ░ ░ ░ ▒   ░ ░  ░     ░    ░▒ ▒ ░░     ░
     ░     ░ ░      ░ ░     ░        ░     ░ ░        ░  ░
                          ░               ░░ ░
▄▄▄█████▓ ██░ ██ ▓█████    ▓█████  ███▄    █ ▓█████▄
▓  ██▒ ▓▒▓██░ ██▒▓█   ▀    ▓█   ▀  ██ ▀█   █ ▒██▀ ██▌
▒ ▓██░ ▒░▒██▀▀██░▒███      ▒███   ▓██  ▀█ ██▒░██   █▌
░ ▓██▓ ░ ░▓█ ░██ ▒▓█  ▄    ▒▓█  ▄ ▓██▒  ▐▌██▒░▓█▄   ▌
 ▒██▒ ░ ░▓█▒░██▓░▒████▒   ░▒████▒▒██░   ▓██░░▒████▓
 ▒ ░░    ▒ ░░▒░▒░░ ▒░ ░   ░░ ▒░ ░░ ▒░   ▒ ▒  ▒▒▓  ▒
   ░     ▒ ░▒░ ░ ░ ░  ░    ░ ░  ░░ ░░   ░ ▒░ ░ ▒  ▒
 ░       ░  ░░ ░   ░         ░      ░   ░ ░  ░ ░  ░
         ░  ░  ░   ░  ░      ░  ░         ░    ░
                                             ░

"@
$ChooseYourgame = @"

 ██████ ██   ██  ██████   ██████  ███████ ███████     ██    ██  ██████  ██    ██ ██████       ██████   █████  ███    ███ ███████
██      ██   ██ ██    ██ ██    ██ ██      ██           ██  ██  ██    ██ ██    ██ ██   ██     ██       ██   ██ ████  ████ ██          ██
██      ███████ ██    ██ ██    ██ ███████ █████         ████   ██    ██ ██    ██ ██████      ██   ███ ███████ ██ ████ ██ █████          █████
██      ██   ██ ██    ██ ██    ██      ██ ██             ██    ██    ██ ██    ██ ██   ██     ██    ██ ██   ██ ██  ██  ██ ██          ██
 ██████ ██   ██  ██████   ██████  ███████ ███████        ██     ██████   ██████  ██   ██      ██████  ██   ██ ██      ██ ███████
"@
$wrongChoice = @"

 █     █░ ██▀███   ▒█████   ███▄    █   ▄████
▓█░ █ ░█░▓██ ▒ ██▒▒██▒  ██▒ ██ ▀█   █  ██▒ ▀█▒
▒█░ █ ░█ ▓██ ░▄█ ▒▒██░  ██▒▓██  ▀█ ██▒▒██░▄▄▄░
░█░ █ ░█ ▒██▀▀█▄  ▒██   ██░▓██▒  ▐▌██▒░▓█  ██▓
░░██▒██▓ ░██▓ ▒██▒░ ████▓▒░▒██░   ▓██░░▒▓███▀▒
░ ▓░▒ ▒  ░ ▒▓ ░▒▓░░ ▒░▒░▒░ ░ ▒░   ▒ ▒  ░▒   ▒
  ▒ ░ ░    ░▒ ░ ▒░  ░ ▒ ▒░ ░ ░░   ░ ▒░  ░   ░
  ░   ░    ░░   ░ ░ ░ ░ ▒     ░   ░ ░ ░ ░   ░
    ░       ░         ░ ░           ░       ░

 ▄████▄   ██░ ██  ▒█████   ██▓ ▄████▄  ▓█████
▒██▀ ▀█  ▓██░ ██▒▒██▒  ██▒▓██▒▒██▀ ▀█  ▓█   ▀
▒▓█    ▄ ▒██▀▀██░▒██░  ██▒▒██▒▒▓█    ▄ ▒███
▒▓▓▄ ▄██▒░▓█ ░██ ▒██   ██░░██░▒▓▓▄ ▄██▒▒▓█  ▄
▒ ▓███▀ ░░▓█▒░██▓░ ████▓▒░░██░▒ ▓███▀ ░░▒████▒
░ ░▒ ▒  ░ ▒ ░░▒░▒░ ▒░▒░▒░ ░▓  ░ ░▒ ▒  ░░░ ▒░ ░
  ░  ▒    ▒ ░▒░ ░  ░ ▒ ▒░  ▒ ░  ░  ▒    ░ ░  ░
░         ░  ░░ ░░ ░ ░ ▒   ▒ ░░           ░
░ ░       ░  ░  ░    ░ ░   ░  ░ ░         ░  ░
░                             ░
"@
$Global:allofTheThings = @"
 ▄▄▄       ██▓     ██▓        ▒█████    █████▒   ▄▄▄█████▓ ██░ ██ ▓█████
▒████▄    ▓██▒    ▓██▒       ▒██▒  ██▒▓██   ▒    ▓  ██▒ ▓▒▓██░ ██▒▓█   ▀
▒██  ▀█▄  ▒██░    ▒██░       ▒██░  ██▒▒████ ░    ▒ ▓██░ ▒░▒██▀▀██░▒███
░██▄▄▄▄██ ▒██░    ▒██░       ▒██   ██░░▓█▒  ░    ░ ▓██▓ ░ ░▓█ ░██ ▒▓█  ▄
 ▓█   ▓██▒░██████▒░██████▒   ░ ████▓▒░░▒█░         ▒██▒ ░ ░▓█▒░██▓░▒████▒
 ▒▒   ▓▒█░░ ▒░▓  ░░ ▒░▓  ░   ░ ▒░▒░▒░  ▒ ░         ▒ ░░    ▒ ░░▒░▒░░ ▒░ ░
  ▒   ▒▒ ░░ ░ ▒  ░░ ░ ▒  ░     ░ ▒ ▒░  ░             ░     ▒ ░▒░ ░ ░ ░  ░
  ░   ▒     ░ ░     ░ ░      ░ ░ ░ ▒   ░ ░         ░       ░  ░░ ░   ░
      ░  ░    ░  ░    ░  ░       ░ ░                       ░  ░  ░   ░  ░

            ▄▄▄█████▓ ██░ ██  ██▓ ███▄    █   ▄████   ██████
            ▓  ██▒ ▓▒▓██░ ██▒▓██▒ ██ ▀█   █  ██▒ ▀█▒▒██    ▒
            ▒ ▓██░ ▒░▒██▀▀██░▒██▒▓██  ▀█ ██▒▒██░▄▄▄░░ ▓██▄
            ░ ▓██▓ ░ ░▓█ ░██ ░██░▓██▒  ▐▌██▒░▓█  ██▓  ▒   ██▒
              ▒██▒ ░ ░▓█▒░██▓░██░▒██░   ▓██░░▒▓███▀▒▒██████▒▒
              ▒ ░░    ▒ ░░▒░▒░▓  ░ ▒░   ▒ ▒  ░▒   ▒ ▒ ▒▓▒ ▒ ░
                ░     ▒ ░▒░ ░ ▒ ░░ ░░   ░ ▒░  ░   ░ ░ ░▒  ░ ░
              ░       ░  ░░ ░ ▒ ░   ░   ░ ░ ░ ░   ░ ░  ░  ░
                      ░  ░  ░ ░           ░       ░       ░

"@

$Global:Italwaysis = @"

██▓▄▄▄█████▓  ██████     ▄▄▄       ██▓     █     █░ ▄▄▄     ▓██   ██▓  ██████
▓██▒▓  ██▒ ▓▒▒██    ▒    ▒████▄    ▓██▒    ▓█░ █ ░█░▒████▄    ▒██  ██▒▒██    ▒
▒██▒▒ ▓██░ ▒░░ ▓██▄      ▒██  ▀█▄  ▒██░    ▒█░ █ ░█ ▒██  ▀█▄   ▒██ ██░░ ▓██▄
░██░░ ▓██▓ ░   ▒   ██▒   ░██▄▄▄▄██ ▒██░    ░█░ █ ░█ ░██▄▄▄▄██  ░ ▐██▓░  ▒   ██▒
░██░  ▒██▒ ░ ▒██████▒▒    ▓█   ▓██▒░██████▒░░██▒██▓  ▓█   ▓██▒ ░ ██▒▓░▒██████▒▒
░▓    ▒ ░░   ▒ ▒▓▒ ▒ ░    ▒▒   ▓▒█░░ ▒░▓  ░░ ▓░▒ ▒   ▒▒   ▓▒█░  ██▒▒▒ ▒ ▒▓▒ ▒ ░
 ▒ ░    ░    ░ ░▒  ░ ░     ▒   ▒▒ ░░ ░ ▒  ░  ▒ ░ ░    ▒   ▒▒ ░▓██ ░▒░ ░ ░▒  ░ ░
 ▒ ░  ░      ░  ░  ░       ░   ▒     ░ ░     ░   ░    ░   ▒   ▒ ▒ ░░  ░  ░  ░
 ░                 ░           ░  ░    ░  ░    ░          ░  ░░ ░           ░
                                                              ░ ░
▄▄▄█████▓ ██░ ██  ██▀███  ▓█████ ▓█████     ▄▄▄       ███▄ ▄███▓
▓  ██▒ ▓▒▓██░ ██▒▓██ ▒ ██▒▓█   ▀ ▓█   ▀    ▒████▄    ▓██▒▀█▀ ██▒
▒ ▓██░ ▒░▒██▀▀██░▓██ ░▄█ ▒▒███   ▒███      ▒██  ▀█▄  ▓██    ▓██░
░ ▓██▓ ░ ░▓█ ░██ ▒██▀▀█▄  ▒▓█  ▄ ▒▓█  ▄    ░██▄▄▄▄██ ▒██    ▒██
  ▒██▒ ░ ░▓█▒░██▓░██▓ ▒██▒░▒████▒░▒████▒    ▓█   ▓██▒▒██▒   ░██▒
  ▒ ░░    ▒ ░░▒░▒░ ▒▓ ░▒▓░░░ ▒░ ░░░ ▒░ ░    ▒▒   ▓▒█░░ ▒░   ░  ░
    ░     ▒ ░▒░ ░  ░▒ ░ ▒░ ░ ░  ░ ░ ░  ░     ▒   ▒▒ ░░  ░      ░
  ░       ░  ░░ ░  ░░   ░    ░      ░        ░   ▒   ░      ░
          ░  ░  ░   ░        ░  ░   ░  ░         ░  ░       ░

"@
#endregion

# If we are not using the config files because they take too long even though they are the correct wya to do things
# we don't need this replace inhere
# [version]$dbachecksversioninconfig = (Get-DbcConfigValue -Name app.checkrepos).Split('/')[-1].Split('\')[0]
# [version]$dbachecksmodulevarsion = (Get-Module dbachecks).Version
#
# if ($dbachecksmodulevarsion -ne $dbachecksversioninconfig) {
#   Get-ChildItem /workspace/Demos/dbachecksconfigs/*.json | ForEach-Object {
#     (Get-Content -Path $_.FullName) -replace $dbachecksversioninconfig, $dbachecksmodulevarsion | Set-Content $_.FullName
#   }
# }
function Start-Game {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Clear-Host', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'cls', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', 'cls', Justification = 'Dont tell me what to do')]
  [CmdletBinding()]
  param()
  #region set-up
  # Because we are using volumes for the restore demo, need to ensure they are clean before starting the game
  Remove-Item '/var/opt/backups/dbachecks1' -Recurse -Force -ErrorAction SilentlyContinue

  $securePassword = ('dbatools.IO' | ConvertTo-SecureString -AsPlainText -Force)
  $containercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)

  New-DbaDatabase -SqlInstance $dbachecks1 -SqlCredential $containercredential -Name Validation -RecoveryModel Full -WarningAction SilentlyContinue | Out-Null

  # we need an app login
  $Password = ConvertTo-SecureString PubsAdmin -AsPlainText -Force
  New-DbaLogin -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Login PubsAdmin -SecurePassword $Password -WarningAction SilentlyContinue | Out-Null
  New-DbaDbUser -SqlInstance $dbachecks1 -SqlCredential $containercredential -Database Pubs -Login PubsAdmin -Username PubsAdmin -WarningAction SilentlyContinue | Out-Null
  Add-DbaDbRoleMember -SqlInstance $dbachecks1 -SqlCredential $containercredential -Database Pubs -User PubsAdmin -Role db_owner -Confirm:$false | Out-Null

  # Let's add some things to find
  Invoke-DbaQuery -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Northwind -WarningAction SilentlyContinue -Query "
  CREATE PROCEDURE SP_FindMe AS BEGIN
    with cte as (
      select top 1 OrderID, ProductID
      FROM dbo.[Order Details]
      ORDER BY NEWID()
    )
    DELETE
    FROM cte
  END

  GO

  CREATE TRIGGER dbo.trg_chaos_monkey
    ON  dbo.[order details]
    INSTEAD OF UPDATE
  AS
  BEGIN
    print 'no update for you'
  END
  GO
  CREATE FUNCTION udf_FindMe
  (@test int = 1)
  RETURNS int
  AS
  -- For the order details
  BEGIN
    RETURN @test
  END"

  # Add a failed job
  $job = New-DbaAgentJob -SqlInstance $dbachecks2 -SqlCredential $containercredential -Job IamBroke -WarningAction SilentlyContinue
  if ($job) {
    $null = New-DbaAgentJobStep -SqlInstance $dbachecks2 -SqlCredential $containercredential -Job $job.Name -Subsystem TransactSql -Command 'Select * from MissingTable' -StepName 'Step One'
    $null = $job | Start-DbaAgentJob
  }


  #endregion

  Clear-Host # dont use cls here
  $title = "Joshua Says"
  $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Will continue"
  $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Will exit"
  $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
  $result = $host.ui.PromptForChoice($title, $ShallWePLayAGame, $options, 0)

  if ($result -eq 1) {
    cls
    Write-Output $OhNo1
    Start-Sleep -Seconds 1
    cls
    Start-Sleep -Milliseconds 250
    Write-Output $OhNo2
  } elseif ($result -eq 0) {
    Clear-Host # Dont use cls here
    Get-Index
  }
}

function Get-Index {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Clear-Host', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'cls', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', 'cls', Justification = 'Dont tell me what to do')]
  [CmdletBinding()]
  param()
  cls
  Write-Output $ChooseYourgame
  $gameChapters = @(
    ("&1 - Introduction to dbatools", "1 - Introduction to dbatools"),
    ("&2 - Backup and Restore", "2 - Backup and Restore"),
    ("&3 - Copy Copy Copy", "3 - Copy Copy Copy"),
    ("&4 - Snapshots", "4 - Snapshots"),
    ("&5 - Export", "5 - Export"),
    ("&6 - Availability Groups", "6 - Availability Groups"),
    ("&7 - Finding Things", "7 - Finding Things"),
    ("&8 - Data Masking", "8 - Data Masking"),
    ("&9 - Logins", "9 - Logins"),
    ("&M - Advanced Migrations", "10 - Advanced Migrations"),
    ("&R - Registered Servers", "11 - Registered Servers"),
    ("&C - Estate Validation", "12 - Estate Validation"),
    ("&T - TIC TAC TOE", "98 - TIC TAC TOE"),
    ("&Q - Quit", "Quit")
  )

  $options = New-Object System.Collections.ObjectModel.Collection[System.Management.Automation.Host.ChoiceDescription]

  foreach ($Chapter in $gameChapters) {
    $message = '{0}' -f $chapter[1]
    Write-Output $message
    $options.Add((New-Object System.Management.Automation.Host.ChoiceDescription $Chapter ) )
  }
  $title = "Joshua Says"
  $IndexChoice = $host.ui.PromptForChoice($title, "Make Your Choice", $options, 0) + 1

  switch ($IndexChoice) {
    1 {
      cls
      code /workspace/Demos/01-introduction.ps1
      #reset and run tests
      Write-PSFHostColor -String "It was a dark and stormy morning and ripe for learning about dbatools" -DefaultColor DarkCyan
      Write-PSFHostColor -String "The teachers arrived in the class first thing and ran some tests" -DefaultColor DarkYellow
      Write-PSFHostColor -String "They needed to ensure that nothing was wrong before" -DefaultColor DarkRed
      Write-PSFHostColor -String "The Introduction to dbatools" -DefaultColor DarkMagenta
      Write-PSFHostColor -String "Narrator - The Tests are running" -DefaultColor Blue
      Assert-Correct -chapter intro
      Get-GameTimeRemaining
    }
    2 {
      cls
      code /workspace/Demos/02-BackUpRestore.ps1
      Write-PSFHostColor -String "All the students knew that backups and restores were so very important" -DefaultColor DarkCyan
      Write-PSFHostColor -String "To ensure the safety and security of their employees data" -DefaultColor DarkYellow
      Write-PSFHostColor -String "The instructors need to ensure that everything is ok before" -DefaultColor DarkRed
      Write-PSFHostColor -String "2 - Backup and Restore" -DefaultColor DarkMagenta
      Write-PSFHostColor -String "Narrator - The Tests are running" -DefaultColor Blue
      Assert-Correct -chapter Backup
      Get-GameTimeRemaining
    }
    3 {
      cls
      code /workspace/Demos/03-CopyCopy.ps1
      Write-PSFHostColor -String "Entering this chapter carefully" -DefaultColor DarkCyan
      Write-PSFHostColor -String "the players realised that is all looked the same" -DefaultColor DarkYellow
      Write-PSFHostColor -String "It's almost like it has been copied over" -DefaultColor DarkRed
      Write-PSFHostColor -String "3 - Copy Copy Copy" -DefaultColor DarkMagenta
      Write-PSFHostColor -String "Narrator - The Tests are running" -DefaultColor Blue
      Assert-Correct -chapter Copy
      Get-GameTimeRemaining
    }
    4 {
      cls
      code /workspace/Demos/04-Snapshots.ps1
      Write-PSFHostColor -String "The sound of a gun echoed down the corridor" -DefaultColor DarkCyan
      Write-PSFHostColor -String "But as the mist cleared they realised that it was not that sort of shot" -DefaultColor DarkYellow
      Write-PSFHostColor -String "Welcome, said the deep voice, come on in" -DefaultColor DarkRed
      Write-PSFHostColor -String "4 - SnapShots"  -DefaultColor DarkMagenta
      Write-PSFHostColor -String "Narrator - The Tests are running" -DefaultColor Blue
      Assert-Correct -chapter SnapShots
      Get-GameTimeRemaining
    }
    6 {
      cls
      code /workspace/Demos/06-AvailabilityGroups.ps1
      Write-PSFHostColor -String "The noise was getting louder" -DefaultColor DarkCyan
      Write-PSFHostColor -String "This machine can no longer take the strain of the app and the reporting" -DefaultColor DarkYellow
      Write-PSFHostColor -String "I need many copies of this data the voice shouted and quickly now" -DefaultColor DarkRed
      Write-PSFHostColor -String "6 - Availability Groups"  -DefaultColor DarkMagenta
      Write-PSFHostColor -String "Narrator - The Tests are running" -DefaultColor Blue
      Assert-Correct -chapter Ags
      Get-GameTimeRemaining
    }
    5 {
      cls
      code /workspace/Demos/05-Export.ps1
      Write-PSFHostColor -String "As they stomped through the swamp" -DefaultColor DarkCyan
      Write-PSFHostColor -String "They wished the path was easier" -DefaultColor DarkYellow
      Write-PSFHostColor -String "If only someone had written it all down where it could be found.........." -DefaultColor DarkRed
      Write-PSFHostColor -String "5 - Export"  -DefaultColor DarkMagenta
      Write-PSFHostColor -String "Narrator - The Tests are running" -DefaultColor Blue
      Assert-Correct -chapter Export
      Get-GameTimeRemaining
    }
    7 {
      cls
      code /workspace/Demos/07-FindingThings.ps1
      Write-PSFHostColor -String "Lost, said the wispy voices" -DefaultColor DarkCyan
      Write-PSFHostColor -String "and unless you can locate the right things" -DefaultColor DarkYellow
      Write-PSFHostColor -String "~~~~~~~  YOU SHALL BE LOST FOREVER  ~~~~~~~" -DefaultColor DarkRed
      Write-PSFHostColor -String "7 - Finding Things"  -DefaultColor DarkMagenta
      Write-PSFHostColor -String "Narrator - The Tests are running" -DefaultColor Blue

      Assert-Correct -chapter Found
      Get-GameTimeRemaining
    }
    8 {
      cls
      code /workspace/Demos/08-DataMasking.ps1
      Write-PSFHostColor -String "They could hear them rushing towards them" -DefaultColor DarkCyan
      Write-PSFHostColor -String "shouting and hollering in a dreadful manner" -DefaultColor DarkYellow
      Write-PSFHostColor -String "But what was on those faces? Are those ....... Masks?" -DefaultColor DarkRed
      Write-PSFHostColor -String "8 - Data Masking"  -DefaultColor DarkMagenta
      Write-PSFHostColor -String "Narrator - The Tests are running" -DefaultColor Blue
      Assert-Correct -chapter Masking
      Get-GameTimeRemaining
    }
    9 {
      cls
      code /workspace/Demos/09-Logins.ps1
      Write-PSFHostColor -String "They saw a house in the distance and picked up speed" -DefaultColor DarkCyan
      Write-PSFHostColor -String "A massive wooden door faced them, they rang the bell" -DefaultColor DarkYellow
      Write-PSFHostColor -String "The monsters were close though ~~~ LET US IN" -DefaultColor DarkRed
      Write-PSFHostColor -String "PLEASE ~~~ LET US IN" -DefaultColor DarkRed
      Write-PSFHostColor -String "9 - Logins"  -DefaultColor DarkMagenta
      Write-PSFHostColor -String "Narrator - The Tests are running" -DefaultColor Blue
      Assert-Correct -chapter Logins
      Get-GameTimeRemaining
    }
    #even though you choose M
    10 {
      cls
      Write-Output "10 - Advanced Migrations"
      code /workspace/Demos/10-AdvancedMigrations.ps1

      Write-PSFHostColor -String "Just running some tests a mo" -DefaultColor Green
      Assert-Correct -chapter AdvMigration
      Get-GameTimeRemaining

      Write-PSFHostColor -String "we also need an app to run in the background" -DefaultColor Green
      Write-PSFHostColor -String "In a new session run Invoke-PubsApplication" -DefaultColor Green
    }
    #even though you choose R
    11 {
      cls
      Write-Output "11 - Registered Servers"
      code /workspace/Demos/11-RegisteredServers.ps1

      Write-PSFHostColor -String "Just running some tests a mo" -DefaultColor Green
      # Assert-Correct -chapter RegisterdServers
      Get-GameTimeRemaining
    }
    #even though you choose C
    12 {
      cls
      Write-Output "12 - Estate Validation"
      code /workspace/Demos/12-EstateValidation.ps1

      Write-PSFHostColor -String "Just running some tests a mo" -DefaultColor Green
      # Assert-Correct -chapter RegisterdServers
      Get-GameTimeRemaining
    }
    # even though you choose G
    14 {
      cls
      $Message = ' GREETINGS PROFESSOR FALKEN

      HELLO

      A STRANGE GAME.
      THE ONLY WINNING MOVE IS NOT TO PLAY.

      HOW ABOUT A NICE GAME OF CHESS?
                                                                       '
      Write-Host $message -BackgroundColor 03fcf4 -ForegroundColor Black
    }
    # even though you choose T
    13 {
      Start-TicTacToe
    }
    'q' {
      cls
    }
    Default {
      cls
      Write-Output $wrongChoice
      Start-Sleep -Seconds 1
      cls
      Start-Sleep -Milliseconds 250
      Write-Output $OhNo2
      $message = "You chose - {0}" -f $IndexChoice
      Write-Output $message
    }
  }
}

function Set-ConnectionInfo {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Clear-Host', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'cls', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', 'cls', Justification = 'Dont tell me what to do')]
  [CmdletBinding()]
  param()
  #region Set up connection
  $securePassword = ('dbatools.IO' | ConvertTo-SecureString -AsPlainText -Force)
  $containercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)

  #$Global:PSDefaultParameterValues = @{
  #  "*dba*:SqlCredential"            = $containercredential
  #  "*dba*:SourceSqlCredential"      = $containercredential
  #  "*dba*:DestinationSqlCredential" = $containercredential
  #  "*dba*:DestinationCredential"    = $containercredential
  #  "*dba*:PrimarySqlCredential"     = $containercredential
  #  "*dba*:SecondarySqlCredential"   = $containercredential
  #}


  $containers = $SQLInstances = $dbachecks1, $dbachecks2, $dbachecks3 = 'dbachecks1', 'dbachecks2', 'dbachecks3'
  #endregion
}

Set-ConnectionInfo

function Set-FailedTestMessage {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Clear-Host', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Out-GridView', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'cls', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', 'cls', Justification = 'Dont tell me what to do')]
  [CmdletBinding()]
  param()
  $FailedTests = ($results.FailedCount | Measure-Object -Sum).Sum
  if ($FailedTests -gt 0) {
    Write-PSFHostColor -String "NARRATOR - A thing went wrong" -DefaultColor DarkMagenta
    Write-PSFHostColor -String "NARRATOR - It MUST be fixed before we can continue" -DefaultColor DarkMagenta
    $Failures = $results.TestResult | Where-Object Result -EQ 'Failed' | Select-Object Describe, Context, Name, FailureMessage
    $Failures.ForEach{
      $Message = '{0} at {1} in {2}' -f $_.FailureMessage, $_.Name, $_.Describe
      Write-PSFHostColor -String $Message -DefaultColor DarkCyan
    }
  }
}
function Assert-Correct {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Clear-Host', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'cls', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', 'cls', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'results', Justification = 'Because it is a global variable used later')]

  [CmdletBinding()]
  param (
    # Parameter help description
    [Parameter()]
    [ValidateSet(
      'initial',
      'Intro' ,
      'Backup',
      'Copy',
      'SnapShots',
      'Export',
      'Ags',
      'Found',
      'Masking',
      'Logins',
      'AdvMigration'
    )]
    [string]
    $chapter = 'initial'
  )
  # $Global:PSDefaultParameterValues.CLear()
  switch ($chapter) {
    'initial' {
      # Valid estate is as we expect

      $null = Reset-DbcConfig
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $true  # so we dont get silly output from convert-dbcresult

      Set-DbcConfig -Name app.sqlinstance -Value $containers
      Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
      Set-DbcConfig -Name skip.connection.remoting -Value $true
      Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection -Verbose

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks2'
      Invoke-DbcCheck -SqlCredential $containercredential -Check DatabaseExists

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks1'
      Set-DbcConfig -Name database.exists -Value 'pubs', 'NorthWind' -Append
      Invoke-DbcCheck -SqlCredential $containercredential -Check DatabaseExists

      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $false  # reset
    }
    'Intro' {
      # Valid estate is as we expect

      $null = Reset-DbcConfig
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $true  # so we dont get silly output from convert-dbcresult
      $null = Set-DbcConfig -Name app.sqlinstance -Value $containers
      $null = Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
      $null = Set-DbcConfig -Name skip.connection.remoting -Value $true
      $check1 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection -Show Summary -PassThru
      $check1 | Convert-DbcResult -Label Intro -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      $null = Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks2'
      $check2 = Invoke-DbcCheck -SqlCredential $containercredential -Check DatabaseExists -Show Summary -PassThru
      $check2 | Convert-DbcResult -Label Intro -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      $null = Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks1'
      $null = Set-DbcConfig -Name database.exists -Value 'pubs', 'NorthWind' -Append
      $check3 = Invoke-DbcCheck -SqlCredential $containercredential -Check DatabaseExists -Show Summary -PassThru
      $check3 | Convert-DbcResult -Label Intro -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      $results = @($check1, $check2, $check3)
      Set-FailedTestMessage

      Write-PSFHostColor -String "Are you ready to begin your adventure?" -DefaultColor Blue
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $false  # reset
    }
    'Backup' {
      # Valid estate is as we expect

      $null = Reset-DbcConfig
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $true  # so we dont get silly output from convert-dbcresult
      $null = Set-DbcConfig -Name app.checkrepos -Value '/workspace/Demos/dbachecksconfigs' -Append
      $null = Set-DbcConfig -Name app.sqlinstance -Value $containers
      $null = Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
      $null = Set-DbcConfig -Name skip.connection.remoting -Value $true
      $null = Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks2'

      $check1 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists -Show Summary -PassThru
      $check1 | Convert-DbcResult -Label Backup -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      $null = Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks1'
      $null = Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'Northwind', 'pubs', 'tempdb'

      $check2 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists, NoDatabasesOn1, NoBackupFiles -Show Summary -PassThru
      $check2 | Convert-DbcResult -Label Backup -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      $results = @($check1, $check2)
      Set-FailedTestMessage
      Write-PSFHostColor -String "Should you create a save point before this chapter?" -DefaultColor Blue
      Start-Sleep -Seconds 5
      Write-PSFHostColor -String "Or can you make it to the end?" -DefaultColor DarkRed
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $false # reset

    }
    'Copy' {
      # Valid estate is as we expect

      $null = Reset-DbcConfig
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $true  # so we dont get silly output from convert-dbcresult
      $null = Set-DbcConfig -Name app.checkrepos -Value '/workspace/Demos/dbachecksconfigs' -Append
      Set-DbcConfig -Name app.sqlinstance -Value $containers | Out-Null
      Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL' | Out-Null
      Set-DbcConfig -Name skip.connection.remoting -Value $true | Out-Null
      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks2' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'tempdb' | Out-Null

      $check1 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists, NoDatabasesOn2, NeedNoLogins -Show Summary -PassThru
      $check1 | Convert-DbcResult -Label Copy -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks1' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'Northwind', 'pubs', 'pubs-0', 'pubs-1', 'pubs-10', 'pubs-2', 'pubs-3', 'pubs-4', 'pubs-5', 'pubs-6', 'pubs-7', 'pubs-8', 'pubs-9', 'tempdb' | Out-Null
      $check2 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists -Show Summary -PassThru
      $check2 | Convert-DbcResult -Label Copy -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      $results = @($check1, $check2)
      Set-FailedTestMessage
      Write-PSFHostColor -String "If you get database missing failures - Chapter 2 will be your friend" -DefaultColor Magenta
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $false # reset
    }
    'Snapshots' {
      # Valid estate is as we expect
      Write-PSFHostColor -String "Running the SnapShot Chapter checks" -DefaultColor Green
      $null = Reset-DbcConfig
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $true  # so we dont get silly output from convert-dbcresult
      Set-DbcConfig -Name app.checkrepos -Value '/workspace/Demos/dbachecksconfigs' -Append | Out-Null
      Set-DbcConfig -Name app.sqlinstance -Value $containers | Out-Null
      Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL' | Out-Null
      Set-DbcConfig -Name skip.connection.remoting -Value $true | Out-Null
      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks2' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'tempdb' | Out-Null
      $check1 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists, NoDatabasesOn2, DatabaseStatus, NoSnapshots -Show Summary -PassThru
      $check1 | Convert-DbcResult -Label SnapShots -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks1' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'Northwind', 'pubs', 'tempdb' | Out-Null
      $check2 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists, DatabaseStatus -Show Summary -PassThru
      $check1 | Convert-DbcResult -Label SnapShots -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation
      $results = @($check1, $check2)
      Set-FailedTestMessage
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $false # reset
    }
    'Export' {
      # Valid estate is as we expect

      $null = Reset-DbcConfig
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $true  # so we dont get silly output from convert-dbcresult
      $null = Set-DbcConfig -Name app.sqlinstance -Value $containers
      $null = Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
      $null = Set-DbcConfig -Name skip.connection.remoting -Value $true
      $check1 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection -Show Summary -PassThru
      $check1 | Convert-DbcResult -Label Export -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      $null = Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks2'
      $check2 = Invoke-DbcCheck -SqlCredential $containercredential -Check DatabaseExists -Show Summary -PassThru
      $check2 | Convert-DbcResult -Label Export -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      $null = Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks1'
      $null = Set-DbcConfig -Name database.exists -Value 'pubs', 'NorthWind' -Append
      $check3 = Invoke-DbcCheck -SqlCredential $containercredential -Check DatabaseExists -Show Summary -PassThru
      $check3 | Convert-DbcResult -Label Export -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation
      $results = @($check1, $check2, $check3)
      Set-FailedTestMessage
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $false
    }
    'Ags' {
      # Valid estate is as we expect

      $null = Reset-DbcConfig
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $true  # so we dont get silly output from convert-dbcresult
      $null = Set-DbcConfig -Name app.checkrepos -Value '/workspace/Demos/dbachecksconfigs' -Append | Out-Null
      $null = Set-DbcConfig -Name app.sqlinstance -Value $containers
      $null = Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
      $null = Set-DbcConfig -Name skip.connection.remoting -Value $true
      $check1 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection -Show Summary -PassThru
      $check1 | Convert-DbcResult -Label AvailabilityGroups -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks2' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'tempdb' | Out-Null
      $check2 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists, NoDatabasesOn2, DatabaseStatus, NoSnapshots, NoAgs -Show Summary -PassThru
      $check2 | Convert-DbcResult -Label AvailabilityGroups -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks1' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'Northwind', 'pubs', 'pubs-0', 'pubs-1', 'pubs-10', 'pubs-2', 'pubs-3', 'pubs-4', 'pubs-5', 'pubs-6', 'pubs-7', 'pubs-8', 'pubs-9', 'tempdb' | Out-Null
      $check3 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists, DatabaseStatus -Show Summary -PassThru
      $check3 | Convert-DbcResult -Label AvailabilityGroups -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation
      $results = @($check1, $check2, $check3)
      Set-FailedTestMessage
      Write-PSFHostColor -String "If you get database missing failures - Chapter 2 will be your friend" -DefaultColor Magenta
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $false
    }
    'AdvMigration' {
      # Valid estate is as we expect

      $null = Reset-DbcConfig
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $true  # so we dont get silly output from convert-dbcresult
      Set-DbcConfig -Name app.checkrepos -Value '/workspace/Demos/dbachecksconfigs' -Append | Out-Null
      $null = Set-DbcConfig -Name app.sqlinstance -Value $containers
      $null = Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
      $null = Set-DbcConfig -Name skip.connection.remoting -Value $true
      $check1 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection -Show Summary -PassThru
      $check1 | Convert-DbcResult -Label AdvancedMigration -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks2' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'tempdb' | Out-Null
      $check2 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists, NoDatabasesOn2, DatabaseStatus, NoSnapshots, NoAgs -Show Summary -PassThru
      $check2 | Convert-DbcResult -Label AdvancedMigration -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks1' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'Northwind', 'pubs', 'tempdb' | Out-Null
      $check3 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists, DatabaseStatus -Show Summary -PassThru
      $check3 | Convert-DbcResult -Label AdvancedMigration -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      $results = @($check1, $check2, $check3)
      Set-FailedTestMessage
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $false
    }
    'Found' {
      # Valid estate is as we expect

      $null = Reset-DbcConfig
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $true  # so we dont get silly output from convert-dbcresult
      Set-DbcConfig -Name app.checkrepos -Value '/workspace/Demos/dbachecksconfigs' -Append | Out-Null
      $null = Set-DbcConfig -Name app.sqlinstance -Value $containers
      $null = Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
      $null = Set-DbcConfig -Name skip.connection.remoting -Value $true
      $check1 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection -Show Summary -PassThru
      $check1 | Convert-DbcResult -Label Found -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks2' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'tempdb' | Out-Null
      $check2 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists, NeedJobs, NeedFailedJobs  -Show Summary -PassThru
      $check2 | Convert-DbcResult -Label Found -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks1' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'Northwind', 'pubs', 'tempdb' | Out-Null
      $check3 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists, DatabaseStatus, NeedSps, NeedUDfs, NeedTriggers, NeedLogins -Show Summary -PassThru
      $check3 | Convert-DbcResult -Label Found -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      $results = @($check1, $check2, $check3)
      Set-FailedTestMessage
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $false
    }
    'Masking' {
      # Valid estate is as we expect

      $null = Reset-DbcConfig
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $true  # so we dont get silly output from convert-dbcresult
      Set-DbcConfig -Name app.checkrepos -Value '/workspace/Demos/dbachecksconfigs' -Append | Out-Null
      $null = Set-DbcConfig -Name app.sqlinstance -Value $containers
      $null = Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
      $null = Set-DbcConfig -Name skip.connection.remoting -Value $true
      $check1 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection -Show Summary -PassThru
      $check1 | Convert-DbcResult -Label Masking -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks2' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'tempdb' | Out-Null
      $check2 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists -Show Summary -PassThru
      $check2 | Convert-DbcResult -Label Masking -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks1' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'Northwind', 'pubs', 'tempdb' | Out-Null
      $check3 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists, DatabaseStatus -Show Summary -PassThru
      $check3 | Convert-DbcResult -Label Masking -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      $results = @($check1, $check2, $check3)
      Set-FailedTestMessage
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $false
    }
    'Logins' {
      # Valid estate is as we expect

      $null = Reset-DbcConfig
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $true  # so we dont get silly output from convert-dbcresult
      Set-DbcConfig -Name app.checkrepos -Value '/workspace/Demos/dbachecksconfigs' -Append | Out-Null
      $null = Set-DbcConfig -Name app.sqlinstance -Value $containers
      $null = Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
      $null = Set-DbcConfig -Name skip.connection.remoting -Value $true
      $check1 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection -Show Summary -PassThru
      $check1 | Convert-DbcResult -Label Logins -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks2' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'tempdb' | Out-Null
      $check2 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists -Show Summary -PassThru
      $check2 | Convert-DbcResult -Label Logins -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      Set-DbcConfig -Name app.sqlinstance -Value 'dbachecks1' | Out-Null
      Set-DbcConfig -Name database.exists -Value 'master', 'model', 'msdb', 'Northwind', 'pubs', 'tempdb' | Out-Null
      $check3 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection, DatabaseExists, DatabaseStatus -Show Summary -PassThru
      $check3 | Convert-DbcResult -Label Logins -warningaction SilentlyContinue | Write-DbcTable -SqlInstance $dbachecks1 -SqlCredential $containercredential  -Database Validation

      $results = @($check1, $check2, $check3)
      Set-FailedTestMessage
      $null = Set-PSFConfig -FullName PSFramework.Message.ConsoleOutput.Disable -Value $false
    }
    Default {
      # Valid estate is as we expect

      $null = Reset-DbcConfig

      $null = Import-DbcConfig /workspace/Demos/dbachecksconfigs/initial-config.json
      $check3 = Invoke-DbcCheck -SqlCredential $containercredential -Check InstanceConnection  -Show Summary -PassThru

      $null = Reset-DbcConfig

      $null = Import-DbcConfig /workspace/Demos/dbachecksconfigs/initial-dbachecks1-config.json
      $check2 = Invoke-DbcCheck -SqlCredential $containercredential -Check DatabaseExists -Show Summary -PassThru

      $null = Reset-DbcConfig

      $null = Import-DbcConfig /workspace/Demos/dbachecksconfigs/initial-dbachecks2-config.json
      $check1 = Invoke-DbcCheck -SqlCredential $containercredential -Check DatabaseExists -Show Summary -PassThru
      $results = @($check1, $check2, $check3)
      Set-FailedTestMessage
    }
  }
  #$Global:PSDefaultParameterValues = @{
  #  "*dba*:SqlCredential"            = $containercredential
  #  "*dba*:SourceSqlCredential"      = $containercredential
  #  "*dba*:DestinationSqlCredential" = $containercredential
  #  "*dba*:DestinationCredential"    = $containercredential
  #  "*dba*:PrimarySqlCredential"     = $containercredential
  #  "*dba*:SecondarySqlCredential"   = $containercredential
  #}
}

Function Compare-SPConfig {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Clear-Host', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Out-GridView', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'cls', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', 'cls', Justification = 'Dont tell me what to do')]
  [CmdletBinding()]
  Param(
    $Source,
    $Destination
  )
  $SourceSpConfigure = Get-DbaSpConfigure  -SqlInstance $Source -SqlCredential $containercredential
  $DestSPConfigure = Get-DbaSpConfigure -SqlInstance $Destination -SqlCredential  $containercredential

  $propcompare = foreach ($prop in $SourceSpConfigure) {
    [pscustomobject]@{
      Config                = $prop.DisplayName
      'Source setting'      = $prop.RunningValue
      'Destination Setting' = $DestSPConfigure | Where-Object DisplayName -EQ $prop.DisplayName | Select-Object -ExpandProperty RunningValue
    }
  }

  if ($IsCoreCLR) {
    $propcompare | Out-ConsoleGridView -Title "Comparing Sp_configure Settings Source - $Source With Destination $Destination"
  } else {
    $propcompare | Out-GridView -Title "Comparing Sp_configure Settings Source - $SourceWith Destination $Destination"

  }


}

function Invoke-PubsApplication {
  # This will randomly insert rows into the pubs.dbo.sales table on dbachecks1 to simulate sales activity
  # It'll run until you kill it


  # app connection
  $securePassword = ('PubsAdmin' | ConvertTo-SecureString -AsPlainText -Force)
  $appCred = New-Object System.Management.Automation.PSCredential('PubsAdmin', $securePassword)
  $appConnection = Connect-DbaInstance -SqlInstance $dbachecks1 -SqlCredential $appCred -ClientName 'PubsApplication'

  while ($true) {
    Write-PSFHostColor -String "Pubs application is running...forever... Ctrl+C to get out of here" -DefaultColor Green

    $newOrder = [PSCustomObject]@{
      stor_id  = Get-Random (Invoke-DbaQuery -SqlInstance $appConnection -Database pubs -Query 'select stor_id from stores').stor_id
      ord_num  = Get-DbaRandomizedValue -DataType int -Min 1000 -Max 99999
      ord_date = Get-Date
      qty      = Get-Random -Minimum 1 -Maximum 30
      payterms = Get-Random (Invoke-DbaQuery -SqlInstance $appConnection -Database pubs -Query 'select distinct payterms from pubs.dbo.sales').payterms
      title_id = Get-Random (Invoke-DbaQuery -SqlInstance $appConnection -Database pubs -Query 'select title_id from titles').title_id
    }
    Write-DbaDataTable -SqlInstance $appConnection -Database pubs -InputObject $newOrder -Table sales

    Start-Sleep -Seconds (Get-Random -Maximum 10)
  }
}

function Get-GameTimeRemaining {
  $StartDate = Get-Date -Hour 9 -Minute 00 -Second 0
  $Date = Get-Date
  $Diff = $Date - $StartDate

  $MorningBreak = Get-Date -Hour 10 -Minute 30 -Second 0
  $Lunch = Get-Date -Hour 12 -Minute 30 -Second 0
  $AfternoonBreak = Get-Date -Hour 15 -Minute 00 -Second 0
  $TheEnd = Get-Date -Hour 17 -Minute 00 -Second 0

  switch ($Date) {
    { $Date -lt $TheEnd } {
      $Remaining = $TheEnd - $Date
      $Reason = 'THE END'
    }
    { $Date -lt $AfternoonBreak } {
      $Remaining = $AfternoonBreak - $Date
      $Reason = 'AFTERNOON BREAK'
    }
    { $Date -lt $Lunch } {
      $Remaining = $Lunch - $Date
      $Reason = 'LUNCH BREAK'
    }
    { $Date -lt $MorningBreak } {
      $Remaining = $MorningBreak - $Date
      $Reason = 'MORNING BREAK'
    }
    Default {}
  }
  $message = '
_______________________   _______________________
| GAME TIME ELAPSED    |  | GAME TIME REMAINING  |
|        {0}  HRS        |  |       {3} HRS          |
|  {1} MINS  {2} SECS    |  |  {4} MINS  {5} SECS    |
|                      |  | UNTIL {6}
|______________________|  |______________________|

' -f $Diff.Hours , ("{0:D2}" -f $diff.Minutes) , ("{0:D2}" -f $diff.Seconds), $Remaining.Hours , ("{0:D2}" -f $Remaining.Minutes) , ("{0:D2}" -f $Remaining.Seconds), $Reason

  Write-Host $message -BackgroundColor 03fcf4 -ForegroundColor Black

}

Function TicTacToe {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Clear-Host', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Out-GridView', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'cls', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', 'cls', Justification = 'Dont tell me what to do')]
  [CmdletBinding()]
  Param(
    $Sleep
  )
  $message = '
         |         |
         |         |
         |         |
         |         |
         |         |
------------------------------
         |         |
         |         |
         |         |
         |         |
         |         |
------------------------------
         |         |
         |         |
         |         |
         |         |
         |         |
'
  Clear-Host
  Write-Host $message

  Start-Sleep -Milliseconds $Sleep
  $message = '
         |         |
         |         |
         |         |
         |         |
         |         |
------------------------------
         |         |
         |  X   X  |
         |    X    |
         |  X   X  |
         |         |
------------------------------
         |         |
         |         |
         |         |
         |         |
         |         |
'
  Clear-Host
  Write-Host $message

  Start-Sleep -Milliseconds $Sleep
  $message = '
         |         |
    O    |         |
  O   O  |         |
    O    |         |
         |         |
------------------------------
         |         |
         |  X   X  |
         |    X    |
         |  X   X  |
         |         |
------------------------------
         |         |
         |         |
         |         |
         |         |
         |         |
'
  Clear-Host
  Write-Host $message

  Start-Sleep -Milliseconds $Sleep
  $message = '
         |         |
    O    |         |
  O   O  |         |
    O    |         |
         |         |
------------------------------
         |         |
         |  X   X  |
         |    X    |
         |  X   X  |
         |         |
------------------------------
         |         |
         |  X   X  |
         |    X    |
         |  X   X  |
         |         |
'
  Clear-Host
  Write-Host $message

  Start-Sleep -Milliseconds $Sleep
  $message = '
         |         |
    O    |    O    |
  O   O  |  O   O  |
    O    |    O    |
         |         |
------------------------------
         |         |
         |  X   X  |
         |    X    |
         |  X   X  |
         |         |
------------------------------
         |         |
         |  X   X  |
         |    X    |
         |  X   X  |
         |         |
'
  Clear-Host
  Write-Host $message

  Start-Sleep -Milliseconds $Sleep

  $message = '
         |         |
    O    |    O    |  X   X
  O   O  |  O   O  |    X
    O    |    O    |  X   X
         |         |
------------------------------
         |         |
         |  X   X  |
         |    X    |
         |  X   X  |
         |         |
------------------------------
         |         |
         |  X   X  |
         |    X    |
         |  X   X  |
         |         |
'
  Clear-Host
  Write-Host $message

  Start-Sleep -Milliseconds $Sleep
  $message = '
         |         |
    O    |    O    |  X   X
  O   O  |  O   O  |    X
    O    |    O    |  X   X
         |         |
------------------------------
         |         |
         |  X   X  |
         |    X    |
         |  X   X  |
         |         |
------------------------------
         |         |
    O    |  X   X  |
  O   O  |    X    |
    O    |  X   X  |
         |         |
'
  Clear-Host
  Write-Host $message

  Start-Sleep -Milliseconds $Sleep
  $message = '
         |         |
    O    |    O    |  X   X
  O   O  |  O   O  |    X
    O    |    O    |  X   X
         |         |
------------------------------
         |         |
  X   X  |  X   X  |
    X    |    X    |
  X   X  |  X   X  |
         |         |
------------------------------
         |         |
    O    |  X   X  |
  O   O  |    X    |
    O    |  X   X  |
         |         |
'
  Clear-Host
  Write-Host $message

  Start-Sleep -Milliseconds $Sleep
  $message = '
         |         |
    O    |    O    |  X   X
  O   O  |  O   O  |    X
    O    |    O    |  X   X
         |         |
------------------------------
         |         |
  X   X  |  X   X  |    O
    X    |    X    |  O   O
  X   X  |  X   X  |    O
         |         |
------------------------------
         |         |
    O    |  X   X  |
  O   O  |    X    |
    O    |  X   X  |
         |         |
'
  Clear-Host
  Write-Host $message

  Start-Sleep -Milliseconds $Sleep
  $message = '
         |         |
    O    |    O    |  X   X
  O   O  |  O   O  |    X
    O    |    O    |  X   X
         |         |
------------------------------
         |         |
  X   X  |  X   X  |    O
    X    |    X    |  O   O
  X   X  |  X   X  |    O
         |         |
------------------------------
         |         |
    O    |  X   X  |  X   X
  O   O  |    X    |    X
    O    |  X   X  |  X   X
         |         |
'
  Clear-Host
  Write-Host $message


  Start-Sleep -Milliseconds $Sleep
}

function Start-TicTacToe {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Clear-Host', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Out-GridView', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'cls', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', 'cls', Justification = 'Dont tell me what to do')]
  [CmdletBinding()]
  param()
  $Options = 500, 200, 200, 100, 100, 100, 50, 50, 50, 50, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
  $Options | ForEach-Object {
    TicTacToe -Sleep $_
  }
  Clear-Host
  $Message = ' GREETINGS PROFESSOR FALKEN

  HELLO

  A STRANGE GAME.
  THE ONLY WINNING MOVE IS NOT TO PLAY.

  HOW ABOUT A NICE GAME OF CHESS?
                                                                   '
  Write-Host $message -BackgroundColor 03fcf4 -ForegroundColor Black
}

function pacman {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Clear-Host', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Out-GridView', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'cls', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', 'cls', Justification = 'Dont tell me what to do')]
  [CmdletBinding()]
  param()
  Clear-Host

  $sleep = 15

  $pac = "
   .-.      .--.
  | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .
  |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '
  '^^^'    '--'
  "
  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host
  $pac = "
    .-.      .--.
   | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
   |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
   '^^^'    '--'
  "
  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
     .-.      .--.
    | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
    |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
    '^^^'    '--'
  "
  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
      .-.      .--.
     | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
     |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
     '^^^'    '--'
  "
  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
       .-.      .--.
      | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
      |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
      '^^^'    '--'
  "
  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
        .-.      .--.
       | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-
       |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-
       '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
         .-.      .--.
        | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
        |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
        '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
          .-.      .--.
         | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
         |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
         '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
           .-.      .--.
          | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
          |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
          '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
            .-.      .--.
           | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
           |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
           '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
             .-.      .--.
            | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-
            |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-
            '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
              .-.      .--.
             | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-
             |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-
             '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
               .-.      .--.
              | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .
              |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '
              '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                .-.      .--.
               | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
               |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
               '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host
  $pac = "
                 .-.      .--.
                | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
                |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
                '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                  .-.      .--.
                 | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
                 |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
                 '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
                   .-.      .--.
                  | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
                  |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
                  '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                    .-.      .--.
                   | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-
                   |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-
                   '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                     .-.      .--.
                    | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .
                    |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '
                    '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                      .-.      .--.
                     | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
                     |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
                     '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                       .-.      .--.
                      | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
                      |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
                      '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                        .-.      .--.
                       | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
                       |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
                       '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                         .-.      .--.
                        | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
                        |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
                        '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
                          .-.      .--.
                         | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-
                         |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-
                         '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                           .-.      .--.
                          | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.   .
                          |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'   '
                          '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
                            .-.      .--.
                           | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
                           |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
                           '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                             .-.      .--.
                            | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
                            |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
                            '^^^'    '--'
  "
  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                              .-.      .--.
                             | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
                             |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
                             '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                               .-.      .--.
                              | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-.
                              |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-'
                              '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                .-.      .--.
                               | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .-
                               |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '-
                               '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                 .-.      .--.
                                | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.   .
                                |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'   '
                                '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                  .-.      .--.
                                 | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.
                                 |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'
                                 '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                   .-.      .--.
                                  | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.
                                  |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'
                                  '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                    .-.      .--.
                                   | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.
                                   |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'
                                   '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                     .-.      .--.
                                    | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-.
                                    |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-'
                                    '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                      .-.      .--.
                                     | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .-
                                     |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '-
                                     '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
                                       .-.      .--.
                                      | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.   .
                                      |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'   '
                                      '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                        .-.      .--.
                                       | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.
                                       |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'
                                       '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                         .-.      .--.
                                        | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.
                                        |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'
                                        '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                          .-.      .--.
                                         | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.
                                         |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'
                                         '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                           .-.      .--.
                                          | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-.
                                          |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-'
                                          '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                            .-.      .--.
                                           | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .-
                                           |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '-
                                           '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                             .-.      .--.
                                            | OO|   / _.-' .-.   .-.   .-.   .-.   .-.   .
                                            |   |   \  '-. '-'   '-'   '-'   '-'   '-'   '
                                            '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                              .-.      .--.
                                             | OO|   / _.-' .-.   .-.   .-.   .-.   .-.
                                             |   |   \  '-. '-'   '-'   '-'   '-'   '-'
                                             '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                               .-.      .--.
                                              | OO|   / _.-' .-.   .-.   .-.   .-.   .-.
                                              |   |   \  '-. '-'   '-'   '-'   '-'   '-'
                                              '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                .-.      .--.
                                               | OO|   / _.-' .-.   .-.   .-.   .-.   .-.
                                               |   |   \  '-. '-'   '-'   '-'   '-'   '-'
                                               '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                 .-.      .--.
                                                | OO|   / _.-' .-.   .-.   .-.   .-.   .-.
                                                |   |   \  '-. '-'   '-'   '-'   '-'   '-'
                                                '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                   .-.      .--.
                                                 | OO|   / _.-' .-.   .-.   .-.   .-.   .-
                                                 |   |   \  '-. '-'   '-'   '-'   '-'   '-
                                                 '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                   .-.      .--.
                                                  | OO|   / _.-' .-.   .-.   .-.   .-.   .
                                                  |   |   \  '-. '-'   '-'   '-'   '-'   '
                                                  '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                    .-.      .--.
                                                   | OO|   / _.-' .-.   .-.   .-.   .-.
                                                   |   |   \  '-. '-'   '-'   '-'   '-'
                                                   '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
                                                     .-.      .--.
                                                    | OO|   / _.-' .-.   .-.   .-.   .-.
                                                    |   |   \  '-. '-'   '-'   '-'   '-'
                                                    '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
                                                      .-.      .--.
                                                     | OO|   / _.-' .-.   .-.   .-.   .-.
                                                     |   |   \  '-. '-'   '-'   '-'   '-'
                                                     '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
                                                       .-.      .--.
                                                      | OO|   / _.-' .-.   .-.   .-.   .-.
                                                      |   |   \  '-. '-'   '-'   '-'   '-'
                                                      '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                        .-.      .--.
                                                       | OO|   / _.-' .-.   .-.   .-.   .-
                                                       |   |   \  '-. '-'   '-'   '-'   '-
                                                       '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                         .-.      .--.
                                                        | OO|   / _.-' .-.   .-.   .-.   .
                                                        |   |   \  '-. '-'   '-'   '-'   '
                                                        '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                          .-.      .--.
                                                         | OO|   / _.-' .-.   .-.   .-.
                                                         |   |   \  '-. '-'   '-'   '-'
                                                         '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
                                                           .-.      .--.
                                                          | OO|   / _.-' .-.   .-.   .-.
                                                          |   |   \  '-. '-'   '-'   '-'
                                                          '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                            .-.      .--.
                                                           | OO|   / _.-' .-.   .-.   .-.
                                                           |   |   \  '-. '-'   '-'   '-'
                                                           '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
                                                             .-.      .--.
                                                            | OO|   / _.-' .-.   .-.   .-.
                                                            |   |   \  '-. '-'   '-'   '-'
                                                            '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
                                                              .-.      .--.
                                                             | OO|   / _.-' .-.   .-.   .-
                                                             |   |   \  '-. '-'   '-'   '-
                                                             '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                               .-.      .--.
                                                              | OO|   / _.-' .-.   .-.   .
                                                              |   |   \  '-. '-'   '-'   '
                                                              '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
                                                                .-.      .--.
                                                               | OO|   / _.-' .-.   .-.
                                                               |   |   \  '-. '-'   '-'
                                                               '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                 .-.      .--.
                                                                | OO|   / _.-' .-.   .-.
                                                                |   |   \  '-. '-'   '-'
                                                                '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
                                                                  .-.      .--.
                                                                 | OO|   / _.-' .-.   .-.
                                                                 |   |   \  '-. '-'   '-'
                                                                 '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host



  $pac = "
                                                                   .-.      .--.
                                                                  | OO|   / _.-' .-.   .-.
                                                                  |   |   \  '-. '-'   '-'
                                                                  '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                    .-.      .--.
                                                                   | OO|   / _.-' .-.   .-
                                                                   |   |   \  '-. '-'   '-
                                                                   '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                     .-.      .--.
                                                                    | OO|   / _.-' .-.   .
                                                                    |   |   \  '-. '-'   '
                                                                    '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                      .-.      .--.
                                                                     | OO|   / _.-' .-.
                                                                     |   |   \  '-. '-'
                                                                     '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                       .-.      .--.
                                                                      | OO|   / _.-' .-.
                                                                      |   |   \  '-. '-'
                                                                      '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                        .-.      .--.
                                                                       | OO|   / _.-' .-.
                                                                       |   |   \  '-. '-'
                                                                       '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "
                                                                         .-.      .--.
                                                                        | OO|   / _.-' .-.
                                                                        |   |   \  '-. '-'
                                                                        '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                          .-.      .--.
                                                                         | OO|   / _.-' .-
                                                                         |   |   \  '-. '-
                                                                         '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                           .-.      .--.
                                                                          | OO|   / _.-' .
                                                                          |   |   \  '-. '
                                                                          '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                            .-.      .--.
                                                                           | OO|   / _.-'
                                                                           |   |   \  '-.
                                                                           '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                             .-.      .--.
                                                                            | OO|   / _.-'
                                                                            |   |   \  '-.
                                                                            '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                              .-.      .--
                                                                             | OO|   / _.-
                                                                             |   |   \  '-
                                                                             '^^^'    '--'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                               .-.      .-
                                                                              | OO|   / _.
                                                                              |   |   \  '
                                                                              '^^^'    '--
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                                .-.      .
                                                                               | OO|   / _
                                                                               |   |   \
                                                                               '^^^'    '-
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                                 .-.
                                                                                | OO|   /
                                                                                |   |   \
                                                                                '^^^'    '
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                                  .-.
                                                                                 | OO|   /
                                                                                 |   |   \
                                                                                 '^^^'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                                   .-.
                                                                                  | OO|
                                                                                  |   |
                                                                                  '^^^'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                                    .-.
                                                                                   | OO|
                                                                                   |   |
                                                                                   '^^^'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                                     .-.
                                                                                    | OO|
                                                                                    |   |
                                                                                    '^^^'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                                      .-.
                                                                                     | OO|
                                                                                     |   |
                                                                                     '^^^'
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                                       .-.
                                                                                      | OO
                                                                                      |
                                                                                      '^^^
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                                        .-
                                                                                       | O
                                                                                       |
                                                                                       '^^
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "
                                                                                         .
                                                                                        |
                                                                                        |
                                                                                        '^
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host

  $pac = "

                                                                                         |
                                                                                         |
                                                                                         '
  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


  $pac = "




  "

  Write-Host $pac -ForegroundColor Yellow
  Start-Sleep -Milliseconds $sleep
  Clear-Host


}
New-Alias -Name cls -Value pacman -Force

function Invoke-PerfAndValidateCheck {
  <#
  .SYNOPSIS
  Function to help test that the v5 and v4 tests are doing the same thing & get the performance stats

  .DESCRIPTION
  Function to help test that the v5 and v4 tests are doing the same thing & get the performance stats

  .PARAMETER Checks
  Which checks shall we test

  .PARAMETER PerfDetails
  Shall we show the performance output from profiler

  .PARAMETER SQLInstances
  Which SQL Instances shall we test.

  Defaults ($dbachecks1, $dbachecks2, $dbachecks3 = 'dbachecks1', 'dbachecks2', 'dbachecks3')

  .EXAMPLE
  Invoke-PerfAndValidateCheck -Check InvalidDatabaseOwner

  Check validity and performance for InvalidDatabaseOwner test

  .EXAMPLE
  Invoke-PerfAndValidateCheck -Check ValidDatabaseOwner, InvalidDatabaseOwner

  Check validity and performance for both the ValidDatabaseOwner and InvalidDatabaseOwner tests

  .EXAMPLE
  Invoke-PerfAndValidateCheck -Check ValidDatabaseOwner, InvalidDatabaseOwner -PerfDetails

  Check validity and performance for both the ValidDatabaseOwner and InvalidDatabaseOwner tests and show the top 50 slowest lines

  .EXAMPLE
  Invoke-PerfAndValidateCheck -SqlInstances 'localhost,7401' -Check ValidDatabaseOwner, InvalidDatabaseOwner

  Check validity and performance for both the ValidDatabaseOwner and InvalidDatabaseOwner tests aganinst one container.

  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Clear-Host', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Out-GridView', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'cls', Justification = 'Dont tell me what to do')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', 'cls', Justification = 'Dont tell me what to do')]
  [CmdletBinding()]
  param(
    $Checks,
    [switch]$PerfDetail,
    [switch]$showTestResults,
    $SQLInstances = ($dbachecks1, $dbachecks2, $dbachecks3 = 'dbachecks1', 'dbachecks2', 'dbachecks3')
  )

  $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
  $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
  if ($showTestResults) {
      $show = 'All'
  } else {
      $show = 'None'
  }

  $originalCode = {
      $global:v4code = Invoke-DbcCheck -SqlInstance $Sqlinstances -Check $Checks -SqlCredential $cred  -legacy $true -Show $show -PassThru
  }

  $NewCode = {
      $global:v5code = Invoke-DbcCheck -SqlInstance $Sqlinstances -Check $Checks -SqlCredential $cred -legacy $false  -Show $show -PassThru
  }

  $originalCodetrace = Trace-Script -ScriptBlock $originalCode
  Remove-Module Pester
  Import-Module Pester -MinimumVersion 5.0.0 -Global
  $NewCodetrace = Trace-Script -ScriptBlock $NewCode

  $originalCodeMessage = "With original Code it takes {0} MilliSeconds" -f $originalCodetrace.StopwatchDuration.TotalMilliseconds

  $savingMessage = "
Running with

{3}

Checks against $($Sqlinstances.Count) SQL Containers

With original Code it takes {1} Seconds
With New Code it takes {4} Seconds

New Code for these {5} checks
is saving {0} seconds
from a run of {1} seconds
New Code runs in {2} % of the time
" -f ('{0:N2}' -f ($originalCodetrace.StopwatchDuration.TotalSeconds - $NewCodetrace.StopwatchDuration.TotalSeconds)), ('{0:N2}' -f $originalCodetrace.StopwatchDuration.TotalSeconds), ('{0:N2}' -f (($NewCodetrace.StopwatchDuration.TotalSeconds / $originalCodetrace.StopwatchDuration.TotalSeconds) * 100)), ($Checks -split ',' -join ',') , ('{0:N2}' -f $NewCodetrace.StopwatchDuration.TotalSeconds), $Checks.Count

  Write-PSFMessage -Message $savingMessage -Level Output

  ##validate we got the right answers too

  If (Compare-Object $v5code.Configuration.Filter.Tag.Value $v4code.TagFilter) {
      $Message = "
Uh-Oh - The Tag filters between v4 and v5 are not the same somehow.
For v4 We returned
{0}
and
For v5 we returned
{1}
" -f ($v4code.TagFilter | Out-String), ($v5code.Configuration.Filter.Tag.Value | Out-String)
      Write-PSFMessage -Message $Message -Level Warning
  } else {
      $message = "
The Tags are the same"
      Write-PSFMessage -Message $Message -Level Output
  }

  $changedTags = @(
      @{
          Name          = 'TraceFlagsExpected'
          RunChange     = 3 # + or - the number of tests run for v5
          PassedChange  = 3 # + or - the number of tests passed for v5
          FailedChange  = 0 # + or - the number of tests failed for v5
          SkippedChange = 0 # + or - the number of tests skipped for v5

      },
      @{
          Name          = 'TraceFlagsNotExpected'
          RunChange     = 3 # + or - the number of tests for v5
          PassedChange  = 3 # + or - the number of tests passed for v5
          FailedChange  = 0 # + or - the number of tests failed for v5
          SkippedChange = 0 # + or - the number of tests skipped for v5
      },
      @{
          Name          = 'XESessionRunningAllowed'
          RunChange     = -12 # + or - the number of tests for v5
          PassedChange  = 0 # + or - the number of tests passed for v5
          FailedChange  = -12 # + or - the number of tests failed for v5
          SkippedChange = 0 # + or - the number of tests skipped for v5
      },
      @{
          Name          = 'LinkedServerConnection'
          RunChange     = -3 # + or - the number of tests for v5
          PassedChange  = -3 # + or - the number of tests passed for v5
          FailedChange  = 0 # + or - the number of tests failed for v5
          SkippedChange = 0 # + or - the number of tests skipped for v5
      },
            @{
          Name          = 'SupportedBuild'
          RunChange     = -3 # + or - the number of tests run for v5
          PassedChange  = -3 # + or - the number of tests passed for v5
          FailedChange  = 0 # + or - the number of tests failed for v5
          SkippedChange = 0 # + or - the number of tests skipped for v5

      }
  )
  $runchange = 0
  $passedchange = 0
  $failedchange = 0
  $skippedchange = 0
  $tagNameMessageAppend = $null
  foreach ($changedTag in $changedTags) {
      if ($v5code.Configuration.Filter.Tag.Value -contains $changedTag.Name) {
          $runchange += $changedTag.RunChange
          $passedchange += $changedTag.PassedChange
          $failedchange += $changedTag.FailedChange
          $skippedchange += $changedTag.SkippedChange
          $tagNameMessageAppend += "tag {0} with:
      - run change {1}
      - passed change {2}
      - failed change {3}
      - skipped change {4}
      " -f $changedTag.Name, $changedTag.RunChange, $changedTag.PassedChange, $changedTag.FailedChange, $changedTag.SkippedChange
      }
  }
  $messageAppend = if ($tagNameMessageAppend) { "although this includes {0}" -f $tagNameMessageAppend } else { '' }

  $v5run = $v5code.TotalCount - $v5code.NotRunCount + $runchange
  $v5Passed = $v5code.PassedCount + $passedchange
  $v5failed = $v5code.FailedCount + $failedchange
  $v5skipped = $v5code.SkippedCount + $skippedchange

  #total checks
  If ($v5run -ne $v4code.TotalCount) {
      $Message = "
Uh-Oh - The total tests run between v4 and v5 are not the same somehow.
For v4 We ran
{0} tests
and
For v5 we ran
{1} tests
The MOST COMMON REASON IS you have used Tags instead of Tag in your Describe block {2}
" -f $v4code.TotalCount, $v5run, $messageAppend
      Write-PSFMessage -Message $Message -Level Warning
  } else {
      $message = "
The Total Tests Run are the same {0} {1}
{2}" -f $v4code.TotalCount, $v5run, $messageAppend
      Write-PSFMessage -Message $Message -Level Output
  }

  #total passed checks
  If ($v5Passed -ne $v4code.PassedCount) {
      $Message = "
Uh-Oh - The total tests Passed between v4 and v5 are not the same somehow.
For v4 We Passed
{0} tests
and
For v5 we Passed
{1} tests
{2}" -f $v4code.PassedCount, $v5Passed, $messageAppend
      Write-PSFMessage -Message $Message -Level Warning
  } else {
      $message = "
The Total Tests Passed are the same {0} {1}
{2}" -f $v4code.PassedCount, $v5Passed, $messageAppend
      Write-PSFMessage -Message $Message -Level Output
  }
  # total failed
  If ($v5failed -ne $v4code.FailedCount) {
      $Message = "
Uh-Oh - The total tests Failed between v4 and v5 are not the same somehow.
For v4 We Failed
{0} tests
and
For v5 we Failed
{1} tests
" -f $v4code.FailedCount, $v5failed
      Write-PSFMessage -Message $Message -Level Warning
  } else {
      $message = "
The Total Tests Failed are the same {0} {1}
{2}" -f $v4code.FailedCount, $v5failed, $messageAppend
      Write-PSFMessage -Message $Message -Level Output
  }

  If ($v5skipped -ne $v4code.SkippedCount) {
      $Message = "
Uh-Oh - The total tests Skipped between v4 and v5 are not the same somehow.
For v4 We Skipped
{0} tests
and
For v5 we Skipped
{1} tests
{2}" -f $v4code.SkippedCount, $v5skipped, $messageAppend
      Write-PSFMessage -Message $Message -Level Warning
  } else {
      $message = "
The Total Tests Skipped are the same {0} {1}
{2}"-f $v4code.SkippedCount, $v5skipped, $messageAppend
      Write-PSFMessage -Message $Message -Level Output
  }
  if ($PerfDetail) {
      $message = "
    Let's take a look at the slowest code as well "
      Write-PSFMessage -Message $Message -Level Output
      $NewCodetrace.Top50SelfDuration| Select SelfPercent,HitCount,Line,Function, Text }
}

Set-PSFConfig -Module JessAndBeard -Name shallweplayagame -Value $true -Initialize -Description "Whether to ask or not" -ModuleExport
