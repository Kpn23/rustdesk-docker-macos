# RustDesk Server Setup with Docker on macOS

This guide walks you through setting up your own RustDesk server using Docker on macOS, providing complete control over your remote desktop connections.

## � Official Documentation

For additional information and advanced configurations, refer to the official RustDesk documentation:
- **Official Docker Setup Guide:** https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/docker/

## �📋 Prerequisites

- macOS system
- Homebrew installed
- Admin access to your router (for external access)

## 🚀 Step 1: Install Docker Desktop

### Check if Docker is already installed:
```bash
docker --version
```

### Install Docker Desktop via Homebrew:
```bash
# Check if Homebrew is installed
brew --version

# Install Docker Desktop
brew install --cask docker
```

### Start Docker Desktop:
- Open Docker Desktop from Applications folder, or
- Press `Cmd + Space` and search for "Docker"
- Wait for Docker Desktop to fully start (whale icon in menu bar should be stable)

### Verify installation:
```bash
docker --version
docker info
```

## 📁 Step 2: Create RustDesk Server Setup

### Create project directory:
```bash
mkdir rustdeskdocker
cd rustdeskdocker
```

### Create docker-compose.yml:
```yaml
services:
  hbbs:
    container_name: hbbs
    image: rustdesk/rustdesk-server:latest
    command: hbbs
    volumes:
      - ./data:/root
    ports:
      - "21115:21115"
      - "21116:21116"
      - "21116:21116/udp"
      - "21118:21118"
    depends_on:
      - hbbr
    restart: unless-stopped
  hbbr:
    container_name: hbbr
    image: rustdesk/rustdesk-server:latest
    command: hbbr
    volumes:
      - ./data:/root
    ports:
      - "21117:21117"
      - "21119:21119"
    restart: unless-stopped
```

### Create data directory:
```bash
mkdir data
```

## 🔧 Step 3: Start RustDesk Server

### Start the services:
```bash
docker compose up -d
```

### Verify containers are running:
```bash
docker compose ps
```

### Check logs:
```bash
docker compose logs
```

### Test local connectivity:
```bash
nc -zv localhost 21116
nc -zv localhost 21117
```

## 🔑 Step 4: Get Server Configuration

### Retrieve your server key:
```bash
cat data/id_ed25519.pub
```

### Find your local IP address:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### Find your public IP address:
```bash
curl -s ifconfig.me
```

## 🌐 Step 5: Configure Port Forwarding (For External Access)

### Access your router's admin panel:
1. Open web browser and go to your router's IP (usually `192.168.1.1` or `192.168.0.1`)
2. Log in with admin credentials

### Add port forwarding rules:
| Service Name | External Port | Internal IP | Internal Port | Protocol |
|--------------|---------------|-------------|---------------|----------|
| RustDesk-NAT | 21115 | [YOUR_LOCAL_IP] | 21115 | TCP |
| RustDesk-Main | 21116 | [YOUR_LOCAL_IP] | 21116 | TCP/UDP |
| RustDesk-Relay | 21117 | [YOUR_LOCAL_IP] | 21117 | TCP |
| RustDesk-WS1 | 21118 | [YOUR_LOCAL_IP] | 21118 | TCP |
| RustDesk-WS2 | 21119 | [YOUR_LOCAL_IP] | 21119 | TCP |

Replace `[YOUR_LOCAL_IP]` with your actual local IP address.

### Test external connectivity:
```bash
nc -zv [YOUR_PUBLIC_IP] 21116
```

## 📱 Step 6: Configure RustDesk Clients

### For Local Network Devices:
- **ID Server:** `[YOUR_LOCAL_IP]:21116`
- **Relay Server:** `[YOUR_LOCAL_IP]:21117`
- **Key:** `[YOUR_SERVER_KEY]`

### For Internet/External Devices:
- **ID Server:** `[YOUR_PUBLIC_IP]:21116`
- **Relay Server:** `[YOUR_PUBLIC_IP]:21117`
- **Key:** `[YOUR_SERVER_KEY]`

### Configuration Steps:
1. Open RustDesk on the client device
2. Go to Settings → Network
3. Enter the appropriate server settings above
4. Save and restart RustDesk

## 🛠️ Management Commands

### View running containers:
```bash
docker compose ps
```

### View logs:
```bash
docker compose logs
docker compose logs -f  # Follow logs in real-time
```

### Stop the server:
```bash
docker compose down
```

### Restart the server:
```bash
docker compose restart
```

### Update to latest version:
```bash
docker compose pull
docker compose up -d
```

## 🔍 Troubleshooting

### "Not ready, please check your connection" error:
1. Use `localhost:21116` instead of IP address for same-machine setup
2. Restart RustDesk client after changing settings
3. Check macOS firewall settings (System Preferences → Security & Privacy → Firewall)
4. Ensure Docker Desktop is running
5. Verify containers are healthy: `docker compose ps`

### External connections not working:
1. Verify port forwarding is configured correctly
2. Check if ISP blocks the ports
3. Test local connection first: `nc -zv localhost 21116`
4. Ensure router firewall allows the ports

### Container startup issues:
1. Check Docker Desktop is running
2. Verify docker-compose.yml syntax
3. Check available disk space
4. Review container logs: `docker compose logs`

## 📊 Port Reference

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 21115 | hbbs | TCP | NAT test and web console |
| 21116 | hbbs | TCP/UDP | Main rendezvous server |
| 21117 | hbbr | TCP | Relay server |
| 21118 | hbbs | TCP | WebSocket |
| 21119 | hbbr | TCP | WebSocket |

## 🔒 Security Considerations

- **Local Network Only:** Most secure, only devices on your network can connect
- **Internet Access:** Requires port forwarding, exposes server to internet
- **VPN Alternative:** Set up VPN server instead of port forwarding for better security
- **Firewall:** Keep macOS firewall enabled and only allow necessary applications

## ✅ Success Indicators

- ✅ Docker containers show "Up" status
- ✅ Local port tests succeed (`nc -zv localhost 21116`)
- ✅ External port tests succeed (if port forwarding configured)
- ✅ RustDesk client shows "Ready" status
- ✅ Can establish remote connections between devices

---

## 📝 Example Configuration

Here's how the configuration would look with example values:

### Server Information:
- **Local IP:** `192.168.1.100` (example)
- **Public IP:** `203.0.113.10` (example)
- **Server Key:** `ABCD1234567890abcdef1234567890ABCDEF1234567890abcdef=` (example)

### Client Settings Example:
**Local Network:**
- ID Server: `192.168.1.100:21116`
- Relay Server: `192.168.1.100:21117`
- Key: `ABCD1234567890abcdef1234567890ABCDEF1234567890abcdef=`

**Internet Access:**
- ID Server: `203.0.113.10:21116`
- Relay Server: `203.0.113.10:21117`
- Key: `ABCD1234567890abcdef1234567890ABCDEF1234567890abcdef=`

> **Note:** Replace the example values above with your actual server IP addresses and key generated during setup.

## 🆘 Common Issues & Solutions

### Issue: "network_mode: host" doesn't work on macOS
**Solution:** Use explicit port mapping instead (as shown in our docker-compose.yml)

### Issue: Containers start but ports aren't accessible
**Solution:**
1. Remove `network_mode: "host"` from docker-compose.yml
2. Add explicit port mappings under `ports:` section
3. Restart containers: `docker compose down && docker compose up -d`

### Issue: RustDesk client can't connect to localhost
**Solution:**
1. Try `localhost:21116` instead of IP address
2. Check macOS firewall settings
3. Ensure Docker Desktop has firewall permissions

## 🔄 Maintenance

### Regular Tasks:
- **Weekly:** Check container status and logs
- **Monthly:** Update to latest RustDesk server image
- **As needed:** Backup the `data` directory

### Backup Command:
```bash
tar -czf rustdesk-backup-$(date +%Y%m%d).tar.gz data/
```

### Restore Command:
```bash
tar -xzf rustdesk-backup-YYYYMMDD.tar.gz
```

## 📖 Additional Resources

- **Official RustDesk Documentation:** https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/docker/
- **RustDesk GitHub Repository:** https://github.com/rustdesk/rustdesk-server
- **Docker Compose Documentation:** https://docs.docker.com/compose/
- **Docker Desktop for Mac:** https://docs.docker.com/desktop/mac/

## 🤝 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review the official RustDesk documentation
3. Check Docker Desktop status and logs
4. Verify network connectivity and firewall settings

**Your RustDesk server is now ready for secure remote desktop connections!** 🎉
