param(
    [ValidateSet('All', 'Both', 'Classic', 'TBC', 'Mists', 'Forever', 'Retail', 'Minimal')][string]$Flavor = 'All',
    [switch]$AddonOnly,
    [switch]$CurseForge
)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$taskAddon = Join-Path $taskRoot 'QuestTargets'
$taskDist = Join-Path $taskRoot 'dist'
$taskVersion = (Select-String -LiteralPath (Join-Path $taskAddon 'QuestTargets.toc') -Pattern '^## Version: (.+)$').Matches[0].Groups[1].Value
$taskClientPins = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'client-versions.json') -Raw | ConvertFrom-Json
$taskInterfaces = (Select-String -LiteralPath (Join-Path $taskAddon 'QuestTargets.toc') -Pattern '^## Interface: (.+)$').Matches[0].Groups[1].Value -split ',\s*'
foreach ($taskClientPin in $taskClientPins.flavors.PSObject.Properties) {
    if ([string]$taskClientPin.Value.interface -notin $taskInterfaces) {
        throw "TOC interface differs from pinned $($taskClientPin.Name) client"
    }
}
$taskRuntimeFiles = @('QuestTargets.toc','Bindings.xml','Core.lua','Locale.lua','Database.lua','Proximity.lua','Resolvers.lua','Scanner.lua','UI.lua','SettingsCaption.xml','Master.lua','QuestieTracker.lua','RestedXP.lua','Diagnostics.lua','Main.lua','Textures/QuestCompassUp.tga','Textures/QuestCompassDown.tga','Textures/TransparencyEye.tga')
if ($AddonOnly -or $CurseForge) { $Flavor = 'Minimal' }
New-Item -ItemType Directory -Path $taskDist -Force | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

function Add-FileEntry($archive, [string]$sourcePath, [string]$entryName) {
    $entry = $archive.CreateEntry($entryName, [IO.Compression.CompressionLevel]::Optimal)
    $entry.LastWriteTime = [DateTimeOffset]::new(2026, 1, 1, 0, 0, 0, [TimeSpan]::Zero)
    $source = [IO.File]::OpenRead($sourcePath)
    $target = $entry.Open()
    try { $source.CopyTo($target) } finally { $target.Dispose(); $source.Dispose() }
}

# Legacy flavor switches remain accepted; every client uses the same archive.
$taskFlavors = @('All')
foreach ($taskFlavor in $taskFlavors) {
    $taskFiles = $taskRuntimeFiles
    foreach ($taskFile in $taskFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $taskAddon $taskFile))) { throw "Missing source: $taskFile" }
    }
    $taskZip = Join-Path $taskDist "QuestTargets-$taskVersion.zip"
    $stream = [IO.File]::Open($taskZip, [IO.FileMode]::Create)
    $archive = [IO.Compression.ZipArchive]::new($stream, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($file in $taskFiles) {
            Add-FileEntry $archive (Join-Path $taskAddon $file) ('QuestTargets/' + $file.Replace('\', '/'))
        }
    } finally { $archive.Dispose(); $stream.Dispose() }
    $check = [IO.Compression.ZipFile]::OpenRead($taskZip)
    try {
        foreach ($file in $taskFiles) {
            if (-not $check.GetEntry('QuestTargets/' + $file.Replace('\', '/'))) { throw "Missing ZIP entry: $file" }
        }
        if (@($check.Entries | Where-Object { -not $_.FullName.StartsWith('QuestTargets/') }).Count) {
            throw 'Unexpected addon in release ZIP'
        }
    } finally { $check.Dispose() }
    Get-Item -LiteralPath $taskZip | Select-Object FullName, Length
}
