# Kamal Desk

The missing web UI for Kamal deployments.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Kamal Desk is a local-first Rails app that wraps the [Kamal CLI](https://kamal-deploy.org/) — similar to [Polaris](https://polaris-deploy.com/), but in your browser. Register Kamal projects, deploy with live output, inspect containers and proxy routes, stream logs, and open a remote Rails console.

**Repository:** https://github.com/BasharLulu/kamal-desk

## Features

- **Multi-project workspace** — manage all your Kamal apps from one UI
- **Auto-discovery** — scans `~/Sites` for folders with `config/deploy.yml`
- **Deploy operations** — deploy, redeploy, setup, rollback with live streamed output
- **Production state** — containers, proxy routes, audit log, server metrics
- **Logs** — `kamal app logs -f` in the browser with pause/resume
- **Remote console** — Rails console via xterm.js + ActionCable
- **Accessories** — boot and view logs for configured accessories
- **Maintenance mode** — toggle maintenance/live via `kamal app`

## Requirements

- Ruby **4.0.5** (see `.ruby-version`)
- Rails 8.1
- [Kamal](https://kamal-deploy.org/) available in registered projects (`bundle exec kamal`)
- Docker and SSH access to your deployment servers
- Kamal projects on disk (typically under `~/Sites`)

## Setup

```bash
git clone https://github.com/BasharLulu/kamal-desk.git ~/Sites/kamal-desk
cd ~/Sites/kamal-desk
bin/setup
```

`bin/setup` installs gems, prepares the database, and loads Solid Queue/Cable schemas.

## Running

Start three processes (recommended — `bin/dev` may fail with asdf/foreman):

```bash
# Terminal 1 — web server
bin/rails server -b 127.0.0.1

# Terminal 2 — background jobs (deploys, logs, console)
bin/jobs

# Terminal 3 — Tailwind CSS (if styles look unstyled)
bin/rails tailwindcss:watch
```

Open **http://127.0.0.1:3000**

## Usage

1. Add projects from the **Discovered in ~/Sites** list or enter a path manually.
2. Open a project → pick a **destination** (staging, production, etc.).
3. Use the nav tabs:
   - **Overview** — config summary, deploy buttons, live output, audit preview
   - **Containers** — running containers, rollback versions
   - **Proxy** — kamal-proxy routes and TLS
   - **Logs** — stream container logs
   - **Console** — remote Rails console
   - **Server load** — docker stats (auto-refreshes every 15s)
   - **Accessories** — boot and logs

Registered project paths must live under `~/Sites` or `~/Developer`.

## Optional authentication

To protect the UI on your local network:

```bash
KAMAL_DESK_PASSWORD=your-secret bin/rails server -b 127.0.0.1
```

Username defaults to `admin` (override with `KAMAL_DESK_USERNAME`).

## Security

- Binds to `127.0.0.1` by default
- Never displays `kamal config` or `.kamal/secrets`
- Audit output is redacted for lines containing password/secret/token/key
- Kamal commands run in isolated subprocesses (`chdir:` per project — not `Dir.chdir`)

## Stack

Rails 8 · Ruby 4.0.5 · SQLite · Hotwire · ActionCable · Solid Queue · Tailwind CSS · xterm.js

## Documentation

See [PLAN.md](PLAN.md) for the full implementation record — architecture, commit history, bug fixes, and deferred work.

## Contributing

Bug reports, feature ideas, and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) — Copyright (c) 2026 Bashar Lulu
