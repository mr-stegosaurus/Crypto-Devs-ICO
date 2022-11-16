//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    // price of one crypto dev token
    uint256 public constant tokenPrice = 0.001 ether;
    // each NFT would give the user 10 tokens
    // it needs to be represented as 10 * (10 ** 18) as ERC20 tokens are represented by the smallest denomination possible for the token
    // by default, ERC20 tokens have the smallest denomination of 10^(-18). This means, having a balance of (1) is actually equal to (10 ^ -18) tokens.
    // owning 1 full token is equivalent ot owning (10^18) tokens when you account for the decimal places
    // more information on this can be found in the Freshman track cryptocurrency tutorial
    uint256 public constant tokensPerNFT = 10 * 10**18;
    // the max total supply is 10000 for Crypto Dev Tokens
    uint256 public constant maxTotalSupply = 10000 * 10**18;
    // CryptoDevsNFT contract instance
    ICryptoDevs CryptoDevsNFT;
    // mapping to keep track of which tokenIds have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    /*
    @dev Mints 'amount' number of CryptoDevTokens
    Req: 
    -msg.value should be equal to or greater than the tokenPrice * amount
    */
    function mint(uint256 amount) public payable {
        // the value of ether that should be equal or greater than tokenPrice * amount;
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is incorrect")
        // total tokens + amount <= 10000, otherwise revert the transaction
        uint256 amountWithDecimals = amount * 10**18;
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Exceeds the max total supply available."
        );
        // call the internal function from OpenZeppelin's ERC20 contract
        _mint(msg.sender, amountWithDecimals);
    }

    /*
    @dev mints tokens based on the number of NFT's held by the sender
    Req:
    balnce of Crypto Dev NFT's owned by the sender should be greater than 0
    Tokens should have not been claimed for all the NFTs owned by the sender
    */
    function claim() public {
        address sender = msg.sender;
        // get the number of cryptodev NFT's held by a given sender address
        uint256 balance = CryptoDevsNFT.balanceOf(sender)
    }
}