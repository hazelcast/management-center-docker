#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")" && cd ..

./bin/hz-mc start "$@"
