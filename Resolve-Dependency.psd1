@{
    #PSDependTarget  = './output/modules'
    #Proxy = ''
    #ProxyCredential = '$MyCredentialVariable' #TODO: find a way to support credentials in build (resolve variable)

    Gallery         = 'PSGallery'

    # To use a private nuget repository change the following to your own feed. The locations must be a Nuget v2 feed due
    # to limitation in PowerShellGet v2.x. Example below is for a Azure DevOps Server project-scoped feed. While resolving
    # dependencies it will be registered as a trusted repository with the name specified in the property 'Gallery' above,
    # unless property 'Name' is provided in the hashtable below, if so it will override the property 'Gallery' above. The
    # registered repository will be removed when dependencies has been resolved, unless it was already registered to begin
    # with. If repository is registered already but with different URL:s the repository will be re-registered and reverted
    # after dependencies has been resolved. Currently only Windows integrated security works with private Nuget v2 feeds
    # (or if it is a public feed with no security), it is not possible yet to securely provide other credentials for the feed.
    #RegisterGallery = @{
    #    #Name = 'MyPrivateFeedName'
    #    GallerySourceLocation = 'https://azdoserver.company.local/<org_name>/<project_name>/_packaging/<feed_name>/nuget/v2'
    #    GalleryPublishLocation = 'https://azdoserver.company.local/<org_name>/<project_name>/_packaging/<feed_name>/nuget/v2'
    #    GalleryScriptSourceLocation = 'https://azdoserver.company.local/<org_name>/<project_name>/_packaging/<feed_name>/nuget/v2'
    #    GalleryScriptPublishLocation = 'https://azdoserver.company.local/<org_name>/<project_name>/_packaging/<feed_name>/nuget/v2'
    #    #InstallationPolicy = 'Trusted'
    #}

    #AllowOldPowerShellGetModule = $true
    #MinimumPSDependVersion = '0.3.0'
    AllowPrerelease = $false
    WithYAML        = $true # Will also bootstrap PowerShell-Yaml to read other config files
}

