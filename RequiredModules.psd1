@{
    PSDependOptions             = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = 'PSGallery'
        }
    }

    InvokeBuild                 = 'latest'
    PSScriptAnalyzer            = 'latest'
    Pester                      = 'latest'
    Plaster                     = 'latest'
    ModuleBuilder               = 'latest'
    ChangelogManagement         = 'latest'
    Sampler                     = 'latest'
    'Sampler.GitHubTasks'       = 'latest'
    MarkdownLinkCheck           = 'latest'
    'DscResource.Common'        = 'latest'
    'DscResource.Test'          = 'latest'
    'DscResource.AnalyzerRules' = 'latest'
    xDscResourceDesigner        = 'latest'
    'DscResource.DocGenerator'  = 'latest'
}

