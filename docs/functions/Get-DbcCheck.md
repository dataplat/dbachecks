# Get-DbcCheck

## SYNOPSIS
Lists all checks, tags and unique identifiers

## SYNTAX

```
Get-DbcCheck [[-Tag] <String>] [[-Pattern] <String>] [[-Group] <String>] [<CommonParameters>]
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

### -Tag
The tag to return information about

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

### -Pattern
May be any string, supports wildcards.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Group
To be able to filter by group

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

[https://dbachecks.readthedocs.io/en/latest/functions/Get-DbcCheck/](https://dbachecks.readthedocs.io/en/latest/functions/Get-DbcCheck/)

