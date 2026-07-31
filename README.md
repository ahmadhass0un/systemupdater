# systemupdater

A simple Debian/Ubuntu maintenance script that updates the package list, upgrades
installed packages, and cleans up unused packages and cache files.

## What it does

1. `apt update` — refresh the package index
2. `apt upgrade` — upgrade installed packages
3. `apt autoclean` — remove obsolete .deb cache files
4. `apt autoremove` — remove unused dependencies

## Requirements

- Debian, Ubuntu, or a derivative using `apt`
- `sudo` access

## Usage

Run it from a terminal:

```bash
./systemupdater.sh
```

You'll be asked for your password once at the start; subsequent `sudo` calls reuse
the cached credential.

## Exit behavior

Each step aborts the script with a non-zero exit code if it fails, so the script is
safe to call from cron or CI.

## Install (optional)

```bash
sudo install -m 0755 systemupdater.sh /usr/local/bin/systemupdater
```
