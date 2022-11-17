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
        uint256 balance = CryptoDevsNFT.balanceOf(sender);
        // if the balance is zero, revert the transaction
        require(balance > 0, "you don't own any crypto dev nft's");
        // amount keeps track of number of unclaimed tokenIds
        uint256 amount = 0;
        // loop over the balance and get the token ID owned by 'sender' at a given index of its token list.
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
            // if the tokenId has not bee claimed, increase the amount
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        // if all the token ids have been claimed, revert the transaction;
        require(amount > 0, "you already claimed all the tokens");
        // call the internal function from Openzeppelin's ERC20 contract
        // mint (amount * 10) tokens for each NFT
        _mint(msg.sender, amount * tokensPerNFT);
    }

    /*
    @dev withdraws all ETH and tokens sent to the contract
    req:
    wallet connected must be the owner's address
    */
    function withdraw() public onlyOwner() {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call(value: amount)("");
        require(sent, 'failed to send ether');
    }

    //function to receive ether. msg.data must be empty
    receive() external payable{}

    //fallback function is called when msg.data is not empty
    fallback() external payable {}
}