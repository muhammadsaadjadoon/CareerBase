$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'Dependency resolution failed.' }
flutter analyze
if ($LASTEXITCODE -ne 0) { throw 'Analysis failed.' }
flutter test
if ($LASTEXITCODE -ne 0) { throw 'Tests failed.' }
flutter build apk --debug --dart-define=DEMO=true
if ($LASTEXITCODE -ne 0) { throw 'Android demo build failed.' }
Write-Host 'Analysis, tests and demo APK passed. Check Firebase live mode separately.'
