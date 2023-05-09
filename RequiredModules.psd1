@{
    PSDependOptions       = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = 'PSGallery'
        }
    }

    'dbatools.library'    = 'latest'
    InvokeBuild           = 'latest'
    PSScriptAnalyzer      = 'latest'
    Pester                = 'latest'
    Plaster               = 'latest'
    ModuleBuilder         = 'latest'
    ChangelogManagement   = 'latest'
    Sampler               = 'latest'
    'Sampler.GitHubTasks' = 'latest'
    MarkdownLinkCheck     = 'latest'
    dbatools              = 'latest'
    PSFramework           = 'latest'
}

