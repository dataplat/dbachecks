$Config = (Get-Content TestConfig.JSON) -join "`n" | ConvertFrom-Json
$Date = Get-Date -Format ddMMyyyHHmmss
$XML = $Config.XMLHTML.Path + $Config.XMLHTML.FileName + "_$Date.xml"
Set-Location $Config.XMLHTML.pesterLocation
Invoke-Pester -OutputFile $xml -OutputFormat NUnitXml

#download and extract ReportUnit.exe
Set-Location $Config.XMLHTML.Path 
$url = 'http://relevantcodes.com/Tools/ReportUnit/reportunit-1.2.zip'
$reportunit = $Config.XMLHTML.Path + '\reportunit.exe'
if((Test-Path $reportunit) -eq $false)
{
(New-Object Net.WebClient).DownloadFile($url,$fullPath)
Expand-Archive -Path $fullPath -DestinationPath $Config.XMLHTML.Path
}

#run reportunit against report.xml and display result in browser
$HTML = $Config.XMLHTML.Path + 'index.html'
& .\reportunit.exe $Config.XMLHTML.Path
Invoke-Item $HTML
