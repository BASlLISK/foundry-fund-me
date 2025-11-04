# FundMe – Foundry Project

A simple crowdfunding-style smart contract that accepts ETH if it meets a USD-denominated minimum using a Chainlink price feed. Includes helper scripts for deployment and interaction, mocks for local testing, and a full test suite.

---

## Table of contents

- [FundMe – Foundry Project](#fundme--foundry-project)
  - [Table of contents](#table-of-contents)
  - [Overview](#overview)
  - [Contracts](#contracts)
  - [Project layout](#project-layout)
  - [Requirements](#requirements)
  - [Environment variables](#environment-variables)
  - [Running locally (Anvil)](#running-locally-anvil)
  - [Deploy](#deploy)
    - [Sepolia](#sepolia)
    - [Mainnet](#mainnet)
  - [Interact](#interact)
    - [Fund with 0.1 ETH](#fund-with-01-eth)
    - [Withdraw (owner only)](#withdraw-owner-only)
  - [Testing](#testing)
  - [Notes \& gotchas](#notes--gotchas)
  - [Security](#security)
  - [License](#license)

---

## Overview

* **FundMe** accepts ETH only if `msg.value` converted to USD (via a Chainlink Aggregator) is ≥ **$5**.
* **HelperConfig** selects a price feed per network:

  * **Mainnet (chainid 1):** fixed feed address
  * **Sepolia (11155111):** fixed feed address
  * **Local/Anvil (other):** auto-deploys a **MockV3Aggregator** (8 decimals, initial price 2000e8)
* **Scripts**:

  * `DeployFundMe.s.sol` – deploys `FundMe` with the network’s price feed
  * `Interactions.s.sol` – fund and withdraw helpers using the most recent deployment
* **Tests** cover funding, enforcing minimum, access control, and withdrawals.

Minimum: `MINIMUM_USD = 5e18` (18-decimals “USD” units).

---

## Contracts

* **src/FundMe.sol**

  * Uses `PriceConverter` to compute `msg.value` in USD
  * `fund()` reverts below the minimum
  * `withdraw()` & `cheaperWithdraw()` restricted to owner
  * `fallback()` and `receive()` both call `fund()`
* **src/PriceConverter.sol**

  * `getPrice()` reads latest ETH/USD
  * `getConversionRate(ethAmount, priceFeed)` returns USD value with 18 decimals
* **script/HelperConfig.s.sol**

  * Returns a `NetworkConfig` with `priceFeed` per chain
  * On Anvil, deploys `MockV3Aggregator`
* **test/mocks/MockV3Aggregator.sol**

  * Minimal Chainlink-compatible mock (version = 4)

---

## Project layout

```
├─ script/
│  ├─ DeployFundMe.s.sol
│  ├─ HelperConfig.s.sol
│  └─ Interactions.s.sol
├─ src/
│  ├─ FundMe.sol
│  └─ PriceConverter.sol
└─ test/
   ├─ FundMeTest.t.sol
   ├─ InteractionsTest.t.sol
   └─ mocks/MockV3Aggregator.sol
```

---

## Requirements

* [Foundry](https://book.getfoundry.sh/) (forge + anvil + cast)
* Node/via Foundry remappings for:

  * `forge-std`
  * Chainlink contracts (`@chainlink/contracts`)
  * `foundry-devops` (for `DevOpsTools`)
* RPC endpoints for networks you deploy to
* A funded private key for live/test networks

Install examples:

```bash
forge --version
forge install foundry-rs/forge-std
forge install smartcontractkit/chainlink-brownie-contracts
forge install Cyfrin/foundry-devops
```

> Ensure `remappings.txt` maps `@chainlink/contracts` and `forge-std` correctly.

---

## Environment variables

Create a `.env` (not committed):

```
PRIVATE_KEY=0x...
SEPOLIA_RPC_URL=https://...
MAINNET_RPC_URL=https://...
```

---

## Running locally (Anvil)

Start a local chain:

```bash
anvil
```

Deploy:

```bash
forge script script/DeployFundMe.s.sol:DeployFundMe \
  --rpc-url http://127.0.0.1:8545 \
  --private-key $PRIVATE_KEY \
  --broadcast
```

---

## Deploy

### Sepolia

```bash
forge script script/DeployFundMe.s.sol:DeployFundMe \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast -vv
```

### Mainnet

```bash
forge script script/DeployFundMe.s.sol:DeployFundMe \
  --rpc-url $MAINNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast -vv
```

> Add `--verify --etherscan-api-key $ETHERSCAN_API_KEY` for verification.

---

## Interact

Uses `DevOpsTools.get_most_recent_deployment("FundMe", chainid)`.

### Fund with 0.1 ETH

```bash
forge script script/Interactions.s.sol:FundFundMe \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast -vv
```

### Withdraw (owner only)

```bash
forge script script/Interactions.s.sol:WithdrawFundMe \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast -vv
```

---

## Testing

Run all tests:

```bash
forge test -vvv
```

Optional:

```bash
forge snapshot
forge coverage
```

**Tests include:**

* Minimum funding enforcement
* Owner set correctly
* Price feed version check
* Funding updates mapping & funder array
* Owner-only withdraw
* Withdraw and cheaperWithdraw correctness

---

## Notes & gotchas

* **Minimum USD logic:** `PriceConverter` returns USD with 18 decimals.
* **Feeds:** Hardcoded addresses — verify before deployment.
* **Local testing:** Mock price feed auto-deployed by `HelperConfig`.
* **Ownership:** `i_owner` = deployer.
* **Reentrancy:** Uses call pattern, resets state first.

---

## Security

This is for **educational/demo** purposes.

* No pausing/guardians/emergency withdraws
* No rate limits per funder
* No events emitted
* No reentrancy guard (relies on order of operations)
* Always audit before real use

---

## License

MIT — see SPDX headers in source files!
