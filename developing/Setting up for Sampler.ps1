# Setting up for Sampler

Install-Module -Name 'Sampler' -Scope 'CurrentUser' -AllowPrerelease
$samplerModule = Import-Module -Name Sampler -PassThru

$invokePlasterParameters = @{
    TemplatePath    = Join-Path -Path $samplerModule.ModuleBase -ChildPath 'Templates/Sampler'
    DestinationPath = '..\'
    ModuleType      = 'CompleteSample'
    ModuleName      = Split-Path -Leaf $PWD
    SourceDirectory = 'source'
}
     

Invoke-Plaster @invokePlasterParameters -Verbose



.\build.ps1 -ResolveDependency -Tasks noop

./build.ps1 -Tasks ?

./build.ps1 -Tasks build
./build.ps1 -Tasks build, tests

# If we get test failures whilst developing, we can check the test results in the browser by creating a html page

.\tests\extent.exe -i .\output\testResults\NUnitXml_dbachecks_v2.0.18.Linux.PSv.7.3.0.xml -o .\output\testResults\reports -r v3html

ii .\output\testResults\reports\index.html # outside of container

# the other option is to the tests with Invoke-Pester

Invoke-Pester ./tests 
