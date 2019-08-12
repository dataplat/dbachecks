# Reset-DbcConfig

## SYNOPSIS
Resets configuration entries to their default values.

## SYNTAX

```
Reset-DbcConfig [[-Name] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
This function unregisters configuration values and then registers them back with the default values and type.

This can be used to get the dbachecks back to default state of configuration, or to resolve problems with a specific setting.

## EXAMPLES

### EXAMPLE 1
```
Reset-DbcConfig
```

Resets all the configuration values for dbachecks.

### EXAMPLE 2
```
Reset-DbcConfig -Name policy.recoverymodel.type
```

Resets the policy.recoverymodel.type to the default value and type.

## PARAMETERS

### -Name
Name of the configuration key.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://dbachecks.readthedocs.io/en/latest/functions/Reset-DbcConfig/](https://dbachecks.readthedocs.io/en/latest/functions/Reset-DbcConfig/)

