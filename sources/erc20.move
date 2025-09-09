module token::erc20 {
    use aptos_framework::managed_coin;
    use aptos_framework::coin;
    use std::signer;

    struct Erc20Coin has store, drop, copy {}

    /// Initializes the coin type with metadata.
    public entry fun initialize(account: &signer) {
        managed_coin::initialize<Erc20Coin>(
            account,
            b"Example ERC20",
            b"ERC",
            8,
            true
        );
    }

    /// Registers an account so it can hold the token.
    public entry fun register(account: &signer) {
        coin::register<Erc20Coin>(account);
    }

    /// Mints `amount` tokens to `recipient`.
    public entry fun mint(owner: &signer, recipient: address, amount: u64) {
        managed_coin::mint<Erc20Coin>(owner, recipient, amount);
    }

    /// Burns `amount` tokens from the owner's account.
    public entry fun burn(owner: &signer, amount: u64) {
        managed_coin::burn<Erc20Coin>(owner, amount);
    }

    /// Transfers tokens between users.
    public entry fun transfer(sender: &signer, recipient: address, amount: u64) {
        let coin = coin::withdraw<Erc20Coin>(sender, amount);
        coin::deposit(recipient, coin);
    }

    /// View function returning the balance of `addr`.
    public fun balance(addr: address): u64 {
        coin::balance<Erc20Coin>(addr)
    }
}
