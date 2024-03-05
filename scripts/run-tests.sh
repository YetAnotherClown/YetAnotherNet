#!/bin/bash

set -e

OUTPUT=yan-test-place.rbxl
PORT=27182

if [ ! -d ./DevPackages ]; then
    ./scripts/install-wally.sh
fi

rojo build test.project.json --output $OUTPUT
run-in-roblox --place $OUTPUT --script ./tests/startJest.server.luau --port $PORT