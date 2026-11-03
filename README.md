https://roadmap.sh/projects/log-archive-tool

# Log Archive Tool

A lightweight Bash command-line utility for archiving log directories into timestamped `.tar.gz` files and recording each successful archive operation. Built as a beginner-friendly Linux and shell scripting project inspired by the [roadmap.sh Log Archive Tool project](https://roadmap.sh/projects/log-archive-tool).

## Features

- Accepts a log directory as a command-line argument.
- Validates the input directory before archiving.
- Compresses the directory into a `.tar.gz` archive.
- Names archives using the current date and time (`YYYYMMDD_HHMMSS`).
- Saves archives in `~/log-archives` by default.
- Appends a timestamped entry to `archive.log` after a successful archive.
- Exits with a nonzero status if validation or archiving fails.

## Requirements

- Bash
- `tar` with gzip support
- Standard Unix utilities: `date`, `mkdir`, `dirname`, and `basename`
- Read access to the source directory and write access to the archive destination

The script works on typical Linux distributions and can also be tested on macOS.

## Project Structure

```text
log-archive-tool/
├── log-archive.sh
└── README.md
```

## Installation

1. Create a project directory and script file:

   ```bash
   mkdir -p log-archive-tool
   cd log-archive-tool
   touch log-archive.sh
   ```

2. Copy the script below into `log-archive.sh`.
3. Make it executable:

   ```bash
   chmod +x log-archive.sh
   ```

### Bash Script

```bash
#!/usr/bin/env bash

set -euo pipefail

# Require exactly one argument.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <log-directory>" >&2
    exit 1
fi

LOG_DIR="$1"

# Verify that the log directory exists.
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory not found: $LOG_DIR" >&2
    exit 1
fi

# Create the output directory.
ARCHIVE_DIR="$HOME/log-archives"
mkdir -p "$ARCHIVE_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_NAME"
ACTIVITY_LOG="$ARCHIVE_DIR/archive.log"

echo "Starting log archiving..."
echo "Source: $LOG_DIR"

# Archive the directory, keeping its directory name in the archive.
tar -czf "$ARCHIVE_PATH" \
    -C "$(dirname "$LOG_DIR")" \
    "$(basename "$LOG_DIR")"

# Record successful operations.
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Archived $LOG_DIR -> $ARCHIVE_PATH" \
    >> "$ACTIVITY_LOG"

echo "Archive completed successfully!"
echo "Saved to: $ARCHIVE_PATH"
```

## Usage

Run the script with a directory containing logs:

```bash
./log-archive.sh /path/to/log-directory
```

Example:

```bash
./log-archive.sh ~/test-logs
```

Example output (paths and timestamps will vary):

```text
Starting log archiving...
Source: /home/ubuntu/test-logs
Archive completed successfully!
Saved to: /home/ubuntu/log-archives/logs_archive_20261103_200400.tar.gz
```

### Optional: Install as a Global CLI Command

```bash
sudo install -m 755 log-archive.sh /usr/local/bin/log-archive
```

Then run:

```bash
log-archive ~/test-logs
```

> **Note:** Running with `sudo`, such as `sudo log-archive /var/log`, may cause `$HOME` to resolve to `/root` and archives to be saved under `/root/log-archives`. System logs can contain sensitive information; use appropriate permissions and do not publish raw archives.

## Testing

Create safe sample log files:

```bash
mkdir -p ~/test-logs
printf 'INFO: Application started\n' > ~/test-logs/app.log
printf 'ERROR: Database timeout\n' > ~/test-logs/error.log
printf 'WARN: Memory usage high\n' > ~/test-logs/system.log
```

Run the archiver:

```bash
./log-archive.sh ~/test-logs
```

Inspect generated files:

```bash
ls -lh ~/log-archives
```

Inspect the contents of a generated archive (replace the filename with the actual one):

```bash
tar -tzf ~/log-archives/logs_archive_YYYYMMDD_HHMMSS.tar.gz
```

Check the archive activity log:

```bash
cat ~/log-archives/archive.log
```

Expected output directory:

```text
~/log-archives/
├── logs_archive_20261103_200400.tar.gz
└── archive.log
```

### Negative Test

A nonexistent source directory should return an error:

```bash
./log-archive.sh /path/that/does/not/exist
```

## How It Works

| Command / Concept   | Purpose                                                         |
| ------------------- | --------------------------------------------------------------- |
| `set -euo pipefail` | Enables stricter shell error handling.                          |
| `$1`                | Reads the first command-line argument.                          |
| `-d`                | Checks whether a directory exists.                              |
| `mkdir -p`          | Creates the archive directory if needed.                        |
| `date`              | Generates timestamps for filenames and log entries.             |
| `tar -czf`          | Creates a gzip-compressed tar archive.                          |
| `-C`                | Changes to the source's parent directory while archiving.       |
| `>>`                | Appends an activity record without overwriting earlier entries. |

## Roadmap.sh Requirements Checklist

- [x] Accept a log directory as a CLI argument.
- [x] Compress logs into a `.tar.gz` file.
- [x] Store the archive in a dedicated directory.
- [x] Include the date and time in the archive filename.
- [x] Record the archive timestamp in a log file.

## Limitations and Safety Notes

- **No automatic scheduling:** Run the tool manually or configure a scheduler separately.
- **No retention policy:** Old archives are not removed automatically.
- **Timestamp resolution:** Two runs within the same second can produce the same filename and overwrite an earlier archive.
- **Active log files:** Files being written while `tar` runs may produce warnings or inconsistent snapshots.
- **Disk usage:** Archives consume additional disk space; check free space before backing up large directories.
- **Permissions and privacy:** Only archive directories you are authorized to read. Protect files containing application secrets or personal information.
- **Source files remain untouched:** This tool creates backups; it does not rotate, truncate, or delete source logs.

## Future Improvements

- Schedule daily or weekly archives using cron or a systemd timer.
- Add a configurable retention period (for example, delete archives older than 30 days).
- Support a configurable output directory and custom archive names.
- Add explicit collision prevention, disk-space checks, and better error logs.
- Upload completed archives to remote storage such as an S3-compatible service (MinIO or RustFS).
- Send success or failure notifications to Telegram or Discord.
- Add automated tests using ShellCheck and a Bash testing framework.

## License

No license has been specified yet. Add a `LICENSE` file before distributing the project under an open-source license.
