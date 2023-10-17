// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20Internal} from "../IERC20Internal.sol";
import {ERC20BaseStorage} from "./ERC20BaseStorage.sol";

/**
 * @title Base ERC20 implementation, excluding optional extensions
 */
abstract contract ERC20BaseInternal is IERC20Internal {
    /**
     * @notice query the total minted token supply
     * @return token supply
     */
    function _totalSupply() internal view virtual returns (uint256) {
        return ERC20BaseStorage.layout().totalSupply;
    }

    // function _maxSupply() internal view virtual returns(uint256) {
    //     return ERC20BaseStorage.layout().maxSupply;
    // }

    // function _feeRecipientAddress() internal view virtual returns(address){
    //     return ERC20BaseStorage.layout().feeRecipient;
    // }

    /**
     * @notice query the token balance of given account
     * @param account address to query
     * @return token balance
     */
    function _balanceOf(address account) internal view virtual returns (uint256) {
        return ERC20BaseStorage.layout().balances[account];
    }

    /**
     * @notice enable spender to spend tokens on behalf of holder
     * @param holder address on whose behalf tokens may be spent
     * @param spender recipient of allowance
     * @param amount quantity of tokens approved for spending
     */
    function _approve(address holder, address spender, uint256 amount) internal virtual {
        require(holder != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ERC20BaseStorage.layout().allowances[holder][spender] = amount;

        emit Approval(holder, spender, amount);
    }

    function _isAllowedToMint() internal virtual returns (bool) {
        ERC20BaseStorage.Layout storage l = ERC20BaseStorage.layout();
        require(msg.sender == l.minter, "ERC20: Not allowed to mint");
        return true;
    }

    /**
     * @notice mint tokens for given account
     * @param account recipient of minted tokens
     * @param amount quantity of tokens minted
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        ERC20BaseStorage.Layout storage l = ERC20BaseStorage.layout();
        l.totalSupply += amount;
        l.balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    /**
     * @notice burn tokens held by given account
     * @param account holder of burned tokens
     * @param amount quantity of tokens burned
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        ERC20BaseStorage.Layout storage l = ERC20BaseStorage.layout();
        uint256 balance = l.balances[account];
        require(balance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            l.balances[account] = balance - amount;
        }
        l.totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @notice transfer tokens from holder to recipient
     * @param holder owner of tokens to be transferred
     * @param recipient beneficiary of transfer
     * @param amount quantity of tokens transferred
     */
    function _transfer(address holder, address recipient, uint256 amount) internal virtual {
        require(holder != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(holder, recipient, amount);

        ERC20BaseStorage.Layout storage l = ERC20BaseStorage.layout();
        uint256 holderBalance = l.balances[holder];
        address feeRecipient = l.feeRecipient;
        require(holderBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 feeAmount = (amount * 1) / 100; // Calculate 1% of the amount as the fee
        uint256 transferAmount = amount - feeAmount; // Calculate the amount to transfer

        unchecked {
            l.balances[holder] = holderBalance - amount;
            l.balances[recipient] += transferAmount; // Transfer the remaining amount
            l.balances[feeRecipient] += feeAmount; // Send the fee to the predefined address
        }

        emit Transfer(holder, recipient, transferAmount);
        emit Transfer(holder, feeRecipient, feeAmount); // Emit an event for the fee transfer
    }

    /**
     * @notice ERC20 hook, called before all transfers including mint and burn
     * @dev function should be overridden and new implementation must call super
     * @param from sender of tokens
     * @param to receiver of tokens
     * @param amount quantity of tokens transferred
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
