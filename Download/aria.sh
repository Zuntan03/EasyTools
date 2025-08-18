#!/bin/bash
set -e

# Aria.bat 互換のダウンロードスクリプト
# 使い方: bash aria.sh <DOWNLOAD_DIR> <DOWNLOAD_FILE> <DOWNLOAD_URL>

DOWNLOAD_DIR="$1"
DOWNLOAD_FILE="$2"
DOWNLOAD_URL="$3"

if [ -z "$DOWNLOAD_DIR" ] || [ -z "$DOWNLOAD_FILE" ] || [ -z "$DOWNLOAD_URL" ]; then
  echo "[ERROR] 使用法: $0 <DOWNLOAD_DIR> <DOWNLOAD_FILE> <DOWNLOAD_URL>"
  exit 1
fi

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
USE_CURL_FLAG="${SCRIPT_DIR}/ARIA_USE_CURL"

# 既存ファイルのチェック（.aria2 がなければスキップ）
if [ -f "${DOWNLOAD_DIR%/}/${DOWNLOAD_FILE}" ]; then
  if [ -f "$USE_CURL_FLAG" ] || [ ! -f "${DOWNLOAD_DIR%/}/${DOWNLOAD_FILE}.aria2" ]; then
    exit 0
  fi
fi

mkdir -p "$DOWNLOAD_DIR"

if [ -f "$USE_CURL_FLAG" ]; then
  echo "[INFO] curl でダウンロードします: $DOWNLOAD_URL -> ${DOWNLOAD_DIR%/}/${DOWNLOAD_FILE}"
  curl -L -C - -o "${DOWNLOAD_DIR%/}/${DOWNLOAD_FILE}" "$DOWNLOAD_URL"
else
  if command -v aria2c >/dev/null 2>&1; then
    # 最大接続数の設定（既定値: 4）
    ARIA_MAX_CONNECTION_FILE="${SCRIPT_DIR}/Aria_MaxConnection.txt"
    if [ ! -f "$ARIA_MAX_CONNECTION_FILE" ]; then
      echo 4 > "$ARIA_MAX_CONNECTION_FILE"
    fi
    ARIA_MAX_CONNECTION=$(cat "$ARIA_MAX_CONNECTION_FILE" 2>/dev/null || echo 4)
    echo "[INFO] aria2c でダウンロードします (-x${ARIA_MAX_CONNECTION}): $DOWNLOAD_URL -> ${DOWNLOAD_DIR%/}/${DOWNLOAD_FILE}"
    aria2c --console-log-level=warn --file-allocation=none --check-certificate=false --disable-ipv6 \
      -x"$ARIA_MAX_CONNECTION" -c -d "${DOWNLOAD_DIR%/}" -o "$DOWNLOAD_FILE" "$DOWNLOAD_URL"
  else
    echo "[WARN] aria2c が見つからないため curl にフォールバックします。"
    curl -L -C - -o "${DOWNLOAD_DIR%/}/${DOWNLOAD_FILE}" "$DOWNLOAD_URL"
  fi
fi

sleep 1

