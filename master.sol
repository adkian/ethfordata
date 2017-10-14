pragma solidity ^0.4.13;

/* MASTER TODO */

contract ClientInterface {
  
  struct Datapoint{
    uint client_id;
    int timestamp;
    int lat;
    int long;
  }

  uint numDatapoint;
  mapping (uint => Datapoint) datapoints;  
  
  function getData(uint ID, uint time, int lat, int long) external returns (bool){
    uint dp = numDatapoint++;
    datapoints[dp] = Datapoint[ID, time, lat, long];
  }    
}


contract Master is ClientInterface{

  function getBalance() constant returns (uint){
    return this.balance;
  }
  
  /* struct to hold funders data */
  struct Funder{
    address add;
    uint ID;
    uint amount;
    uint tier;    
  }

  uint numFunders;
  mapping (uint => Funder) funders;
 

  /* funder struct getter functions */
  function getFunderID(address add) constant returns (uint){
    for(int x=0;x<numFunders;x++){
      if(Funders[x].add == add)
	return x;
    }
    return -1;
  }  
  function getFunderAmount(uint ID) constant returns (uint){
    return Funders[ID].amount;
  }
  Function getFunderTier(uint ID) constant returns (uint){
    return Funders[ID].tier;
  }

  
  
  modifier onlyOwner(){
    if(msg.sender != owner)
      revert();	
    else
      _;
  }

  /***assign values based on Vlad's results** */
  /* return a requesting funder's current tier; */
  /* tier 1 (upper) cutoff: t1cutoff */
  /* tier 2 (upper) cutoff: t2cutoff */
  /* tier 3 (upper) cutoff: t3cutoff */
  function getTier(uint amount) returns (uint){
    uint t1cutoff;
    uint t2cutoff;
    uint t3cutoff;

    uint tier;

    if(amount<t3cutoff){
      tier = 0;
    }else if(amount>=t3cutoff && amount<t2cutoff){
      tier = 3;
    }else if(amount>=t2cutoff && amount<t1cutoff){
      tier = 2;
    }else if(amount>=t1){
      tier = 1;
    }

    return tier;
  }
  
  /* Fund the contract. Should also act as a funder registration function */
  function fund() payable returns (bool){


    int id = getFunderID(msg.sender);

    //if the funder is not in the system, add them
    if(id<0){
      address funderAddress = msg.sender;
      uint funderID = numFunders++;
      uint funderAmount = msg.value;
      uint funderTier = getTier(funderAmount);

      //add all this info into a new struct;   
      funders[funderID] = Funder(funderAddress, funderID, funderAmount, funderTier);
    }
    else{
      funders[id].amount+=msg.value;      
    }
        
    return true;      
  }


  /* TODO */
  /* pay the clients based on granularity tiers */
  function Pay() returns (bool){
    
  }

  
  
}


