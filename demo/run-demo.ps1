# Launches a clean OmniMentor demo in a temp directory.
# Usage: powershell -File demo/run-demo.ps1 [-NoLaunch] [-Model provider/model]
param(
    [switch]$NoLaunch,
    [string]$Model = 'zenmux/deepseek/deepseek-v4.1-flash'
)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false)
$root = Split-Path -Parent $PSScriptRoot
$demo = Join-Path $env:TEMP 'omnimentor-demo'

if (Test-Path $demo) { Remove-Item $demo -Recurse -Force }
New-Item -ItemType Directory -Force $demo | Out-Null
Copy-Item (Join-Path $root '.claude') $demo -Recurse -Force
Copy-Item (Join-Path $root 'core') $demo -Recurse -Force
Copy-Item (Join-Path $root 'scripts') $demo -Recurse -Force
New-Item -ItemType Directory -Force (Join-Path $demo '.omnimentor') | Out-Null
Copy-Item (Join-Path $PSScriptRoot 'seed-progress.md') (Join-Path $demo '.omnimentor\progress.md')

$config = @{ '$schema' = 'https://opencode.ai/config.json'; model = $Model } | ConvertTo-Json
[IO.File]::WriteAllText((Join-Path $demo 'opencode.json'), $config, $utf8)

Write-Host ""
Write-Host "Demo directory: $demo"
Write-Host "Model: $Model"
Write-Host "Profile seeded with: Rust mastery, two due reviews, weak Python dicts."
Write-Host "Start your recorder, then run: opencode"
Write-Host ""

Set-Location $demo
if (-not $NoLaunch) {
    Write-Host "Starting OpenCode in 5 seconds..."
    Start-Sleep -Seconds 5
    opencode
}
