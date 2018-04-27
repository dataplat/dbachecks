function Invoke-ConfigurationScript {
    <# 
    .SYNOPSIS
    Invokes the configurations/configuration.ps1 script

    .DESCRIPTION
    This function is necessary to be able to do integration tests of Reset-DbcConfig without affecting the real configuration values
    It is important to be able to validate, that Reset-DbcConfig does not reset too much without affecting live configuration values.
    #>
    [CmdletBinding()]
    param()
    . $script:ModuleRoot\internal\configurations\configuration.ps1
}
