// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RentalMarketplace
 * @dev Manages bookings and escrow for property rentals.
 */
contract RentalMarketplace is ReentrancyGuard, Ownable {
    enum Status { AVAILABLE, BOOKED, CHECKED_IN, COMPLETED }

    struct Property {
        address host;
        uint256 pricePerNight;
        uint256 securityDeposit;
        Status status;
        address currentGuest;
    }

    mapping(uint256 => Property) public properties;
    uint256 public nextPropertyId;

    event PropertyListed(uint256 indexed id, address indexed host, uint256 price);
    event StayBooked(uint256 indexed id, address indexed guest);
    event FundsReleased(uint256 indexed id, uint256 amount);

    constructor() Ownable(msg.sender) {}

    function listProperty(uint256 _price, uint256 _deposit) external {
        properties[nextPropertyId] = Property({
            host: msg.sender,
            pricePerNight: _price,
            securityDeposit: _deposit,
            status: Status.AVAILABLE,
            currentGuest: address(0)
        });
        emit PropertyListed(nextPropertyId++, msg.sender, _price);
    }

    function bookStay(uint256 _propertyId, uint256 _nights) external payable nonReentrant {
        Property storage p = properties[_propertyId];
        uint256 totalCost = (p.pricePerNight * _nights) + p.securityDeposit;
        
        require(p.status == Status.AVAILABLE, "Property not available");
        require(msg.value >= totalCost, "Insufficient payment");

        p.status = Status.BOOKED;
        p.currentGuest = msg.sender;
        emit StayBooked(_propertyId, msg.sender);
    }

    function checkIn(uint256 _propertyId) external {
        Property storage p = properties[_propertyId];
        require(msg.sender == p.currentGuest, "Only guest can check in");
        require(p.status == Status.BOOKED, "Invalid status");

        p.status = Status.CHECKED_IN;
        // Release partial payment to host immediately
        uint256 partialPayment = (address(this).balance - p.securityDeposit) / 2;
        payable(p.host).transfer(partialPayment);
    }

    function completeStay(uint256 _propertyId) external {
        Property storage p = properties[_propertyId];
        require(msg.sender == p.host, "Only host can complete stay");
        require(p.status == Status.CHECKED_IN, "Not checked in");

        p.status = Status.AVAILABLE;
        uint256 remainingPayment = address(this).balance - p.securityDeposit;
        
        payable(p.host).transfer(remainingPayment);
        payable(p.currentGuest).transfer(p.securityDeposit); // Return deposit
        
        p.currentGuest = address(0);
        emit FundsReleased(_propertyId, remainingPayment);
    }
}
