$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
flutter create --empty --platforms=android,ios,web --project-name=careerbase --org=com.saadi .
if ($LASTEXITCODE -ne 0) { throw 'Platform generation failed.' }
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'Dependency resolution failed.' }
dart run scripts/configure_platforms.dart
if ($LASTEXITCODE -ne 0) { throw 'Platform configuration failed.' }
dart run flutter_launcher_icons
if ($LASTEXITCODE -ne 0) { throw 'Launcher icon generation failed.' }
dart format lib test scripts
if ($LASTEXITCODE -ne 0) { throw 'Formatting failed.' }
flutter analyze
if ($LASTEXITCODE -ne 0) { throw 'Analysis failed.' }
flutter test
if ($LASTEXITCODE -ne 0) { throw 'Tests failed.' }
Write-Host 'Bootstrap checks passed. Run scripts/verify.ps1 for an Android demo APK.'
