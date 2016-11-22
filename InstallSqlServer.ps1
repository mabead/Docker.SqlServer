param(
    [Parameter(Mandatory)]
    [string]$SaPassword,

    [Parameter(Mandatory)]
    [string]$PrerequisitesRootUrl
)
$ErrorActionPreference = 'Stop'

Write-Host "$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') : Installing sql server with sa password '$SaPassword'"

$workFolder           = 'c:\SqlServerInstallation'
$workTempFolder       = Join-Path $workFolder 'tmp'

$netfxTempFolder      = Join-Path $workTempFolder 'netfx'
$netfxCabFile         = Join-Path $netfxTempFolder 'microsoft-windows-netfx3-ondemand-package.cab'

$sqlServerTempFolder  = Join-Path $workTempFolder 'sql'
$sqlServerZip         = Join-Path $sqlServerTempFolder 'SqlServerInstaller.zip'

New-Item $workTempFolder      -ItemType Directory > $null
New-Item $netfxTempFolder     -ItemType Directory > $null
New-Item $sqlServerTempFolder -ItemType Directory > $null

$webClient = New-Object System.Net.WebClient

Write-Host "$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') : Downloading netfx cab file"
$webClient.DownloadFile("$PrerequisitesRootUrl/microsoft-windows-netfx3-ondemand-package.cab", $netfxCabFile)

Write-Host "$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') : Installing netfx 3"
Install-WindowsFeature Net-Framework-Core -source $netfxTempFolder

Write-Host "$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') : Download sql setup"
$webClient.DownloadFile("$PrerequisitesRootUrl/SqlServerInstaller.zip", $sqlServerZip)

Write-Host "$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') : Uncompress SQL setup"
Expand-Archive -Path $sqlServerZip -DestinationPath $sqlServerTempFolder

Write-Host "$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') : Installing sql server"
$sqlSetup  = Join-Path $sqlServerTempFolder 'setup.exe'
& $sqlSetup '/IACCEPTSQLSERVERLICENSETERMS' "/ConfigurationFile=$workFolder\SqlServerConfiguration.ini" "/SAPWD=$SaPassword"

if ($LASTEXITCODE -ne 0) 
{
    throw "SqlServer installation failed with code $LASTEXITCODE"
}

Write-Host "$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') : Cleaning up"
Remove-Item -Recurse -Force $workTempFolder

Write-Host "$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') : Done"
