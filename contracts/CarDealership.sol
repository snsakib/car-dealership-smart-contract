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

        emit CarListingSuccess(id, address(this), msg.sender, brand, price, mileage, true);
    }
}
