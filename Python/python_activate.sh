#!/bin/bash

# このスクリプトは、Pythonの仮想環境（venv）を準備します。
# 呼び出し元のシェルで環境を有効にするには、`source ./python_activate.sh`のように実行する必要があります。

# --- 設定 ---
# デフォルトの仮想環境ディレクトリ名
VIRTUAL_ENV_DIR=${1:-venv}

# --- チェック ---
# python3コマンドの存在確認
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] python3が見つかりません。`sudo apt update && sudo apt install python3`でインストールしてください。"
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then return 1; else exit 1; fi
fi

# python3-venvパッケージの存在確認 (Debian/Ubuntu系)
if ! dpkg -s python3-venv &> /dev/null; then
    echo "[ERROR] python3-venvパッケージが見つかりません。`sudo apt install python3-venv`でインストールしてください。"
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then return 1; else exit 1; fi
fi

# --- 仮想環境の構築 ---
if [ ! -d "$VIRTUAL_ENV_DIR" ]; then
    echo "仮想環境を '$VIRTUAL_ENV_DIR' に作成します..."
    python3 -m venv "$VIRTUAL_ENV_DIR"
    if [ $? -ne 0 ]; then
        echo "[ERROR] 仮想環境の作成に失敗しました。"
        if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then return 1; else exit 1; fi
    fi
else
    echo "仮想環境 '$VIRTUAL_ENV_DIR' は既に存在します。"
fi

# --- 有効化 --- 
# このスクリプトを source で実行した場合、以下のコマンドが呼び出し元のシェルで実行される
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo "仮想環境を有効化します..."
    # shellcheck disable=SC1091
    source "$VIRTUAL_ENV_DIR/bin/activate"
else
    echo "仮想環境の準備ができました。"
    echo "次のコマンドで有効化してください: source $VIRTUAL_ENV_DIR/bin/activate"
fi
