use starknet::ContractAddress;

#[starknet::interface]
pub trait IUserVault<TContractState> {
    /// Returns the contract owner address.
    fn get_owner(self: @TContractState) -> ContractAddress;

    /// Returns the balance of a given user.
    fn get_balance(self: @TContractState, user: ContractAddress) -> u256;

    /// Checks if a user is KYC verified.
    fn is_kyc_verified(self: @TContractState, user: ContractAddress) -> bool;

    /// Checks if a user's strategy is active.
    fn is_strategy_active(self: @TContractState, user: ContractAddress) -> bool;

    /// Deposits funds into the caller's account.
    fn deposit(ref self: TContractState, amount: u256);

    /// Withdraws funds from the caller's account.
    fn withdraw(ref self: TContractState, amount: u256);

    /// Verifies a user (owner only).
    fn verify_user(ref self: TContractState, user: ContractAddress);

    /// Activates the caller's strategy.
    fn activate_strategy(ref self: TContractState);
}

#[starknet::contract]
pub mod UserVault {
    use starknet::{get_caller_address, ContractAddress};
    use starknet::storage::{Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess};
    use crate::errors::{ZERO_DEP, ZERO_WIT, NO_BAL, NOT_KYC, ONLY_OWNER, STRATEGY_ACTIVE};

    #[storage]
    struct Storage {
        owner: ContractAddress,
        balances: Map<ContractAddress, u256>,
        kyc_verified: Map<ContractAddress, bool>,
        strategy_active: Map<ContractAddress, bool>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Deposit: Deposit,
        Withdraw: Withdraw,
        UserVerified: UserVerified,
        StrategyActivated: StrategyActivated,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Deposit {
        #[key] pub from: ContractAddress,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Withdraw {
        #[key] pub from: ContractAddress,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct UserVerified {
        #[key] pub user: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    pub struct StrategyActivated {
        #[key] pub user: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
        self.owner.write(initial_owner);
    }

    #[abi(embed_v0)]
    impl UserVaultImpl of super::IUserVault<ContractState> {
        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }

        fn get_balance(self: @ContractState, user: ContractAddress) -> u256 {
            self.balances.entry(user).read()
        }

        fn is_kyc_verified(self: @ContractState, user: ContractAddress) -> bool {
            self.kyc_verified.entry(user).read()
        }

        fn is_strategy_active(self: @ContractState, user: ContractAddress) -> bool {
            self.strategy_active.entry(user).read()
        }

        fn deposit(ref self: ContractState, amount: u256) {
            assert(amount != 0, ZERO_DEP);
            let caller = get_caller_address();
            assert(self.kyc_verified.entry(caller).read(), NOT_KYC);

            let old_balance = self.balances.entry(caller).read();
            self.balances.entry(caller).write(old_balance + amount);

            self.emit(Event::Deposit(Deposit { from: caller, amount }));
        }

        fn withdraw(ref self: ContractState, amount: u256) {
            assert(amount != 0, ZERO_WIT);
            let caller = get_caller_address();
            assert(self.kyc_verified.entry(caller).read(), NOT_KYC);

            let old_balance = self.balances.entry(caller).read();
            assert(old_balance >= amount, NO_BAL);

            self.balances.entry(caller).write(old_balance - amount);

            self.emit(Event::Withdraw(Withdraw { from: caller, amount }));
        }

        fn verify_user(ref self: ContractState, user: ContractAddress) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), ONLY_OWNER);

            self.kyc_verified.entry(user).write(true);

            self.emit(Event::UserVerified(UserVerified { user }));
        }

        fn activate_strategy(ref self: ContractState) {
            let caller = get_caller_address();
            assert(self.kyc_verified.entry(caller).read(), NOT_KYC);
            assert(!self.strategy_active.entry(caller).read(), STRATEGY_ACTIVE);

            self.strategy_active.entry(caller).write(true);

            self.emit(Event::StrategyActivated(StrategyActivated { user: caller }));
        }
    }
}
