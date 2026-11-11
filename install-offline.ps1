# Installs Herdr (app and core) on Windows from this folder alone, for a
# network with no internet at all. Copy the whole folder over, then in it:
#
#   powershell -ExecutionPolicy Bypass -File install-offline.ps1
#
# Leave the folder where it is: the app looks there for updates. To update,
# put a newer copy in its place and run this again.
$ErrorActionPreference = "Stop"
$base = ([Uri]$PSScriptRoot).AbsoluteUri.TrimEnd("/")

# The manifests name downloads on the mirror they were made for: point them here.
foreach ($f in "app\latest.json", "core\latest.json") {
    $p = Join-Path $PSScriptRoot $f
    $text = [IO.File]::ReadAllText($p) -replace '"url":\s*"[^"]*/((app|core)/[^/"]+/[^/"]+)"', ('"url": "' + $base + '/$1"')
    [IO.File]::WriteAllText($p, $text)
}

$env:HERDR_RELEASES_URL = $base
# The core first, every time: its installer installs or updates it, and the
# app's then finds it there.
& (Join-Path $PSScriptRoot "core\install.ps1")
& (Join-Path $PSScriptRoot "app\install.ps1")
