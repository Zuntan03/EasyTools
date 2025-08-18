#!/bin/bash
set -e
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
touch "$SCRIPT_DIR/ARIA_USE_CURL"
echo "[INFO] ARIA_USE_CURL フラグを有効化しました。"

