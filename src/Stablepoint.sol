// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Stablepoint is ERC20, Ownable, ERC20Permit {
    mapping(address => bool) public minters;

    constructor(address initialOwner)
        ERC20("Stablepoint", "STBPT")
        Ownable(initialOwner)
        ERC20Permit("Stablepoint")
    {
        // Transfer the ownership from the deployer to the initial owner
        transferOwnership(initialOwner);

        // Initially, set the initial owner as a minter
        minters[initialOwner] = true;
    }

    modifier onlyMinter() {
        require(minters[msg.sender], "Caller is not a minter");
        _;
    }

    function mint(address to, uint256 amount) public onlyMinter {
        _mint(to, amount);
    }

    function addMinter(address _minter) public onlyOwner {
        require(_minter != address(0), "Minter is the zero address");
        minters[_minter] = true;
    }

    function removeMinter(address _minter) public onlyOwner {
        minters[_minter] = false;
    }
}
