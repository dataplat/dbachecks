# dbachecks

Checkin pester stuff. This module will only be available for PS 5+ and in the Gallery. 
No GitHub support download install will be possible since it has dependencies.

## Getting started

When you install from the Gallery, it'll auto-install:

* dbatools
* Pester
* PSFramework

When you import, it'll auto-import

* dbatools
* Pester
* PSFramework

## Getting started for real

```
# Set the servers you'll be working with
Set-DbcConfig -Name SqlInstance -Value sql2016, sql2017, sqlcluster

# Look at the current configs
Get-DbcConfig

# Invoke the one test I wrote so far
Invoke-DbcCheck
```

![image](https://user-images.githubusercontent.com/8278033/34134078-bb26459e-e458-11e7-8e87-9289ab65ba8e.png)

## Notes

* Set-DbcConfig will persist once Fred makes an update to PSFramework
* If you `Set-DbcConfig -Name sqlcredential -Value (Get-Credential sa)` it'll set the SqlCredential for the whole module! but nothing more. So cool.

Same can't be said for WinCredential right now, unfortunately - becuase we aliased Credential to SqlCredential. Sad face.

## Party

Nice work!
