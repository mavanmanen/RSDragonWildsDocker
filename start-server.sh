#!/bin/bash
echo "Checking for RuneScape Dragonwilds server updates..."

steamcmd +@sSteamCmdForcePlatformType linux \
         +login anonymous \
         +app_update 4019830 \
         +quit
echo "Update check complete."

config_file="/server-files/RSDragonwilds/Saved/Config/LinuxServer/DedicatedServer.ini"

if [ ! -f "$config_file" ]; then
    echo "First time run to generate settings file"
    ./RSDragonwildsServer.sh  > /dev/null 2>&1 &
    server_pid=$!

    timeout=30
    while [ ! -f "$config_file" ] && [ $timeout -gt 0 ]; do
        sleep 1
        ((timeout--))
    done

    sleep 2
    pkill -P "$server_pid"
    kill -9 "$server_pid" 2>/dev/null
    pkill -9 -f "RSDragonwildsServer"
    echo "Done!"
fi

set_config() {
    local tmp_config="config.ini.tmp"
    local section="/Script/Dominion.DedicatedServerSettings"
    initool set "$config_file" "$section" "$1" "$2" > $tmp_config
    mv config.ini.tmp $config_file
}

set_config "OwnerId" "$OWNER_ID"
set_config "ServerName" "$SERVER_NAME"
set_config "WorldPassword" "$WORLD_PASSWORD"
set_config "DefaultWorldName" "$DEFAULT_WORLD_NAME"
set_config "PlatformPolicy" "$PLATFORM_POLICY"
set_config "bAllowSendingCrashDumps" "$ALLOW_SENDING_CRASH_DUMPS"

echo "Starting server"
(
  log_file="/server-files/RSDragonwilds/Saved/Logs/RSDragonwilds.log"
  until [ -f "$log_file" ]; do sleep 1; done

  code=""
  tail -F -n 0 "$log_file" 2>/dev/null | while read -r line; do
    if [[ "$line" =~ Setting\ \[\"JoinCode\"\]\ written\ with\ key\[xz\]\ value\[([^]]+)\] ]]; then
      code="${BASH_REMATCH[1]}"
    fi

    if [[ -n "$code" && "$line" =~ UPDATE\ SESSION\ -\ complete ]]; then
      sleep 1
      echo "Server ready to join!"
      echo "Join Code: ${code}"
      code=""
    fi

    if [[ "$line" =~ LogNet:\ Join\ succeeded:\ (.+) ]]; then
      player="${BASH_REMATCH[1]}"
      echo "Player joined: ${player}"
    fi

    if [[ "$line" =~ LogDomMatcherSession:\ Player\ REMOVED\ to\ session.*-\[([^]]+)\] ]] || \
       [[ "$line" =~ Close:\ [^,]+,\ Player:\ ([^,]+), ]]; then
      player="${BASH_REMATCH[1]}"
      echo "Player disconnected: ${player}"
    fi
  done
) &

./RSDragonwildsServer.sh > /dev/null 2>&1