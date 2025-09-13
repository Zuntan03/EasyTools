#!/bin/bash
# chcp 65001 > NUL

SCRIPT_DIR=$(dirname "$0")

# SdImageDietのvenvディレクトリの存在チェック
if [ ! -d "$SCRIPT_DIR/SdImageDiet/SdImageDiet/venv/" ]; then
    echo "call $SCRIPT_DIR/SdImageDiet/SdImageDiet_Update.sh"
    "$SCRIPT_DIR/SdImageDiet/SdImageDiet_Update.sh"
fi

# 再度SdImageDietのvenvディレクトリの存在チェック
if [ ! -d "$SCRIPT_DIR/SdImageDiet/SdImageDiet/venv/" ]; then
    echo "$SCRIPT_DIR/SdImageDiet/SdImageDiet/venv/ not found"
    read -p "Press any key to continue..."
    exit 1
fi

# SdImageDietディレクトリに移動
pushd "$SCRIPT_DIR/SdImageDiet/SdImageDiet" > /dev/null

# Python仮想環境の有効化
# shellcheck disable=SC1090
source "$SCRIPT_DIR/Python/python_activate.sh"
if [ $? -ne 0 ]; then
    popd > /dev/null
    exit 1
fi

# アプリケーションの実行
echo "python SdImageDietGUI.py $* &"
python SdImageDietGUI.py "$@" &

# popd
popd > /dev/null
