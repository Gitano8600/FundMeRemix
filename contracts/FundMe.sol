// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    
    
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5e18;
    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;
    address public immutable i_owner;


    constructor() {
        i_owner = msg.sender;
    }


    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Minimum amount of 1 ETH required!");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }


    function withdraw() public {

        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex = funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }


    modifier onlyOwner() {
        if(msg.sender != i_owner) revert NotOwner();
        _;
    }


    receive() external payable {
        fund();
    }


    fallback() external payable {
        fund();
     }

}
