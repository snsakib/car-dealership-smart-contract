//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract CarDealership is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _carIds;

    address payable contractOwner;

    struct Car {
        uint256 id;
        address payable contractAddress;
        address payable owner;
        string brand;
        uint256 price;
        uint256 mileage;
        bool isListedForSale;
    }

    mapping(uint256 => Car) private _idToCar;

    event CarListingSuccess(
        uint256 indexed id,
        address contractAddress,
        address owner,
        string brand,
        uint256 price,
        uint256 mileage,
        bool isListedForSale
    );

    constructor() ERC721("CarDealership", "CARNFT") {
        contractOwner = payable(msg.sender);
    }

    function mintCar(
        string memory tokenURI,
        string memory brand,
        uint256 price,
        uint256 mileage
    ) public payable returns (uint256) {
        _carIds.increment();
        uint256 newCarId = _carIds.current();

        _safeMint(msg.sender, newCarId);
        _setTokenURI(newCarId, tokenURI);

        listCar(newCarId, brand, price, mileage);

        return newCarId;
    }

    function listCar(
        uint256 id,
        string memory brand,
        uint256 price,
        uint256 mileage
    ) private {
        require(price > 0, "Price must be greater than zero.");

        _idToCar[id] = Car(
            id,
            payable(address(this)),
            payable(msg.sender),
            brand,
            price,
            mileage,
            true
        );

        _transfer(msg.sender, address(this), id);

        emit CarListingSuccess(
            id,
            address(this),
            msg.sender,
            brand,
            price,
            mileage,
            true
        );
    }

    function getAllCars() public view returns (Car[] memory) {
        uint256 carCount = _carIds.current();
        Car[] memory items = new Car[](carCount);
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < carCount; i++) {
            Car storage currentItem = _idToCar[i + 1];
            items[currentIndex] = currentItem;
            currentIndex += 1;
        }

        return items;
    }

    function getMyCars() public view returns (Car[] memory) {
        uint256 totalCarCount = _carIds.current();
        uint256 myCarCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalCarCount; i++) {
            if (
                _idToCar[i + 1].contractAddress == msg.sender ||
                _idToCar[i + 1].owner == msg.sender
            ) {
                myCarCount += 1;
            }
        }

        Car[] memory items = new Car[](myCarCount);
        for (uint256 i = 0; i < totalCarCount; i++) {
            if (
                _idToCar[i + 1].contractAddress == msg.sender ||
                _idToCar[i + 1].owner == msg.sender
            ) {
              Car storage currentItem = _idToCar[i+1];
              items[currentIndex] = currentItem;
              currentIndex += 1;
            }
        }

        return items;
    }

    function buyCar(uint256 id) public payable {
      uint256 price = _idToCar[id].price;
      address payable seller = _idToCar[id].owner;

      require(msg.value == price, "Please submit the required price");

      _idToCar[id].isListedForSale = true;
      _idToCar[id].owner = payable(msg.sender);

      _transfer(address(this), msg.sender, id);
      approve(address(this), id);

      (bool success, ) = payable(seller).call{value: msg.value}("");
      require(success, "Transfer failed");
    }
}
