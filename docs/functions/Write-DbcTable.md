# Write-DbcTable

## SYNOPSIS
Writes the result of Invoke-DbcCheck (with -PassThru) after Convert-DbcResult to a database table

## SYNTAX

```
Write-DbcTable [-SqlInstance] <String> [[-SqlCredential] <PSCredential>] [[-Database] <Object>]
 [-InputObject] <Object> [[-Table] <String>] [[-Schema] <String>] [-Truncate] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
After running Invoke-DbcCheck (With PassThru) and converting it to a datatable with Convert-DbcResult, this command
will write the results to a database table and will also write the current Checks to another table called dbachecksChecks

## EXAMPLES

### EXAMPLE 1
```
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Write-DbcTable -SqlInstance sql2017n5 -Database tempdb -Table newdbachecks
```

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and writes it to a table newdbachecks in tempdb on SQL2017N5 (NB Don't use tempdb!!)

## PARAMETERS

### -SqlInstance
The Instance for the results

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

### -SqlCredential
The SQL Credential for the instance if required

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Database
The database to write the results

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
The datatable from Convert-DbcResult

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Table
The name of the table for the results - will be created if it doesn't exist.
By default it will be named CheckResults

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: CheckResults
Accept pipeline input: False
Accept wildcard characters: False
```

### -Schema
The schema for the table - defaults to dbo

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Dbo
Accept pipeline input: False
Accept wildcard characters: False
```

### -Truncate
Will truncate the existing table (if results go to a staging table for example)

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

### System.String
## NOTES
Initial - RMS 28/12/2019

## RELATED LINKS
