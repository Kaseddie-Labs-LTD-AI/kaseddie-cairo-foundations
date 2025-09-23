#[cfg(test)]
mod tests {
    use core::traits::TryInto;
    use starknet::ContractAddress;
    use snforge_std::{
        declare,
        DeclareResultTrait,
        cheatcodes::contract_class::ContractClassTrait,
        spy_events, EventSpyAssertionsTrait
    };
    use snforge_std::cheatcodes::execution_info::caller_address::{
        start_cheat_caller_address,
        stop_cheat_caller_address,
    };
    use kaseddie_cairo_foundations::user_vault::{IUserVaultDispatcher, IUserVaultDispatcherTrait};
    use kaseddie_cairo_foundations::user_vault::UserVault::{Event, Deposit, Withdraw, UserVerified, StrategyActivated};

    fn OWNER() -> ContractAddress { 'owner'.try_into().unwrap() }
    fn USER() -> ContractAddress { 'user'.try_into().unwrap() }
    fn OTHER_USER() -> ContractAddress { 'other_user'.try_into().unwrap() }

    fn deploy_contract() -> (ContractAddress, IUserVaultDispatcher) {
        let declare_result = declare("UserVault").unwrap();
        let class = declare_result.contract_class();
        let constructor_calldata = array![OWNER().into()];
        let (contract_address, _) = class.deploy(@constructor_calldata).unwrap();
        let dispatcher = IUserVaultDispatcher { contract_address };
        (contract_address, dispatcher)
    }

    #[test]
    fn test_owner_is_set() {
        let (_, contract) = deploy_contract();
        let owner = contract.get_owner();
        assert(owner == OWNER(), 'Owner not set');
    }

    #[test]
    fn test_deposit_and_withdraw() {
        let (addr, contract) = deploy_contract();
        let deposit_amount: u256 = 1000;
        let withdraw_amount: u256 = 400;

        let mut spy = spy_events();
        start_cheat_caller_address(addr, OWNER());
        contract.verify_user(USER());
        stop_cheat_caller_address(addr);
        assert(contract.is_kyc_verified(USER()), 'User not verified');
        spy.assert_emitted(@array![
            (addr, Event::UserVerified(UserVerified { user: USER() }))
        ]);

        start_cheat_caller_address(addr, USER());
        contract.deposit(deposit_amount);
        stop_cheat_caller_address(addr);
        assert(contract.get_balance(USER()) == deposit_amount, 'Bad balance dep');
        spy.assert_emitted(@array![
            (addr, Event::Deposit(Deposit { from: USER(), amount: deposit_amount }))
        ]);

        start_cheat_caller_address(addr, USER());
        contract.withdraw(withdraw_amount);
        stop_cheat_caller_address(addr);
        let expected_final_balance = deposit_amount - withdraw_amount;
        assert(contract.get_balance(USER()) == expected_final_balance, 'Bad balance wd');
        spy.assert_emitted(@array![
            (addr, Event::Withdraw(Withdraw { from: USER(), amount: withdraw_amount }))
        ]);
    }

    #[test]
    fn test_kyc_flow() {
        let (addr, contract) = deploy_contract();
        let mut spy = spy_events();

        assert(!contract.is_kyc_verified(USER()), 'User verified init');

        start_cheat_caller_address(addr, OWNER());
        contract.verify_user(USER());
        stop_cheat_caller_address(addr);

        assert(contract.is_kyc_verified(USER()), 'User not verified');
        spy.assert_emitted(@array![
            (addr, Event::UserVerified(UserVerified { user: USER() }))
        ]);
    }

    #[test]
    #[should_panic(expected: ('Only owner can verify',))]
    fn test_only_owner_can_verify() {
        let (addr, contract) = deploy_contract();

        start_cheat_caller_address(addr, USER());
        contract.verify_user(OTHER_USER());
        stop_cheat_caller_address(addr);
    }

    #[test]
    #[should_panic(expected: ('User not KYC verified',))]
    fn test_non_kyc_cannot_deposit() {
        let (addr, contract) = deploy_contract();

        start_cheat_caller_address(addr, USER());
        contract.deposit(1000);
        stop_cheat_caller_address(addr);
    }

    #[test]
    fn test_strategy_activation() {
        let (addr, contract) = deploy_contract();
        let mut spy = spy_events();

        start_cheat_caller_address(addr, OWNER());
        contract.verify_user(USER());
        stop_cheat_caller_address(addr);
        assert(contract.is_kyc_verified(USER()), 'User not verified');

        assert(!contract.is_strategy_active(USER()), 'Strategy active init');

        start_cheat_caller_address(addr, USER());
        contract.activate_strategy();
        stop_cheat_caller_address(addr);

        assert(contract.is_strategy_active(USER()), 'Strategy not active');
        spy.assert_emitted(@array![
            (addr, Event::UserVerified(UserVerified { user: USER() })),
            (addr, Event::StrategyActivated(StrategyActivated { user: USER() }))
        ]);
    }

    #[test]
    #[should_panic(expected: ('Strategy already active',))]
    fn test_cannot_activate_strategy_twice() {
        let (addr, contract) = deploy_contract();

        start_cheat_caller_address(addr, OWNER());
        contract.verify_user(USER());
        stop_cheat_caller_address(addr);

        start_cheat_caller_address(addr, USER());
        contract.activate_strategy();
        contract.activate_strategy();
        stop_cheat_caller_address(addr);
    }

    #[test]
    fn test_other_user_isolated_balance() {
        let (addr, contract) = deploy_contract();
        let mut spy = spy_events();

        start_cheat_caller_address(addr, OWNER());
        contract.verify_user(USER());
        contract.verify_user(OTHER_USER());
        stop_cheat_caller_address(addr);

        start_cheat_caller_address(addr, USER());
        contract.deposit(100);
        stop_cheat_caller_address(addr);

        start_cheat_caller_address(addr, OTHER_USER());
        contract.deposit(70);
        stop_cheat_caller_address(addr);

        let b1: u256 = contract.get_balance(USER());
        let b2: u256 = contract.get_balance(OTHER_USER());
        assert(b1 == 100, 'iso1');
        assert(b2 == 70, 'iso2');
        spy.assert_emitted(@array![
            (addr, Event::UserVerified(UserVerified { user: USER() })),
            (addr, Event::UserVerified(UserVerified { user: OTHER_USER() })),
            (addr, Event::Deposit(Deposit { from: USER(), amount: 100 })),
            (addr, Event::Deposit(Deposit { from: OTHER_USER(), amount: 70 }))
        ]);
    }

    #[test]
    #[should_panic(expected: ('Deposit amount must be > 0',))]
    fn test_deposit_must_be_greater_than_zero_reverts() {
        let (addr, contract) = deploy_contract();

        start_cheat_caller_address(addr, OWNER());
        contract.verify_user(USER());
        stop_cheat_caller_address(addr);

        start_cheat_caller_address(addr, USER());
        contract.deposit(0);
        stop_cheat_caller_address(addr);
    }

    #[test]
    #[should_panic(expected: ('Insufficient balance',))]
    fn test_withdraw_insufficient_balance_reverts() {
        let (addr, contract) = deploy_contract();

        start_cheat_caller_address(addr, OWNER());
        contract.verify_user(USER());
        stop_cheat_caller_address(addr);

        start_cheat_caller_address(addr, USER());
        contract.withdraw(50);
        stop_cheat_caller_address(addr);
    }

    #[test]
    #[should_panic(expected: ('Withdraw amount must be > 0',))]
    fn test_withdraw_must_be_greater_than_zero_reverts() {
        let (addr, contract) = deploy_contract();

        start_cheat_caller_address(addr, OWNER());
        contract.verify_user(USER());
        stop_cheat_caller_address(addr);

        start_cheat_caller_address(addr, USER());
        contract.deposit(100);
        stop_cheat_caller_address(addr);

        start_cheat_caller_address(addr, USER());
        contract.withdraw(0);
        stop_cheat_caller_address(addr);
    }
}