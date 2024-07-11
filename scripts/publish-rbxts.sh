#!/bin/sh

set -e

rojo sourcemap default.project.json -o sourcemap.json
darklua process --config publish.darklua.json lib/ dist/lib

cd ./dist

cp ../package.json package.json
cp ../README.md README.md
cp ../LICENSE LICENSE
cp ../lib/index.d.ts ./lib/index.d.ts

if [ "$1" = "--publish" ]; then
    npm publish
else
    npm pack
fi