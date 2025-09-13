#!/bin/bash
# chcp 65001 > NUL

SCRIPT_DIR=$(dirname "$0")
MOSAIC="mosaic_20240601"

# Mosaicのvenvディレクトリの存在チェック
if [ ! -d "$SCRIPT_DIR/Mosaic/$MOSAIC/venv/" ]; then
    echo "call $SCRIPT_DIR/Mosaic/Mosaic_Update.sh"
    "$SCRIPT_DIR/Mosaic/Mosaic_Update.sh"
fi

# 再度Mosaicのvenvディレクトリの存在チェック
if [ ! -d "$SCRIPT_DIR/Mosaic/$MOSAIC/venv/" ]; then
    echo "$SCRIPT_DIR/Mosaic/$MOSAIC/venv/ not found"
    read -p "Press any key to continue..."
    exit 1
fi

# Mosaicディレクトリに移動
pushd "$SCRIPT_DIR/Mosaic/$MOSAIC/" > /dev/null

# Python仮想環境(Tkinter付き)の有効化
# shellcheck disable=SC1090
source "$SCRIPT_DIR/../Python/python_activate_tkinter.sh"
if [ $? -ne 0 ]; then
    popd > /dev/null
    exit 1
fi

# アプリケーションの実行
echo "python mosaic.py $*"
python mosaic.py "$@"

# popd
popd > /dev/null
