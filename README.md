# systemupdater

A single-command maintenance script for Debian/Ubuntu systems. It refreshes the
package list, upgrades installed packages, and cleans up unused packages and
cache files — with clear, colored feedback for every step.

## Features

- **Full update in one command** — `update`, `upgrade`, `autoclean`, and `autoremove` in a single run
- **Step-by-step reporting** — each step prints `OK`/`FAIL` with colored separators
- **Fail-fast behavior** — exits with a non-zero code the moment any step fails, so it's safe for cron or CI
- **Error detection** — watches for `E:`, `Err:`, and `Failed to fetch` in the apt output instead of trusting the exit code alone
- **Single password prompt** — validates `sudo` once at the start; later steps reuse the cached credential

## What it does

| Step | Command | Purpose |
|------|---------|---------|
| 1 | `apt update` | Refresh the package index |
| 2 | `apt upgrade -y` | Upgrade all installed packages |
| 3 | `apt autoclean` | Remove obsolete `.deb` cache files |
| 4 | `apt autoremove -y` | Remove packages that are no longer required |

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

## Example output

```
OK:   Package list updated
----- The package list has been updated. -----
...
OK:   System upgraded
----- The system has been updated. -----
OK:   System cleaned
----- The system has been cleaned. -----
OK:   Unnecessary packages removed
----- The unnecessary packages have been removed. -----
```

## License

Free to use and modify.