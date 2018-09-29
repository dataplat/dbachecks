# Set-DbcConfig

## SYNOPSIS
Sets configuration entries.

## SYNTAX

```
Set-DbcConfig [[-Name] <String>] [[-Value] <Object>] [[-Handler] <ScriptBlock>] [-Append] [-Temporary]
 [-EnableException] [<CommonParameters>]
```

## DESCRIPTION
This function creates or changes configuration values.

These can be used to provide dynamic configuration information outside the PowerShell variable system.

## EXAMPLES

### EXAMPLE 1
```
Set-DbcConfig -Name Lists.SqlServers -Value sql2016, sql2017, sqlcluster
```

Resets the lists.sqlservers entry to sql2016, sql2017, sqlcluster

### EXAMPLE 2
```
Set-DbcConfig -Name Lists.SqlServers -Value sql2016, sql2017, sqlcluster -Append
```

Addds on to the current lists.sqlservers entry with sql2016, sql2017, sqlcluster

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
The value to assign to the named configuration element.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
