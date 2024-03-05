#!/bin/bash

set -e

wally install
rojo sourcemap test.project.json --output sourcemap.json
wally-package-types --sourcemap sourcemap.json DevPackages/