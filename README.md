# Axelar Network audit details

-   Total Prize Pool: $80,000 USDC
    -   HM awards: $54,662 USDC
    -   Analysis awards: $3,312 USDC
    -   QA awards: $1,655 USDC
    -   Bot Race awards: $4,966 USDC
    -   Gas awards: $1,655 USDC
    -   Judge awards: $8,000 USDC
    -   Lookout awards: $5,250 USDC
    -   Scout awards: $500 USDC
-   Join [C4 Discord](https://discord.gg/code4rena) to register
-   Submit findings [using the C4 form](https://code4rena.com/contests/2023-07-axelar/submit)
-   [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
-   Starts July 07, 2023 20:00 UTC
-   Ends July 17, 2023 20:00 UTC

## Automated Findings / Publicly Known Issues

Automated findings output for the audit will be found [here](add link to report) within 24 hours of audit opening.

_Note for C4 wardens: Anything included in the automated findings output is considered a publicly known issue and is ineligible for awards._

# Overview

Axelar is a decentralized interoperability network connecting all blockchains, assets and apps through a universal set of protocols and APIs.
It is built on top off the Cosmos SDK. Users/Applications can use Axelar network to send tokens between any Cosmos and EVM chains. They can also send arbitrary messages between chains.

Axelar network's decentralized validators confirm events emitted on EVM chains (such as message send),
and sign off on commands submitted (by automated services) to the gateway smart contracts (such as minting token, and approving message on the destination).

Axelar powered apps implement the [AxelarExecutable](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/executable/AxelarExecutable.sol) contract which exposes an `execute` method that checks if the Axelar Gateway contract recorded an approval for that message. The relayer (can be anyone due to being permissionless) triggers the `execute` method automatically once the message has been confirmed by the Axelar network.

The scope of this audit covers the following features:

-   Interchain governance mechanism that allows Axelar DAO to manage upgrades for the axelar gateway and service contracts. And similarly for other DAOs to execute governance proposals interchain.
-   Interchain token service that allows permissionless bridging of tokens cross-chain
-   Helper utilities for deploying upgradable contracts with deterministic addresses.

Please see design [docs](https://github.com/code-423n4/2023-07-axelar/blob/main/DESIGN.md) for specific implementation details.

## Build

```bash
npm ci

npm run build

npm run test

REPORT_GAS=true npm run test  # report gas estimates

npm run coverage  # open ./coverage/index.html for unit test coverage
```

# Scope

Below is a list of all contracts and interfaces within scope for this audit.

NOTE: There is a SLOC discrepancy between the total SLOC of AxelarGateway.sol and the scope because this contract has already undergone audits in the past. Only code that has been modified, specifically the `upgrade`, `setup`, `transferGovernance`, `transferMintLimiter`, `setTokenMintLimits` functions and the `onlyGovernance` and `onlyMintLimiter` modifier definitions are within the scope of this audit.
| Contract | SLOC | Purpose | Libraries used |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [IInterchainGovernance.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/cgp/interfaces/IInterchainGovernance.sol) | 26 | This interface extends IAxelarExecutable to receive interchain governance proposals. | N/A |
| [InterchainGovernance.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/cgp/governance/InterchainGovernance.sol) | 96 | This contract handles cross-chain governance actions. It includes functionality to create, cancel, and execute governance proposals. | N/A |
| [IAxelarServiceGovernance.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/cgp/interfaces/IAxelarServiceGovernance.sol) | 14 | This interface extends IInterchainGovernance and IMultisigBase for multisig proposal actions. | N/A |
| [AxelarServiceGovernance.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/cgp/governance/AxelarServiceGovernance.sol) | 62 | This contract is part of the Axelar Governance system, it inherits the Interchain Governance contract with added functionality to approve and execute multisig proposals. | N/A |
| [IMultisigBase.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/cgp/interfaces/IMultisigBase.sol) | 17 | An interface defining the base operations for a multisignature contract. | N/A |
| [MultisigBase.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/cgp/auth/MultisigBase.sol) | 82 | This contract implements a custom multisignature wallet where transactions must be confirmed by a threshold of signers. The signers and threshold can be updated. | N/A |
| [IMultisig.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/cgp/interfaces/IMultisig.sol) | 10 | This interface extends IMultisigBase by adding an execute function for multisignature transactions. | N/A |
| [Multisig.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/cgp/governance/Multisig.sol) | 15 | An extension of MultisigBase that can call functions on any contract. | N/A |
| [ITimeLock.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/interfaces/ITimeLock.sol) | 8 | Interface for a TimeLock that enables function execution after a certain time has passed. | N/A |
| [TimeLock.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/util/TimeLock.sol) | 45 | A contract that enables function execution after a certain time has passed. Implements the ITimeLock interface. | N/A |
| [ICaller.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/cgp/interfaces/ICaller.sol) | 5 | Interface for external contract caller.sol. | N/A |
| [Caller.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/cgp/util/Caller.sol) | 15 | A contract to call a target address with specified calldata and optionally send value. | N/A |
| [AxelarGateway.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/cgp/AxelarGateway.sol) | 70 | Updated implementation of AxelarGateway with governance and mint limiter integration. NOTE: only the `upgrade`, `setup`, `transferGovernance`/`transferMintLimiter`, and `onlyGovernance`/`onlyMintLimiter` functions are within scope. | N/A |
| [InterchainProposalSender.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/interchain-governance-executor/InterchainProposalSender.sol) | 54 | This contract is responsible for facilitating the execution of approved proposals across multiple chains. It achieves this by working in conjunction with the AxelarGateway and AxelarGasService contracts. This is meant to be used by on-chain DAOs to enable interchain governance of their cross-chain apps, e.g. Uniswap. | [InterchainCalls](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/interchain-governance-executor/lib/InterchainCalls.sol) |
| [IInterchainProposalSender.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/interchain-governance-executor/interfaces/IInterchainProposalSender.sol) | 11 | Interface for InterchainProposalSender. | N/A |
| [InterchainProposalExecutor.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/interchain-governance-executor/InterchainProposalExecutor.sol) | 84 | This contract is intended to be the destination contract for `InterchainProposalSender` contract. The proposal will be received and executed from this contract on the destination chain. | [StringToAddress](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/util/AddressString.sol) [InterchainCalls](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/interchain-governance-executor/lib/InterchainCalls.sol) |
| [IInterchainProposalExecutor.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/interchain-governance-executor/interfaces/IInterchainProposalExecutor.sol) | 19 | Interface for InterchainProposalExecutor. | N/A |
| [InterchainCalls.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/interchain-governance-executor/lib/InterchainCalls.sol) | 14 | This library provides struct definitions for interchain calls. | N/A |
| [ConstAddressDeployer.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/deploy/ConstAddressDeployer.sol) | 48 | This contract is responsible for deploying and initializing new contracts using CREATE2 which ensures that the deployed address is deterministic and depends on the sender address, salt, and contract bytecode. | N/A |
| [Create3Deployer.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/deploy/Create3Deployer.sol) | 26 | This contract is responsible for deploying and initializing new contracts using the CREATE3 technique which ensures that only the sender address and salt influence the deployed address, not the contract bytecode. | [Create3.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/util/Create3.sol) |
| [Create3.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/deploy/Create3.sol) | 32 | This file contains the `CreateDeployer` contract and the `Create3` library to help with the implementation of `Create3Deployer`. | [ContractAddress.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/util/ContractAddress.sol) |
| [BaseProxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/upgradable/BaseProxy.sol) | 31 | This abstract contract implements a basic proxy that stores an implementation address. Fallback function calls are delegated to the implementation. | N/A |
| [Proxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/upgradable/Proxy.sol) | 23 | A proxy contract that delegates calls to a designated implementation contract, useful for upgradable contracts. | N/A |
| [IProxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/interfaces/IProxy.sol) | 10 | Interface for the Proxy contract. | N/A |
| [Upgradable.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/upgradable/Upgradable.sol) | 39 | This contract provides an interface for upgradable smart contracts and includes the functionality to perform upgrades. | N/A |
| [IUpgradable.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/interfaces/IUpgradable.sol) | 17 | Interface for the Upgradable contract. | N/A |
| [InitProxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/upgradable/InitProxy.sol) | 33 | A proxy contract that can be initialized to use a specified implementation and owner. Useful in conjuction with `ConstAddressDeployer` based on create2, so the init args don't need to be on the constructor. | N/A |
| [IInitProxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/interfaces/IInitProxy.sol) | 9 | Interface for the InitProxy contract. | N/A |
| [FinalProxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/upgradable/FinalProxy.sol) | 39 | The FinalProxy contract is a proxy that can be upgraded to a final non-upgradable implementation that uses less gas than regular proxy calls. | N/A |
| [IFinalProxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/interfaces/IFinalProxy.sol) | 6 | Interface for the FinalProxy contract. | N/A |
| [FixedProxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/upgradable/FixedProxy.sol) | 25 | The FixedProxy is a type of Proxy contract with a fixed implementation that cannot be upgraded, and uses less gas. | N/A |
| [InterchainToken.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interchain-token/InterchainToken.sol) | 50 | An example implementation of the IInterchainToken. It extends the ERC-20 standard by providing convenience methods such as `interchainTransfer`. | N/A |
| [IInterchainToken.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/IInterchainToken.sol) | 17 | Interface for InterchainToken. | N/A |
| [InterchainTokenService.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interchain-token-service/InterchainTokenService.sol) | 533
 | This contract is responsible for facilitating interchain token transfers. It provides several features such as easy deployment of interchain tokens, express transfers, and token flow limits. | [StringToBytes32](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/util/Bytes32ToString.sol) [Bytes32ToString](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/util/Bytes32ToString.sol) [AddressBytesUtils](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/libraries/AddressBytesUtils.sol) |
| [AddressBytesUtils.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/libraries/AddressBytesUtils.sol) | 17 | This library provides utility functions to convert between `address` and `bytes`. | N/A |
| [IInterchainTokenService.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/IInterchainTokenService.sol) | 151 | Interface for InterchainTokenService. | N/A |
| [InterchainTokenServiceProxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/proxies/InterchainTokenServiceProxy.sol) | 13 | Proxy contract for interchain token service contracts. | N/A |
| [RemoteAddressValidatorProxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/proxies/RemoteAddressValidatorProxy.sol) | 13 | Proxy contract for the RemoteAddressValidator contract. | N/A |
| [StandardizedTokenProxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/proxies/StandardizedTokenProxy.sol) | 15 | Proxy contract for StandardizedToken contracts. | N/A |
| [IStandardizedTokenProxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/IStandardizedTokenProxy.sol) | 4 | Interface for StandardizedTokenProxy. | N/A |
| [TokenManagerProxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/proxies/TokenManagerProxy.sol) | 48 | This contract is a proxy for token manager contracts. | N/A |
| [ITokenManagerProxy.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/ITokenManagerProxy.sol) | 8 | Interface for TokenManagerProxy. | N/A |
| [RemoteAddressValidator.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/remote-address-validator/RemoteAddressValidator.sol) | 80 | Manages and validates remote addresses, keeps track of the address of the interchain token service on remote chains. For EVM chains, the address of the token service would be the same everywhere, but this doesn't hold on non-EVM chains that'll be supported in the future. | [AddressToString](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/gmp-sdk/util/AddressToString.sol) |
| [IRemoteAddressValidator.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/IRemoteAddressValidator.sol) | 17 | Interface for RemoteAddressValidator. | N/A |
| [StandardizedToken.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/token-implementations/StandardizedToken.sol) | 48 | This contract implements a standardized token which extends InterchainToken functionality. | [AddressBytesUtils](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/libraries/AddressBytesUtils.sol) |
| [StandardizedTokenLockUnlock.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/token-implementations/StandardizedTokenLockUnlock.sol) | 7 | This contract extends StandardizedToken to use lock/unlock for interchain transfers, giving ERC-20 approval to the token manager to do so. | [AddressBytesUtils](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/libraries/AddressBytesUtils.sol) |
| [StandardizedTokenMintBurn.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/token-implementations/StandardizedTokenMintBurn.sol) | 7 | This contract extends StandardizedToken to use mint/burn mechanism. | [AddressBytesUtils](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/libraries/AddressBytesUtils.sol) |
| [IStandardizedToken.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/IStandardizedToken.sol) | 8 | Interface for StandardizedToken. | N/A |
| [TokenManager.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/token-manager/TokenManager.sol) | 105 | This contract is responsible for handling tokens before initiating an interchain token transfer, or after receiving one. | [AddressBytesUtils](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/libraries/AddressBytesUtils.sol) |
| [TokenManagerAddressStorage.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/token-manager/implementations/TokenManagerAddressStorage.sol) | 18 | This contract extends the TokenManager contract and provides additional functionality to store and retrieve the token address using a predetermined storage slot. | [AddressBytesUtils](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/libraries/AddressBytesUtils.sol) |
| [TokenManagerLockUnlock.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/token-manager/implementations/TokenManagerLockUnlock.sol) | 26 | This contract is an implementation of TokenManager that locks and unlocks a specific token on behalf of the interchain token service. | [AddressBytesUtils](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/libraries/AddressBytesUtils.sol) |
| [TokenManagerMintBurn.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/token-manager/implementations/TokenManagerMintBurn.sol) | 25 | This contract is an implementation of TokenManager that mints and burns a specific token on behalf of the interchain token service. | [AddressBytesUtils](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/libraries/AddressBytesUtils.sol) |
| [TokenManagerLiquidityPool.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/token-manager/implementations/TokenManagerLiquidityPool.sol) | 42 | This contract is a an implementation of TokenManager that stores all tokens in a separate liquity pool rather than within itself. | [AddressBytesUtils](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/libraries/AddressBytesUtils.sol) |
| [ITokenManager.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/ITokenManager.sol) | 35 | Interface for TokenManager. | N/A |
| [ITokenManagerType.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/ITokenManagerType.sol) | 8 | Interface for different Token Manager types. | N/A |
| [Distributable.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/utils/Distributable.sol) | 23 | A contract module which provides a basic access control mechanism, where there is an account (a distributor) that can be granted exclusive access to specific functions. | N/A |
| [IDistributable.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/IDistributable.sol) | 7 | Interface for Distributable. | N/A |
| [ExpressCallHandler.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/utils/ExpressCallHandler.sol) | 172 | Integrates the interchain token service with the GMP express service by providing methods to handle express calls for token transfers and token transfers with contract calls between chains. | N/A |
| [IExpressCallHandler.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/IExpressCallHandler.sol) | 54 | Interface for ExpressCallHandler. | N/A |
| [FlowLimit.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/utils/FlowLimit.sol) | 72 | Implements flow limit logic for interchain token transfers. The deployer/owner of the token can optionally set a flow limit which limits the net out flow - in flow volume for interchain transfers of a token. This acts as a security measure to minimize damage of exploits. | N/A |
| [IFlowLimit.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/IFlowLimit.sol) | 8 | Interface for FlowLimit. | N/A |
| [Implementation.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/utils/Implementation.sol) | 13 | This contract serves as a base for other contracts and enforces a proxy-first access restriction. | N/A |
| [IImplementation.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/IImplementation.sol) | 4 | Interface for Implementation. | N/A |
| [Multicall.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/utils/Multicall.sol) | 15 | This contract is a multi-functional smart contract which allows for multiple contract calls in a single transaction. See [this](https://github.com/code-423n4/2023-07-axelar/tree/main/test/its/tokenServiceFullFlow.js) for example usage. | N/A |
| [IMulticall.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/IMulticall.sol) | 4 | Interface for Multicall. | N/A |
| [Operatable.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/utils/Operatable.sol) | 23 | A contract module which provides a basic access control mechanism, where there is an account (an operator) that can be granted exclusive access to specific functions, such as setting flow limits. For the interchain token service itself, this is the axelar service governance contract. | N/A |
| [IOperatable.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/IOperatable.sol) | 7 | Interface for Operatable. | N/A |
| [Pausable.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/utils/Pausable.sol) | 20 | This contract provides a mechanism to halt the execution of specific functions on the interchain token service if a paused by the governance operator. | N/A |
| [IPausable.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/IPausable.sol) | 6 | Interface for Pausable. | N/A |
| [StandardizedTokenDeployer.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/utils/StandardizedTokenDeployer.sol) | 39 | This contract is used to deploy new instances of the StandardizedTokenProxy contract. | N/A |
| [IStandardizedTokenDeployer.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/IStandardizedTokenDeployer.sol) | 17 | Interface for StandardizedTokenDeployer. | N/A |
| [TokenManagerDeployer.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/utils/TokenManagerDeployer.sol) | 21 | This contract is used to deploy new instances of the TokenManagerProxy contract. | N/A |
| [ITokenManagerDeployer.sol](https://github.com/code-423n4/2023-07-axelar/tree/main/contracts/its/interfaces/ITokenManagerDeployer.sol) | 12 | Interface for TokenManagerDeployer. | N/A |

## Out of scope

All contracts and interfaces not explicitly mentioned above.

# Additional Context

Network resources: https://docs.axelar.dev/resources

Deployed contracts: https://docs.axelar.dev/resources/mainnet

General Message Passing Usage: https://docs.axelar.dev/dev/gmp

Example cross-chain token swap app: https://app.squidrouter.com

## Scoping Details

```
- If you have a public code repo, please share it here:  https://github.com/axelarnetwork/axelar-cgp-solidity https://github.com/axelarnetwork/axelar-gmp-sdk-solidity https://github.com/axelarnetwork/interchain-governance-executor https://github.com/axelarnetwork/interchain-token-service
- How many contracts are in scope?:   44
- Total SLoC for these contracts?:  3940
- How many external imports are there?: 1
- How many separate interfaces and struct definitions are there for the contracts within scope?:  29
- Does most of your code generally use composition or inheritance?:   Inheritance
- How many external calls?:   0
- What is the overall line coverage percentage provided by your tests?:  95
- Is there a need to understand a separate part of the codebase / get context in order to audit this part of the protocol?: False
- Please describe required context: N/A
- Does it use an oracle?:  No
- Does the token conform to the ERC20 standard?:  True
- Are there any novel or unique curve logic or mathematical models?: N/A
- Does it use a timelock function?:  True
- Is it an NFT?: False
- Does it have an AMM?: False
- Is it a fork of a popular project?: False
- Does it use rollups?: False
- Is it multi-chain?:  True
- Does it use a side-chain?: False
- Is this an upgrade of an existing system? False
- Describe any specific areas you would like addressed.: Verify correctness of different token deployment types, and cross-chain transfers. Try to break authentication, token bridging invariants, and governance timelock mechanism
```
