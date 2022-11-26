$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName


Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe Get-PrivateFunction {
        Context 'Default' {
            BeforeEach {
                $return = Get-PrivateFunction -PrivateData 'string'
            }

            It 'Returns a single object' {
                ($return | Measure-Object).Count | Should -Be 1
            }

            It 'Returns a string based on the parameter PrivateData' {
                $return | Should -Be 'string'
            }
        }
    }
}
