// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { InterchainCalls } from '../lib/InterchainCalls.sol';

interface IInterchainProposalSender {
    // An error emitted when the given gas is invalid
    error InvalidFee();

    /**
     * @dev Broadcast the proposal to be executed at multiple destination chains
     * @param calls An array of calls to be executed at the destination chain
     */
    function sendProposals(InterchainCalls.InterchainCall[] memory calls) external payable;

    /**
     * @dev Broadcast the proposal to be executed at single destination chain
     * @param destinationChain destination chain
     * @param destinationContract destination contract
     * @param calls An array of calls to be executed at the destination chain
     */
    function sendProposal(
        string calldata destinationChain,
        string calldata destinationContract,
        InterchainCalls.Call[] calldata calls
    ) external payable;
}
