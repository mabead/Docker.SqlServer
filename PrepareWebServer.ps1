param(
    [Parameter(Mandatory)]
    [string]$SqlServerIso,

    [Parameter(Mandatory)]
    [string]$WindowsServerCoreIso,

    [Parameter(Mandatory)]
    [string]$Destination
)

$ErrorActionPreference = 'Stop'

$sqlMount        = Mount-DiskImage -ImagePath $SqlServerIso         -PassThru
$serverCoreMount = Mount-DiskImage -ImagePath $WindowsServerCoreIso -PassThru

try
{
    $sqlRoot        = (Get-DiskImage -ImagePath $sqlMount.ImagePath        | Get-Volume).DriveLetter + ":\"
    $serverCoreRoot = (Get-DiskImage -ImagePath $serverCoreMount.ImagePath | Get-Volume).DriveLetter + ":\"

    Copy-Item -Path (Join-Path $serverCoreRoot 'sources\sxs\microsoft-windows-netfx3-ondemand-package.cab') -Destination $Destination -Force

    Add-Type -assembly "system.io.compression.filesystem"
    [System.IO.Compression.ZipFile]::CreateFromDirectory($sqlRoot, (Join-Path $Destination 'SqlServerInstaller.zip'), 'NoCompression', $true)
}
finally
{
    Dismount-DiskImage -ImagePath $SqlServerIso
    Dismount-DiskImage -ImagePath $WindowsServerCoreIso
}
