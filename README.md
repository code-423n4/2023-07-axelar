# ✨ So you want to run an audit

This `README.md` contains a set of checklists for our audit collaboration.

Your audit will use two repos:

-   **an _audit_ repo** (this one), which is used for scoping your audit and for providing information to wardens
-   **a _findings_ repo**, where issues are submitted (shared with you after the audit)

Ultimately, when we launch the audit, this repo will be made public and will contain the smart contracts to be reviewed and all the information needed for audit participants. The findings repo will be made public after the audit report is published and your team has mitigated the identified issues.

Some of the checklists in this doc are for **C4 (🐺)** and some of them are for **you as the audit sponsor (⭐️)**.

---

# Repo setup

## ⭐️ Sponsor: Add code to this repo

-   [ ] Create a PR to this repo with the below changes:
-   [ ] Provide a self-contained repository with working commands that will build (at least) all in-scope contracts, and commands that will run tests producing gas reports for the relevant contracts.
-   [ ] Make sure your code is thoroughly commented using the [NatSpec format](https://docs.soliditylang.org/en/v0.5.10/natspec-format.html#natspec-format).
-   [ ] Please have final versions of contracts and documentation added/updated in this repo **no less than 24 hours prior to audit start time.**
-   [ ] Be prepared for a 🚨code freeze🚨 for the duration of the audit — important because it establishes a level playing field. We want to ensure everyone's looking at the same code, no matter when they look during the audit. (Note: this includes your own repo, since a PR can leak alpha to our wardens!)

---

## ⭐️ Sponsor: Edit this README

Under "SPONSORS ADD INFO HERE" heading below, include the following:

-   [ ] Modify the bottom of this `README.md` file to describe how your code is supposed to work with links to any relevent documentation and any other criteria/details that the C4 Wardens should keep in mind when reviewing. ([Here's a well-constructed example.](https://github.com/code-423n4/2022-08-foundation#readme))
    -   [ ] When linking, please provide all links as full absolute links versus relative links
    -   [ ] All information should be provided in markdown format (HTML does not render on Code4rena.com)
-   [ ] Under the "Scope" heading, provide the name of each contract and:
    -   [ ] source lines of code (excluding blank lines and comments) in each
    -   [ ] external contracts called in each
    -   [ ] libraries used in each
-   [ ] Describe any novel or unique curve logic or mathematical models implemented in the contracts
-   [ ] Does the token conform to the ERC-20 standard? In what specific ways does it differ?
-   [ ] Describe anything else that adds any special logic that makes your approach unique
-   [ ] Identify any areas of specific concern in reviewing the code
-   [ ] Review the Gas award pool amount. This can be adjusted up or down, based on your preference - just flag it for Code4rena staff so we can update the pool totals across all comms channels.
-   [ ] Optional / nice to have: pre-record a high-level overview of your protocol (not just specific smart contract functions). This saves wardens a lot of time wading through documentation.
-   [ ] See also: [this checklist in Notion](https://code4rena.notion.site/Key-info-for-Code4rena-sponsors-f60764c4c4574bbf8e7a6dbd72cc49b4#0cafa01e6201462e9f78677a39e09746)
-   [ ] Delete this checklist and all text above the line below when you're ready.

---

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

Automated findings output for the audit can be found [here](add link to report) within 24 hours of audit opening.

_Note for C4 wardens: Anything included in the automated findings output is considered a publicly known issue and is ineligible for awards._

[ ⭐️ SPONSORS ADD INFO HERE ]

# Overview

_Please provide some context about the code being audited, and identify any areas of specific concern in reviewing the code. (This is a good place to link to your docs, if you have them.)_

# Scope

_List all files in scope in the table below (along with hyperlinks) -- and feel free to add notes here to emphasize areas of focus._

_For line of code counts, we recommend using [cloc](https://github.com/AlDanial/cloc)._

| Contract                                                                                               | SLOC | Purpose                                                                                                                                                                         | Libraries used |
| ------------------------------------------------------------------------------------------------------ | ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- |
| [contracts/auth/MultisigBase.sol](contracts/auth/MultisigBase.sol)                                     | 148  | This contract implements a custom multisignature wallet where transactions must be confirmed by a threshold of signers. The signers and threshold may be updated every `epoch`. | N/A            |
| [contracts/interfaces/IMultisigBase.sol](contracts/interfaces/IMultisigBase.sol)                       | 56   | An interface defining the base operations for a multisignature contract.                                                                                                        | N/A            |
| [contracts/governance/AxelarServiceGovernance.sol](contracts/governance/AxelarServiceGovernance.sol)   | 108  | This contract is part of the Axelar Governance system, it inherits the Interchain Governance contract with added functionality to approve and execute multisig proposals.       | N/A            |
| [contracts/interfaces/IAxelarServiceGovernance.sol](contracts/interfaces/IAxelarServiceGovernance.sol) | 29   | This interface extends IInterchainGovernance and IMultisigBase for multisig proposal actions.                                                                                   | N/A            |
| [contracts/governance/InterchainGovernance.sol](contracts/governance/InterchainGovernance.sol)         | 148  | This contract handles cross-chain governance actions. It includes functionality to create, cancel, and execute governance proposals.                                            | N/A            |
| [contracts/interfaces/IInterchainGovernance.sol](contracts/interfaces/IInterchainGovernance.sol)       | 70   | This interface extends IAxelarExecutable for interchain governance mechanisms.                                                                                                  | N/A            |
| [contracts/governance/Multisig.sol](contracts/governance/Multisig.sol)                                 | 42   | An extension of MultisigBase that can call functions on any contract.                                                                                                           | N/A            |
| [contracts/interfaces/IMultisig.sol](contracts/interfaces/IMultisig.sol)                               | 24   | This interface extends IMultisigBase by adding an execute function for multisignature transactions.                                                                             | N/A            |
| [contracts/util/TimeLock.sol](contracts/util/TimeLock.sol)                                             | 110  | A contract that enables function execution after a certain time has passed. Implements the ITimeLock interface.                                                                 | N/A            |
| [contracts/interfaces/ITimeLock.sol](contracts/interfaces/ITimeLock.sol)                               | 26   | Interface for a TimeLock that enables function execution after a certain time has passed.                                                                                       | N/A            |
| [contracts/util/Caller.sol](contracts/util/Caller.sol)                                                 | 23   | A contract to call a target address with specified calldata and optionally send value.                                                                                          | N/A            |
| [contracts/interfaces/ICaller.sol](contracts/interfaces/ICaller.sol)                                   | 8    | Interface for Caller.sol.                                                                                                                                                       | N/A            |

## Out of scope

All contracts and interfaces not explicitly mentioned above.

# Additional Context

_Describe any novel or unique curve logic or mathematical models implemented in the contracts_

_Sponsor, please confirm/edit the information below._

## Scoping Details

```
- If you have a public code repo, please share it here:  https://github.com/axelarnetwork/interchain-token-service
- How many contracts are in scope?:   50
- Total SLoC for these contracts?:  2500
- How many external imports are there?: 0
- How many separate interfaces and struct definitions are there for the contracts within scope?:  30
- Does most of your code generally use composition or inheritance?:   Inheritance
- How many external calls?:   1
- What is the overall line coverage percentage provided by your tests?:  95
- Is there a need to understand a separate part of the codebase / get context in order to audit this part of the protocol?:
- Please describe required context:
- Does it use an oracle?:  No
- Does the token conform to the ERC20 standard?:  True
- Are there any novel or unique curve logic or mathematical models?: N/A
- Does it use a timelock function?:  True
- Is it an NFT?:
- Does it have an AMM?:
- Is it a fork of a popular project?:
- Does it use rollups?:
- Is it multi-chain?:  True
- Does it use a side-chain?: False
- Is this an upgrade of an existing system? False
- Describe any specific areas you would like addressed.: Verify correctness of different token deployment types, and cross-chain transfers. Try to break authentication, token bridging invariants, and governance timelock mechanism
```

# Tests

_Provide every step required to build the project from a fresh git clone, as well as steps to run the tests with a gas report._

_Note: Many wardens run Slither as a first pass for testing. Please document any known errors with no workaround._
