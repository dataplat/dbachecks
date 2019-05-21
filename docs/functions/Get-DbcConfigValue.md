# Get-DbcConfigValue

## SYNOPSIS
Retrieves raw configuration values by name.

## SYNTAX

```
Get-DbcConfigValue [[-Name] <String>] [-EnableException] [<CommonParameters>]
```

## DESCRIPTION
Retrieves raw configuration values by name.

Can be used to search the existing configuration list.

## EXAMPLES

### EXAMPLE 1
```
Get-DbcConfigValue app.sqlinstance
```

Retrieves the raw value for the key "app.sqlinstance"

## PARAMETERS

### -Name
Default: "*"

The name of the configuration element(s) to retrieve.
May be any string, supports wildcards.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: *
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

[https://dbachecks.readthedocs.io/en/latest/functions/Get-DbcConfig/](https://dbachecks.readthedocs.io/en/latest/functions/Get-DbcConfig/)

