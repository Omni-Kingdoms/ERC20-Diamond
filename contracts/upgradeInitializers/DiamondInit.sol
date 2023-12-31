// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * \
 * Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
 * EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
 *
 * Implementation of a diamond.
 * /*****************************************************************************
 */

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IDiamondLoupe} from "../interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {IERC173} from "../interfaces/IERC173.sol";
import {IERC165} from "../interfaces/IERC165.sol";
import {IERC20} from "contracts/solidstate-solidity/token/ERC20/IERC20.sol";
import {ERC20MetadataStorage} from "contracts/solidstate-solidity/token/ERC20/metadata/ERC20Metadata.sol";
import {ERC20BaseStorage} from "contracts/solidstate-solidity/token/ERC20/base/ERC20BaseStorage.sol";
import {ERC20BaseInternal} from "contracts/solidstate-solidity/token/ERC20/base/ERC20BaseInternal.sol";

// It is exapected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

contract DiamondInit {
    using ERC20MetadataStorage for ERC20MetadataStorage.Layout;
    using ERC20BaseStorage for ERC20BaseStorage.Layout;

    // You can add parameters to this function in order to pass in
    // data to set your own state variables
    function init() external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;
        ds.supportedInterfaces[type(IERC20).interfaceId] = true;

        // add your own state variables
        // EIP-2535 specifies that the `diamondCut` function takes two optional
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface
        ERC20MetadataStorage.Layout storage l = ERC20MetadataStorage.layout();

        l.name = "OmniKingdoms Gold";
        l.symbol = "OMKG";
        l.decimals = 18;

        ERC20BaseStorage.Layout storage lb = ERC20BaseStorage.layout();

        lb.maxSupply = 10000000000000000000000000;
        lb.feeRecipient = 0x08d8E680A2d295Af8CbCD8B8e07f900275bc6B8D;
        lb.minter = msg.sender;
    }
}
