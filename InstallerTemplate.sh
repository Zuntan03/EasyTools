#!/bin/bash
set -e

# EasyTools Installer Template (Linux)
# 目的: プロジェクトおよび EasyTools の初期化、セットアップ、必要に応じたモデル等のダウンロードを行う
# 使い方: bash InstallerTemplate.sh （引数なし: Windows版と同等のインタフェース）

# --- 既定値（Windows版の変数名に合わせる） ---
PROJECT_NAME=${PROJECT_NAME:-Project}
PROJECT_URL=${PROJECT_URL:-"https://github.com/Zuntan03/${PROJECT_NAME}"}
PROJECT_BRANCH=${PROJECT_BRANCH:-main}

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
EASY_TOOLS_DIR="${SCRIPT_DIR}/EasyTools"
EASY_GIT_DIR="${EASY_TOOLS_DIR}/Git"

PROJECT_DIR="${SCRIPT_DIR}/."
PROJECT_SETUP_SH="${SCRIPT_DIR}/${PROJECT_NAME}/Setup.sh"
PROJECT_MODEL_DOWNLOAD_SH="${SCRIPT_DIR}/Download/minimum.sh"

# --- 依存チェック ---
need_cmd() { command -v "$1" >/dev/null 2>&1; }

if ! need_cmd git; then
  echo "[ERROR] git が見つかりません。'sudo apt install -y git' でインストールしてください。"
  exit 1
fi

if ! need_cmd curl; then
  echo "[WARN] curl が見つかりません。'sudo apt install -y curl' を推奨します。"
fi

# --- 汎用: 初期化/フェッチ/ブランチ切替 ---
init_repo() {
  local repo_dir=$1 repo_url=$2 branch=$3
  mkdir -p "$repo_dir"
  (
    cd "$repo_dir"
    if [ ! -d .git ]; then
      git init -q
      git remote add origin "$repo_url" 2>/dev/null || true
    fi
    git fetch --all --tags
    git switch "$branch" 2>/dev/null || git checkout -b "$branch"
  )
}

echo "[INFO] EasyTools を初期化: ${EASY_TOOLS_DIR}"
init_repo "$EASY_TOOLS_DIR" "https://github.com/Zuntan03/EasyTools" main

echo "[INFO] プロジェクトを初期化: ${PROJECT_DIR} <- ${PROJECT_URL} (${PROJECT_BRANCH})"
init_repo "$PROJECT_DIR" "$PROJECT_URL" "$PROJECT_BRANCH"

# --- セットアップ実行（存在する場合） ---
if [ -f "$PROJECT_SETUP_SH" ]; then
  echo "[INFO] プロジェクトセットアップを実行: $PROJECT_SETUP_SH"
  bash "$PROJECT_SETUP_SH"
else
  echo "[INFO] Setup.sh は見つかりませんでした。スキップします。"
fi

# --- モデル等のダウンロード確認 ---
read -r -p "動作に必要なモデルなどをダウンロードしますか？ [y/N]: " yn
case "$yn" in
  [yY]*)
    if [ -f "$PROJECT_MODEL_DOWNLOAD_SH" ]; then
      echo "[INFO] ダウンロードスクリプトを実行: $PROJECT_MODEL_DOWNLOAD_SH"
      bash "$PROJECT_MODEL_DOWNLOAD_SH" || true
    else
      echo "[INFO] ダウンロードスクリプトが見つかりません: $PROJECT_MODEL_DOWNLOAD_SH"
    fi
    ;;
  *)
    echo "[INFO] ダウンロードはスキップしました。"
    ;;
esac

echo "[INFO] 完了しました。"
