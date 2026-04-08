# WinTube

### Blazing Fast Media Downloader for Windows
<p align="left">
  <img src="https://img.shields.io/badge/PowerShell-Script-012456?style=for-the-badge" alt="PowerShell">
  <img src="https://img.shields.io/github/license/jino99/wintube-downloader?style=for-the-badge&color=ff00d4" alt="License">
  <img src="https://img.shields.io/github/stars/jino99/wintube-downloader?style=for-the-badge&color=ffcc00" alt="Stars">
  <img src="https://img.shields.io/github/forks/jino99/wintube-downloader?style=for-the-badge&color=ff6b6b" alt="Forks">
  <img src="https://img.shields.io/badge/Platform-Windows-0078D4?style=for-the-badge" alt="Platform">

![Banner](https://capsule-render.vercel.app/api?type=waving&color=gradient&height=200&section=header&text=WinTube&fontSize=80&animation=fadeIn&fontAlignY=40)

> **Download anything. Anywhere. Anytime.** No ads. No tracking. Pure speed.

---

## Quick Install

```powershell
irm https://github.com/jino99/wintube-downloader | iex
```

---

## 📖 Usage

```powershell
# Interactive mode
.\wintube.ps1

# Download video
.\wintube.ps1 -Url "https://example.com/video" -Mode 1

# Download audio (MP3)
.\wintube.ps1 -Url "https://example.com/video" -Mode 2
```

| Flag | Description |
|------|-------------|
| `-Url` | Media URL |
| `-Mode` | 1 = Video, 2 = Audio |
| `-Help` | Show help |

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

[MIT](LICENSE)
