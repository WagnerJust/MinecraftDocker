
DOCKER HUB IMAGE:
	justhwagner/minecraft:global

To run the docker image without a compose:
docker run -it --name minecraft-papermc-server -p 25568:25565 -v $(pwd)/server_data:/minecraft --env-file .env justhwagner/minecraft:global

To run with docker compose use:
docker compose up --build


TYPES: PaperMC, Vanilla, Forge, Fabric
.env File Example

TYPE=PaperMC
RAM=8G
PLUGINS=True
DATADIR=~/Minecraft/
NAME=minecraft-papermc
PORT=25565
CPUS=7
MEMORY=10G
MODS=False
DATAPACKS=False

plugin_urls.txt example:

https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsX-2.20.1.jar
https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsXChat-2.20.1.jar
https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsXSpawn-2.20.1.jar
https://hangarcdn.papermc.io/plugins/pop4959/Chunky/versions/1.4.10/PAPER/Chunky-1.4.10.jar
https://cdn.modrinth.com/data/TpxWaIMT/versions/KkVdJRVL/lagassist-2.32.jar


datapacks_urls.txt example:

https://cdn.modrinth.com/data/YVMr2l79/versions/aJwN0nSk/Skyblock_Infinite_1_1_5.zip


single_mods.urls.txt example:
https://www.curseforge.com/minecraft/mc-mods/clumps/download/6014988

modpacks_urls.txt example:

https://www.curseforge.com/minecraft/modpacks/all-the-mods-9/download/6021681