#!/bin/bash

# Configuration
SERVICE_NAME="com.nulldivision.ghibli.wallpaper"
PLIST_FILENAME="${SERVICE_NAME}.plist"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROTATION_SCRIPT="${SCRIPT_DIR}/rotate_wallpaper.sh"

# Helper function to print usage
usage() {
    echo "Usage: $0 [hourly|daily]"
    exit 1
}

# Parse argument
FREQUENCY=$1
if [ -z "$FREQUENCY" ]; then
    FREQUENCY="hourly" # Default
fi

case "$FREQUENCY" in
    hourly)
        INTERVAL=3600
        echo "Configuring for HOURLY rotation ($INTERVAL seconds)..."
        ;;
    daily)
        INTERVAL=86400
        echo "Configuring for DAILY rotation ($INTERVAL seconds)..."
        ;;
    *)
        echo "Error: Invalid frequency '$FREQUENCY'."
        usage
        ;;
esac

echo "Rotation script location: $ROTATION_SCRIPT"

# Verify rotation script exists
if [ ! -f "$ROTATION_SCRIPT" ]; then
    echo "Error: rotate_wallpaper.sh not found at $ROTATION_SCRIPT"
    exit 1
fi

# Create/Update the plist file
# We treat the source 'com.nulldivision.ghibli.wallpaper.plist' as a template or overwrite it
# Here we'll just write a fresh one to be sure the path and interval are correct
cat > "$PLIST_FILENAME" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${SERVICE_NAME}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${ROTATION_SCRIPT}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StartInterval</key>
    <integer>${INTERVAL}</integer>
    <key>StandardOutPath</key>
    <string>/tmp/ghibli_wallpaper.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/ghibli_wallpaper.error.log</string>
</dict>
</plist>
EOF

echo "Generated $PLIST_FILENAME"

# Install to LaunchAgents
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
DEST_PLIST="${LAUNCH_AGENTS_DIR}/${PLIST_FILENAME}"

echo "Installing to $DEST_PLIST..."
mkdir -p "$LAUNCH_AGENTS_DIR"
cp "$PLIST_FILENAME" "$DEST_PLIST"

# Reload Service
echo "Reloading service..."
launchctl unload "$DEST_PLIST" 2>/dev/null
launchctl load "$DEST_PLIST"

# Check status
if launchctl list | grep -q "$SERVICE_NAME"; then
    echo "Success! Service $SERVICE_NAME is running."
else
    echo "Warning: Service might not have started correctly. Check logs at /tmp/ghibli_wallpaper.error.log"
fi
