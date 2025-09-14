#[test_only]
module token::erc20_test {
    use aptos_framework::account;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;
    use std::signer;
    use addr::erc20;

    fun setup_test() {
        // Initialize aptos coin for testing environment
        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(&account::create_signer_for_test(@aptos_framework));
        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }

    #[test(aptos_framework = @aptos_framework, owner = @token, user1 = @0x123, user2 = @0x456)]
    public fun test_initialize_and_mint(aptos_framework: &signer, owner: &signer, user1: &signer, user2: &signer) {
        setup_test();
        
        // Create accounts
        account::create_account_for_test(signer::address_of(owner));
        account::create_account_for_test(signer::address_of(user1));
        account::create_account_for_test(signer::address_of(user2));

        // Initialize the coin
        erc20::initialize(owner);

        // Register users to receive coins
        erc20::register(user1);
        erc20::register(user2);

        // Mint some coins to user1
        let mint_amount = 1000;
        erc20::mint(owner, signer::address_of(user1), mint_amount);

        // Check balance
        let balance = erc20::balance(signer::address_of(user1));
        assert!(balance == mint_amount, 1);

        // Check user2 has zero balance
        let balance2 = erc20::balance(signer::address_of(user2));
        assert!(balance2 == 0, 2);
    }

    #[test(aptos_framework = @aptos_framework, owner = @token, user1 = @0x123, user2 = @0x456)]
    public fun test_transfer(aptos_framework: &signer, owner: &signer, user1: &signer, user2: &signer) {
        setup_test();
        
        // Setup
        account::create_account_for_test(signer::address_of(owner));
        account::create_account_for_test(signer::address_of(user1));
        account::create_account_for_test(signer::address_of(user2));

        erc20::initialize(owner);
        erc20::register(user1);
        erc20::register(user2);

        // Mint coins to user1
        let initial_amount = 1000;
        erc20::mint(owner, signer::address_of(user1), initial_amount);

        // Transfer from user1 to user2
        let transfer_amount = 300;
        erc20::transfer(user1, signer::address_of(user2), transfer_amount);

        // Check balances
        let balance1 = erc20::balance(signer::address_of(user1));
        let balance2 = erc20::balance(signer::address_of(user2));

        assert!(balance1 == initial_amount - transfer_amount, 3);
        assert!(balance2 == transfer_amount, 4);
    }

    #[test(aptos_framework = @aptos_framework, owner = @token, user1 = @0x123)]
    public fun test_burn(aptos_framework: &signer, owner: &signer, user1: &signer) {
        setup_test();
        
        // Setup
        account::create_account_for_test(signer::address_of(owner));
        account::create_account_for_test(signer::address_of(user1));

        erc20::initialize(owner);
        erc20::register(owner);

        // Mint coins to owner
        let mint_amount = 1000;
        erc20::mint(owner, signer::address_of(owner), mint_amount);

        // Burn some coins (owner burns from own account)
        let burn_amount = 300;
        erc20::burn(owner, burn_amount);

        // Check balance
        let balance = erc20::balance(signer::address_of(owner));
        assert!(balance == mint_amount - burn_amount, 5);
    }

    #[test(aptos_framework = @aptos_framework, owner = @token, user1 = @0x123)]
    #[expected_failure(abort_code = 0x10006, location = aptos_framework::coin)]
    public fun test_transfer_insufficient_balance(aptos_framework: &signer, owner: &signer, user1: &signer) {
        setup_test();
        
        // Setup
        account::create_account_for_test(signer::address_of(owner));
        account::create_account_for_test(signer::address_of(user1));

        erc20::initialize(owner);
        erc20::register(user1);

        // Try to transfer without having any coins (should fail)
        erc20::transfer(user1, signer::address_of(owner), 100);
    }
}