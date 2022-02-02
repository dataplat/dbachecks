# Export-DbcConfig

## SYNOPSIS
Exports dbachecks configs to a json file to make it easier to modify or be used for specific configurations.

## SYNTAX

```
Export-DbcConfig [[-Path] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Exports dbachecks configs to a json file to make it easier to modify or be used for specific configurations.

## EXAMPLES

### EXAMPLE 1
```
Export-DbcConfig
```

Exports config to "$script:localapp\config.json"

### EXAMPLE 2
```
Export-DbcConfig -Path \\nfs\projects\config.json
```

Exports config to \\\\nfs\projects\config.json

### EXAMPLE 3
```
$config = Export-DbcConfig | Invoke-Item
```

Exports config to "$script:localapp\config.json" as and opens it in a default application.

## PARAMETERS

### -Path
The path to export to, by default is "$script:localapp\config.json"

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

### -Force
Overwrite Existing file

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

### System.String
## NOTES

## RELATED LINKS

[https://dbachecks.readthedocs.io/en/latest/functions/Export-DbcConfig/](https://dbachecks.readthedocs.io/en/latest/functions/Export-DbcConfig/)

