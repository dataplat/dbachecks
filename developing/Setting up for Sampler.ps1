# Setting up for Sampler

Install-Module -Name 'Sampler' -Scope 'CurrentUser' -AllowPrerelease
$samplerModule = Import-Module -Name Sampler -PassThru

$invokePlasterParameters = @{
    TemplatePath    = Join-Path -Path $samplerModule.ModuleBase -ChildPath 'Templates/Sampler'
    DestinationPath = '..\'
    ModuleType      = 'dsccommunity'
    ModuleName      = Split-Path -Leaf $PWD
    SourceDirectory = 'source'
}
     

Invoke-Plaster @invokePlasterParameters -Verbose



.\build.ps1 -ResolveDependency -Tasks noop

./build.ps1 -Tasks ?

./build.ps1 -Tasks build
./build.ps1 -Tasks tests