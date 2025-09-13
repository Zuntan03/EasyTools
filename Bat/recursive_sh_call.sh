#!/bin/bash
# chcp 65001 > NUL

# 第一引数がディレクトリでない場合はエラー
if [ ! -d "$1" ]; then
    echo "Error: The first argument must be a directory."
    exit 1
fi

# findで見つけたファイルリストを配列に格納
mapfile -t scripts < <(find "$1" -type f -name "*.sh")

# スクリプトを順番に実行
for script in "${scripts[@]}"; do
    bash "$script"
    if [ $? -ne 0 ]; then
        echo "Error executing script: $script"
        exit 1
    fi
done
