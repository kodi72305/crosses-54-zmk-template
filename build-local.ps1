[CmdletBinding()]
param(
    [ValidateSet('init', 'update', 'left', 'right', 'reset', 'all', 'clean', 'purge')]
    [string]$Command = 'all',
    [switch]$Logging
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot    = Split-Path -Parent $MyInvocation.MyCommand.Path
$Workspace   = Join-Path $RepoRoot '.zmk-workspace'
$FirmwareDir = Join-Path $RepoRoot 'firmware'
$ConfigDir   = Join-Path $RepoRoot 'config'
$Manifest    = Join-Path $ConfigDir 'west.yml'
$MarkerFile  = Join-Path $Workspace '.west_update_marker'
$DockerImage = 'zmkfirmware/zmk-dev-arm:stable'

$Board       = 'nice_nano'
$ShieldLeft  = 'crosses_left'
$ShieldRight = 'crosses_right'
$SnippetArg  = if ($Logging) { '-S zmk-usb-logging' } else { '' }

New-Item -ItemType Directory -Force -Path $Workspace, $FirmwareDir | Out-Null
Set-Location $RepoRoot

function Update-Marker {
    if (-not (Test-Path $MarkerFile)) {
        New-Item -ItemType File -Path $MarkerFile | Out-Null
    }
    [System.IO.File]::SetLastWriteTimeUtc($MarkerFile, [DateTime]::UtcNow)
}

function Invoke-Docker {
    param(
        [Parameter(Mandatory = $true)][string]$Script,
        [switch]$MountModule,
        [switch]$MountFirmware = $true
    )

    $args = @(
        '--rm',
        '-w', '/workspace',
        '-v', "$Workspace:/workspace",
        '-v', "$ConfigDir:/workspace/config:ro"
    )

    if ($MountFirmware) {
        $args += @('-v', "$FirmwareDir:/workspace/firmware")
    }
    if ($MountModule) {
        $args += @('-v', "$RepoRoot:/workspace/module:ro")
    }

    $args += @(
        $DockerImage,
        'bash', '-lc', "set -euo pipefail; $Script"
    )

    & docker @args
}

function Initialize-Workspace {
    Write-Host "Initializing ZMK workspace..."
    Invoke-Docker -MountModule:$false -Script @"
if [ ! -d zmk ]; then
  west init -l config
fi
west update
west zephyr-export
pip3 install --user -r zmk/app/scripts/requirements.txt
"@
    Update-Marker
}

function Update-Workspace {
    Write-Host "Updating west workspace..."
    Invoke-Docker -MountModule:$false -Script @"
west update
west zephyr-export
"@
    Update-Marker
}

function Ensure-Workspace {
    if (-not (Test-Path (Join-Path $Workspace 'zmk'))) {
        Initialize-Workspace
        return
    }

    if ((-not (Test-Path $MarkerFile)) -or ((Get-Item $Manifest).LastWriteTimeUtc -gt (Get-Item $MarkerFile).LastWriteTimeUtc)) {
        Update-Workspace
    }
}

function Build-Side {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Shield,
        [string]$ExtraKconfig = ''
    )

    Ensure-Workspace
    Write-Host "Building $Name ($Shield)..."
    $buildDir = "build/$Name"

    $script = @"
west zephyr-export >/dev/null 2>&1 || true
west build -s zmk/app -b $Board $SnippetArg -d $buildDir -p auto -- -DSHIELD=$Shield -DZMK_CONFIG=/workspace/config -DZMK_EXTRA_MODULES=/workspace/module $ExtraKconfig
cp $buildDir/zephyr/zmk.uf2 /workspace/firmware/${Board}-${Shield}.uf2
"@

    Invoke-Docker -MountModule -Script $script
    Write-Host "✓ firmware/${Board}-${Shield}.uf2 обновлён."
}

function Clean-Builds {
    Write-Host "Cleaning build artifacts..."
    Remove-Item -Recurse -Force (Join-Path $Workspace 'build') -ErrorAction SilentlyContinue
    Get-ChildItem $FirmwareDir -Filter '*.uf2' -ErrorAction SilentlyContinue | Remove-Item -Force
}

function Purge-Workspace {
    Write-Host "Purging entire workspace..."
    Remove-Item -Recurse -Force $Workspace -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $FirmwareDir -ErrorAction SilentlyContinue
}

if ($Logging) {
    Write-Host "USB logging enabled; cleaning cached builds."
    Clean-Builds
}

switch ($Command) {
    'init'   { Initialize-Workspace }
    'update' { Ensure-Workspace; Update-Workspace }
    'left'   { Build-Side -Name 'left'  -Shield $ShieldLeft }
    'right'  { Build-Side -Name 'right' -Shield $ShieldRight -ExtraKconfig '-DCONFIG_ZMK_STUDIO=y' }
    'reset'  { Build-Side -Name 'reset' -Shield 'settings_reset' }
    'all'    {
        Build-Side -Name 'left'  -Shield $ShieldLeft
        Build-Side -Name 'right' -Shield $ShieldRight -ExtraKconfig '-DCONFIG_ZMK_STUDIO=y'
        Build-Side -Name 'reset' -Shield 'settings_reset'
    }
    'clean'  { Clean-Builds }
    'purge'  { Purge-Workspace }
}

Write-Host "`nFirmware outputs:"
$uf2 = Get-ChildItem $FirmwareDir -Filter '*.uf2' -ErrorAction SilentlyContinue
if ($uf2) {
    $uf2 | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
} else {
    Write-Host " (нет готовых .uf2 файлов)"
}
