<#
.SYNOPSIS
Tests common Windows remote-work connectivity and client readiness.
#>
[CmdletBinding()]
param(
    [string[]]$Endpoint=@('login.microsoftonline.com','outlook.office365.com','teams.microsoft.com','onedrive.live.com'),
    [string]$OutputRoot="$env:PUBLIC\Documents\RemoteWorkReadinessReports"
)

Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$runPath=Join-Path $OutputRoot ("RemoteWork_{0}_{1}" -f $env:COMPUTERNAME,(Get-Date -Format 'yyyyMMdd_HHmmss'))
$results=New-Object System.Collections.Generic.List[object]

try{
    if($env:OS -ne 'Windows_NT'){throw 'Windows is required.'}
    New-Item $runPath -ItemType Directory -Force|Out-Null

    Get-NetAdapter -ErrorAction SilentlyContinue|
        Select-Object Name,InterfaceDescription,Status,LinkSpeed,MacAddress|
        Export-Csv (Join-Path $runPath 'NetworkAdapters.csv') -NoTypeInformation
    Get-NetIPConfiguration -ErrorAction SilentlyContinue|
        Export-Clixml (Join-Path $runPath 'IPConfiguration.xml')
    netsh.exe winhttp show proxy 2>&1|Out-File (Join-Path $runPath 'Proxy.txt')

    foreach($target in $Endpoint){
        $dns=$false;$https=$false;$address=''
        try{
            $resolved=Resolve-DnsName $target -ErrorAction Stop|Where-Object IPAddress|Select-Object -First 1
            $dns=$true;$address=$resolved.IPAddress
        }catch{}
        try{$https=(Test-NetConnection $target -Port 443 -WarningAction SilentlyContinue).TcpTestSucceeded}catch{}
        $results.Add([pscustomobject]@{Endpoint=$target;DnsResolved=$dns;Address=$address;Https443=$https})
    }

    $results|Export-Csv (Join-Path $runPath 'EndpointTests.csv') -NoTypeInformation

    Get-NetAdapter -ErrorAction SilentlyContinue|Where-Object{$_.InterfaceDescription -match 'VPN|TAP|Tunnel|WireGuard|AnyConnect'}|
        Select-Object Name,InterfaceDescription,Status,LinkSpeed|
        Export-Csv (Join-Path $runPath 'VpnAdapters.csv') -NoTypeInformation

    $clientPaths=@(
        "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe",
        "$env:ProgramFiles\Microsoft OneDrive\OneDrive.exe",
        "$env:LOCALAPPDATA\Microsoft\WindowsApps\ms-teams.exe"
    )
    $clientPaths|ForEach-Object{[pscustomobject]@{Path=$_;Exists=(Test-Path $_)}}|
        Export-Csv (Join-Path $runPath 'ClientPaths.csv') -NoTypeInformation
    Get-Process OneDrive,ms-teams,Teams -ErrorAction SilentlyContinue|
        Select-Object Name,Id,StartTime,WorkingSet|
        Export-Csv (Join-Path $runPath 'ClientProcesses.csv') -NoTypeInformation

    $results|ConvertTo-Html -Title 'Remote Work Readiness' -PreContent "<h1>Remote Work Readiness</h1><p>$env:COMPUTERNAME - $(Get-Date)</p>"|
        Out-File (Join-Path $runPath 'RemoteWorkReadiness.html') -Encoding UTF8

    $failed=@($results|Where-Object{-not $_.DnsResolved -or -not $_.Https443}).Count
    Write-Host "[OK] Report created: $runPath" -ForegroundColor Green
    if($failed -gt 0){exit 2}else{exit 0}
}catch{Write-Error $_.Exception.Message;exit 1}
