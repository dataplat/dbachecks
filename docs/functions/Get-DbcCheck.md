# Get-DbcCheck

## SYNOPSIS
Lists all checks, tags and unique identifiers

## SYNTAX

```
Get-DbcCheck [[-Pattern] <String>] [-EnableException] [<CommonParameters>]
```

## DESCRIPTION
Lists all checks, tags and unique identifiers

## EXAMPLES

### EXAMPLE 1
```
Get-DbcCheck
```

Retrieves all of the available checks

### EXAMPLE 2
```
Get-DbcCheck backups
```

Retrieves all of the available tags that match backups

## PARAMETERS

### -Pattern
May be any string, supports wildcards.

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

[https://dbachecks.readthedocs.io/en/latest/functions/Get-DbcCheck/](https://dbachecks.readthedocs.io/en/latest/functions/Get-DbcCheck/)

