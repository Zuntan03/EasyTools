#!/bin/bash

# このスクリプトは、Pythonの仮想環境（venv）を準備し、tkinterを有効化します。
# 呼び出し元のシェルで環境を有効にするには、`source ./python_activate_tkinter.sh`のように実行する必要があります。

SCRIPT_DIR=$(dirname "$0")

# python_activate.sh を source で実行
# shellcheck disable=SC1090
source "$SCRIPT_DIR/python_activate.sh" "$@"
if [ $? -ne 0 ]; then
    return 1
fi

# tkinterがインストール済みか確認
python3 -c "import tkinter; root = tkinter.Tk()" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    # 既にインストール済み
    return 0
fi

# Pythonのバージョンを取得 (例: 3.10)
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d. -f1,2)
TKINTER_ZIP="$SCRIPT_DIR/python_tkinter-$PYTHON_VERSION.zip"

# zipファイルの存在確認
if [ ! -f "$TKINTER_ZIP" ]; then
    echo "[ERROR] 対応するtkinterのzipファイルが見つかりません: $TKINTER_ZIP"
    # apt-getでのインストールを促す
    echo "[INFO] \`sudo apt update && sudo apt install python3-tk\` を試してください。"
    return 1
fi

# zipファイルを仮想環境に展開
# VIRTUAL_ENV_DIRはpython_activate.shで設定される
echo "unzip -o \"$TKINTER_ZIP\" -d \"$VIRTUAL_ENV_DIR\""
unzip -o "$TKINTER_ZIP" -d "$VIRTUAL_ENV_DIR"
if [ $? -ne 0 ]; then
    echo "[ERROR] tkinterの展開に失敗しました。"
    return 1
fi

# 再度tkinterがインストール済みか確認
python3 -c "import tkinter; root = tkinter.Tk()" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "[ERROR] Python に tkinter がインストールされていません。"
    echo "[ERROR] Python does not have tkinter installed."
    return 1
fi

return 0
