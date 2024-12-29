FROM eclipse-temurin:21-jre-jammy

WORKDIR /minecraft

#Install wget and unzip
RUN apt-get update && \
    apt-get install -y wget unzip && \
    apt-get clean


# Define enviroment variables
ENV RAM=2048M
ENV PORT=25565
ENV TYPE=Vanilla
ENV PLUGINS=False

# Expose the default Minecraft port
EXPOSE 25565

# Copy the startup script and plugin URLs file
COPY start.sh /start.sh
COPY plugin_urls.txt /plugin_urls.txt
COPY mods_urls.txt /mods_urls.txt
COPY datapacks_urls.txt /datapacks_urls.txt
COPY server.properties /server.properties

# Ensure the startup script is executable
RUN chmod +x /start.sh

# Start the Minecraft server
CMD ["/start.sh"]

