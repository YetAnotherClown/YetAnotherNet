#!/bin/sh

set -e

stylua lib/ tests/ --verify --config-path stylua.toml