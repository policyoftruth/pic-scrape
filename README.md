# pic-scrape: Studio Ghibli Wallpaper Manager

A tool to cureate and rotate high-quality Studio Ghibli wallpapers on macOS.

This project scrapes the official "Scene Photographs" provided by Studio Ghibli, which are "artist's selections" meant for the general public. It downloads these high-resolution images and schedules them to rotate as your desktop background, bringing a bit of Ghibli magic to your daily workflow.

> **Respectful Scraping**: This tool is designed to be respectful to the Studio Ghibli servers. It includes intentional delays between requests to avoid overloading their site. Please use it responsibly.

## Features
- **Scraper**: Downloads high-resolution still images from recent Studio Ghibli movies.
- **Wallpaper Rotator**: Helper script to set a random downloaded image as your wallpaper.
- **Scheduler**: Launchd agent to automatically rotate your wallpaper (configurable: daily or hourly).

## Prerequisites
- macOS (Developed and tested on macOS "Tahoe")
- `curl`
- `bash`

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/pic-scrape.git
   cd pic-scrape
   ```

2. make the scripts executable:
   ```bash
   chmod +x ghibli_scrape.sh rotate_wallpaper.sh
   ```

## Usage

### 1. Download Images
Run the scraper script to populate the `images/` directory. It works by fetching the movie list from the Ghibli "works" page and downloading gallery images for each.

```bash
./ghibli_scrape.sh
```
> **Note**: The script includes delays to be respectful to the Ghibli website servers.

### 2. Manual Wallpaper Change
You can pick a random image and set it as your wallpaper immediately by running:

```bash
./rotate_wallpaper.sh
```

### 3. Automatic Rotation
To schedule the wallpaper to change automatically, use the provided install script.

```bash
# Install for HOURLY rotation (default)
./install_wallpaper_service.sh hourly

# Install for DAILY rotation
./install_wallpaper_service.sh daily
```

This script will:
- Update the configuration with the correct path to your script.
- Set the rotation interval.
- Install and load the service automatically.

## Uninstallation
To stop the automatic rotation:

```bash
launchctl unload ~/Library/LaunchAgents/com.nulldivision.ghibli.wallpaper.plist
rm ~/Library/LaunchAgents/com.nulldivision.ghibli.wallpaper.plist
```

## Reference
Original image source: https://www.ghibli.jp/info/013772/
