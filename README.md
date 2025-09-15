RADME.md 
## Kaseddie Cairo Foundations

This repository documents my journey of rebuilding the on-chain components for Kaseddie AI from the ground up. Each contract is designed for correctness, security, and best practices, not complexity or speed. The goal is to establish a rock-solid foundation for the next, production-ready version of the Kaseddie AI platform.

## Table of Contents

- Overview  
- Goals  
- Repository Structure  
- Getting Started  
- Running Tests  
- Roadmap  
- Contributing  
- License  
- Author  

##  Overview

Inspired by feedback from the Starknet Foundation, this repo is built in public to:

- Deepen my understanding of Cairo and Starknet development  
- Showcase simple, well-tested contracts  
- Share learnings and contribute back to the ecosystem  

Every contract here is accompanied by a full test suite demonstrating both happy paths and revert scenarios.

##  Goals

- Establish a minimal, auditable codebase for core on-chain logic  
- Enforce best practices for security and maintainability  
- Cultivate reproducible test environments and CI-ready workflows  
- Serve as the foundation for Kaseddie AI’s production launch

##  Repository Structure
- cairo-contracts/ ├─ src/ │  └─ user_vault.cairo ├─ tests/ │  └─ uservault_test.cairo ├─ Scarb.toml ├─ README.md └─ .gitignore

##  Getting Started

**Prerequisites**  
- WSL2 or Linux/macOS  
- Cairo 1.x toolchain & Rust  
- Scarb (Cairo package manager)  
- Starknet Foundry (snforge) v0.49.0  

**Steps**  
1. Clone the repo  
   `git clone https://github.com/Kaseddie-Labs-LTD-AI/kaseddie-cairo-foundations.git`  
2. Install deps  
   `cd cairo-contracts && scarb install`  
3. Build contracts  
   `scarb build`

**Running Tests**

From the `cairo-contracts/` folder run:  
- snforge test
You should see all seven tests pass, covering both success and revert cases.

**Roadmap**

- [x] Basic deposit/withdraw vault contract  
- [x] Full integration tests (happy & revert paths)  
- [ ] Coverage reporting and CI integration  
- [ ] Additional utility contracts (multi-sig, timelock)  
- [ ] Production-grade auditing and optimizations

## Contributing

I’m building in public—your bug reports and PRs are welcome!  
1. Fork  
2. Branch (`git checkout -b feature/...`)  
3. Commit & push  
4. Open a PR  

## License

MIT

## Author

Eddie Kasamba Wahitu 
Founder,
 Kaseddie Labs LTD
