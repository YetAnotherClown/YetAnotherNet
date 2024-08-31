#!/bin/bash

set -e

OUTPUT=yetanothernet-development.rbxl
PORT=27182

if [ ! -d ./DevPackages ]; then
    ./scripts/install-wally.sh
fi

darklua process --config dev.darklua.json lib/ dist/lib \
    && darklua process --config dev.darklua.json tests/ dist/tests \
    && rojo build dev.project.json --output $OUTPUT \
    && run-in-roblox --place $OUTPUT --script ./dist/tests/startJest.server.luau --port $PORT