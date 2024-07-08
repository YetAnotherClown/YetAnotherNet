#!/bin/sh

set -e

rojo sourcemap default.project.json -o sourcemap.json
curl -O https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.lua

luau-lsp analyze --definitions=globalTypes.d.lua --base-luaurc=.luaurc \
    --sourcemap=sourcemap.json --settings=.vscode/settings.json \
    --no-strict-dm-types --ignore="DevPackages/**" --ignore="lib/__*__/**" \
    lib/