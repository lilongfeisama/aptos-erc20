# Aptos ERC20 Example

This project demonstrates an ERC20-like fungible token implemented in Move for the Aptos testnet. It includes the Move module and helper scripts for deployment and basic interaction.

## Layout
- `Move.toml` and `sources/` contain the Move package defining the token.
- `scripts/deploy.sh` publishes the package to the testnet.
- `scripts/test.sh` registers an account, mints tokens, and prints the balance.
- `scripts/test.py` does the same using the Aptos Python SDK.

## Deployment
1. Install the [Aptos CLI](https://aptos.dev/cli-tools/aptos-cli-tool/install-aptos-cli/).
2. Create or configure an Aptos profile that points to testnet and holds the deployer's keys.
3. Publish the module, replacing `<deployer-address>` with your account address:

```bash
./scripts/deploy.sh <deployer-address> [profile]
```

## Testing
After deployment, interact with the token using:

```bash
./scripts/test.sh <profile> <module-address> <recipient-address>
```

The script registers the recipient to hold the token, mints 1000 tokens, and queries the resulting balance.

### Python

Alternatively, run the Python version (requires the [`aptos-sdk`](https://pypi.org/project/aptos-sdk/) and `PyYAML` packages and a configured Aptos profile):

```bash
python scripts/test.py <profile> <module-address> <recipient-address>
```
