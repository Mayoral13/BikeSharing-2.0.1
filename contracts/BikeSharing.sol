pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./SafeMath.sol";
contract BikeShare is ERC20{
    using SafeMath for uint;

    // TO KEEP TRACK OF WHEN RENT STARTS
    uint private start;
    // TO KEEP TRACK OF WHEN RENT ENDS
    uint private end;
    // AMOUNT TO RENT A BIKE
    uint private amount = 5000;
    // REQUIRED AMOUNT TO PAY AS ESCROW
    uint private EscrowAmount = 15000;
    // THE RATE IN WHICH TOKENS ARE BOUGHT
    uint private buyRate = 40000000000;
    // VARIABLE TO COUNT HOW MANY TIMES ONE HAS RENTED A BIKE
    uint private rentCounter;
    // VARIABLE TO COUNT ACTIVE RENTERS
    uint private id;

    address private owner;
    address[]Renters;

    //MAPPING TO CHECK IF AN ADDRESS HAS RENTED A BIKE
    mapping(address => bool)isRented;
    //MAPPING TO CHECK HOW MANY TIMES AN ADDRESS HAS RENTED A BIKE
    mapping(address => uint)RentedTimes;
    //MAPPING TO STORE PAYMENTS FOR RENTING
    mapping(address => uint)Payments;

    //MAPPING THAT STORES THE ID OF THE RENT TO THE TOTAL DURATION OF THE RENT
    // EXAMPLE A USER RENTED A BIKE 3 TIMES FIRST TIME HE HAD THE BIKE FOR 67 SECONDS
    // SECOND TIME HE HAD IT FOR 1000 SECONDS THIRD TIME FOR 8888 SECONDS
    mapping(uint => mapping(address => uint))Record;
   
        constructor()
        ERC20("BSHARE","BS"){
        
        owner = msg.sender;
    }
        
    
    event tokensBought(address indexed _from,uint _value);
    event rentBike(address indexed _by,uint _start);
    event returnBike(address indexed _by,uint stop);

    //FUNCTION TO BUY TOKENS
    function BuyTokens()external payable returns(bool success){
        uint bought = msg.value.div(buyRate);
        uint VendorBalance = balanceOf(address(this)); 
        require(msg.value != 0,"You cannot send nothing");
        require(VendorBalance >= bought,"Insufficient Balance");
        _mint(msg.sender,bought);
        emit tokensBought(msg.sender,bought);
        return true;
    }


    // FUNCTION TO RENT A BIKE
    function Rent()public returns(bool success){
        uint user = balanceOf(msg.sender);
        require(isRented[msg.sender] == false ,"You have rented a bike already");
        require(user >= EscrowAmount,"Insufficient Balance");
        _burn(msg.sender,EscrowAmount);
        _mint(address(this),EscrowAmount);
        Payments[msg.sender] = Payments[msg.sender] + EscrowAmount;
        start = block.timestamp;
        rentCounter++;
        RentedTimes[msg.sender] = rentCounter;
        id++;
        isRented[msg.sender] = true;
        Renters.push(msg.sender);
        emit rentBike(msg.sender,block.timestamp);
        return true;
    }

    // FUNCTION TO RETURN RENTED BIKE
    function ReturnBike()public returns(bool success){
        require(isRented[msg.sender] == true ,"You must rent a bike");
      end = block.timestamp;
      uint duration = end - start;
      _mint(msg.sender,Payments[msg.sender]);
      _burn(address(this),Payments[msg.sender]);
      id--;
      isRented[msg.sender] = false;
      Record[rentCounter][msg.sender] = duration;
      Payments[msg.sender] = 0;
      Renters.pop();
      emit returnBike(msg.sender,block.timestamp);
      return true;
    }
    
    // FUNCTION TO CHECK IF USER HAS RENTED A BIKE
    function isBikeOwner()public view returns(bool){
        return isRented[msg.sender];
    }

    // FUNCTION TO CHECK USER BALANCE
    function BalanceChecker()public view returns(uint){
        return balanceOf(msg.sender);
    }

    //FUNCTION TO CHECK ACCOUNT TOKEN BALANCE
    function EscrowBalance()public view returns(uint){
        return balanceOf(address(this));
    }

    //FUNCTION TO RETURN CONTRACT OWNER
    function ReturnOwner()public view returns(address){
        return owner;
    }

    //FUNCTION TO RETURN AMOUNTTO BE PAID AS ESCROW
    function ReturnEscrowAmount()public view returns(uint){
        return EscrowAmount;
    }

    //FUNCTION TO RETURN BASE AMOUNT
    function ReturnAmount()public view returns(uint){
        return amount;
    }

    // FUNCTION TO RETURN ACTIVE RENTERS
    function ReturnRenters()public view returns(uint){
        return id;
    }

    //FUNCTION TO RETURN HOW MANY TIMES A USER HAS RENTED A BIKE 
    function ReturnTimesRented()public view returns(uint){
        return RentedTimes[msg.sender];
    }

    //FUNCTION TO RETURN THE RECORD OF THE RENT
    function ReturnRentRecord(uint value)public view returns(uint){
        return Record[value][msg.sender];
    }

}