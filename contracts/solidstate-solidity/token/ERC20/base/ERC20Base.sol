// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "../IERC20.sol";
import {ERC20BaseInternal} from "./ERC20BaseInternal.sol";
import {ERC20BaseStorage} from "./ERC20BaseStorage.sol";
import {LibDiamond} from "../../../../libraries/LibDiamond.sol";

/**
 * @title Base ERC20 implementation, excluding optional extensions
 */
abstract contract ERC20Base is IERC20, ERC20BaseInternal {
    /**
     * @inheritdoc IERC20
     */
    function totalSupply() public view virtual override returns (uint256) {
        return ERC20BaseStorage.layout().totalSupply;
    }

    function maxSupply() public view virtual returns (uint256) {
        return ERC20BaseStorage.layout().maxSupply;
    }

    function feeRecipientAddress() public view virtual returns (address) {
        return ERC20BaseStorage.layout().feeRecipient;
    }

    function minterRole() public view virtual returns (address) {
        return ERC20BaseStorage.layout().minter;
    }

    /**
     * @inheritdoc IERC20
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balanceOf(account);
    }

    function updateMaxSupply(uint256 amount) public {
        LibDiamond.enforceIsContractOwner();
        ERC20BaseStorage.layout().maxSupply = amount;
    }

    function updateFeeRecipient(address recipient) public {
        LibDiamond.enforceIsContractOwner();
        ERC20BaseStorage.layout().feeRecipient = recipient;
    }

    function updateMinter(address minter) public {
        LibDiamond.enforceIsContractOwner();
        ERC20BaseStorage.layout().minter = minter;
    }

    function mint(address account, uint256 amount) public {
        _isAllowedToMint();
        _mint(account, amount);
    }

    /**
     * @inheritdoc IERC20
     */
    function allowance(address holder, address spender) public view virtual override returns (uint256) {
        return ERC20BaseStorage.layout().allowances[holder][spender];
    }

    /**
     * @inheritdoc IERC20
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @inheritdoc IERC20
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @inheritdoc IERC20
     */
    function transferFrom(address holder, address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 currentAllowance = ERC20BaseStorage.layout().allowances[holder][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(holder, msg.sender, currentAllowance - amount);
        }
        _transfer(holder, recipient, amount);
        return true;
    }
}
