Function Install-PreReq{
    <#
    .SYNOPSIS
        Installs prerequisites for the DbaCheck module

    
    .DESCRIPTION
        Parses the module manifest and installs any prerquisites
    
    .PARAMETER Scope



    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
	param(
    
        [validateset('Global','Local')]
        [String]$Scope
    )
    BEGIN {
        $isElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }

    PROCESS {
        if ( -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-warning -Message "Must be run as administrator, exiting"
            return
        }

        $ModuleManifest = Import-PowerShellDataFile -Path .\dbachecks.psd1
        ForEach ($Module in $ModuleManifest.RequiredModules){
            $output = "NotImported"
            if ((Get-Module -Name $Module.ModuleName -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -first 1).version -ge $Module.ModuleVersion){
                #Suitable module version held locally, try forcing an import
                Try{
                    $Output = Import-Module $Module.ModuleName -MinimumVersion $Module.ModuleVersion -force -WarningAction Stop 
                    Write-Output "Imported $($Module.ModuleName)"   
                }
                catch {
                    Write-Warning -Message "Could not not install $($Module.ModuleName) version $($Module.ModuleVersion) from local source" 
                }
            }

            if ($Output -eq 'NotImported'){
                if ((Get-PsRepository -Name PsGallery).SourceLocation -ne 'https://www.powershellgallery.com/api/v2/'){
                    Write-Warning -Message "Using a non standard repository, cannot guarantee you'll get the right modules"
                }
                Write-Output "Installing $($Module.ModuleName)"
                if ($pscmdlet.ShouldProcess("Install $($Module.ModuleName) version $($Module.ModuleVersion) from repository")) {

                    try {
                        Install-Module -Name $Module.ModuleName -MinimumVersion $Module.ModuleVersion 
                    }
                    catch {
                        if ($_.exception.Message -like '*No match was found for the specified search criteria and module name*'){
                            Write-Warning -Message "Module $($Module.ModuleName) version $($Module.ModuleVersion) could not be installed " 
                        }
                        else {
                            Write-Warning -Message "Error installing module $($Module.ModuleName): $_"
                        }
                        continue            
                    }
                }
                try {
                    $Output = Import-Module $Module.ModuleName -MinimumVersion $Module.ModuleVersion -force -ErrorAction Stop
                }
                catch {
                    Write-Warning -Message "Error importing $($Module.ModuleName): $_"
                }
            }
        }
    }
}