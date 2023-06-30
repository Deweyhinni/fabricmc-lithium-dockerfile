# Fabric Server + Lithium Dockerfile 

## Building
``` bash
# Build command:
docker build --build-arg RCON_PASSWORD="your_desired_password" --build-arg FABRIC_VERSION="1.19.4" --build-arg LITHIUM_VERSION="mc1.19.4-0.11.1" -t minecraft-server .
```

1.  Set the RCON_PASSWORD build argument to the password that you will use to connect to the server console via RCON. This password will be used for all the containers you run but you can manually change that if you want
2.  Set the build argument FABRIC_VERSION to the minecraft version you want to use
3.  Go to [Lithium mod github page](https://github.com/CaffeineMC/lithium-fabric/releases) and find a release that matches your minecraft version and copy the version name like mcX.XX.X-X.XX.X found in the assets tab and set that as the build argument LITHIUM_VERSION  

## Running with a bind mounts
``` bash
# run command for bind mount: 
docker run -d -e "MEMORY=2" -p 25565:25565 -p 25575:25575 -v "$(pwd)"/WorldFolder:/minecraft/WorldFolderMnt --name minecraft-server-container minecraft-server
```

If you want to change the default amount of memory your server uses set the MEMORY enviroment variable to the amount of memory you want it to allocate in GB. <br/>

To change the ports you use to connect to your server change the -p like this XXXXX:25565 for the server itself and XXXXX:25575 for the RCON port. <br/>

The -v argument creates a bind mount to the folder WorldFolder on the host system so if you want to use a specific persistant world you would name the world folder WorldFolder and put it in the same directory as the Dockerfile. <br/>

Then set the name of the docker container after the --name argument and the final argument is the name of the docker image that you set when building


## Running with volume
``` bash
# run command for volumes: 
docker run -d -e "MEMORY=2" -p 25565:25565 -p 25575:25575 -v WorldFolder:/minecraft/WorldFolderMnt --name minecraft-server minecraft-server
```

This run command is the same as the one above except it creates a volume and generates a random world in that volume, the volume is persistant until you delete it but you can create multiple to use with multiple servers by specifying the name of the volume like  ``` -v <volume name>:/minecraft/WorldFolderMnt``` 

## If you need to use a fabric loader version before 0.13.0 replace the CMD with this code to patch log4j2 vulnerability
``` dockerfile
# Start the Minecraft server with log4shell vulnerability fix based on versions
CMD if [ "${FABRIC_ENV}" = "1.18" ]; then \
      java -Xmx${MEMORY}G -jar fabric-server-mc.${FABRIC_ENV}-loader.0.14.21-launcher.0.11.2.jar nogui; \
    elif [[ "${FABRIC_ENV}" =~ ^1\.17\..* ]]; then \
      java -Xmx${MEMORY}G -Dlog4j2.formatMsgNoLookups=true -jar fabric-server-mc.${FABRIC_ENV}-loader.0.14.21-launcher.0.11.2.jar nogui; \
    elif [[ "${FABRIC_ENV}" =~ ^(1\.12|1\.13|1\.14|1\.15|1\.16)\..* ]]; then \
      curl -OJ https://launcher.mojang.com/v1/objects/02937d122c86ce73319ef9975b58896fc1b491d1/log4j2_112-116.xml && \
      mv log4j2_112-116.xml log4j2.xml && \
      java -Xmx${MEMORY}G -Dlog4j.configurationFile=log4j2.xml -jar fabric-server-mc.${FABRIC_ENV}-loader.0.14.21-launcher.0.11.2.jar nogui; \
    elif [[ "${FABRIC_ENV}" =~ ^(1\.7|1\.8|1\.9|1\.10|1\.11)\..* ]]; then \
      curl -OJ https://launcher.mojang.com/v1/objects/4bb89a97a66f350bc9f73b3ca8509632682aea2e/log4j2_17-111.xml && \
      mv log4j2_17-111.xml log4j2.xml && \
      java -Xmx${MEMORY}G -Dlog4j.configurationFile=log4j2.xml -jar fabric-server-mc.${FABRIC_ENV}-loader.0.14.21-launcher.0.11.2.jar nogui; \
    else \
      java -Xmx${MEMORY}G -jar fabric-server-mc.${FABRIC_ENV}-loader.0.14.21-launcher.0.11.2.jar nogui; \
    fi
# DISCLAIMER this code to download and apply the patches was written by chatgpt bc bash is confusing lmao
```
