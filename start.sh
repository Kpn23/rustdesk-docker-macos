#!/bin/bash

# RustDesk Server Start Script
# This script starts the RustDesk server containers and displays connection information

echo "🚀 Starting RustDesk Server..."
echo "================================"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "⚠️  Docker is not running. Starting Docker Desktop..."

    # Start Docker Desktop
    open -a Docker

    echo "⏳ Waiting for Docker Desktop to start..."

    # Wait for Docker to be ready (max 60 seconds)
    for i in {1..60}; do
        if docker info >/dev/null 2>&1; then
            echo "✅ Docker Desktop is now running!"
            break
        fi

        if [ $i -eq 60 ]; then
            echo "❌ Docker Desktop failed to start within 60 seconds."
            echo "Please start Docker Desktop manually and try again."
            exit 1
        fi

        sleep 1
        echo -n "."
    done
    echo ""
fi

# Navigate to the script directory
cd "$(dirname "$0")"

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found!"
    echo "Please make sure you're in the correct directory."
    exit 1
fi

# Start the containers
echo "📦 Starting containers..."
docker compose up -d

# Wait a moment for containers to start
sleep 3

# Check container status
echo ""
echo "📊 Container Status:"
docker compose ps

# Check if containers are running
if docker compose ps | grep -q "Up"; then
    echo ""
    echo "✅ RustDesk Server started successfully!"
    echo ""
    
    # Get server information
    echo "🔧 Server Configuration:"
    echo "========================"
    
    # Get local IP
    LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
    echo "Local IP: $LOCAL_IP"
    
    # Get public IP
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unable to fetch")
    echo "Public IP: $PUBLIC_IP"
    
    # Get server key
    if [ -f "data/id_ed25519.pub" ]; then
        SERVER_KEY=$(cat data/id_ed25519.pub)
        echo "Server Key: $SERVER_KEY"
    else
        echo "Server Key: Not yet generated (check logs)"
    fi
    
    echo ""
    echo "📱 Client Configuration:"
    echo "========================"
    echo "For Local Network Devices:"
    echo "  ID Server: $LOCAL_IP:21116"
    echo "  Relay Server: $LOCAL_IP:21117"
    if [ -f "data/id_ed25519.pub" ]; then
        echo "  Key: $SERVER_KEY"
    fi
    
    echo ""
    echo "For Internet Devices (requires port forwarding):"
    echo "  ID Server: $PUBLIC_IP:21116"
    echo "  Relay Server: $PUBLIC_IP:21117"
    if [ -f "data/id_ed25519.pub" ]; then
        echo "  Key: $SERVER_KEY"
    fi
    
    echo ""
    echo "🔍 Useful Commands:"
    echo "==================="
    echo "View logs: docker compose logs"
    echo "Stop server: ./stop.sh"
    echo "Restart server: ./stop.sh && ./start.sh"
    echo ""
    
else
    echo ""
    echo "❌ Failed to start containers!"
    echo "Check the logs for more information:"
    echo "docker compose logs"
    exit 1
fi
