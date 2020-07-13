# Set-DbcConfig

## SYNOPSIS
Sets configuration values for specific checks.

## SYNTAX

```
Set-DbcConfig [[-Name] <String>] [[-Value] <Object>] [[-Handler] <ScriptBlock>] [-Append] [-Temporary]
 [-EnableException] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Changes configuration values which enable each check to have specific thresholds

## EXAMPLES

### EXAMPLE 1
```
Set-DbcConfig -Name app.sqlinstance -Value sql2016, sql2017, sqlcluster
```

Sets the SQL Instances which will be checked by default using Invoke-DbcCheck
to sql2016, sql2017, sqlcluster

### EXAMPLE 2
```
Set-DbcConfig -Name policy.validdbowner.name -Value 'TheBeard\sqldbowner'
```

Sets the value of the configuration for the expected database owners to
TheBeard\sqldbowner

### EXAMPLE 3
```
Set-DbcConfig -Name policy.database.status.excludereadonly -Value 'TheBeard'
```

Sets the value of the configuration for databases that are expected to be readonly
to TheBeard

### EXAMPLE 4
```
Set-DbcConfig -Name agent.validjobowner.name -Value 'TheBeard\SQLJobOwner' -Append
```

Adds 'TheBeard\SQLJobOwner' to the value of the configuration for accounts that
are expected to be owners of SQL Agent Jobs

## PARAMETERS

### -Name
Name of the configuration entry.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
The value to assign.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Handler
A scriptblock that is executed when a value is being set.

Is only executed if the validation was successful (assuming there was a validation, of course)

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Append
Adds the value to the existing configuration instead of overwriting it

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

### -Temporary
The setting is not persisted outside the current session.
By default, settings will be remembered across all powershell sessions.

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
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

[https://dbachecks.readthedocs.io/en/latest/functions/Set-DbcConfig/](https://dbachecks.readthedocs.io/en/latest/functions/Set-DbcConfig/)

