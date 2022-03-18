#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."

exec ./bin/hz-mc start "$@"
