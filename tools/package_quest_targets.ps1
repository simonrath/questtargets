param(
    [ValidateSet('All', 'Both', 'Classic', 'TBC', 'Mists', 'Forever', 'Retail', 'Minimal')][string]$Flavor = 'All',
    [switch]$AddonOnly,
    [switch]$CurseForge,
    [ValidatePattern('^\d+\.\d+\.\d+$')][string]$PreviewVersion,
    [string]$OutputDirectory
)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$taskAddon = Join-Path $taskRoot 'QuestTargets'
$taskDist = Join-Path $taskRoot 'dist'
if ($OutputDirectory) { $taskDist = [IO.Path]::GetFullPath($OutputDirectory) }
$taskVersion = (Select-String -LiteralPath (Join-Path $taskAddon 'QuestTargets.toc') -Pattern '^## Version: (.+)$').Matches[0].Groups[1].Value
if ($PreviewVersion) {
    $taskVersion = $PreviewVersion + '-preview.' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff') + 'Z'
}
& (Join-Path $PSScriptRoot 'update_patch_notes.ps1') -Check -Version $taskVersion
$taskClientPins = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'client-versions.json') -Raw | ConvertFrom-Json
$taskInterfaces = (Select-String -LiteralPath (Join-Path $taskAddon 'QuestTargets.toc') -Pattern '^## Interface: (.+)$').Matches[0].Groups[1].Value -split ',\s*'
foreach ($taskClientPin in $taskClientPins.flavors.PSObject.Properties) {
    if ([string]$taskClientPin.Value.interface -notin $taskInterfaces) {
        throw "TOC interface differs from pinned $($taskClientPin.Name) client"
    }
}
$taskRuntimeFiles = @('QuestTargets.toc','Bindings.xml','Core.lua','Locale.lua','Database.lua','Proximity.lua','Resolvers.lua','Scanner.lua','UI.lua','Resize.lua','SettingsRows.xml','Master.lua','QuestieTracker.lua','EllesmereTracker.lua','FlareUITracker.lua','RestedXP.lua','ItemTree.lua','RareScanner.lua','Diagnostics.lua','Main.lua','Textures/QuestCompassUp.tga','Textures/QuestCompassDown.tga','Textures/TransparencyEye.tga','Textures/FeedbackQR.tga','Textures/RarePulse.tga')
$taskRuntimeFiles += @('PatchNotes.lua', 'PatchNotesData.lua', 'Tutorial.lua', 'Textures/TutorialMrrml.tga', 'Textures/PatchNotesGreetings.tga', 'Textures/TargetBarBorder.tga', 'Textures/TargetBarDivider.tga')
$taskRuntimeFiles += @(Get-ChildItem -LiteralPath (Join-Path $taskAddon 'Libs') -File -Recurse | ForEach-Object {
    $_.FullName.Substring($taskAddon.Length + 1).Replace('\', '/')
})
if ($AddonOnly -or $CurseForge) { $Flavor = 'Minimal' }
New-Item -ItemType Directory -Path $taskDist -Force | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

function Add-FileEntry($archive, [string]$sourcePath, [string]$entryName) {
    $entry = $archive.CreateEntry($entryName, [IO.Compression.CompressionLevel]::Optimal)
    $entry.LastWriteTime = [DateTimeOffset]::new(2026, 1, 1, 0, 0, 0, [TimeSpan]::Zero)
    if ($PreviewVersion -and $entryName -eq 'QuestTargets/QuestTargets.toc') {
        $text = [IO.File]::ReadAllText($sourcePath)
        $text = [regex]::Replace($text, '(?m)^## Version: [^\r\n]+', ('## Version: ' + $taskVersion))
        $target = $entry.Open()
        try {
            $bytes = [Text.UTF8Encoding]::new($false).GetBytes($text)
            $target.Write($bytes, 0, $bytes.Length)
        } finally { $target.Dispose() }
        return
    }
    $source = [IO.File]::OpenRead($sourcePath)
    $target = $entry.Open()
    try { $source.CopyTo($target) } finally { $target.Dispose(); $source.Dispose() }
}

# Releases before the rename keep their historical archive names.
$taskArchivePrefix = if ([version]($taskVersion.Split('-')[0]) -ge [version]'1.8.1') { 'Next' } else { 'QuestTargets' }

# Legacy flavor switches remain accepted; every client uses the same archive.
$taskFlavors = @('All')
foreach ($taskFlavor in $taskFlavors) {
    $taskFiles = $taskRuntimeFiles
    foreach ($taskFile in $taskFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $taskAddon $taskFile))) { throw "Missing source: $taskFile" }
    }
    $taskZip = Join-Path $taskDist "$taskArchivePrefix-$taskVersion.zip"
    # Never replace an existing release or preview, including concurrent builds.
    $stream = [IO.File]::Open($taskZip, [IO.FileMode]::CreateNew)
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
