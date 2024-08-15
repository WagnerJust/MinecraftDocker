#!/bin/bash

# Function to download and install plugins
install_plugins() {
    if [ -f /plugin_urls.txt ]; then
        mkdir -p /minecraft/plugins
        echo "Installing plugins..."
        while IFS= read -r url; do
            echo "Downloading plugin from $url..."
            wget -P /minecraft/plugins "$url" -nv || { echo "Failed to download $url"; exit 1; }
        done < /plugin_urls.txt
        echo "Plugins installed."
    	rm /plugin_urls.txt
        echo "plugin_urls.txt deleted."
    else
        echo "No plugin_urls.txt found. Skipping plugin installation."
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
            echo "Type of server is invalid"
            exit 1
            ;;
    esac
}

# Check if eula.txt exists, if not create it
if [ ! -f /minecraft/eula.txt ]; then
    echo "Creating eula.txt..."
    echo "eula=true" > /minecraft/eula.txt || { echo "Failed to create eula.txt"; exit 1; }
fi

# Install plugins
if [ ${PLUGINS} = "True" ]; then
	install_plugins
fi

#Download jar file for associated server
download_server_jar

# Start the Minecraft server
echo "Starting Minecraft server with ${RAM} RAM..."
exec java -Xmx${RAM} -Xms${RAM} -jar /minecraft/server.jar nogui || { echo "Failed to start Minecraft server"; exit 1; }

