# Invoke-DbcConfigFile

## SYNOPSIS
Opens the default location of the json config file for easy edits.

## SYNTAX

```
Invoke-DbcConfigFile [[-Path] <String>] [-EnableException] [<CommonParameters>]
```

## DESCRIPTION
Opens the default location of the json config file for easy edits.
Follow with Import-DbcConfig to import changes.

## EXAMPLES

### EXAMPLE 1
```
Invoke-DbcConfigFile
```

Opens "$script:localapp\config.json" for editing.
Follow with Import-DbcConfig.

## PARAMETERS

### -Path
The path to open, by default is "$script:localapp\config.json"

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

[https://dbachecks.readthedocs.io/en/latest/functions/Invoke-DbcConfigFile/](https://dbachecks.readthedocs.io/en/latest/functions/Invoke-DbcConfigFile/)

