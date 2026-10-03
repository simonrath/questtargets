param(
    [ValidateSet('All', 'Both', 'Classic', 'TBC', 'Mists', 'Forever', 'Retail', 'Minimal')][string]$Flavor = 'All',
    [string]$ProviderCache,
    [switch]$AddonOnly,
    [switch]$CurseForge
)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$taskAddon = Join-Path $taskRoot 'QuestTargets'
$taskDist = Join-Path $taskRoot 'dist'
$taskVersion = (Select-String -LiteralPath (Join-Path $taskAddon 'QuestTargets.toc') -Pattern '^## Version: (.+)$').Matches[0].Groups[1].Value
$taskRuntimeFiles = @('QuestTargets.toc','Core.lua','Locale.lua','Database.lua','Proximity.lua','Resolvers.lua','Scanner.lua','UI.lua','Master.lua','QuestieTracker.lua','RestedXP.lua','Main.lua','Textures/QuestCompassUp.tga','Textures/QuestCompassDown.tga','Textures/TransparencyEye.tga')
if ($AddonOnly -or $CurseForge) { $Flavor = 'Minimal' }
if (-not $ProviderCache) { $ProviderCache = Join-Path $env:TEMP 'quest-targets-questiedb-v1.0.4' }
New-Item -ItemType Directory -Path $taskDist -Force | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

# Pinned to QuestieDB v1.0.4 release.json. Do not use a moving release URL.
$taskProviders = @{
    Classic = @{ Artifact = 'Vanilla'; Sha256 = 'cf0ac8dfd6b0986a0624db6364d4e42a3691089663b8b00122d8ae2b2d040eed'; Toc = 'QuestieDB_Vanilla.toc' }
    TBC = @{ Artifact = 'TBC'; Sha256 = '5b2c398579425b22171e25bd7396268117caaed0f61b19785b81158e3988bf26'; Toc = 'QuestieDB_TBC.toc' }
    Mists = @{ Artifact = 'Mists'; Sha256 = 'cf2e33ccc6e8fd4b4a827fa3b7d33e70a37301ed3123edb618a806205bd542b6'; Toc = 'QuestieDB_Mists.toc' }
    Forever = @{ Artifact = 'Forever'; Sha256 = '2435d382c1a78c0876064c197196e73b9f417669f75187f51cc311fd8c2c19e1'; Toc = 'QuestieDB_Forever.toc' }
}

function Add-FileEntry($archive, [string]$sourcePath, [string]$entryName) {
    $entry = $archive.CreateEntry($entryName, [IO.Compression.CompressionLevel]::Optimal)
    $entry.LastWriteTime = [DateTimeOffset]::new(2026, 1, 1, 0, 0, 0, [TimeSpan]::Zero)
    $source = [IO.File]::OpenRead($sourcePath)
    $target = $entry.Open()
    try { $source.CopyTo($target) } finally { $target.Dispose(); $source.Dispose() }
}

function Add-ProviderEntries($archive, [string]$providerZip, [string]$expectedToc) {
    $sourceZip = [IO.Compression.ZipFile]::OpenRead($providerZip)
    try {
        $seen = @{}
        foreach ($sourceEntry in $sourceZip.Entries) {
            $name = $sourceEntry.FullName.Replace('\', '/')
            if (-not $name.StartsWith('QuestieDB/', [StringComparison]::Ordinal) -or
                $name -match '(^|/)\.\.(/|$)|:|^/' -or $name.Contains('//')) {
                throw "Unsafe provider ZIP path: $name"
            }
            if ($name.EndsWith('/')) { continue }
            if ($seen.ContainsKey($name)) { throw "Duplicate provider ZIP path: $name" }
            $seen[$name] = $true
            $entry = $archive.CreateEntry($name, [IO.Compression.CompressionLevel]::Optimal)
            $entry.LastWriteTime = [DateTimeOffset]::new(2026, 1, 1, 0, 0, 0, [TimeSpan]::Zero)
            $source = $sourceEntry.Open()
            $target = $entry.Open()
            try { $source.CopyTo($target) } finally { $target.Dispose(); $source.Dispose() }
        }
        if (-not $seen.ContainsKey('QuestieDB/' + $expectedToc) -or
            -not $seen.ContainsKey('QuestieDB/src/api.lua')) {
            throw "Incomplete provider archive: $providerZip"
        }
    } finally { $sourceZip.Dispose() }
}

$taskFlavors = if ($Flavor -eq 'All') { @('Retail', 'Classic', 'TBC', 'Mists', 'Forever') }
    elseif ($Flavor -eq 'Both') { @('Classic', 'Forever') } else { @($Flavor) }
foreach ($taskFlavor in $taskFlavors) {
    $taskFiles = if ($CurseForge -or $taskFlavor -eq 'Retail') { $taskRuntimeFiles }
        else { $taskRuntimeFiles + @('README.md','QUESTIEDB-NOTICE.md') }
    foreach ($taskFile in $taskFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $taskAddon $taskFile))) { throw "Missing source: $taskFile" }
    }
    $provider = if ($taskFlavor -eq 'Minimal' -or $taskFlavor -eq 'Retail') { $null } else { $taskProviders[$taskFlavor] }
    $providerZip = $null
    if ($provider) {
        New-Item -ItemType Directory -Path $ProviderCache -Force | Out-Null
        $providerZip = Join-Path $ProviderCache ('QuestieDB-' + $provider.Artifact + '.zip')
        if (-not (Test-Path -LiteralPath $providerZip)) {
            $url = 'https://github.com/Questie/QuestieDB/releases/download/v1.0.4/QuestieDB-' + $provider.Artifact + '.zip'
            Invoke-WebRequest $url -OutFile $providerZip
        }
        $hashStream = [IO.File]::OpenRead($providerZip)
        $sha = [Security.Cryptography.SHA256]::Create()
        try { $actualHash = [BitConverter]::ToString($sha.ComputeHash($hashStream)).Replace('-', '') }
        finally { $sha.Dispose(); $hashStream.Dispose() }
        if ($actualHash -ine $provider.Sha256) { throw "QuestieDB checksum mismatch: $providerZip ($actualHash)" }
    }
    $suffix = if ($taskFlavor -eq 'Minimal') { '' } else { '-' + $taskFlavor }
    $taskZip = Join-Path $taskDist "QuestTargets-$taskVersion$suffix.zip"
    $stream = [IO.File]::Open($taskZip, [IO.FileMode]::Create)
    $archive = [IO.Compression.ZipArchive]::new($stream, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($file in $taskFiles) {
            Add-FileEntry $archive (Join-Path $taskAddon $file) ('QuestTargets/' + $file.Replace('\', '/'))
        }
        if ($provider) { Add-ProviderEntries $archive $providerZip $provider.Toc }
    } finally { $archive.Dispose(); $stream.Dispose() }
    $check = [IO.Compression.ZipFile]::OpenRead($taskZip)
    try {
        foreach ($file in $taskFiles) {
            if (-not $check.GetEntry('QuestTargets/' + $file.Replace('\', '/'))) { throw "Missing ZIP entry: $file" }
        }
        if ($provider -and -not $check.GetEntry('QuestieDB/' + $provider.Toc)) { throw "Missing provider TOC: $($provider.Toc)" }
        if (-not $provider -and @($check.Entries | Where-Object { $_.FullName.StartsWith('QuestieDB/') }).Count) {
            throw 'Unexpected provider in minimal ZIP'
        }
    } finally { $check.Dispose() }
    Get-Item -LiteralPath $taskZip | Select-Object FullName, Length
}
