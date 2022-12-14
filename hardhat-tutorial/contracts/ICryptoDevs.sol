// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICryptoDevs {
    /*
    @dev Returns a token ID owned by 'owner' at a give 'index' of its token list
    Use along with {balanceOf} to enumerate all of ''owner'''s tokens.
    */
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);
    
    /*
    @dev Returns the number of tokens in 'owner' account.
    */
   function balanceOf(address owner) external view returns (uint256 balance);
    
}