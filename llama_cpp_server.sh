#!/bin/bash
# chcp 65001 > NUL

# スクリプトが配置されているディレクトリを取得
SCRIPT_DIR=$(dirname "$0")

# LlamaCppディレクトリの存在チェック
if [ ! -d "$SCRIPT_DIR/LlamaCpp/LlamaCpp/" ]; then
    echo "call $SCRIPT_DIR/LlamaCpp/llama_cpp_update.sh"
    # LlamaCppのアップデートスクリプトを実行
    "$SCRIPT_DIR/LlamaCpp/llama_cpp_update.sh"
fi

# 再度LlamaCppディレクトリの存在チェック
if [ ! -d "$SCRIPT_DIR/LlamaCpp/LlamaCpp/" ]; then
    echo "$SCRIPT_DIR/LlamaCpp/LlamaCpp/ not found"
    read -p "Press any key to continue..."
    exit 1
fi

# LlamaCppディレクトリに移動
pushd "$SCRIPT_DIR/LlamaCpp/LlamaCpp/" > /dev/null

# llama-serverの実行
echo "./llama-server $*"
./llama-server "$@"
# エラーチェック
if [ $? -ne 0 ]; then
    read -p "Press any key to continue..."
    popd > /dev/null
    exit 1
fi

# 元のディレクトリに戻る
popd > /dev/null