# Run this from the root of your google_maps_flutter group directory
# Usage: .\force_overrides.ps1

$packages = @(
    "google_maps_flutter",
    "google_maps_flutter/example",
    "google_maps_flutter_android",
    "google_maps_flutter_android/example",
    "google_maps_flutter_ios",
    "google_maps_flutter_ios/example",
    "google_maps_flutter_web",
    "google_maps_flutter_web/example"
)

# The override block to append. 
# We use relative paths that work generally from the package root structure.
# Adjust ../ levels dynamically based on depth.
$overridesTemplate = @"

dependency_overrides:
  google_maps_flutter:
    path: {0}google_maps_flutter
  google_maps_flutter_android:
    path: {0}google_maps_flutter_android
  google_maps_flutter_ios:
    path: {0}google_maps_flutter_ios
  google_maps_flutter_platform_interface:
    path: {0}google_maps_flutter_platform_interface
  google_maps_flutter_web:
    path: {0}google_maps_flutter_web
"@

foreach ($pkg in $packages) {
    $pubspecPath = Join-Path (Get-Location) "$pkg\pubspec.yaml"
    
    if (Test-Path $pubspecPath) {
        Write-Host "Processing $pkg..." -ForegroundColor Cyan
        
        # Calculate depth to determine how many "../" we need
        # If we are in "google_maps_flutter", we need "../" (1 level up to group root)
        # If we are in "google_maps_flutter/example", we need "../../" (2 levels up)
        $depth = ($pkg.Split('/').Count)
        $relativePath = "../" * $depth
        
        $overrides = $overridesTemplate -f $relativePath
        
        # Read file content
        $content = Get-Content $pubspecPath -Raw
        
        # Remove existing dependency_overrides if they exist (simple cleanup)
        if ($content -match "dependency_overrides:") {
            Write-Host "  - Removing old overrides..." -ForegroundColor Yellow
            $content = $content -replace "(?ms)^dependency_overrides:.*?(\Z|^[a-z])", '$1'
        }
        
        # Append new overrides
        $newContent = $content.Trim() + $overrides
        Set-Content -Path $pubspecPath -Value $newContent
        
        Write-Host "  - Overrides added." -ForegroundColor Green
    } else {
        Write-Host "  - Skipping $pkg (pubspec.yaml not found)" -ForegroundColor DarkGray
    }
}

Write-Host "`nAll done! Run 'flutter pub get' in each directory." -ForegroundColor White