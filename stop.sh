#!/bin/bash

# RustDesk Server Stop Script
# This script stops the RustDesk server containers and optionally closes Docker Desktop

echo "🛑 Stopping RustDesk Server..."
echo "==============================="

# Check command line arguments
CLOSE_DOCKER=false
if [ "$1" = "--close-docker" ] || [ "$1" = "-d" ]; then
    CLOSE_DOCKER=true
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running!"
    echo "Cannot stop containers - Docker Desktop is not available."
    exit 1
fi

# Navigate to the script directory
cd "$(dirname "$0")"

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found!"
    echo "Please make sure you're in the correct directory."
    exit 1
fi

# Check if containers are running
if docker compose ps | grep -q "Up"; then
    echo "📦 Stopping containers..."
    docker compose down
    
    # Wait a moment for containers to stop
    sleep 2
    
    # Verify containers are stopped
    if ! docker compose ps | grep -q "Up"; then
        echo ""
        echo "✅ RustDesk Server stopped successfully!"
        echo ""
        echo "📊 Container Status:"
        docker compose ps
        echo ""

        # Close Docker Desktop if requested
        if [ "$CLOSE_DOCKER" = true ]; then
            echo "🔄 Closing Docker Desktop..."
            osascript -e 'quit app "Docker Desktop"'
            echo "✅ Docker Desktop closed!"
            echo ""
        fi

        echo "🔍 To start the server again:"
        echo "  ./start.sh"
        if [ "$CLOSE_DOCKER" = false ]; then
            echo ""
            echo "💡 To stop and close Docker Desktop:"
            echo "  ./stop.sh --close-docker"
        fi
        echo ""
    else
        echo ""
        echo "⚠️  Some containers may still be running:"
        docker compose ps
        echo ""
        echo "Try forcing stop with:"
        echo "  docker compose down --remove-orphans"
    fi
else
    echo "ℹ️  No running containers found."
    echo ""
    echo "📊 Current Status:"
    docker compose ps
    echo ""

    # Close Docker Desktop if requested
    if [ "$CLOSE_DOCKER" = true ]; then
        echo "🔄 Closing Docker Desktop..."
        osascript -e 'quit app "Docker Desktop"'
        echo "✅ Docker Desktop closed!"
        echo ""
    fi

    echo "🔍 To start the server:"
    echo "  ./start.sh"
    if [ "$CLOSE_DOCKER" = false ]; then
        echo ""
        echo "💡 To close Docker Desktop:"
        echo "  ./stop.sh --close-docker"
    fi
fi
