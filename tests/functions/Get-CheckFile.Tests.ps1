Remove-Module dbachecks -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\dbachecks.psd1"

. "$PSScriptRoot/../../internal/functions/Get-CheckFile.ps1"

Describe "Testing Get-CheckFile function" {
    Mock Get-ChildItem {
        return @(
            @{ Name = "One.Tests.ps1"; FullName = "C:\Checks\One.Tests.ps1" },
            @{ Name = "Two.Tests.ps1"; FullName = "C:\Checks\Two.Tests.ps1" },
            @{ Name = "Three.Tests.ps1"; FullName = "C:\Checks\Three.Tests.ps1" }
        )
    } -ParameterFilter { $Path }

    Mock Get-Content {
        return "
# some comments to start with

Describe `"First fake check`" -Tags FirstCheck {
    Context `"Some context`" {
    }
}

Describe `"Second fake check`" -Tags SecondCheck, `$filename {
    Context `"Some context`" {
    }
}

Describe `"Third fake check`" -Tags ThirdCheck, `$filename {
    Context `"Some context`" {
    }
}
        ".Split([Environment]::NewLine)
    } -ParameterFilter { $Path -eq "C:\Checks\One.Tests.ps1" }

    Mock Get-Content {
        return "
`$filename = `$MyInvocation.MyCommand.Name.Replace(`".Tests.ps1`", `"`")

Describe `"Fourth fake check`" -Tags FourthCheck, CommonTag, `$filename {
    Context `"Some context`" {
    }
}

Describe `"Fifth fake check`" -Tags FifthCheck,CommonTag,`$filename {
    Context `"Some context`" {
    }
}

# some comments at the end of a file, perhaps a function definition
function Get-MeSomeStuff {
    param([string]`$whatToGet)
    process { }
}
        ".Split([Environment]::NewLine)
    } -ParameterFilter { $Path -eq "C:\Checks\Two.Tests.ps1" }

    Mock Get-Content {
        return "
Describe `"Sixth fake check`" -Tags `"SixthCheck`" {
    Context `"Some context`" {
    }
}
        ".Split([Environment]::NewLine)
    } -ParameterFilter { $Path -eq "C:\Checks\Three.Tests.ps1" }

    Context "Testing with files matching by name" {
        $cases = @(
            @{ CheckValue = "One"; MatchingFile = "C:\Checks\One.Tests.ps1" }
            @{ CheckValue = "Two"; MatchingFile = "C:\Checks\Two.Tests.ps1" }
            @{ CheckValue = "Three"; MatchingFile = "C:\Checks\Three.Tests.ps1" }
        )

        It "<MatchingFile> is found when Check is <CheckValue>" -TestCases $cases {
            param([String]$CheckValue, [String]$MatchingFile)
            $result = @(Get-CheckFile -Repo "FakeRepo" -Check $CheckValue)
            $result.Count | Should -Be 1 -Because "we expect exactly one file"
            $result[0] | Should -Be $MatchingFile -Because "we expect specific file"
        }

        It "When two files match, both should be returned" {
            $result = @(Get-CheckFile -Repo "FakeRepo" -Check One,three)
            $result.Count | Should -Be 2 -Because "we expect exactly two files, one and three"
        }
    }

    Context "Testing with files matching by tag" {
        $cases = @(
            @{ CheckValue = "FirstCheck"; MatchingFile = "C:\Checks\One.Tests.ps1" }
            @{ CheckValue = "SecondCheck"; MatchingFile = "C:\Checks\One.Tests.ps1" }
            @{ CheckValue = "ThirdCheck"; MatchingFile = "C:\Checks\One.Tests.ps1" }
            @{ CheckValue = "FourthCheck"; MatchingFile = "C:\Checks\Two.Tests.ps1" }
            @{ CheckValue = "FifthCheck"; MatchingFile = "C:\Checks\Two.Tests.ps1" }
            @{ CheckValue = "SixthCheck"; MatchingFile = "C:\Checks\Three.Tests.ps1" }
        )

        It "<MatchingFile> is found when Check is <CheckValue>" -TestCases $cases {
            param([String]$CheckValue, [String]$MatchingFile)
            $result = @(Get-CheckFile -Repo "FakeRepo" -Check $CheckValue)
            $result.Count | Should -Be 1 -Because "we expect exactly one file"
        }

        It "When two files match, both should be returned" {
            $result = @(Get-CheckFile -Repo "FakeRepo" -Check SecondCheck,SixthCheck)
            $result.Count | Should -Be 2 -Because "we expect exactly two files, one and three"
        }
    }

    Context "Testing to make sure duplicates are not returned" {
        $cases = @(
            @{ CheckValue = "One,FirstCheck"; MatchingFile = "C:\Checks\One.Tests.ps1" }
            @{ CheckValue = "One,FirstCheck,SecondCheck"; MatchingFile = "C:\Checks\One.Tests.ps1" }
            @{ CheckValue = "Two,FourthCheck,InvalidCheck"; MatchingFile = "C:\Checks\Two.Tests.ps1" }
            @{ CheckValue = "Three,Three,Three"; MatchingFile = "C:\Checks\Three.Tests.ps1" }
        )

        It "<MatchingFile> is found when Check is <CheckValue>" -TestCases $cases {
            param([String]$CheckValue, [String]$MatchingFile)
            $result = @(Get-CheckFile -Repo "FakeRepo" -Check $CheckValue.Split(","))
            $result.Count | Should -Be 1 -Because "we expect exactly one file"
        }
    }
    # test for duplicates


    Context "Testing things that don't match" {
        It "If there is no match, no file should be returned" {
            $result = @(Get-CheckFile -Repo "FakeRepo" -Check "NotMatchingAnything")
            $result.Count | Should -Be 0 -Because "we don't expect any matches to NotMatchingAnything"
        }
    }
}