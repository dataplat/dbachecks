function Send-DbcMailMessage {
<#
	.SYNOPSIS
	Converts Pester results and emails results

	.DESCRIPTION
	Converts Pester results and emails results

	Wraps the Send-MailMessage cmdlet which sends an e-mail message from within Windows PowerShell.

	.PARAMETER InputObject
	Required. Resultset from Invoke-DbcCheck.

	.PARAMETER To
	Specifies the addresses to which the mail is sent. Enter names (optional) and the e-mail address, such as "Name
	<someone@example.com>". This parameter is required.
		
	.PARAMETER Subject
	Specifies the subject of the e-mail message. Default is "dbachecks results"

	.PARAMETER SmtpServer
	Specifies the name of the SMTP server that sends the e-mail message.

	The default value is the value of the $PSEmailServer preference variable. If the preference variable is not set and this parameter is omitted, the command fails.

	.PARAMETER From
	Specifies the address from which the mail is sent. Enter a name (optional) and e-mail address, such as "Name
	<someone@example.com>". This parameter is required.

	.PARAMETER Cc
	Specifies the e-mail addresses to which a carbon copy (CC) of the e-mail message is sent. Enter names (optional) and the e-mail address, such as "Name <someone@example.com>".

	.PARAMETER Credential
	Specifies a user account that has permission to perform this action. The default is the current user.

	Type a user name, such as "User01" or "Domain01\User01". Or, enter a PSCredential object, such as one from the
	Get-Credential cmdlet.

	.PARAMETER Port
	Specifies an alternate port on the SMTP server. The default value is 25, which is the default SMTP port. This
	parameter is available in Windows PowerShell 3.0 and newer releases.

	.PARAMETER Priority
	Specifies the priority of the e-mail message. The valid values for this are Normal, High, and Low. Normal is the default.

	.PARAMETER DeliveryNotificationOption
	Specifies the delivery notification options for the e-mail message. You can specify multiple values. "None" is the default value.  The alias for this parameter is "dno".

	The delivery notifications are sent in an e-mail message to the address specified in the value of the To parameter.

	Valid values are:

	.PARAMETER - None: No notification.

	.PARAMETER - OnSuccess: Notify if the delivery is successful.

	.PARAMETER - OnFailure: Notify if the delivery is unsuccessful.

	.PARAMETER - Delay: Notify if the delivery is delayed.

	.PARAMETER - Never: Never notify.

	.PARAMETER Bcc
	Specifies the e-mail addresses that receive a copy of the mail but are not listed as recipients of the message.
	Enter names (optional) and the e-mail address, such as "Name <someone@example.com>".

	.PARAMETER Attachments
	Specifies the path and file names of files to be attached to the e-mail message. You can use this parameter or pipe the paths and file names to Send-MailMessage.

	.PARAMETER Body
	Specifies the body (content) of the e-mail message. Automatically provided by this command.

	.PARAMETER BodyAsHtml
	Indicates that the value of the Body parameter contains HTML. Automatically provided by this command.

	.PARAMETER Encoding
	Specifies the encoding used for the body and subject. Valid values are ASCII, UTF8, UTF7, UTF32, Unicode,
	BigEndianUnicode, Default, and OEM. ASCII is the default.

	.PARAMETER UseSsl
	Uses the Secure Sockets Layer (SSL) protocol to establish a connection to the remote computer to send mail. By
	default, SSL is not used.

	.PARAMETER EnableException
	By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
	This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
	Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.
		
	.EXAMPLE
	Invoke-DbcCheck -SqlInstance sql2017 -Tags SuspectPage, LastBackup -OutputFormat NUnitXml -PassThru | 
	Send-DbcMailMessage -To clemaire@dbatools.io -From nobody@dbachecks.io -SmtpServer smtp.ad.local
		
	Runs two tests against sql2017 and sends a mail message

#>
	[CmdletBinding()]
	param (
		[parameter(ValueFromPipeline, Mandatory)]
		[pscustomobject]$InputObject,
		[parameter(Mandatory)]
		[string[]]$To,
		[string]$From,
		[string]$Subject,
		[string]$Body,
		[string]$SmtpServer,
		[int]$Port,
		[string]$Priority,
		[string[]]$Attachments,
		[string[]]$Bcc,
		[string[]]$Cc,
		[switch]$BodyAsHtml,
		[PSCredential]$Credential,
		[string]$DeliveryNotificationOption,
		# None | OnSuccess | OnFailure | Delay | Never

		[string]$Encoding,
		[switch]$UseSsl,
		[string]$EnableException
	)
	end {
		if (Test-PSFParameterBinding -ParameterName Subject -Not) {
			$PSBoundParameters['Subject'] = "dbachecks results"
		}
		
		$outputpath = "$script:maildirectory\index.html"
		$reportunit = "$script:ModuleRoot\bin\ReportUnit.exe"
		
		if (-not (Test-Path -Path $script:maildirectory)) {
			try {
				$null = New-Item -ItemType Directory -Path $script:maildirectory
			}
			catch {
				Stop-PSFFunction -Message "Failure" -ErrorRecord $_
				return
			}
		}
		
		if (-not ($files = Get-ChildItem -Path "$script:maildirectory\*.xml")) {
			Stop-PSFFunction -Message "Oops, $("$script:maildirectory\*.xml") does not exist"
			return
		}
		
		foreach ($file in $files) {
			$xml = [xml](Get-Content $file.FullName)
			$total = $xml.'test-results'.Total
			if ($total -eq 0) {
				$file | Remove-Item -ErrorAction SilentlyContinue
				Write-PSFMessage -Level Verbose -Message "Removed $file because it contained 0 total test results"
			}
			else {
				# I give up trynna parse this to CSV
				#$xml.'test-results'.'test-suite'.results
				$Attachments += $file
			}
		}
		
		if (Get-ChildItem -Path "$script:maildirectory\*.xml") {
			try {
				# Output report
				& $reportunit $script:maildirectory
				
				# Get HTML varaible
				$htmlbody = Get-Content -Path $outputpath -ErrorAction SilentlyContinue | Out-String
				
				# Modify the params as required
				$null = $PSBoundParameters.Remove("InputObject")
				$PSBoundParameters['Body'] = $htmlbody
				$PSBoundParameters['BodyAsHtml'] = $true
				if ($Attachments) {
					$PSBoundParameters['Attachments'] = $Attachments
				}
				try {
					Send-MailMessage -ErrorAction Stop @PSBoundParameters
				}
				catch {
					Stop-PSFFunction -Message "Failure" -ErrorRecord $_
					return
				}
			}
			catch {
				Stop-PSFFunction -Message "Failure" -ErrorRecord $_
				return
			}
			
			Get-ChildItem -Path "$script:maildirectory\*.*" | Remove-Item -ErrorAction SilentlyContinue
		}
		if (-not $InputObject) {
			Stop-PSFFunction -Message "InputObject is null. Did you forget to specify -Passthru for your previous command?"
			return
		}
	}
}