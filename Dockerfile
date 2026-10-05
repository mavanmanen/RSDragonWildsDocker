FROM ubuntu:noble

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN dpkg --add-architecture i386
RUN add-apt-repository multiverse
RUN rm -rf /var/lib/apt/lists/*

RUN apt-get update
RUN apt-get install -y --no-install-recommends wget libsdl2-2.0-0 ca-certificates lib32gcc-s1 unzip
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir /steamcmd
WORKDIR /steamcmd
RUN wget -qO- https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xvz
RUN chmod a+x ./steamcmd.sh
RUN mv steamcmd.sh steamcmd
RUN cp -r ./** /usr/local/bin/
RUN steamcmd +quit

RUN mkdir /initool
WORKDIR /initool
RUN wget https://github.com/dbohdan/initool/releases/download/v1.0.0/initool-v1.0.0-9dc7574-linux-x86_64.zip
RUN unzip initool-v1.0.0-9dc7574-linux-x86_64.zip
RUN chmod a+x ./initool
RUN cp ./initool /usr/local/bin/initool

RUN mkdir /server
WORKDIR /server
COPY start-server.sh .
RUN chmod a+x start-server.sh

RUN useradd -m -s /bin/bash steam
RUN mkdir /server-files
RUN chown -R steam:steam /server-files

EXPOSE 7777/udp
EXPOSE 8888/udp

USER steam
CMD ["/server/start-server.sh"]