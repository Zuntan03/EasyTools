#!/bin/bash
# chcp 65001 > NUL

# スクリプトが配置されているディレクトリを取得
EASY_TOOLS=$(dirname "$0")
SD_CFG="$EASY_TOOLS/../stable-diffusion-webui-reForge/config.json"

# InfiniteImageBrowsingのvenvディレクトリの存在チェック
if [ ! -d "$EASY_TOOLS/InfiniteImageBrowsing/sd-webui-infinite-image-browsing/venv/" ]; then
    echo "call $EASY_TOOLS/InfiniteImageBrowsing/InfiniteImageBrowsing_Update.sh"
    # InfiniteImageBrowsingのアップデートスクリプトを実行
    "$EASY_TOOLS/InfiniteImageBrowsing/InfiniteImageBrowsing_Update.sh"
fi

# 再度InfiniteImageBrowsingのvenvディレクトリの存在チェック
if [ ! -d "$EASY_TOOLS/InfiniteImageBrowsing/sd-webui-infinite-image-browsing/venv/" ]; then
    echo "$EASY_TOOLS/InfiniteImageBrowsing/sd-webui-infinite-image-browsing/venv/ not found"
    read -p "Press any key to continue..."
    exit 1
fi

# InfiniteImageBrowsingディレクトリに移動
pushd "$EASY_TOOLS/InfiniteImageBrowsing/sd-webui-infinite-image-browsing" > /dev/null

# Python仮想環境の有効化
source "$EASY_TOOLS/Python/python_activate.sh"
if [ $? -ne 0 ]; then
    popd > /dev/null
    exit 1
fi

# ブラウザで開く (CUI環境では不要な場合があるためコメントアウト)
# xdg-open http://localhost:7850

# アプリケーションの実行
echo "python app.py --sd_webui_config=\"$SD_CFG\" --sd_webui_path_relative_to_config --host=localhost --port=7850 $*")"
python app.py --sd_webui_config="$SD_CFG" --sd_webui_path_relative_to_config --host=localhost --port=7850 "$@"
if [ $? -ne 0 ]; then
    read -p "Press any key to continue..."
    popd > /dev/null
    exit 1
fi

# 元のディレクトリに戻る
popd > /dev/null