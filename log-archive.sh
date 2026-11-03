
#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <log-directory>"
    exit 1
fi

LOG_DIR="$1"

if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory not found: $LOG_DIR"
    exit 1
fi

ARCHIVE_DIR="$HOME/log-archives"
mkdir -p "$ARCHIVE_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_NAME"

ACTIVITY_LOG="$ARCHIVE_DIR/archive.log"

echo "Starting log archiving..."
echo "Source: $LOG_DIR"

tar -czf "$ARCHIVE_PATH" \
    -C "$(dirname "$LOG_DIR")" \
    "$(basename "$LOG_DIR")"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Archived $LOG_DIR -> $ARCHIVE_PATH" \
    >> "$ACTIVITY_LOG"

echo "Archive completed successfully!"
echo "Saved to: $ARCHIVE_PATH"
