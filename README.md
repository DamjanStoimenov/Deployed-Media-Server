# 🎬 Ultimate Media Server Stack Setup Guide

This repository contains everything you need to set up a complete media server stack with Docker Compose, including Sonarr, Radarr, Prowlarr, Jellyfin, and more.

![mediaserver_icon-Photoroom](https://github.com/user-attachments/assets/7aee94c1-91b4-47a6-a91e-5184ac1683f3)
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
- [Remote Access Setup](#remote-access-setup)
  - [Tailscale VPN Configuration](#tailscale-vpn-configuration)
  - [User Onboarding Process](#user-onboarding-process)
- [Directory Structure](#directory-structure)
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

## 🌐 Remote Access Setup

### Tailscale VPN Configuration

Tailscale provides a secure and easy way to share your media server with friends and family without exposing your server to the public internet.

1. **Install Tailscale on your server:**
   ```bash
   curl -fsSL https://tailscale.com/install.sh | sh
   ```

2. **Authenticate and start Tailscale:**
   ```bash
   sudo tailscale up
   ```
   
### User Onboarding Process

Once your Tailscale network is set up, you can invite users to access your media server:

1. **Invite users to your Tailscale network:**
   - Log in to the Tailscale admin console
   - Generate invite links for your users
   - Send the invite links to your friends and family
   - Guide them through installing Tailscale on their devices(https://tailscale.com/download)

2. **Create Jellyfin/Jellyseerr accounts using Wizarr:**
   - Access Wizarr at `http://<your-tailscale-ip>:5690`
   - Go to **Invitations → Create New Invitation**
   - Configure the invitation settings:
     - Set permission levels (what libraries they can access)
     - Set expiration time for the invitation
     - Enable/disable Jellyseerr integration
   - Click "Create Invitation"
   - Copy the generated invitation link
   - Send the invitation link to your users

3. **User Registration Process:**
   - Users will click the Wizarr invitation link
   - They'll create their Jellyfin account through the Wizarr interface
   - If enabled, a Jellyseerr account will also be created
   - The accounts will be automatically configured with the permissions you specified

4. **Accessing the Media Server:**
   - Users can access Jellyfin at `http://<your-tailscale-ip>:8096`
   - Users can access Jellyseerr at `http://<your-tailscale-ip>:5055`
   - They log in with the credentials they created through the Wizarr invitation

5. **Security Tips:**
   - Consider creating separate Jellyfin libraries for different user groups
   - Use Jellyfin's user policy settings to limit bandwidth for remote users if needed
   - Monitor Tailscale access logs periodically

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

## 🔗 Useful Links

- [Servarr Wiki](https://wiki.servarr.com/)
- [Trash Guides](https://trash-guides.info/)
- [Jellyfin Documentation](https://jellyfin.org/docs/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [Wizarr Documentation](https://docs.wizarr.dev/)

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Acknowledgements

- The incredible [LinuxServer.io](https://linuxserver.io/) team for maintaining many of these container images

---

Happy streaming! 🍿 📺
