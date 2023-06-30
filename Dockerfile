# Use the official OpenJDK 17 image as the base
FROM openjdk:17

WORKDIR /minecraft

ARG FABRIC_VERSION="1.16.5"
ARG LITHIUM_VERSION="mc1.16.5-0.6.1"

# Download the Fabric server launcher
RUN curl -OJ https://meta.fabricmc.net/v2/versions/loader/${FABRIC_VERSION}/0.14.21/0.11.2/server/jar

# Run the Fabric server launcher to download the server jar
RUN java -Xmx2G -jar fabric-server-mc.${FABRIC_VERSION}-loader.0.14.21-launcher.0.11.2.jar nogui

# Accept the Minecraft EULA
RUN echo eula=true > eula.txt

# Download and move the Lithium mod to the mods folder
RUN curl -LJO https://github.com/CaffeineMC/lithium-fabric/releases/download/${LITHIUM_VERSION}/lithium-fabric-${LITHIUM_VERSION}.jar \
    && mv lithium-fabric-${LITHIUM_VERSION}.jar mods/lithium-fabric-${LITHIUM_VERSION}.jar

# Expose the default Minecraft port
EXPOSE 25565

# Expose the RCON port
EXPOSE 25575

# Set RCON properties based on environment variables
ARG RCON_PASSWORD="your_rcon_password"
RUN sed -i 's/^enable-rcon=false/enable-rcon=true/' server.properties && \
    sed -i 's/^rcon.port=25575/rcon.port=25575/' server.properties && \
    sed -i "s/^rcon.password=.*/rcon.password=${RCON_PASSWORD}/" server.properties && \
    sed -i 's/^level-name=world/level-name=WorldFolderMnt/' server.properties

ENV FABRIC_ENV=${FABRIC_VERSION}
ENV MEMORY="2"

CMD ["sh", "-c", "java -Xmx${MEMORY}G -jar fabric-server-mc.${FABRIC_ENV}-loader.0.14.21-launcher.0.11.2.jar nogui"]

# Build command:
# docker build --build-arg RCON_PASSWORD="your_desired_password" --build-arg FABRIC_VERSION="1.19.4" --build-arg LITHIUM_VERSION="mc1.19.4-0.11.1" -t minecraft-server .

# run command for bind mount: 
# docker run -d -e "MEMORY=2" -p 25565:25565 -p 25575:25575 -v "$(pwd)"/WorldFolder:/minecraft/WorldFolderMnt --name minecraft-server minecraft-server

# run command for volumes: 
# docker run -d -e "MEMORY=2" -p 25565:25565 -p 25575:25575 -v WorldFolder:/minecraft/WorldFolderMnt --name minecraft-server minecraft-server
