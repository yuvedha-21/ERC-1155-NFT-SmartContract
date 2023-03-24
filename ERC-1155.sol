// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import"@openzeppelin/contracts/utils/Strings.sol";

contract Token_1155 is ERC1155, Ownable, Pausable, ERC1155Supply {
    uint256 public publicPrice=0.02 ether;
    uint256 public allowListPrice=0.01 ether;
    uint256 public maxSupply=100;
    bool public PublicMintOpen=false;
    bool public allowListMintOpen=false;
    mapping(address=>bool)allowListpool;
    uint256 public maxPerWallet=3;
    mapping(address=>uint256) purchasesPerWallet;

    constructor()
        ERC1155("ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/")
    {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }
    
    //to switch between pause and unpause the NFT 

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    
//to transfer balance to contract owner - (only owner modifier)

function withdraw(address _addr)external onlyOwner{
        uint256 balance=address(this).balance;
        payable(_addr).transfer(balance);
    }

// Addresses in the allowList let them mint NFT for lower prince than the public minting

function setAllowList(address[] calldata addresses)external onlyOwner{
    for(uint256 i=0;i<addresses.length;i++){
        allowListpool[addresses[i]]=true;
    }
}

//this to change the state whether people can start minting or not, applicable for both public minting and allowList

function editMintWindow(bool _PublicMintOpen,bool _allowListMintOpen)external onlyOwner{
        PublicMintOpen=_PublicMintOpen;
        allowListMintOpen=_allowListMintOpen;
    }
    
    //return the number of NFT hold  by the given addresses

function checkBalance(address _addr)view public returns(uint256){
    return purchasesPerWallet[_addr];
}

//this function let people mint NFT for low price under certain contions

function allowListMint(uint256 id,uint256 amount) public payable{

        require(allowListMintOpen,"AllowList Mint is closed ");
        require(allowListpool[msg.sender],"You can only mint in public mint");
        require(id<2,"Sorry , you tried minting the NFT which doesn't exists");
        require(msg.value== allowListPrice*amount,"Not enough money sent");

   mint(id,amount);

}
function uri(uint256 _id)  public view virtual override returns(string memory){

    require(exists(_id),"URI: Not exist");
    return string(abi.encodePacked(super.uri(_id),Strings.toString(_id),".json"));

}

//funtion for people to mint at normal price

function PublicMint( uint256 id, uint256 amount)
        public payable
        
    {
        require(PublicMintOpen,"Public Mint is closed");
        require(id<2,"Sorry , you tried minting the NFT which doesn;t exists");
      require(msg.value== publicPrice*amount,"Not enough money sent");

        mint(id,amount);
    }

function mint(uint256 id,uint256 amount) internal {
    require(purchasesPerWallet[msg.sender]+amount<=maxPerWallet,"wallet limit reached");
        require(totalSupply(id)+amount<=maxSupply,"maximum supply limit Exceeded ");
        _mint(msg.sender, id, amount,  "");
        purchasesPerWallet[msg.sender]+=amount;
}    

function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
         _mintBatch(to, ids, amounts, data);
    }

function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
