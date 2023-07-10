// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library InterchainCalls {
    /**
     * @dev An interchain call to be executed at the destination chain
     * @param destinationChain destination chain
     * @param destinationContract destination contract
     * @param gas The amount of native token to transfer to the target contract as gas payment for the interchain call
     * @param calls An array of calls to be executed at the destination chain
     */
    struct InterchainCall {
        string destinationChain;
        string destinationContract;
        uint256 gas;
        Call[] calls;
    }

    /**
     * @dev A call to be executed at the destination chain
     * @param target The address of the contract to call
     * @param value The amount of native token to transfer to the target contract
     * @param callData The data to pass to the target contract
     */
    struct Call {
        address target;
        uint256 value;
        bytes callData;
    }
}
