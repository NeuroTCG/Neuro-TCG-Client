#!/usr/bin/env bash

ORIGINAL_WASM_NAME=index.wasm
ORIGINAL_PACK_NAME=index.pck

WASM_HASH=$(sha256sum ${ORIGINAL_WASM_NAME} | cut -f1 -d' ')
PACK_HASH=$(sha256sum ${ORIGINAL_PACK_NAME} | cut -f1 -d' ')

NEW_WASM_NAME=${WASM_HASH}-${ORIGINAL_WASM_NAME}
NEW_PACK_NAME=${PACK_HASH}-${ORIGINAL_PACK_NAME}

sed "s|engine\.startGame({|engine.startGame({'executable': \"${NEW_WASM_NAME%.*}\", 'mainPack': \"${NEW_PACK_NAME}\",|" -i index.html

mv ${ORIGINAL_WASM_NAME} ${NEW_WASM_NAME}
mv ${ORIGINAL_PACK_NAME} ${NEW_PACK_NAME}
