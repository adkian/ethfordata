pragma solidity ^0.4.13;

contract Client {
   
  string public lat;
  string public long;
  string public timel;
  uint public ID;
  address owner;
  
  //the address below would be used by this contract to transact with the master contract
  address public master_address;
  
  event IncomingData(
		     address client,
		     string time,
		     string lat,
		     string long
		     );

  modifier onlyClient(){
    if(msg.sender != owner)
      revert();
    else
      _;
  }

  function Client(){
    owner = msg.sender;
    
    //this transaction should act as registration with the master contract
    ID =  master_address.getID();
  }

  
  
  function forawardLoc(string lat, string long, string time) external returns (bool){

    this.lat = lat;
    this.long = long;
    this.time = time;      
    
    IncomingData(msg.sender, time, lat, long);
    
    master_address.getData(ID, time, lat, long);
    return true;
  }    
}

