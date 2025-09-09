#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <deployer-address> [profile]" >&2
  exit 1
fi

ADDR=$1
PROFILE=${2:-default}

aptos move publish \
  --package-dir "$(dirname "$0")/.." \
  --named-addresses token=$ADDR \
  --profile $PROFILE \
  --network testnet
