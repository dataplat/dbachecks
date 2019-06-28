# Import-DbcConfig

## SYNOPSIS
Imports dbachecks configs from a json file

## SYNTAX

```
Import-DbcConfig [[-Path] <String>] [-Temporary] [-EnableException] [<CommonParameters>]
```

## DESCRIPTION
Imports dbachecks configs from a json file

## EXAMPLES

### EXAMPLE 1
```
Import-DbcConfig
```

Imports config from "$script:localapp\config.json"

### EXAMPLE 2
```
Import-DbcConfig -Path \\nas\projects\config.json
```

Imports config from \\\\nas\projects\config.json

## PARAMETERS

### -Path
The path to import from, by default is "$script:localapp\config.json"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "$script:localapp\config.json"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Temporary
The settings are not persisted outside the current session.
By default, settings will be remembered across all PowerShell sessions.

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

[https://dbachecks.readthedocs.io/en/latest/functions/Import-DbcConfig/](https://dbachecks.readthedocs.io/en/latest/functions/Import-DbcConfig/)

