// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.6.7;

contract Math {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }
}
