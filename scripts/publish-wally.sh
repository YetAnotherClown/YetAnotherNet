#!/bin/sh

set -e

rojo sourcemap default.project.json -o sourcemap.json
darklua process --config publish.darklua.json lib/ dist/lib

cp README.md dist/README.md
cp LICENSE dist/LICENSE
cp wally.toml dist/wally.toml
cp wally.lock dist/wally.lock

cp build.project.json dist/default.project.json
sed -i 's/dist\/lib/lib/' dist/default.project.json

cd ./dist

if [ "$1" = "--publish" ]; then
    wally publish
else
    wally package --output release.zip
fi