#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 3 ]; then
  echo "Usage: $0 <profile> <module-address> <recipient-address>" >&2
  exit 1
fi

PROFILE=$1
MODULE=$2
RECIPIENT=$3

# Register recipient to hold the token
aptos move run \
  --function-id ${MODULE}::erc20::register \
  --profile $PROFILE \
  --network testnet \
  --args address:$RECIPIENT

# Mint 1000 tokens to recipient
aptos move run \
  --function-id ${MODULE}::erc20::mint \
  --profile $PROFILE \
  --network testnet \
  --args address:$RECIPIENT u64:1000

# View recipient balance
aptos move view \
  --function-id ${MODULE}::erc20::balance \
  --network testnet \
  --args address:$RECIPIENT
