#!/bin/bash

# Hammerspoon 工作目录
WORKING_DIR="${HOME}/.hammerspoon"

# 工作目录不存在
if [ ! -d "$WORKING_DIR" ]; then
	mkdir "$WORKING_DIR"
else
	mv "${WORKING_DIR}" "${WORKING_DIR}.bak"
fi

cd "$WORKING_DIR" || exit
echo "工作目录：$WORKING_DIR"

# 拉取工程（为加快拉取速度，不拉取历史记录）
git init
git remote add origin git@github.com:boomker/spacehammer.git
git pull origin main --depth=1

# copy blueutil to bin directory
cp ./bin/blueutil /usr/local/bin/ && chmod +x /usr/local/bin/blueutil
