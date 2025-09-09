#!/usr/bin/env python3
"""Interact with the deployed token using the Aptos Python SDK.

Usage:
    python scripts/test.py <profile> <module_address> <recipient_address>

The script expects an Aptos CLI configuration file at ~/.aptos/config.yaml
from which it loads the private key for the given profile.
"""
from __future__ import annotations

import sys
from pathlib import Path

try:
    import yaml
    from aptos_sdk.account import Account
    from aptos_sdk.client import AptosClient
    from aptos_sdk.transactions import EntryFunction, TransactionArgument, TransactionPayload
    from aptos_sdk.account_address import AccountAddress
except Exception as exc:  # pragma: no cover - import side effect
    print(f"Missing dependencies: {exc}", file=sys.stderr)
    sys.exit(1)

TESTNET_NODE = "https://fullnode.testnet.aptoslabs.com/v1"


def load_account(profile: str) -> Account:
    """Load an account from the Aptos CLI config for the given profile."""
    config = Path.home() / ".aptos" / "config.yaml"
    data = yaml.safe_load(config.read_text())
    priv_key = data["profiles"][profile]["private_key"]
    return Account.load_key(priv_key)


def main() -> int:
    if len(sys.argv) < 4:
        print("Usage: test.py <profile> <module_address> <recipient_address>", file=sys.stderr)
        return 1
    profile, module, recipient = sys.argv[1:4]

    client = AptosClient(TESTNET_NODE)
    account = load_account(profile)
    recipient_addr = AccountAddress.from_str(recipient)

    # Register recipient
    payload: TransactionPayload = EntryFunction.natural(
        f"{module}::erc20",
        "register",
        [],
        [TransactionArgument(recipient_addr)]
    )
    tx_hash = client.submit_transaction(account, payload)
    client.wait_for_transaction(tx_hash)

    # Mint 1000 tokens
    payload = EntryFunction.natural(
        f"{module}::erc20",
        "mint",
        [],
        [TransactionArgument(recipient_addr), TransactionArgument(1000)]
    )
    tx_hash = client.submit_transaction(account, payload)
    client.wait_for_transaction(tx_hash)

    # Query balance
    result = client.view(
        f"{module}::erc20::balance",
        [],
        [str(recipient_addr)],
    )
    print(f"Balance: {result[0]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
