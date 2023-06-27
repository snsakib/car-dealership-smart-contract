//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract CarDealership is ERC721URIStorage {

  address payable contractOwner;

  struct Car {
    uint256 id;
    address payable owner;
    address payable seller;
    string brand;
    uint256 price;
    uint256 mileage;
    bool isListedForSale;
  }

  mapping(uint256 => Car) private idToCar;

  constructor() ERC721("CarDealership", "CARNFT") {
    contractOwner = payable(msg.sender);
  }
}