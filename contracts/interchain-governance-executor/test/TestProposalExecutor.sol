// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { AxelarExecutable } from '../../gmp-sdk/executable/AxelarExecutable.sol';
import { IAxelarExecutable } from '../../gmp-sdk/interfaces/IAxelarExecutable.sol';
import { InterchainProposalExecutor } from '../InterchainProposalExecutor.sol';
import { InterchainCalls } from '../lib/InterchainCalls.sol';

/**
 * @title InterchainProposalExecutor
 * @dev This contract provides a simple implementation of the `InterchainProposalExecutor` abstract contract.
 * It offers specific logic for handling proposal execution success and failures as well as emitting events
 * after proposal execution.
 */
contract TestProposalExecutor is InterchainProposalExecutor {
    event BeforeProposalExecuted(string sourceChain, string sourceAddress, bytes payload);

    event TargetExecuted(address target, uint256 value, bytes callData);

    constructor(address _gateway, address _owner) InterchainProposalExecutor(_gateway, _owner) {}

    function _beforeProposalExecuted(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal override {
        emit BeforeProposalExecuted(sourceChain, sourceAddress, payload);
    }

    function forceExecute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external onlyOwner {
        _execute(sourceChain, sourceAddress, payload);
    }

    function _onTargetExecutionFailed(InterchainCalls.Call memory, bytes memory result) internal pure override {
        // You can add your own logic here to handle the failure of the target contract execution. The code below is just an example.
        if (result.length > 0) {
            // The failure data is a revert reason string.
            assembly {
                revert(add(32, result), mload(result))
            }
        } else {
            // There is no failure data, just revert with no reason.
            revert ProposalExecuteFailed();
        }
    }

    function _onTargetExecuted(InterchainCalls.Call memory call, bytes memory) internal override {
        emit TargetExecuted(call.target, call.value, call.callData);
    }
}
