// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Import libraries
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC20/ERC20.sol";

contract TokenizedFD is ERC721URIStorage, Ownable {
    
    ERC20 public depositToken; // deposit token to use
    uint256 public numFDToken; // incremental token ID

    // FD packages offered
    struct FDProduct {
        uint256 productID;
        string productName;
        uint256 interestRate; // basis points
        uint256 duration; // months
        uint256 minDepositAmt;
        uint256 maxDepositAmt;
        bool active;
    }

    mapping(uint256 => FDProduct) public fdProducts;

    // Tracking FD tokens
    struct FDToken {
        uint256 tokenID;
        uint256 productID;
        address customer;
        uint256 startTime;
        uint256 endTime;
        uint256 principal;
        bool redeemed;
    }

    mapping(uint256 => FDToken) public fdTokens;

    // List of customers
    struct Customer {
        uint256 customerID;
        address customerAddress;
        uint256[] purchases; // list of tokenID
    }

    mapping(address => Customer) public customers;
    mapping(address => bool) public existingCustomers;

    // Events
    event FDProductCreated(uint256 indexed productID, string productName, uint256 interestRate, uint256 duration, uint256 minDepositAmt, uint maxDepositAmt);
    event FDTokenMinted(uint256 indexed tokenID, uint256 indexed productID, address indexed customer, uint256 startTime, uint256 principal, bool redeemed);

    constructor(address _depositToken) ERC721("Tokenized FD", "tFD") {
        require(_depositToken != address(0), "Deposit token cannot be zero address");
        depositToken = ERC20(_depositToken); // linking depositToken to token intended to be used as deposit (e.g. USDC, XSGD, YangCoin)
    }

    // Admin functions
    uint256 public numFDProduct; // incremental product ID

    function createFDProduct(string memory _productName, uint256 _interestRate, uint256 _duration, uint256 _minDepositAmt,uint256 _maxDepositAmt) external onlyOwner {
        
        // Creation requirement
        require(_interestRate > 0, "Interest rate must be greater than 0");
        require(_duration > 0, "Duration must be greater than 0");
        require(_minDepositAmt > 0, "Min deposit amount must be greater than 0");

        // Creating product
        fdProducts[numFDProduct] = FDProduct({
            productID: numFDProduct,
            productName: _productName,
            interestRate: _interestRate,
            duration: _duration,
            minDepositAmt: _minDepositAmt,
            maxDepositAmt: _maxDepositAmt,
            active: true
        });

        emit FDProductCreated(numFDProduct, _productName, _interestRate, _duration, _minDepositAmt, _maxDepositAmt);
        numFDProduct ++;
    }

    function toggleFDProduct(uint256 _productID) external onlyOwner {
        // Activate and Deactivate
        fdProducts[_productID].active = !fdProducts[_productID].active;
    }

    function viewPool() public view onlyOwner returns (uint256) {
        // View number of coins deposited in this FD smart contract
        return depositToken.balanceOf(address(this));
    }

    // Customer functions
    uint256 numCustomer;
    function purchaseFDProduct(uint256 _productID, uint256 _principal) public {

        FDProduct memory product = fdProducts[_productID]; // get the product

        // FD requirement
        require(product.active, "Product is not active");
        require(_principal >= product.minDepositAmt, "Deposit amount is less than minimum deposit amount");
        require(_principal <= product.maxDepositAmt, "Deposit amount is more than maximum deposit amount");

        // Transfer principal amount from customer's wallet to the address of this FD smart contract
        require(depositToken.transferFrom(msg.sender, address(this), _principal));

        // Mint FD Token
        uint256 currentTime = block.timestamp;
        uint256 maturityTime = currentTime + product.duration; // we will pretend that 1 second = 1 month
        
        FDToken memory fdTokenMinted = FDToken({
            tokenID: numFDToken,
            productID: _productID,
            customer: msg.sender,
            startTime: currentTime,
            endTime: maturityTime,
            principal: _principal,
            redeemed: false
        });

        fdTokens[numFDToken] = fdTokenMinted;

        // Update customer and their purchases
        if (!existingCustomers[msg.sender]) {
            Customer storage newCustomer = customers[msg.sender];
            newCustomer.customerID = numCustomer;
            newCustomer.customerAddress = msg.sender;
            newCustomer.purchases.push(numFDToken);

            existingCustomers[msg.sender] = true;
            numCustomer ++;
        } else {
            customers[msg.sender].purchases.push(numFDToken);
        }

        emit FDTokenMinted(numFDToken, _productID, msg.sender, currentTime, _principal, false);
        numFDToken ++;
    }

    function viewMyPurchases() public view returns (uint256[] memory) {
        return customers[msg.sender].purchases; // View customer's purchases
    }

    function redeemFDToken(uint256 _fdTokenID) public {

        // Redeem requirement
        FDToken storage fdToken = fdTokens[_fdTokenID];
        require(fdToken.customer == msg.sender, "You are not the owner of this FDToken.");
        require(!fdToken.redeemed, "FDToken has already been redeemed.");

        uint256 currentTime = block.timestamp;

        // Matured
        if (currentTime >= fdToken.endTime) {
            uint256 interest = (fdToken.principal * fdProducts[fdToken.productID].interestRate) / 10000;
            uint256 amount = fdToken.principal + interest;

            depositToken.transfer(msg.sender, amount);
        
        // Early redemption
        } else {

            // proportional interest
            uint256 timeElapsed = currentTime - fdToken.startTime;
            uint256 duration = fdToken.endTime - fdToken.startTime;
            uint256 proportionalInterest = (fdToken.principal * fdProducts[fdToken.productID].interestRate * timeElapsed) / (duration * 10000);
            // 20% penalty
            uint256 amount = fdToken.principal + (proportionalInterest * 80 / 100); 

            depositToken.transfer(msg.sender, amount);
        }

        fdToken.redeemed = true;
    }


    
}
