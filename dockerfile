FROM eclipse-temurin:21-jre-jammy

WORKDIR /minecraft

# Install wget
RUN apt-get install -y wget && ocl-icd-libopencl1 && \
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

# Ensure the startup script is executable
RUN chmod +x /start.sh

# Start the Minecraft server
CMD ["/start.sh"]

