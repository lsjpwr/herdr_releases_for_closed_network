# Mirrors releases.herdr.dev (Windows x64 only) into this folder, for a closed
# network that reaches GitHub but not herdr.dev. Run it on a PC with internet,
# with this folder as a clone of a PUBLIC GitHub repo, then commit and push:
#
#   .\mirror.ps1 https://raw.githubusercontent.com/OWNER/REPO/main
#
# The closed network then installs with:
#
#   powershell -c "irm https://raw.githubusercontent.com/OWNER/REPO/main/app/install.ps1 | iex"
#
# Run it again and push to update the mirror; installed apps update from it.
# ponytail: old versions' folders stay; delete them by hand when the repo grows.
param([Parameter(Mandatory)][string]$Base)
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$up = "https://releases.herdr.dev"
$Base = $Base.TrimEnd("/")

function Fetch($path) {
    $out = Join-Path $PSScriptRoot $path
    New-Item -ItemType Directory -Force (Split-Path $out) | Out-Null
    curl.exe -fsSL "$up/$path" -o $out
    if ($LASTEXITCODE) { throw "download failed: $up/$path" }
}

# Points every herdr.dev URL in a text file at the mirror (UTF-8, no BOM).
function Rewrite($path) {
    $full = Join-Path $PSScriptRoot $path
    [IO.File]::WriteAllText($full, [IO.File]::ReadAllText($full).Replace($up, $Base))
}

foreach ($part in "app", "core") {
    Fetch "$part/latest.json"
    $m = Get-Content -Raw (Join-Path $PSScriptRoot "$part/latest.json") | ConvertFrom-Json
    $url = $m.targets."windows-x86_64".url
    if (-not $url.StartsWith("$up/")) { throw "$part/latest.json points outside ${up}: $url" }
    Fetch $url.Substring($up.Length + 1)
    Rewrite "$part/latest.json"
    Write-Host "$part $($m.version) mirrored."
}

Fetch "core/install.ps1"
Rewrite "core/install.ps1"
Copy-Item (Join-Path $PSScriptRoot "herdr_261110.ps1") (Join-Path $PSScriptRoot "app/install.ps1")
Rewrite "app/install.ps1"
Write-Host "Done. Commit and push app/ and core/."
