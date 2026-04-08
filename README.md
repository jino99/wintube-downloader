# WinTube

### Fast Media Downloader for Windows

<p align="left">
  <img src="https://img.shields.io/badge/PowerShell-5.1+-5391FE?logo=powershell&logoColor=white" alt="PowerShell">
  <img src="https://img.shields.io/badge/Windows-10%20|%2011-0078D6?logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/Maintained-yes-success" alt="Maintained">
  <img src="https://img.shields.io/badge/CI-ready-blue" alt="CI Ready">
</p>

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&height=200&section=header&text=WinTube&fontSize=80&animation=fadeIn&fontAlignY=40" alt="WinTube Banner">
</p>

> **Download anything. Anywhere. Anytime.**  
> No ads. No tracking. Pure speed.

---

## Quick Install

```powershell
irm https://raw.githubusercontent.com/jino99/wintube-downloader/main/wintube.ps1 | iex
```

---

## 📖 Usage

```powershell
# Interactive mode
.\wintube.ps1

# Download video (MP4)
.\wintube.ps1 -Url "https://example.com/video" -Video

# Download audio (MP3)
.\wintube.ps1 -Url "https://example.com/video" -Audio
```

| Flag | Description |
|------|-------------|
| `-Url` | Media URL |
| `-Video` | Download as MP4 (default) |
| `-Audio` | Extract as MP3 |
| `-Help` | Show help |
| `-Version` | Show version |

---

## Features

- Auto-install (yt-dlp, FFmpeg)
- Fast downloads with retries
- High quality (4K, 8K, HDR)
- Audio extraction (MP3)
- No ads, no tracking

---

## Requirements

- Windows 10/11
- PowerShell 5.1+

---

## License

[MIT](LICENSE.txt)
