#!/bin/sh

set -e

rojo sourcemap default.project.json -o sourcemap.json

darklua process --config publish.darklua.json lib/ dist/lib
rojo build build.project.json -o YetAnotherNet.rbxm