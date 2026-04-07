# Real Estate Rental Escrow (Airbnb-style)

A professional-grade implementation for decentralized property management. This repository removes the 15-20% platform fees associated with traditional rental sites. By using a smart contract as the intermediary, both the Host and the Guest are protected: the Host is guaranteed payment upon a successful stay, and the Guest's funds are held in escrow until check-in.

## Core Features
* **Booking State Machine:** Tracks the lifecycle of a stay from `Requested` to `Confirmed`, `CheckedIn`, and `Completed`.
* **Security Deposit Escrow:** Automatically holds a secondary deposit that is returned only after the Host confirms no damages occurred.
* **Flexible Cancellation:** Built-in logic to refund a percentage of the stay based on how far in advance the Guest cancels.
* **Flat Architecture:** Single-directory layout for the Property Registry, Booking Logic, and Dispute Escrow.



## Logic Flow
1. **List:** Host registers a property with a price per night and a security deposit amount.
2. **Book:** Guest selects dates and sends the total stay cost + security deposit to the contract.
3. **Check-in:** Upon arrival, the Guest triggers the check-in; 50% of the funds are released to the Host.
4. **Complete:** After the stay, the Host triggers completion; the remaining funds are released, and the security deposit is returned to the Guest.

## Setup
1. `npm install`
2. Deploy `RentalMarketplace.sol`.
