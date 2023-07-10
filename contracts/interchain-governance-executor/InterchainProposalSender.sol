// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IAxelarGateway } from '../gmp-sdk/interfaces/IAxelarGateway.sol';
import { IAxelarGasService } from '../gmp-sdk/interfaces/IAxelarGasService.sol';
import { IInterchainProposalSender } from './interfaces/IInterchainProposalSender.sol';
import { InterchainCalls } from './lib/InterchainCalls.sol';

/**
 * @title InterchainProposalSender
 * @dev This contract is responsible for facilitating the execution of approved proposals across multiple chains.
 * It achieves this by working in conjunction with the AxelarGateway and AxelarGasService contracts.
 *
 * The contract allows for the sending of a single proposal to multiple destination chains. This is achieved
 * through the `sendProposals` function, which takes in arrays representing the destination chains,
 * destination contracts, fees, target contracts, amounts of tokens to send, function signatures, and encoded
 * function arguments.
 *
 * Each destination chain has a unique corresponding set of contracts to call, amounts of native tokens to send,
 * function signatures to call, and encoded function arguments. This information is provided in a 2D array where
 * the first dimension is the destination chain index, and the second dimension corresponds to the specific details
 * for each chain.
 *
 * In addition, the contract also allows for the execution of a single proposal at a single destination chain
 * through the `sendProposal` function. This is a more granular approach and works similarly to the
 * aforementioned function but for a single destination.
 *
 * The contract ensures the correctness of the provided proposal details and fees through a series of internal
 * functions that revert the transaction if any of the checks fail. This includes checking if the provided fees
 * are equal to the total value sent with the transaction, if the lengths of the provided arrays match, and if the
 * provided proposal arguments are valid.
 *
 * The contract works in conjunction with the AxelarGateway and AxelarGasService contracts. It uses the
 * AxelarGasService contract to pay for the gas fees of the interchain transactions and the AxelarGateway
 * contract to call the target contracts on the destination chains with the provided encoded function arguments.
 */
contract InterchainProposalSender is IInterchainProposalSender {
    IAxelarGateway public gateway;
    IAxelarGasService public gasService;

    constructor(address _gateway, address _gasService) {
        gateway = IAxelarGateway(_gateway);
        gasService = IAxelarGasService(_gasService);
    }

    /**
     * @dev Broadcast the proposal to be executed at multiple destination chains
     * @param interchainCalls An array of `InterchainCalls.InterchainCall` to be executed at the destination chains. Where each `InterchainCalls.InterchainCall` contains the following:
     * - destinationChain: destination chain
     * - destinationContract: destination contract
     * - gas: gas to be paid for the interchain transaction
     * - calls: An array of `InterchainCalls.Call` to be executed at the destination chain. Where each `InterchainCalls.Call` contains the following:
     *   - target: target contract
     *   - value: amount of tokens to send
     *   - callData: encoded function arguments
     * Note that the destination chain must be unique in the destinationChains array.
     */
    function sendProposals(InterchainCalls.InterchainCall[] calldata interchainCalls) external payable override {
        // revert if the sum of given fees are not equal to the msg.value
        revertIfInvalidFee(interchainCalls);

        for (uint256 i = 0; i < interchainCalls.length; ) {
            _sendProposal(interchainCalls[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Broadcast the proposal to be executed at single destination chain.
     * @param destinationChain destination chain
     * @param destinationContract destination contract
     * @param calls An array of calls to be executed at the destination chain. Where each call contains the following:
     * - target: target contract
     * - value: amount of tokens to send
     * - callData: encoded function arguments
     */
    function sendProposal(
        string memory destinationChain,
        string memory destinationContract,
        InterchainCalls.Call[] calldata calls
    ) external payable override {
        _sendProposal(InterchainCalls.InterchainCall(destinationChain, destinationContract, msg.value, calls));
    }

    function _sendProposal(InterchainCalls.InterchainCall memory interchainCall) internal {
        bytes memory payload = abi.encode(msg.sender, interchainCall.calls);

        if (interchainCall.gas > 0) {
            gasService.payNativeGasForContractCall{ value: interchainCall.gas }(
                address(this),
                interchainCall.destinationChain,
                interchainCall.destinationContract,
                payload,
                msg.sender
            );
        }

        gateway.callContract(interchainCall.destinationChain, interchainCall.destinationContract, payload);
    }

    function revertIfInvalidFee(InterchainCalls.InterchainCall[] calldata interchainCalls) private {
        uint256 totalGas = 0;
        for (uint256 i = 0; i < interchainCalls.length; ) {
            totalGas += interchainCalls[i].gas;
            unchecked {
                ++i;
            }
        }

        if (totalGas != msg.value) {
            revert InvalidFee();
        }
    }
}
