# Mirrors releases.herdr.dev (Windows and Linux, x86_64) into this folder, for
# networks that reach GitHub but not herdr.dev, or nothing at all. Run it on a
# PC with internet, with this folder as a clone of a PUBLIC GitHub repo, then
# commit and push:
#
#   .\mirror.ps1 https://raw.githubusercontent.com/OWNER/REPO/main
#
# GitHub-only networks then install with:
#
#   Windows: powershell -c "irm https://raw.githubusercontent.com/OWNER/REPO/main/app/install.ps1 | iex"
#   Linux:   curl -fsSL https://raw.githubusercontent.com/OWNER/REPO/main/app/install.sh | sh
#
# Networks with no internet: copy the whole folder over, then run
# install-offline.ps1 (Windows) or install-offline.sh (Linux) in it.
#
# Run it again and push to update the mirror; only the latest version stays.
param([Parameter(Mandatory)][string]$Base)
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$up = "https://releases.herdr.dev"
$Base = $Base.TrimEnd("/")
# Add "linux-aarch64" for ARM Linux (about 40MB more per version).
$targets = "windows-x86_64", "linux-x86_64"

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
    # The manifest names nothing older, so older versions' folders go.
    Get-ChildItem (Join-Path $PSScriptRoot $part) -Directory | Where-Object Name -ne $m.version | Remove-Item -Recurse -Force
    foreach ($target in $targets) {
        $url = $m.targets.$target.url
        if (-not $url.StartsWith("$up/")) { throw "$part/latest.json has no $target build on ${up}: $url" }
        Fetch $url.Substring($up.Length + 1)
    }
    Rewrite "$part/latest.json"
    Fetch "$part/install.sh"
    Rewrite "$part/install.sh"
    Write-Host "$part $($m.version) mirrored."
}

Fetch "core/install.ps1"
Rewrite "core/install.ps1"
Copy-Item (Join-Path $PSScriptRoot "herdr_261110.ps1") (Join-Path $PSScriptRoot "app/install.ps1")
Rewrite "app/install.ps1"
Write-Host "Done. Commit and push app/ and core/."
