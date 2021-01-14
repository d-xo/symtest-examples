// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.7.5;

import {ERC20} from "./ERC20.sol";

/*
   Synth implements a collateral backed synthetic asset.

   Anyone can mint new synth as long as they provide sufficient backing collateral.

   If the value of the backing value falls below `threshold` times the
   outstanding synth amount, then that position becomes eligible for liqudation.

   Anyone can liquidate an unsafe position by calling `bite`, where they can
   buy the backing collateral at a 3% discount.

   The price of synth is set by a trusted authority.
*/
contract Synth is ERC20 {
    // --- Auth ---

    address public owner;
    modifier auth() { require(msg.sender == owner, "unauthorized"); _; }

    // --- Data ---

    uint public price;               // price of 1 unit of collateral in synth                [wad]
    uint immutable public discount;  // discount multiplier used when selling collateral      [wad]
    uint immutable public threshold; // min ratio of collateral value to synth value per user [wad]

    ERC20 public collateral;                  // collateral token
    mapping (address => Vault) public vaults; // per user metadata

    struct Vault {
        uint256 locked; // collateral locked [wad]
        uint256 minted; // synths minted     [wad]
    }

    // --- Init ---

    constructor(address _collateral, uint _discount, uint _threshold) {
        owner = msg.sender;
        collateral = ERC20(_collateral);
        discount = _discount;
        threshold = _threshold;
    }

    // --- Collateral Management ---

    function lock(uint wad) external {
        Vault storage vault = vaults[msg.sender];

        vault.locked = add(vault.locked, wad);
        collateral.transferFrom(msg.sender, address(this), wad);
    }
    function free(uint wad) external {
        Vault storage vault = vaults[msg.sender];

        uint backing     = wmul(sub(vault.locked, wad), price);
        uint outstanding = wmul(vault.minted, threshold);
        require(backing > outstanding, "insufficient backing collateral");

        vault.locked = sub(vault.locked, wad);
        collateral.transfer(msg.sender, wad);
    }

    // --- Synth Management ---

    function mint(uint wad) external {
        Vault storage vault = vaults[msg.sender];

        uint backing     = wmul(vault.locked, price);
        uint outstanding = wmul(add(vault.minted, wad), threshold);
        require(backing > outstanding, "insufficient backing collateral");

        vault.minted = add(vault.minted, wad);
        _mint(msg.sender, wad);
    }
    function burn(uint wad) external {
        vaults[msg.sender].minted = sub(vaults[msg.sender].minted, wad);
        _burn(msg.sender, wad);
    }

    // --- Liquidation ---

    function bite(address usr) external {
        Vault storage vault = vaults[usr];

        uint backing     = wmul(vault.locked, price);
        uint outstanding = wmul(vault.minted, threshold);
        require(backing < outstanding, "usr is safe");

        uint cost = wmul(backing, discount);
        _burn(msg.sender, cost);

        collateral.transfer(msg.sender, vault.locked);
        vault.locked = 0;
        vault.minted = 0;
    }

    // --- Price Feed Management ---

    function poke(uint amt) external auth {
        price = amt;
    }

    // --- Internal ---

    function _mint(address usr, uint wad) internal {
        balanceOf[usr] = add(balanceOf[usr], wad);
        totalSupply    = add(totalSupply, wad);
        emit Transfer(address(0), msg.sender, wad);
    }

    function _burn(address usr, uint wad) internal {
        balanceOf[usr] = sub(balanceOf[usr], wad);
        totalSupply    = sub(totalSupply, wad);
        emit Transfer(msg.sender, address(0), wad);
    }
}
