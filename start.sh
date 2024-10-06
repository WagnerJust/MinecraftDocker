#!/bin/bash

# Set default values
TYPE=${TYPE:-PaperMC}
RAM=${RAM:-4G}
PLUGINS=${PLUGINS:-False}
PORT=${PORT:-25565}

# Function to download and install plugins
install_plugins() {
    if [ -f /plugin_urls.txt ]; then
        mkdir -p /minecraft/plugins
        echo "Installing plugins..."
        while IFS= read -r url; do
            echo "Downloading plugin from $url..."
            wget -P /minecraft/plugins "$url" -nv || { echo "Failed to download $url"; continue; }
        done < /plugin_urls.txt
        echo "Plugins installed."
        rm /plugin_urls.txt
        echo "plugin_urls.txt deleted."
    else
        echo "No plugin_urls.txt found. Skipping plugin installation."
    fi
}
# Function to configure plugins for performance
configure_plugins() {
    # ClearLag configuration
    if [ -f /minecraft/plugins/ClearLag.jar ]; then
        mkdir -p /minecraft/plugins/ClearLag
        cat > /minecraft/plugins/ClearLag/config.yml << EOL
lagg:
  auto-removal:
    enabled: true
    interval: 300
    remove:
      items: true
      mobs: true
      xp-orbs: true
  chunk-unloader:
    enabled: true
    interval: 600
EOL
        echo "ClearLag configured for optimal performance."
    else
        echo "ClearLag not found. Skipping configuration."
    fi

    # LagAssist configuration
    if [ -f /minecraft/plugins/LagAssist.jar ]; then
        mkdir -p /minecraft/plugins/LagAssist
        cat > /minecraft/plugins/LagAssist/config.yml << EOL
performance:
  chunk-loader:
    enabled: true
    max-per-tick: 50
  entity-limiter:
    enabled: true
    max-per-chunk: 25
  tile-entity-limiter:
    enabled: true
    max-per-chunk: 50
EOL
        echo "LagAssist configured for optimal performance."
    else
        echo "LagAssist not found. Skipping configuration."
    fi

    # Chunky configuration
    if [ -f /minecraft/plugins/Chunky.jar ]; then
        mkdir -p /minecraft/plugins/Chunky
        cat > /minecraft/plugins/Chunky/config.yml << EOL
chunky:
  shape: square
  center: world,0,0
  radius: 1000
  tasks:
    generation:
      period: 20
      max-per-tick: 200
EOL
        echo "Chunky configured for optimal performance."
    else
        echo "Chunky not found. Skipping configuration."
    fi
}

download_server_jar(){
    case "${TYPE}" in
        Vanilla)
            wget -O /minecraft/server.jar https://piston-data.mojang.com/v1/objects/59353fb40c36d304f2035d51e7d6e6baa98dc05c/server.jar || { echo "Failed to download server.jar"; exit 1; }
            ;;
        PaperMC)
            wget -O /minecraft/server.jar https://api.papermc.io/v2/projects/paper/versions/1.21.1/builds/14/downloads/paper-1.21.1-14.jar || { echo "Failed to download server.jar"; exit 1; }
            ;;
        *)
            echo "Invalid server type. Defaulting to PaperMC."
            wget -O /minecraft/server.jar https://api.papermc.io/v2/projects/paper/versions/1.21.1/builds/14/downloads/paper-1.21.1-14.jar || { echo "Failed to download server.jar"; exit 1; }
            ;;
    esac
}

# Check if eula.txt exists, if not create it
if [ ! -f /minecraft/eula.txt ]; then
    echo "Creating eula.txt..."
    echo "eula=true" > /minecraft/eula.txt || { echo "Failed to create eula.txt"; exit 1; }
fi

# Install plugins if PLUGINS is set to True
if [ "${PLUGINS}" = "True" ]; then
    install_plugins
    configure_plugins
fi

# Download jar file for associated server
download_server_jar

# Start the Minecraft server
echo "Starting Minecraft server (${TYPE}) with ${RAM} RAM on port ${PORT}..."
exec java -Xmx${RAM} -Xms${RAM} -jar /minecraft/server.jar nogui || { echo "Failed to start Minecraft server"; exit 1; }