<#
.DESCRIPTION
    Script to extract XD session activity summary data by minute for accurate peak usage count.
    to be setup as scheduled task to run every 3 hours on one of the delivery controllers 
.NOTES
    File Name      : SessionActivitySummariesByMinute-ODATA.ps1
    Author         : Siva Mulpuru [sivamulpuru.com]
#>

Function Get-LocalTime($UTCTime)
{
$strCurrentTimeZone = "Eastern Standard Time"
$TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
$LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTCTime, $TZ)
Return $LocalTime
}

$datescope = (get-date).AddHours(-3).ToUniversalTime()
$datescope = get-date($datescope) -Format s
$filename = "SSH-SessionActivitySummariesByMinute-" + (get-date ($datescope) -f "MM-yyyy") + ".csv"
$uri = "http://localhost/Citrix/Monitor/OData/v3/Data/SessionActivitySummaries()?`$filter=Granularity eq 1 and SummaryDate gt DateTime`'$datescope`' &`$select=DesktopGroup/Name,SummaryDate,ConcurrentSessionCount,ConnectedSessionCount,DisconnectedSessionCount&`$orderby=SummaryDate asc&`$expand=DesktopGroup&`$format=json"
$records = Invoke-RestMethod -Uri $uri -UseDefaultCredentials
$records.value | Select-Object @{Name='SummaryDateEST';Expression={Get-LocalTime($_.SummaryDate)}},ConcurrentSessionCount,ConnectedSessionCount,DisconnectedSessionCount,@{Name='DesktopGroupName';Expression={$_.DesktopGroup.Name}} | Export-csv .\$filename -NoTypeInformation -Append

<#
Scrach Notes
ConnectedSessionCount
DesktopGroup
DisconnectedSessionCount
Granularity
SummaryDate
TotalLogOnCount
TotalLogOnDuration
http://localhost/Citrix/Monitor/OData/v3/Data/SessionActivitySummaries()?`$filter=day(SummaryDate) eq $day and Granularity eq 1 and DesktopGroup/Name eq `'Win10-Standard`'
ref >> https://www.odata.org/documentation/odata-version-3-0/url-conventions/
#>
