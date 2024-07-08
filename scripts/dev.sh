#!/bin/sh

set -e

if [ ! -d "DevPackages" ]; then
    sh scripts/install-dependencies.sh
fi

rojo serve dev.project.json \
    & rojo sourcemap default.project.json -o sourcemap.json --watch \
    & darklua process --config .darklua.json --watch lib/ dist/lib \
    & darklua process --config .darklua.json --watch tests/ dist/tests