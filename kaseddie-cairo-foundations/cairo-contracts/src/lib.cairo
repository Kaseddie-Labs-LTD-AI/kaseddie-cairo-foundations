#[starknet::contract]
mod UserVault {
    use starknet::{ContractAddress, get_caller_address};

    // --- Storage ---
    // We will keep track of user balances.
    #[storage]
    struct Storage {
        balances: LegacyMap<ContractAddress, u256>,
    }

    // --- Events ---
    // Events help us track what happens on-chain.
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Deposited: Deposited,
        Withdrawn: Withdrawn,
    }

    #[derive(Drop, starknet::Event)]
    struct Deposited {
        #[key]
        user: ContractAddress,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Withdrawn {
        #[key]
        user: ContractAddress,
        amount: u256,
    }

    // --- External Functions ---
    // These are the functions users can call.

    /// Allows a user to deposit funds into their vault.
    /// Note: In a real ERC20 scenario, this would follow a transferFrom pattern.
    /// For this simple version, we are just crediting their balance.
    #[external(v0)]
    fn deposit(ref self: ContractState, amount: u256) {
        let caller = get_caller_address();
        assert(amount > 0, 'Deposit amount must be greater than zero');
        
        let current_balance = self.balances.read(caller);
        self.balances.write(caller, current_balance + amount);
        
        self.emit(Deposited { user: caller, amount: amount });
    }

    /// Allows a user to withdraw funds from their vault.
    #[external(v0)]
    fn withdraw(ref self: ContractState, amount: u256) {
        let caller = get_caller_address();
        assert(amount > 0, 'Withdrawal amount must be greater than zero');

        let current_balance = self.balances.read(caller);
        assert(current_balance >= amount, 'Insufficient balance');
        
        self.balances.write(caller, current_balance - amount);
        
        self.emit(Withdrawn { user: caller, amount: amount });
    }

    /// A "view" function that lets anyone check a user's balance.
    #[external(v0)]
    fn get_balance(self: @ContractState, user: ContractAddress) -> u256 {
        self.balances.read(user)
    }
}