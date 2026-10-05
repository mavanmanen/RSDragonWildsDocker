# RuneScape: Dragonwilds Dedicated Server (Docker)

A containerized dedicated server for **RuneScape: Dragonwilds** running on Ubuntu Noble with SteamCMD, automated configuration injection, log monitoring, and persistent data storage.

---

## Features

- **Automated SteamCMD Updates:** Automatically checks and downloads game server updates (App ID: `4019830`) on container startup.
- **Config Management:** Automatically initializes `DedicatedServer.ini` and dynamically updates server settings from environment variables via `initool`.
- **Live Event Monitoring:** Parses the server logs in real-time to output the active **Join Code**, player connections, and player disconnects directly to container stdout.
- **Persistent Data:** Separates game installation, save games, and logs using Docker volumes for seamless updates.
- **Security:** Runs under an unprivileged `steam` user.
- **Automated CI/CD:** Builds and publishes Docker images to the GitHub Container Registry (GHCR) via GitHub Actions.

---

## Ports & Networking

Ensure the following UDP ports are accessible on your host machine and router (if hosting publicly):

| Port | Protocol | Description |
| :--- | :--- | :--- |
| `7777` | UDP | Main Game Server Port |
| `8888` | UDP | Matchmaking / Query Port |

---

## Configuration & Environment Variables

Create a `.env` file from the provided template `example.env` or specify environment variables directly:

```bash
cp example.env .env
```

| Variable | Example / Default | Description |
| :--- | :--- | :--- |
| `OWNER_ID` | `000255c1c0744e09bc7d8db80f0d0a4d` | Unique ID of the server owner / admin |
| `SERVER_NAME` | `"My Server"` | Server name shown in the server browser |
| `WORLD_PASSWORD` | *(empty)* | Optional password required to join |
| `DEFAULT_WORLD_NAME` | `"MyWorld"` | Name of the world / save game |
| `PLATFORM_POLICY` | `CrossPlay` | Platform policy (e.g. `CrossPlay`) |
| `ALLOW_SENDING_CRASH_DUMPS` | `True` / `False` | Whether to send crash telemetry |

---

## Deployment Instructions

### 1. Using Pre-built Image (Docker Compose)

1. Clone this repository:
   ```bash
   git clone https://github.com/mavanmanen/RSDragonWildsDocker.git
   cd RSDragonWildsDocker
   ```

2. Copy the example compose and environment files:
   ```bash
   cp compose.example.yml compose.yml
   cp example.env .env
   ```

3. Edit `.env` to configure your server name, owner ID, and settings.

4. Start the server in the background:
   ```bash
   docker compose up -d
   ```

5. View server logs to track startup progress and retrieve your **Join Code**:
   ```bash
   docker compose logs -f
   ```

6. Stop the server safely:
   ```bash
   docker compose down
   ```

---

## Development & Local Build

### 1. Running in Development Mode with Compose

A development Compose configuration (`compose.dev.yml`) is provided that builds the image from source and loads variables from `dev.env`:

```bash
docker compose -f compose.dev.yml --env-file dev.env up -d --build
```

To follow the logs:
```bash
docker compose -f compose.dev.yml logs -f
```

To stop:
```bash
docker compose -f compose.dev.yml down
```

### 2. Manual Docker CLI Commands

**Build locally:**
```bash
docker build -t rsdragonwilds-server:local .
```

**Run container:**
```bash
docker run -d \
  --name rsdragonwilds-server \
  -p 7777:7777/udp \
  -p 8888:8888/udp \
  --env-file .env \
  -v rsdragonwilds-data:/server-files \
  -v "$(pwd)/logs:/server-files/RSDragonwilds/Saved/Logs" \
  -v "$(pwd)/saves:/server-files/RSDragonwilds/Saved/SaveGames" \
  rsdragonwilds-server:local
```

---

## Repository Structure

```text
├── .github/
│   └── workflows/
│       └── docker-publish.yml   # CI/CD pipeline to build & push image to GHCR
├── compose.example.yml          # Production Docker Compose template (uses GHCR image)
├── compose.dev.yml              # Development Docker Compose (builds from local Dockerfile)
├── example.env                  # Example environment variable template
├── dev.env                      # Development environment variable template
├── Dockerfile                   # Ubuntu Noble + SteamCMD + dependencies
├── start-server.sh              # SteamCMD updater, INI config updater & log watcher
├── logs/                        # Host directory mapped to server logs
├── saves/                       # Host directory mapped to world save files
├── LICENSE                      # License file
└── README.md                    # Project documentation
```

---

## License

This project is licensed under the terms included in the [LICENSE](file:///c:/Users/mavan/Projects/RSDragonWildsDocker/LICENSE) file.