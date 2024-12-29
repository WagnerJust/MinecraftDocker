#!/bin/bash

# Set default values
TYPE=${TYPE:-PaperMC}
RAM=${RAM:-4G}
PLUGINS=${PLUGINS:-False}
MODS=${MODS:-False}
PORT=${PORT:-25565}
DATAPACKS=${DATAPACKS:-False}

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
    if ls /minecraft/plugins/*lagassist*.jar 1> /dev/null 2>&1; then
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

    if ls /minecraft/plugins/*[Cc]hunky*.jar 1> /dev/null 2>&1; then
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

# Function to download and install mods from single_mods_urls.txt
install_single_mods() {
    if [ -f /single_mods_urls.txt ]; then
        if [ -s /single_mods_urls.txt ]; then
            mkdir -p /minecraft/mods
            echo "Installing mods from single_mods_urls.txt..."
            while IFS= read -r url; do
                echo "Downloading mod from $url..."
                wget -P /minecraft/mods "$url" -nv || { echo "Failed to download $url"; continue; }
            done < /single_mods_urls.txt
            echo "Mods installed from single_mods_urls.txt."
            rm /single_mods_urls.txt
            echo "single_mods_urls.txt deleted."
        else
            echo "single_mods_urls.txt is empty. Skipping mods installation."
        fi
    else
        echo "No single_mods_urls.txt found. Skipping mods installation."
    fi
}

# Function to download and install modpacks from modpacks_urls.txt
install_modpacks() {
    if [ -f /modpacks_urls.txt ]; then
        if [ -s /modpacks_urls.txt ]; then
            echo "Installing modpacks from modpacks_urls.txt..."
            while IFS= read -r url; do
                echo "Downloading modpack from $url..."
                wget -O /tmp/modpack.zip "$url" -nv || { echo "Failed to download $url"; continue; }
                echo "Extracting modpack from $url..."
                mkdir -p /minecraft
                unzip -o /tmp/modpack.zip -d /minecraft || { echo "Failed to extract modpack"; continue; }
                echo "Modpack installed from $url."
                rm /tmp/modpack.zip
            done < /modpacks_urls.txt
            echo "Modpacks installed from modpacks_urls.txt."
            rm /modpacks_urls.txt
            echo "modpacks_urls.txt deleted."
        else
            echo "modpacks_urls.txt is empty. Skipping modpack installation."
        fi
    else
        echo "No modpacks_urls.txt found. Skipping modpack installation."
    fi
}

# Check for MODS environment variable
echo "Checking for MODS environment variable..."
if [ "${MODS}" = "True" ]; then
    echo "MODS=True. Checking for modpacks and single mods..."

    MODPACK_EXISTS=false
    MODS_EXISTS=false

    if [ -f /modpacks_urls.txt ] && [ -s /modpacks_urls.txt ]; then
        MODPACK_EXISTS=true
    fi

    if [ -f /single_mods_urls.txt ] && [ -s /single_mods_urls.txt ]; then
        MODS_EXISTS=true
    fi

    if ! $MODPACK_EXISTS && ! $MODS_EXISTS; then
        echo "Error: MODS=True but no valid modpacks_urls.txt or single_mods_urls.txt provided."
        exit 1
    fi

    install_modpacks
    install_single_mods
else
    echo "MODS=False. Skipping mods and modpack installation."
fi

# Function to download server jar
download_server_jar() {
    case "${TYPE}" in
        Vanilla)
            wget -O /minecraft/server.jar https://piston-data.mojang.com/v1/objects/59353fb40c36d304f2035d51e7d6e6baa98dc05c/server.jar || { echo "Failed to download server.jar"; exit 1; }
            ;;
        PaperMC)
            wget -O /minecraft/server.jar https://api.papermc.io/v2/projects/paper/versions/1.21.1/builds/14/downloads/paper-1.21.1-14.jar || { echo "Failed to download server.jar"; exit 1; }
            ;;
        Forge)
            wget -O /minecraft/installer.jar https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.5-36.2.34/forge-1.16.5-36.2.34-installer.jar || { echo "Failed to download Forge installer"; exit 1; }
            java -jar /minecraft/installer.jar --installServer /minecraft || { echo "Failed to install Forge server"; exit 1; }
            ;;
        Fabric)
            wget -O /minecraft/fabric-installer.jar https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar || { echo "Failed to download Fabric installer"; exit 1; }
            java -jar /minecraft/fabric-installer.jar server -dir /minecraft || { echo "Failed to install Fabric server"; exit 1; }
            ;;
        *)
            echo "Invalid server type. Defaulting to PaperMC."
            wget -O /minecraft/server.jar https://api.papermc.io/v2/projects/paper/versions/1.21.1/builds/14/downloads/paper-1.21.1-14.jar || { echo "Failed to download server.jar"; exit 1; }
            ;;
    esac
}

# Create eula.txt if not exists
if [ ! -f /minecraft/eula.txt ]; then
    echo "Creating eula.txt..."
    echo "eula=true" > /minecraft/eula.txt || { echo "Failed to create eula.txt"; exit 1; }
fi

# Install plugins if PLUGINS=True
if [ "${PLUGINS}" = "True" ]; then
    install_plugins
    configure_plugins
fi

# Download server jar if required
download_server_jar

# Start the server
echo "Starting Minecraft server (${TYPE}) with ${RAM} RAM on port ${PORT}..."
exec java -Xmx${RAM} -Xms${RAM} -jar /minecraft/server.jar nogui || { echo "Failed to start Minecraft server"; exit 1; }
