# Save-DbcRequiredModules

## SYNOPSIS
Saves all required modules, including dbachecks, dbatools, Pester and PSFramework to a directory.
Ideal for offline installs.

## SYNTAX

```
Save-DbcRequiredModules [-Path] <String> [-EnableException] [<CommonParameters>]
```

## DESCRIPTION
Saves all required modules, including dbachecks, dbatools, Pester and PSFramework to a directory.
Ideal for offline installs.

## EXAMPLES

### EXAMPLE 1
```
Save-DbcRequiredModules -Path C:\temp\downlaods
```

Saves all required modules and dbachecks to C:\temp\downloads

## PARAMETERS

### -Path
The directory where the modules will be saved.
Directory will be created if it does not exist.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableException
By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://dbachecks.readthedocs.io/en/latest/functions/Save-DbcRequiredModules/](https://dbachecks.readthedocs.io/en/latest/functions/Save-DbcRequiredModules/)

