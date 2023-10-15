// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library ERC20BaseStorage {
    struct Layout {
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        uint256 totalSupply;
        uint256 maxSupply;
        address feeRecipient;
        address minter; // The Omni Kingdom game diamond which is allowed to mint
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('solidstate.contracts.storage.ERC20Base');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    function setMaxSupply(Layout storage l, uint256 amount) internal {
        l.maxSupply = amount;
    }

    function setFeeRecipient(Layout storage l, address recipient) internal {
        l.feeRecipient = recipient;
    }

    function setMinter(Layout storage l, address minter) internal {
        l.minter = minter;
    }
}
