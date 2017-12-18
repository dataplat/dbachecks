# dbachecks

When you install, it'll auto-install:

* dbatools
* Pester
* PSFramework

When you import, it'll auto-import

* dbatools
* Pester
* PSFramework

## Getting started

```
Set-DbcConfig -Name SqlInstance -Value sql2016, sql2017, sqlcluster
Get-DbcConfig
Invoke-DbcCheck
```

## Notes

* Set-DbcConfig will persist once Fred makes an update to PSFramework
* If you `Set-DbcConfig -Name sqlcredential -Value (Get-Credential sa)` it'll set the SqlCredential for the whole module! but nothing more. So cool.

Same can't be said for WinCredential right now, unfortunately - becuase we aliased Credential to SqlCredential. Sad face.

## Party

Nice work!