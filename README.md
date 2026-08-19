# systemupdater

A single-command maintenance script for Debian/Ubuntu systems. It refreshes the
package list, upgrades installed packages, and cleans up unused packages and
cache files — with clear, colored feedback for every step.

## Requirements

- Debian, Ubuntu, or a derivative using `apt`
- `sudo` access

## Usage

```bash
./systemupdater.sh
```

You'll be asked for your password once at the start; subsequent `sudo` calls
reuse the cached credential.

### Install (optional)

```bash
sudo install -m 0755 systemupdater.sh /usr/local/bin/systemupdater
systemupdater
```

## License

Free to use and modify.