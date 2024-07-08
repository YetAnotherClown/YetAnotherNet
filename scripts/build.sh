#!/bin/sh

set -e

if [ ! -d "DevPackages" ]; then
    sh scripts/install-dependencies.sh
fi

rojo sourcemap default.project.json -o sourcemap.json

darklua process --config .darklua.json lib/ dist/
rojo build build.project.json -o YetAnotherNet.rbxm