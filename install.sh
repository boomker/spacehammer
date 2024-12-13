#!/bin/bash

# Hammerspoon 工作目录
WORKING_DIR="${HOME}/.hammerspoon"

# 工作目录不存在
if [[ ! -d "$WORKING_DIR" ]]; then
	mkdir "$WORKING_DIR"
else
	mv "${WORKING_DIR}" "${WORKING_DIR}.bak"
fi

# 拉取工程（为加快拉取速度，不拉取历史记录）
[[ -z $(command -v git) ]] && echo 'Git must be installed first!' && exit
git -C "${WORKING_DIR}" init
git -C "${WORKING_DIR}" remote add origin git@github.com:boomker/spacehammer.git
git -C "${WORKING_DIR}" pull origin main --depth=1

# copy blueutil to bin directory
# cp -ar "${WORKING_DIR}/bin/blueutil" /usr/local/bin/ && chmod +x /usr/local/bin/blueutil
