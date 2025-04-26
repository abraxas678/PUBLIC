#!/bin/bash
DATA_FOLDER=/home/abrax/Resilio\ Sync
WEBUI_PORT=8888

mkdir -p $DATA_FOLDER

docker run -d --name sync -p 127.0.0.1:$WEBUI_PORT:8888 -p 55555 -v "$DATA_FOLDER:/mnt/sync" --restart on-failure resilio/sync

