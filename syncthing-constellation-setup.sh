#!/bin/bash

# Syncthing Constellation Setup Script
# Configures P2P file synchronization for Elias ecosystem nodes
# Version: 1.0
# Author: Elias Ecosystem

set -e

echo "🌌 Syncthing Constellation Setup"
echo "================================"
echo ""

# Check if Syncthing is installed
if ! command -v syncthing &> /dev/null; then
    echo "📦 Installing Syncthing..."
    
    # Detect OS and install accordingly
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux installation
        curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
        echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
        sudo apt update
        sudo apt install syncthing -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS installation
        if command -v brew &> /dev/null; then
            brew install syncthing
        else
            echo "❌ Homebrew not found. Please install Homebrew first or install Syncthing manually."
            exit 1
        fi
    else
        echo "❌ Unsupported OS. Please install Syncthing manually: https://syncthing.net/downloads/"
        exit 1
    fi
fi

echo "✅ Syncthing installed"

# Get node information
echo ""
echo "🏷️  Node Configuration"
echo "====================="

# Prompt for node type
echo "Select your constellation node type:"
echo "1) Gracey (MacBook VM - Development)"
echo "2) Griffith (RTX 5060 Ti - Primary Server)"
echo "3) Clarabelle (Raspberry Pi 5 - Lightweight Server)"
echo "4) Marceline (Web Server - Public Interface)"
echo "5) External Satellite (e.g., Patrick's node)"
echo ""
read -p "Enter choice (1-5): " node_choice

case $node_choice in
    1)
        NODE_NAME="gracey"
        NODE_TYPE="development"
        DEVICE_NAME="Gracey-MacBook-VM"
        ;;
    2)
        NODE_NAME="griffith"
        NODE_TYPE="primary-server"
        DEVICE_NAME="Griffith-RTX-Server"
        ;;
    3)
        NODE_NAME="clarabelle"
        NODE_TYPE="lightweight-server"
        DEVICE_NAME="Clarabelle-Pi5"
        ;;
    4)
        NODE_NAME="marceline"
        NODE_TYPE="web-server"
        DEVICE_NAME="Marceline-Web"
        ;;
    5)
        echo "Enter external node name (e.g., patrick-slovakia):"
        read -p "Node name: " NODE_NAME
        NODE_TYPE="external-satellite"
        DEVICE_NAME="External-${NODE_NAME^}"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo "✅ Node configured as: $DEVICE_NAME"

# Create Syncthing configuration directory
SYNCTHING_DIR="$HOME/.config/syncthing"
mkdir -p "$SYNCTHING_DIR"

# Start Syncthing to generate initial config
echo ""
echo "🚀 Starting Syncthing to generate configuration..."
syncthing generate

# Get device ID
DEVICE_ID=$(syncthing -device-id)
echo "📱 Your device ID: $DEVICE_ID"

# Configure device name
echo ""
echo "⚙️  Configuring Syncthing settings..."

# Create custom config with device name
cat > "$SYNCTHING_DIR/config.xml.tmp" << EOF
<configuration version="37">
    <folder id="elias-shared" label="Elias Shared" path="\$HOME/constellation/shared" type="sendreceive" rescanIntervalS="3600" fsWatcherEnabled="true">
        <device id="$DEVICE_ID" introducedBy=""></device>
        <minDiskFree unit="%">1</minDiskFree>
        <versioning></versioning>
        <copiers>0</copiers>
        <pullerMaxPendingKiB>0</pullerMaxPendingKiB>
        <hashers>0</hashers>
        <order>random</order>
        <ignoreDelete>false</ignoreDelete>
        <scanProgressIntervalS>0</scanProgressIntervalS>
        <pullerPauseS>0</pullerPauseS>
        <maxConflicts>10</maxConflicts>
        <disableSparseFiles>false</disableSparseFiles>
        <disableTempIndexes>false</disableTempIndexes>
        <paused>false</paused>
        <weakHashThresholdPct>25</weakHashThresholdPct>
        <markerName>.stfolder</markerName>
        <copyOwnershipFromParent>false</copyOwnershipFromParent>
        <modTimeWindowS>0</modTimeWindowS>
        <maxConcurrentWrites>2</maxConcurrentWrites>
        <disableFsync>false</disableFsync>
        <blockPullOrder>standard</blockPullOrder>
        <copyRangeMethod>standard</copyRangeMethod>
        <caseSensitiveFS>false</caseSensitiveFS>
        <junctionsAsDirs>false</junctionsAsDirs>
    </folder>
    <device id="$DEVICE_ID" name="$DEVICE_NAME" compression="metadata" introducer="false" skipIntroductionRemovals="false" introducedBy="" paused="false" allowedNetwork="" autoAcceptFolders="false" maxSendKbps="0" maxRecvKbps="0" maxRequestKiB="0" untrusted="false" remoteGUIPort="0">
        <address>dynamic</address>
    </device>
    <gui enabled="true" tls="false" debugging="false" apikey="">
        <address>127.0.0.1:8384</address>
        <user></user>
        <password></password>
        <theme>default</theme>
    </gui>
    <ldap></ldap>
    <options>
        <listenAddress>default</listenAddress>
        <globalAnnounceServer>default</globalAnnounceServer>
        <globalAnnounceEnabled>true</globalAnnounceEnabled>
        <localAnnounceEnabled>true</localAnnounceEnabled>
        <localAnnouncePort>21027</localAnnouncePort>
        <localAnnounceMCAddr>[ff12::8384]:21027</localAnnounceMCAddr>
        <maxSendKbps>0</maxSendKbps>
        <maxRecvKbps>0</maxRecvKbps>
        <reconnectionIntervalS>60</reconnectionIntervalS>
        <relaysEnabled>true</relaysEnabled>
        <relayReconnectIntervalM>10</relayReconnectIntervalM>
        <startBrowser>true</startBrowser>
        <natEnabled>true</natEnabled>
        <natLeaseMinutes>60</natLeaseMinutes>
        <natRenewalMinutes>30</natRenewalMinutes>
        <natTimeoutSeconds>10</natTimeoutSeconds>
        <urAccepted>-1</urAccepted>
        <urSeen>0</urSeen>
        <urUniqueId></urUniqueId>
        <urURL>https://data.syncthing.net/newdata</urURL>
        <urPostInsecurely>false</urPostInsecurely>
        <urInitialDelayS>1800</urInitialDelayS>
        <autoUpgradeIntervalH>12</autoUpgradeIntervalH>
        <upgradeToPreReleases>false</upgradeToPreReleases>
        <keepTemporariesH>24</keepTemporariesH>
        <cacheIgnoredFiles>false</cacheIgnoredFiles>
        <progressUpdateIntervalS>5</progressUpdateIntervalS>
        <limitBandwidthInLan>false</limitBandwidthInLan>
        <minHomeDiskFree unit="%">1</minHomeDiskFree>
        <releasesURL>https://upgrades.syncthing.net/meta.json</releasesURL>
        <overwriteRemoteDeviceNamesOnConnect>false</overwriteRemoteDeviceNamesOnConnect>
        <tempIndexMinBlocks>10</tempIndexMinBlocks>
        <trafficClass>0</trafficClass>
        <setLowPriority>true</setLowPriority>
        <maxFolderConcurrency>0</maxFolderConcurrency>
        <crashReportingURL>https://crash.syncthing.net/newcrash</crashReportingURL>
        <crashReportingEnabled>true</crashReportingEnabled>
        <stunKeepaliveStartS>180</stunKeepaliveStartS>
        <stunKeepaliveMinS>20</stunKeepaliveMinS>
        <stunServer>default</stunServer>
        <databaseTuning>auto</databaseTuning>
        <maxConcurrentIncomingRequestKiB>0</maxConcurrentIncomingRequestKiB>
        <announceLANAddresses>true</announceLANAddresses>
        <sendFullIndexOnUpgrade>false</sendFullIndexOnUpgrade>
    </options>
</configuration>
EOF

# Backup original config if it exists
if [ -f "$SYNCTHING_DIR/config.xml" ]; then
    cp "$SYNCTHING_DIR/config.xml" "$SYNCTHING_DIR/config.xml.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Move new config into place
mv "$SYNCTHING_DIR/config.xml.tmp" "$SYNCTHING_DIR/config.xml"

# Create constellation shared directory
mkdir -p "$HOME/constellation/shared"

echo "✅ Syncthing configuration created"

# Display connection information
echo ""
echo "🔗 Constellation Network Connection Info"
echo "========================================"
echo "Device Name: $DEVICE_NAME"
echo "Device ID: $DEVICE_ID"
echo "Node Type: $NODE_TYPE"
echo "Shared Folder: $HOME/constellation/shared"
echo ""

# Create device connection file for easy sharing
CONNECTION_FILE="$HOME/constellation/shared/device-connections/${NODE_NAME}-connection.json"
mkdir -p "$(dirname "$CONNECTION_FILE")"

cat > "$CONNECTION_FILE" << EOF
{
  "node_name": "$NODE_NAME",
  "device_name": "$DEVICE_NAME", 
  "device_id": "$DEVICE_ID",
  "node_type": "$NODE_TYPE",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "shared_folder": "$HOME/constellation/shared",
  "syncthing_version": "$(syncthing --version | head -n1)"
}
EOF

echo "💾 Connection info saved to: $CONNECTION_FILE"

# Known constellation device IDs (to be updated as nodes are added)
echo ""
echo "🌌 Known Constellation Devices"
echo "=============================="
echo "Add these device IDs to connect to other constellation nodes:"
echo ""
echo "Gracey (Development):     [Device ID to be shared]"
echo "Griffith (Primary):       [Device ID to be shared]"
echo "Clarabelle (Pi5):         [Device ID to be shared]"
echo "Marceline (Web):          [Device ID to be shared]"
echo ""

# Create auto-start script
AUTOSTART_SCRIPT="$HOME/constellation/scripts/start-syncthing.sh"
mkdir -p "$(dirname "$AUTOSTART_SCRIPT")"

cat > "$AUTOSTART_SCRIPT" << 'EOF'
#!/bin/bash
# Auto-start Syncthing for constellation node

echo "🌌 Starting Syncthing for constellation node..."

# Start Syncthing in background
syncthing serve --no-browser &
SYNCTHING_PID=$!

echo "✅ Syncthing started (PID: $SYNCTHING_PID)"
echo "📱 Web interface: http://localhost:8384"
echo "🛑 To stop: kill $SYNCTHING_PID"

# Save PID for easy stopping
echo $SYNCTHING_PID > "$HOME/.syncthing.pid"
EOF

chmod +x "$AUTOSTART_SCRIPT"

echo "🚀 Auto-start script created: $AUTOSTART_SCRIPT"

# Offer to start Syncthing now
echo ""
read -p "Start Syncthing now? (y/N): " start_now

if [[ $start_now =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Starting Syncthing..."
    syncthing serve --no-browser &
    SYNCTHING_PID=$!
    echo $SYNCTHING_PID > "$HOME/.syncthing.pid"
    
    echo "✅ Syncthing started (PID: $SYNCTHING_PID)"
    echo "📱 Web interface: http://localhost:8384"
    
    # Wait a moment for startup
    sleep 3
    
    echo ""
    echo "🌐 Opening web interface..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "http://localhost:8384"
    elif [[ "$OSTYPE" == "linux-gnu"* ]] && command -v xdg-open &> /dev/null; then
        xdg-open "http://localhost:8384"
    else
        echo "   Manual: Open http://localhost:8384 in your browser"
    fi
fi

echo ""
echo "📋 Next Steps:"
echo "=============="
echo "1. Access web interface: http://localhost:8384"
echo "2. Share your Device ID with other constellation nodes"
echo "3. Add other constellation device IDs to connect"
echo "4. Verify 'elias-shared' folder is syncing"
echo "5. Test file synchronization across nodes"
echo ""
echo "🔧 Management Commands:"
echo "  Start:  $AUTOSTART_SCRIPT"
echo "  Stop:   kill \$(cat ~/.syncthing.pid)"
echo "  Status: ps aux | grep syncthing"
echo ""
echo "✨ Constellation node setup complete!"
echo "   Your device is ready to join the Elias ecosystem"