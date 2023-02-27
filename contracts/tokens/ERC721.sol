// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract MyERC721Token is ERC721, ERC721URIStorage {
    address public immutable OWNER;
    constructor(string memory _name, string memory _symbol) payable
        ERC721(_name, _symbol)
    {
        OWNER=msg.sender;
    }

    modifier onlyOwner(){
        require(OWNER==msg.sender,"Owner unauthorized");
        _;
    }

    function safeMint(address to,string memory uri, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

   
}
