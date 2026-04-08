# WinTube v1.0.0 - MIT

param (
    [string]$Url,
    [switch]$Video,
    [switch]$Audio,
    [switch]$Help,
    [switch]$Version
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

$USER_DIR    = [Environment]::GetFolderPath('UserProfile')
$WINTUBE_DIR = Join-Path $USER_DIR '.wintube'
$YT_DLP_EXE  = Join-Path $WINTUBE_DIR 'yt-dlp.exe'
$FFMPEG_EXE  = Join-Path $WINTUBE_DIR 'ffmpeg.exe'
$FFPROBE_EXE = Join-Path $WINTUBE_DIR 'ffprobe.exe'
$FFMPEG_ZIP  = Join-Path $WINTUBE_DIR 'ffmpeg_temp.zip'
$FFMPEG_TEMP = Join-Path $WINTUBE_DIR 'ffmpeg_extract'
$ERR_LOG     = Join-Path $WINTUBE_DIR 'wintube_stderr.log'

$YT_DLP_URL = 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe'
$FFMPEG_URL = 'https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-master-latest-win64-gpl.zip'

function Write-Status {
    param (
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Success','Error','Warning','Action','Info')][string]$Type = 'Info'
    )
    $sym = @{ Success='[+]'; Error='[-]'; Warning='[!]'; Action='[>]'; Info='[*]' }
    $col = @{ Success='Green'; Error='Red'; Warning='Yellow'; Action='Cyan'; Info='Gray' }
    Write-Host "  $($sym[$Type]) $Message" -ForegroundColor $col[$Type]
}

function Show-Header {
    Write-Host ''
    Write-Host '  ===========================================' -ForegroundColor Cyan
    Write-Host '         W I N T U B E  v1.0.0'              -ForegroundColor Cyan
    Write-Host '      Media Downloader for Windows'           -ForegroundColor Cyan
    Write-Host '  ===========================================' -ForegroundColor Cyan
    Write-Host ''
}

function Initialize-Environment {
    if (-not (Test-Path $WINTUBE_DIR)) {
        New-Item -ItemType Directory -Path $WINTUBE_DIR -Force | Out-Null
    }
    $dl = Join-Path $USER_DIR 'Downloads'
    if (-not (Test-Path $dl)) {
        New-Item -ItemType Directory -Path $dl -Force | Out-Null
    }
}

function Install-YtDlp {
    if (Test-Path $YT_DLP_EXE) { Write-Status 'yt-dlp already installed.' -Type Info; return }
    Write-Status 'Downloading yt-dlp ...' -Type Action
    try {
        (New-Object System.Net.WebClient).DownloadFile($YT_DLP_URL, $YT_DLP_EXE)
        Write-Status 'yt-dlp ready.' -Type Success
    } catch {
        Write-Status "Failed to download yt-dlp: $_" -Type Error
        exit 1
    }
}

function Install-FFmpeg {
    if ((Test-Path $FFMPEG_EXE) -and (Test-Path $FFPROBE_EXE)) {
        Write-Status 'FFmpeg already installed.' -Type Info; return
    }
    Write-Status 'Downloading FFmpeg (~70 MB) ...' -Type Action
    try {
        (New-Object System.Net.WebClient).DownloadFile($FFMPEG_URL, $FFMPEG_ZIP)

        if (Test-Path $FFMPEG_TEMP) { Remove-Item $FFMPEG_TEMP -Recurse -Force }
        New-Item -ItemType Directory -Path $FFMPEG_TEMP -Force | Out-Null
        Expand-Archive -Path $FFMPEG_ZIP -DestinationPath $FFMPEG_TEMP -Force

        $binDir = Get-ChildItem -LiteralPath $FFMPEG_TEMP -Recurse -Filter 'ffmpeg.exe' -ErrorAction SilentlyContinue |
                  Select-Object -First 1 | ForEach-Object { $_.DirectoryName }

        if (-not $binDir) { throw 'ffmpeg.exe not found inside ZIP.' }

        Copy-Item (Join-Path $binDir 'ffmpeg.exe')  $FFMPEG_EXE  -Force
        Copy-Item (Join-Path $binDir 'ffprobe.exe') $FFPROBE_EXE -Force
        Write-Status 'FFmpeg ready.' -Type Success
    } catch {
        Write-Status "Failed to install FFmpeg: $_" -Type Error
        exit 1
    } finally {
        if (Test-Path $FFMPEG_ZIP)  { Remove-Item $FFMPEG_ZIP  -Force -ErrorAction SilentlyContinue }
        if (Test-Path $FFMPEG_TEMP) { Remove-Item $FFMPEG_TEMP -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

function Install-Dependencies {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-YtDlp
    Install-FFmpeg
}

function Get-UserSelection {
    Write-Host '  [1]  Video  (MP4 - 4K/8K/HDR supported)' -ForegroundColor White
    Write-Host '  [2]  Audio  (MP3 - highest quality)'      -ForegroundColor White
    Write-Host ''
    Write-Host '  Enter URL    : ' -NoNewline -ForegroundColor Cyan
    $inputUrl = Read-Host
    if ([string]::IsNullOrWhiteSpace($inputUrl)) {
        Write-Status 'URL is required.' -Type Error; exit 1
    }
    if ($inputUrl -notmatch '^https?://') {
        Write-Status "Invalid URL: '$inputUrl'" -Type Error; exit 1
    }
    Write-Host '  Select [1-2] : ' -NoNewline -ForegroundColor Cyan
    $inputMode = Read-Host
    $mode = if ($inputMode.Trim() -eq '2') { 'Audio' } else {
        if ($inputMode.Trim() -ne '1') { Write-Status 'Invalid selection, defaulting to Video.' -Type Warning }
        'Video'
    }
    return @{ Url = $inputUrl.Trim(); Mode = $mode }
}

function Invoke-MediaDownload {
    param (
        [Parameter(Mandatory)][string]$MediaUrl,
        [Parameter(Mandatory)][ValidateSet('Video','Audio')][string]$Mode
    )

    $downloadsDir   = Join-Path $USER_DIR 'Downloads'
    $outputTemplate = Join-Path $downloadsDir '%(title)s.%(ext)s'

    $ytArgs = [System.Collections.Generic.List[string]]::new()
    $ytArgs.AddRange([string[]]@(
        '--no-playlist',
        '--retries',          '5',
        '--fragment-retries', '5',
        '--newline',
        '--ffmpeg-location',  $WINTUBE_DIR,
        '--output',           $outputTemplate
    ))

    if ($Mode -eq 'Video') {
        $ytArgs.AddRange([string[]]@('-f', 'bv*+ba/best', '--merge-output-format', 'mp4'))
    } else {
        $ytArgs.AddRange([string[]]@('-x', '--audio-format', 'mp3', '--audio-quality', '0'))
    }

    $ytArgs.Add($MediaUrl)

    Write-Host ''
    Write-Status "Mode   : $Mode"        -Type Info
    Write-Status "Output : $downloadsDir" -Type Info
    Write-Status 'Starting download ...'  -Type Action
    Write-Host ''

    if (Test-Path $ERR_LOG) { Remove-Item $ERR_LOG -Force -ErrorAction SilentlyContinue }

    try {
        $proc = Start-Process -FilePath $YT_DLP_EXE -ArgumentList ([string[]]$ytArgs) `
                    -NoNewWindow -Wait -PassThru -RedirectStandardError $ERR_LOG

        if ($proc.ExitCode -eq 0) {
            Write-Host ''
            Write-Status 'Download complete!' -Type Success
            Write-Status "Saved to: $downloadsDir" -Type Info
        } else {
            Write-Host ''
            Write-Status "Download failed (exit code: $($proc.ExitCode))" -Type Error
            if (Test-Path $ERR_LOG) {
                $errText = Get-Content $ERR_LOG -Raw -ErrorAction SilentlyContinue
                if (-not [string]::IsNullOrWhiteSpace($errText)) {
                    $errText -split "`n" | Where-Object { $_ -match '\S' } | ForEach-Object {
                        $line = $_.TrimEnd()
                        if     ($line -match 'ERROR')   { Write-Host "  $line" -ForegroundColor Red }
                        elseif ($line -match 'WARNING') { Write-Host "  $line" -ForegroundColor Yellow }
                        else                            { Write-Host "  $line" -ForegroundColor DarkGray }
                    }
                }
            }
            exit 1
        }
    } catch {
        Write-Status "Unexpected error: $_" -Type Error
        exit 1
    } finally {
        if (Test-Path $ERR_LOG) { Remove-Item $ERR_LOG -Force -ErrorAction SilentlyContinue }
    }
}

# --- Entry Point ---

if ($Help) {
    Show-Header
    Write-Host '  USAGE' -ForegroundColor White
    Write-Host '  .\WinTube.ps1                     Interactive mode'
    Write-Host '  .\WinTube.ps1 -Url <URL>          Download video (default)'
    Write-Host '  .\WinTube.ps1 -Url <URL> -Video   Download video (MP4)'
    Write-Host '  .\WinTube.ps1 -Url <URL> -Audio   Extract audio (MP3)'
    Write-Host '  .\WinTube.ps1 -Help               Show this help'
    Write-Host '  .\WinTube.ps1 -Version            Show version'
    Write-Host ''
    exit 0
}

if ($Version) {
    Write-Host '  WinTube v1.0.0' -ForegroundColor Cyan
    exit 0
}

if ($Video -and $Audio) {
    Write-Status '-Video and -Audio cannot be used together.' -Type Error
    exit 1
}

Show-Header
Initialize-Environment

Write-Status 'Checking dependencies ...' -Type Action
Install-Dependencies

if ([string]::IsNullOrWhiteSpace($Url)) {
    Write-Host ''
    $sel          = Get-UserSelection
    $resolvedUrl  = $sel.Url
    $resolvedMode = $sel.Mode
} else {
    $resolvedUrl = $Url.Trim()
    if ($resolvedUrl -notmatch '^https?://') {
        Write-Status "Invalid URL: '$resolvedUrl'" -Type Error
        exit 1
    }
    $resolvedMode = if ($Audio) { 'Audio' } else { 'Video' }
}

Invoke-MediaDownload -MediaUrl $resolvedUrl -Mode $resolvedMode

Write-Host ''
