// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IInterchainProposalExecutor {
    // An event emitted when the proposal caller is whitelisted
    event WhitelistedProposalCallerSet(string indexed sourceChain, address indexed sourceCaller, bool whitelisted);

    // An event emitted when the proposal sender is whitelisted
    event WhitelistedProposalSenderSet(string indexed sourceChain, address indexed sourceSender, bool whitelisted);

    event ProposalExecuted(bytes32 indexed payloadHash);

    // An error emitted when the proposal execution failed
    error ProposalExecuteFailed();

    // An error emitted when the proposal caller is not whitelisted
    error NotWhitelistedCaller();

    // An error emitted when the proposal sender is not whitelisted
    error NotWhitelistedSourceAddress();

    /**
     * @notice set the whitelisted status of a proposal sender which is the `InterchainProposalSender` contract address on the source chain
     * @param sourceChain The source chain
     * @param sourceSender The source interchain sender address
     * @param whitelisted The whitelisted status
     */
    function setWhitelistedProposalSender(string calldata sourceChain, address sourceSender, bool whitelisted) external;

    /**
     * @notice set the whitelisted status of a proposal caller which normally set to the `Timelock` contract address on the source chain
     * @param sourceChain The source chain
     * @param sourceCaller The source interchain caller address
     * @param whitelisted The whitelisted status
     */
    function setWhitelistedProposalCaller(string calldata sourceChain, address sourceCaller, bool whitelisted) external;
}
