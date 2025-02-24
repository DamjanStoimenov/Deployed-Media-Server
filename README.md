# 🎬 Ultimate Media Server Stack Setup Guide

This repository contains everything you need to set up a complete media server stack with Docker Compose, including Sonarr, Radarr, Prowlarr, Jellyfin, and more.

![Arr Stack Banner](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver-ls-logo.png)

## 📋 Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Service Configuration](#service-configuration)
  - [qBittorrent](#qbittorrent)
  - [Prowlarr](#prowlarr)
  - [Sonarr](#sonarr)
  - [Radarr](#radarr)
  - [Bazarr](#bazarr)
  - [Jellyfin](#jellyfin)
  - [Jellyseerr](#jellyseerr)
  - [Wizarr](#wizarr)
- [Directory Structure](#directory-structure)
- [Troubleshooting](#troubleshooting)
- [Useful Links](#useful-links)

## 🔍 Overview

This stack provides a complete media automation solution:

- 🔍 **Prowlarr**: Indexer manager and proxy
- 📺 **Sonarr**: TV show management and automation
- 🎬 **Radarr**: Movie management and automation
- 📽️ **Jellyfin**: Media server for streaming content
- 🔽 **qBittorrent**: BitTorrent client for downloading
- 🗣️ **Bazarr**: Subtitle management and download
- 🎞️ **Jellyseerr**: Request system for Jellyfin
- 👥 **Wizarr**: Invitation and user management for Jellyfin

## ⚙️ Requirements

- Docker and Docker Compose installed
- Linux environment (tested on Ubuntu)
- Sufficient storage space for media files

## 🛠️ Service Configuration

### qBittorrent
**Port:** 8080

**Initial Setup:**
1. Find the container ID and temporary password:
   ```bash
   sudo docker ps
   sudo docker logs <qbittorrent-container-id>
   ```
2. Access the WebUI at http://localhost:8080
3. Log in with the username `admin` and the temporary password from the logs
4. Navigate to **Tools → Options → WebUI**:
   - Set a permanent username and password
   - Check "Bypass authentication for clients on localhost"
   - Click "Save"

### Prowlarr
**Port:** 9696

**Initial Setup:**
1. Access the WebUI at http://localhost:9696
2. Set up a username and password
3. Configure your indexers:
   - Go to **Indexers** → Click **Add Indexer**
   - Search for indexers like "rarbg" or "yts"
   - Test and save the indexers
4. Add qBittorrent as a download client:
   - Go to **Settings → Download Clients**
   - Click the `+` symbol → Select qBittorrent
   - Set Host to your machine's IP address (not localhost)
   - Enter the port, username, and password from your qBittorrent setup
   - Test and save

### Sonarr
**Port:** 8989

**Initial Setup:**
1. Access the WebUI at http://localhost:8989
2. Set up a username and password
3. Configure root folder:
   - Go to **Settings → Media Management**
   - Click **Add Root Folder**
   - Set `/data/tvshows` as your root folder
4. Configure download client:
   - Go to **Settings → Download Clients**
   - Click the `+` symbol → Select qBittorrent
   - Set Host to your machine's IP address
   - Enter the port, username, and password from your qBittorrent setup
   - Test and save
5. Connect to Prowlarr:
   - Go to **Settings → General**
   - Copy the API key
   - In Prowlarr, go to **Settings → Apps**
   - Click `+` → Select Sonarr
   - Paste the API key and set the correct host IP
   - Test and save
6. Configure backups:
   - Go to **Settings → General** (switch to "Show Advanced")
   - Scroll to "Backups" and set the path to `/data/Backup`

### Radarr
**Port:** 7878

**Initial Setup:**
1. Access the WebUI at http://localhost:7878
2. Set up a username and password
3. Configure root folder:
   - Go to **Settings → Media Management**
   - Click **Add Root Folder**
   - Set `/data/movies` as your root folder
4. Configure download client:
   - Go to **Settings → Download Clients**
   - Click the `+` symbol → Select qBittorrent
   - Set Host to your machine's IP address
   - Enter the port, username, and password from your qBittorrent setup
   - Test and save
5. Connect to Prowlarr:
   - Go to **Settings → General**
   - Copy the API key
   - In Prowlarr, go to **Settings → Apps**
   - Click `+` → Select Radarr
   - Paste the API key and set the correct host IP
   - Test and save
6. Configure backups:
   - Go to **Settings → General** (switch to "Show Advanced")
   - Scroll to "Backups" and set the path to `/data/Backup`

### Bazarr
**Port:** 6767

**Initial Setup:**
1. Access the WebUI at http://localhost:6767
2. Set up a username and password
3. Configure Sonarr and Radarr:
   - Go to **Settings → Sonarr**
   - Enter Sonarr URL (using host IP, not localhost)
   - Enter the API key from Sonarr
   - Test and save
   - Repeat for Radarr
4. Configure subtitle providers:
   - Go to **Settings → Providers**
   - Enable and configure the subtitle providers you want to use
   - Test each provider
5. Configure subtitle languages:
   - Go to **Settings → Languages**
   - Select your preferred languages
   - Configure language profiles

### Jellyfin
**Port:** 8096

**Initial Setup:**
1. Access the WebUI at http://localhost:8096
2. Follow the setup wizard:
   - Create admin user
   - Configure your media libraries:
     - Add library for Movies pointing to `/data/Movies`
     - Add library for TV Shows pointing to `/data/TVShows`
3. Configure additional settings:
   - Hardware transcoding (if needed)
   - Remote access settings

**Note:** If you have issues with port 1900 being in use, run `sudo apt-get remove rygel` to remove the conflicting service.

### Jellyseerr
**Port:** 5055

**Initial Setup:**
1. Access the WebUI at http://localhost:5055
2. Follow the setup wizard:
   - Create admin account
   - Connect to Jellyfin:
     - Enter the Jellyfin URL (using host IP)
     - Enter your Jellyfin API key
     - Test and connect
   - Connect to Radarr and Sonarr:
     - Enter the URLs (using host IP)
     - Enter API keys
     - Test and connect
3. Configure request settings:
   - Default media request settings
   - User permissions

### Wizarr
**Port:** 5690

**Initial Setup:**
1. Access the WebUI at http://localhost:5690
2. Create an admin account
3. Connect to Jellyfin:
   - Enter Jellyfin URL (using host IP)
   - Enter admin credentials
   - Test and connect
4. Configure invitation settings:
   - User template settings
   - Default permissions
   - Invitation expiry time

## 📂 Directory Structure

The stack uses the following directory structure:

```
/media/myfiles/
├── Prowlarr/
│   ├── config/
│   └── backup/
├── Sonarr/
│   ├── config/
│   ├── backup/
│   └── tvshows/
├── Radarr/
│   ├── config/
│   ├── backup/
│   └── movies/
├── Bazarr/
│   └── config/
├── Jellyfin/
│   └── config/
├── Jellyseerr/
│   └── config/
├── qbittorrent/
│   └── config/
└── Downloads/
```

## ❓ Troubleshooting

### Common Issues:

1. **Permission Issues**
   - Ensure proper permissions: `sudo chown -R 1000:1000 /media/Arr`
   - Check the PUID and PGID in your .env file

2. **Port Conflicts**
   - If a port is already in use, either stop the conflicting service or change the port in docker-compose.yml

3. **Container Won't Start**
   - Check logs: `sudo docker logs <container-name>`
   - Ensure sufficient disk space and resources

4. **Network Connectivity Issues**
   - Use IP addresses instead of localhost for inter-container communication
   - Verify your Docker network settings

## 🔗 Useful Links

- [Servarr Wiki](https://wiki.servarr.com/)
- [Trash Guides](https://trash-guides.info/)
- [Jellyfin Documentation](https://jellyfin.org/docs/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🤝 Acknowledgements

- The incredible [LinuxServer.io](https://linuxserver.io/) team for maintaining many of these container images

---

Happy streaming! 🍿 📺
