// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DummyState {
    string public message;

    function setState(string calldata _message) external {
        message = _message;
    }

    function testRevert() external pure {
        revert('kaboom');
    }
}
