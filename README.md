RADME.md 
## Kaseddie Cairo Foundations

This repository documents my journey of rebuilding the on-chain components for Kaseddie AI from the ground up. Each contract is designed for correctness, security, and best practices, not complexity or speed. The goal is to establish a rock-solid foundation for the next, production-ready version of the Kaseddie AI platform.

A secure, production-ready foundation for Kaseddie AI's Web3 components, built on Cairo/Starknet with a React/TypeScript frontend. Developed in public with best practices.

## Table of Contents
Project Overview
Features
Prerequisites
Setup Instructions
Contract Details
Testing
Deploying to Sepolia

## Project Overview
This project is a hands-on exploration of Starknet smart contract development using Cairo. It includes:
A UserVault contract for managing user deposits, withdrawals, KYC verification, and strategy activation. 
Unit tests using Snforge to ensure contract functionality.
Deployment scripts using Starkli for the Starknet Sepolia testnet.

## Features
UserVault Contract:
. Deposit and withdraw funds (tracked as u256).
. KYC verification for users (owner-only).
. Strategy activation for verified users.
. Event emission for deposits, withdrawals, verifications, and strategy activations.
. Testing: Comprehensive Snforge tests covering deposits, withdrawals, KYC, and access control.
. Deployment: Deployed to Starknet Sepolia testnet using Starkli.

## Project Structure
- `cairo-contracts/`: Starknet smart contracts (e.g., `UserVault`) built with Cairo.
- `frontend/`: Vite + React + TypeScript app for user interaction with contracts.

## Backend Setup (cairo-contracts)
### Prerequisites
- Rust (latest stable)
- Scarb (v2.8.2 or later)
- Snforge (latest)
- Starknet Foundry
- Starkli (>=0.2.5) for Starknet interactions.
- Starknet Account: Funded with Sepolia ETH/STRK (via Starknet Faucet or StarkGate).

### Getting Started
1. Clone the repo:
   ```bash
   git clone https://github.com/Kaseddie-Labs-LTD-AI/kaseddie-cairo-foundations.git
   cd kaseddie-cairo-foundations

Install dependencies:
bash cd cairo-contracts
scarb install

Build contracts:
bash scarb build

Run tests:
bash snforge test


Frontend Setup
Prerequisites

Node.js (v18+)
npm (v9+)

Getting Started

Navigate to frontend:
bash cd frontend

Install dependencies:
bash npm install

Copy contract ABIs:
bash npm run copy-abis

Run dev server:
bash npm run dev

Build for production:
bash npm run build

Starkli:

curl https://get.starkli.sh | sh
echo 'export PATH="$HOME/.starkli/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

Key Frontend Files

src/utils/provider.ts: React context provider for app state.
src/hooks/useUserVault.ts: Hook for interacting with UserVault contract.
Components: KycForm.tsx, DepositForm.tsx, WithdrawForm.tsx, StrategyButton.tsx, BalanceDisplay.tsx.

Starknet Integration

Uses @starknet-react/core (v3.0.0) for frontend-contract interactions.
Placeholder: Set REACT_APP_VAULT_ADDRESS in frontend/.env for contract address post-deployment.

Contributing

Follow Cairo and React best practices.
Use Devdock for AI-assisted debugging and Web3 rewards (requires GitHub repo connection).

License
MIT
## Author

## Eddie Kasamba Wahitu 
## Founder,
## Kaseddie Labs LTD
