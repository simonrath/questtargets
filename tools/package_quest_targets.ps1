param([switch]$AddonOnly, [switch]$CurseForge)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$taskAddon = Join-Path $taskRoot 'QuestTargets'
$taskDist = Join-Path $taskRoot 'dist'
$taskVersion = (Select-String -LiteralPath (Join-Path $taskAddon 'QuestTargets.toc') -Pattern '^## Version: (.+)$').Matches[0].Groups[1].Value
New-Item -ItemType Directory -Path $taskDist -Force | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem

$taskProviderZip = $null
if (-not $AddonOnly -and -not $CurseForge) {
    $taskCache = Join-Path $env:TEMP 'quest-targets-questiedb-v1.0.1'
    New-Item -ItemType Directory -Path $taskCache -Force | Out-Null
    $taskProviderZip = Join-Path $taskCache 'QuestieDB-Vanilla.zip'
    if (-not (Test-Path -LiteralPath $taskProviderZip)) {
        Invoke-WebRequest 'https://github.com/Questie/QuestieDB/releases/download/v1.0.1/QuestieDB-Vanilla.zip' -OutFile $taskProviderZip
    }
    if ((Get-FileHash -LiteralPath $taskProviderZip -Algorithm SHA256).Hash -ne '0AA71066DAD715AAC0AF03D79F74ACDB669A63DF8D2368AED222B63DD20F68B8') {
        throw "QuestieDB checksum mismatch: $taskProviderZip"
    }
}
$taskSuffix = if ($AddonOnly -or $CurseForge) { '' } else { '-with-QuestieDB' }
$taskZip = Join-Path $taskDist "QuestTargets-$taskVersion$taskSuffix.zip"
$taskRuntimeFiles = @('QuestTargets.toc','Core.lua','Locale.lua','Database.lua','Proximity.lua','Resolvers.lua','Scanner.lua','UI.lua','Master.lua','Main.lua','Textures/QuestCompassUp.tga','Textures/QuestCompassDown.tga')
$taskExpected = if ($CurseForge) { $taskRuntimeFiles } else { $taskRuntimeFiles + @('README.md','QUESTIEDB-NOTICE.md') }
foreach ($taskFile in $taskExpected) {
    if (-not (Test-Path -LiteralPath (Join-Path $taskAddon $taskFile))) { throw "Missing source: $taskFile" }
}
function Add-QuestTargetsZipText($archive, $name, $value) {
    $entry = $archive.CreateEntry($name, [IO.Compression.CompressionLevel]::Optimal)
    $writer = [IO.StreamWriter]::new($entry.Open(), [Text.UTF8Encoding]::new($false))
    try { $writer.Write($value) } finally { $writer.Dispose() }
}
# Stream straight into the ZIP: no extracted staging tree or recursive cleanup.
$taskStream = [IO.File]::Open($taskZip, [IO.FileMode]::Create)
$taskOutput = [IO.Compression.ZipArchive]::new($taskStream, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($taskFile in $taskExpected) {
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($taskOutput, (Join-Path $taskAddon $taskFile), ('QuestTargets/' + $taskFile)) | Out-Null
    }
    if ($taskProviderZip) {
        $taskInput = [IO.Compression.ZipFile]::OpenRead($taskProviderZip)
        try {
            foreach ($taskEntry in $taskInput.Entries) {
                $taskName = $taskEntry.FullName.Replace('\', '/')
                if (-not $taskName.StartsWith('QuestieDB/') -or $taskName -match '(^|/)\.\.(/|$)|:') { throw "Unsafe provider ZIP path: $taskName" }
                if ($taskName.EndsWith('/')) { continue }
                if ($taskName -eq 'QuestieDB/QuestieDB_Vanilla.toc') {
                    $taskReader = [IO.StreamReader]::new($taskEntry.Open())
                    try { $taskText = $taskReader.ReadToEnd() } finally { $taskReader.Dispose() }
                    $taskText = $taskText -replace '(?m)^## Interface: [^\r\n]+', '## Interface: 11508, 11509, 160001'
                    $taskText = $taskText -replace '(?m)^## IconTexture: [^\r\n]+', '## IconAtlas: UI-QuestPoi-QuestNumber'
                    $taskText = "# Quest Targets local Forever loader adaptation; Classic data, not official Forever support.`n" + $taskText
                    Add-QuestTargetsZipText $taskOutput $taskName $taskText
                    Add-QuestTargetsZipText $taskOutput 'QuestieDB/QuestieDB.toc' $taskText
                } else {
                    $taskSourceStream = $taskEntry.Open()
                    $taskTargetStream = $taskOutput.CreateEntry($taskName, [IO.Compression.CompressionLevel]::Optimal).Open()
                    try { $taskSourceStream.CopyTo($taskTargetStream) }
                    finally { $taskTargetStream.Dispose(); $taskSourceStream.Dispose() }
                }
            }
            Add-QuestTargetsZipText $taskOutput 'QuestieDB/QUESTIEDB-NOTICE.md' ([IO.File]::ReadAllText((Join-Path $taskAddon 'QUESTIEDB-NOTICE.md')))
        } finally { $taskInput.Dispose() }
    }
} finally { $taskOutput.Dispose(); $taskStream.Dispose() }
$taskCheck = [IO.Compression.ZipFile]::OpenRead($taskZip)
try {
    foreach ($taskFile in $taskExpected) {
        if (-not $taskCheck.GetEntry('QuestTargets/' + $taskFile)) { throw "Missing ZIP entry: $taskFile" }
    }
    if (-not $AddonOnly -and -not $CurseForge) {
        foreach ($taskFile in @('QuestieDB/QuestieDB.toc','QuestieDB/QuestieDB_Vanilla.toc','QuestieDB/src/api.lua')) {
            if (-not $taskCheck.GetEntry($taskFile)) { throw "Missing provider file: $taskFile" }
        }
    }
    if ($CurseForge) {
        $taskActual = @($taskCheck.Entries | ForEach-Object { $_.FullName })
        $taskAllowed = @($taskExpected | ForEach-Object { 'QuestTargets/' + $_ })
        if ($taskActual.Count -ne $taskAllowed.Count) { throw "Unexpected file count in CurseForge ZIP: $($taskActual.Count)" }
        foreach ($taskEntryName in $taskActual) {
            if ($taskEntryName -cnotin $taskAllowed) { throw "Unexpected CurseForge ZIP entry: $taskEntryName" }
        }
    }
} finally { $taskCheck.Dispose() }
Get-Item -LiteralPath $taskZip | Select-Object FullName, Length
