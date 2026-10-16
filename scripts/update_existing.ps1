param([Parameter(Mandatory=$true)][string]$Target)
$ErrorActionPreference = 'Stop'
$sourceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$targetRoot = (Resolve-Path $Target).Path
if ($sourceRoot -eq $targetRoot -or $targetRoot.StartsWith($sourceRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'Extract the update into a separate folder first.' }
if (-not (Test-Path (Join-Path $targetRoot 'pubspec.yaml'))) { throw 'Target must be your existing Flutter project root.' }
$targetPackage = Get-Content (Join-Path $targetRoot 'pubspec.yaml') -Raw
if ($targetPackage -notmatch '(?m)^name:\s*careerbase\s*$') { throw 'Target is not the CareerBase project.' }
$keep = @('lib/firebase_options.dart', 'firebase.json', '.firebaserc')
Get-ChildItem -LiteralPath $sourceRoot -Recurse -File -Force | ForEach-Object {
    $relative = $_.FullName.Substring($sourceRoot.Length).TrimStart([char[]]'\/')
    $normalized = $relative.Replace('\', '/')
    if ($keep -notcontains $normalized) {
        $destination = Join-Path $targetRoot $relative
        New-Item -ItemType Directory -Force -Path (Split-Path $destination -Parent) | Out-Null
        Copy-Item -LiteralPath $_.FullName -Destination $destination -Force
    }
}
Write-Host 'Source updated. Existing Firebase options, firebase.json, .firebaserc and platform folders were preserved.'
Write-Host 'Next: flutter pub get; dart format lib test scripts; flutter analyze; flutter test'
