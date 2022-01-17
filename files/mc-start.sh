#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."

./bin/hz-mc start "$@"
